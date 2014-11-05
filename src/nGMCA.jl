function plusOp(x)
    map(y->maximum([y,0]),x)
end

    
function soft(x,l)
    sign(x).*plusOp(abs(x)-l)
end



function updateS(Y,A,lambda,S;maxIter=10000,threshold=1e-5)
    
    H=A'*A
    AtY=A'*Y
    
    R=deepcopy(S)

    Sp=S
    L=0
    try
        L=eigmax(H)
    catch
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
            S=plusOp(soft(R-(H*R-AtY)/L,lambda/L))
        catch
            error("Error in S Iteration calculation")
        end
        if sum(abs(Sp-S))<(threshold*sum(S))
            converged=true
            break
        end
        
        i+=1
    end
    return {S,i,converged}
end




function updateA(Y,S,A;maxIter=10000,threshold=1e-5)

    Ap=A
    
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
        A = plusOp(B-(B*H-YSt)/L)
        
        if sum(abs(Ap-A))<(threshold*sum(A))
            converged=true
            break
        end
        i+=1
    end
    return {A,i,converged}
end


#this definition was taken from thier matlab code with some modifications
function updateLambda!(A,S,Y,iteration,maxIter, phaseRatio,lambda)
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



function nGMCA(Y::Array{Float64},r;verbose=false,maxIter=5000,threshold=1e-6,phaseRatio=0.30,kickstart=true)

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
        S=updateS(Y,A,0,S;maxIter=1000)[1]
        (A,S)=m_reinitializeS(A,S, Y, verbose)
        A=updateA(Y,S,A;maxIter=1000)[1]
        print("\nKickstart complete.")
    end
    
    if verbose
        print("\nL0=",""*string(l,"\nStart Full BSS:\n"))
    end
    
    #Run the algorithm
    j=1
    for j=1:maxIter
        Ap=deepcopy(A)
        Sp=deepcopy(S)

        #normalize columns of A
        for i=1:size(A)[2]
            A[:,i]= A[:,i]./[sum(A.^2.,1).^.5][i]
        end
        
        (A,S)=m_reinitializeS(A,S, Y, verbose)
        S=updateS(Y,A,l,S;maxIter=maxIter)
        (A,S)=m_reinitializeS(A,S, Y, verbose)
        A=updateA(Y,S[1],A;maxIter=maxIter)
        l=updateLambda!(A[1],S[1],Y,j,maxIter,phaseRatio,l)
        
        if verbose && mod(j,10)==0
            print("\r"*string("GI(S) ",round(GI(S[1]),3)," GI(A) ",
            round(GI(A[1]),3),"\t Iterations Total:",j,"  S:",S[2]," A: ",A[2],
            "\tL:",round(l,5),"\t Dist to Y: ",round(sum((A[1]*S[1]-Y).^2.).^.5),5))
        end

        S=S[1]
        A=A[1]
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

    if sum(sum(S, 2) .== 0) > 0
        if verbose
            print("\r"*string("Reinitilizing blank rows/columns: ",sum(sum(S,2).==0)))
        end
        indices = [sum(S, 2) .== 0][:]
        
        (A[:, indices], S[indices, :]) = m_fastExtractNMF(Y - A * S, sum(indices))
    end
    (A,S)
end


function m_fastExtractNMF(residual, r)
    if r > 0
        (m, n) = size(residual);
        A = zeros(m, r);
        S = zeros(r, n);
        for i = 1 : r
            residual = residual .* (residual .> 0);
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