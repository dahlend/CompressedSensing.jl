include("SupportFunctions.jl")


function updateS(Y,A::Array{Float64,2},lambda,S::Array{Float64,2};maxIter=10000,threshold=1e-5)

    H=A'*A
    AtY=A'*Y

    R=deepcopy(S)

    Sp=S
    L=0
    try
        L=eigmax(H)
    catch
        return (S,0,false)
        error("Error in eigenvalue calculation")
    end

    At=A'
    t=1
    tp=t

    i=1

    converged=false
    while i<maxIter
        tp=t
        t=(1+(1+4*tp^2)^0.5)/2

        w=(tp-1)/t

        R=(1+w)*S-w*Sp
        Sp=S
        try
            #S=plusOp(soft(R-(H*R-AtY)/L,lambda/L))
            S=max(R-(H*R-AtY)/L-lambda/L,0)
        catch
            error("Error in S Iteration calculation")
        end
        if sum(abs(Sp-S))<(threshold*sum(S))
            converged=true
            break
        end

        i+=1
    end
    return (S,i,converged)
end




function updateA(Y,S::Array{Float64,2},A::Array{Float64,2};maxIter=10000,threshold=1e-5)

    Ap=A
    B=zeros(size(A))

    H=S*S'
    L=eigmax(H)
    YSt= Y*S'

    t=1
    tp=t

    i=1
    converged=false
    while i<maxIter

        tp=t
        t=(1+(1+4*tp^2)^0.5)/2

        B = (1+(tp-1)/(t)) * A - (tp-1)/(t) * Ap
        Ap=A
        A = max(B-(B*H-YSt)/L,0)

        if sum(abs(Ap-A))<(threshold*sum(A))
            converged=true
            break
        end
        i+=1
    end
    return (A,i,converged)
end


#this definition was taken from thier matlab code with some modifications
function updateLambda!(A::Array{Float64,2},S::Array{Float64,2},Y,iteration,maxIter, phaseRatio,lambda)
    refinement_beginning = floor(phaseRatio * maxIter)

    if refinement_beginning > iteration


        sigma_residue = 1.4826 * median(abs((Y - A*S)[:].-median((Y - A*S)[:])))
        #linear decrease to tau_MAD*sigma_residue when reaching the refinement steps
        lambda = maximum([sigma_residue, lambda - 1/(refinement_beginning - iteration) * (lambda - sigma_residue)])

    else #during refinement, do not modify lambda
        lambda = lambda
    end

    return lambda
end



function nGMCA(Y::Array{Float64},r;verbose=false,maxIter=5000,threshold=1e-6,phaseRatio=0.30,kickstart=true,submaxiter=200)

    #Randomly build one of the two output matricies
    S=rand(size(Y,2),r)'

    #Fit the first as an approximation of the other
    A=Y/S

    #Estimate an L0
    l=maximum(abs(A'*(A*S-Y)))

    if verbose && kickstart
        print("\nKickstarting BSS...")
    end

    if kickstart
        #Kick Start this show!
        A=plusOp(Y/S)
        S=plusOp(A\Y)
        S=updateS(Y,A,0,S;maxIter=submaxiter)[1]
        (A,S)=m_reinitializeS(A,S, Y, verbose)
        A=updateA(Y,S,A;maxIter=submaxiter)[1]
        if verbose
          print("\nKickstart complete.")
        end
    end

    if verbose
        print("\nL0=",""*string(l,"\nStart Full BSS:\n"))
    end

    #Run the algorithm
    j=1
    for j=1:maxIter
        Ap=A
        Sp=S

        #normalize columns of A
        for i=1:size(A,2)
            A[:,i]= A[:,i]./(sum(A.^2.,1).^.5)[i]
        end

        (A,S)=m_reinitializeS(A,S, Y, verbose)
        (S,S_iter,S_converge)=updateS(Y,A,l,S;maxIter=submaxiter)
        (A,S)=m_reinitializeS(A,S, Y, verbose)
        (A,A_iter,A_converge)=updateA(Y,S,A;maxIter=submaxiter)
        l=updateLambda!(A,S,Y,j,submaxiter,phaseRatio,l)

        if verbose && mod(j,max(div(maxIter,100),1))==0
            print("\r"*string("GI(S) ",round(GI(S),3)," GI(A) ",
            round(GI(A),3),"\t Iterations Total:",j,"  S:",S_iter," A: ",A_iter,
            "\tL:",round(l,5),"\t Dist to Y: ",round(sum((A*S-Y).^2.).^.5),5))
        end

        if mod(j,10)==0 && sum(abs(A-Ap))/length(A)<threshold && sum(abs(S-Sp))/length(S)<threshold
            break
        end
    end
    if verbose
        print("\nDone.\n")
        if j>=maxIter
            print("\nFailed to converge!\n")
        end
    end
    return {A,S}
end




# reinitialization when a source was set to 0
function m_reinitializeS(A,S, Y, verbose)
    #straightforward reinitialization of a line of S and a column of A
    #by picking one column in the residue
    attempt=0
    while sum(sum(S, 2) .== 0) > 0 && attempt<10
        if verbose
            print("\r"*string("Reinitilizing blank rows/columns: ",sum(sum(S,2).==0)))
        end
        indices = [sum(S, 2) .== 0][:]

        (A[:, indices], S[indices, :]) = m_fastExtractNMF(Y - A * S, sum(indices))
        attempt+=1
    end
    (A,S)
end


function m_fastExtractNMF(residual, r)
    if r > 0
        (m, n) = size(residual);
        A = zeros(m, r);
        S = zeros(r, n);
        for i = 1 : r
            residual = max(residual,0)
            if sum(residual[:]) != 0
                #compute square norm of residual to select maximum one
                res2 = sum(residual.^2,1);
                j = findin(res2,maximum(res2));
                if !isempty(j)
                    j = j[1];
                    if res2[j] > 0
                        #normalize maximum residual
                        A[:, i] = residual[:, j] / res2[j].^.5;
                        #compute scalar product with the rest of the residual and keep only
                        #positive coefficients
                        S[i, :] = A[:, i]' * residual;
                        S[i, :] = max(S[i, :], zeros(size(S[i,:])) );
                        #compute new residual
                        residual = residual - A[:, i] * S[i, :];
                    end
                end
            end
        end
    else
        A = [];
        S = [];
    end

    return (A,S)
end
