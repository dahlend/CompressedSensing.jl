function r2(x)
    nrows=size(x,1)
    out = zeros(eltype(x),nrows)
    for i = 1:nrows
        out[i] = norm(x[i,:])
        #out[i] = sum((x[i,:]).^2.)^(0.5)
    end
    out
end

function f(w,alpha)
    if abs(w) <= 1/alpha
        return 2*alpha*sign(w)-2*alpha^2*w
    end
    return 0
end

function dJ(x,alpha)
    (nrows,ncols) = size(x)
    out = zeros(eltype(x),nrows,ncols)

    for i = 1:nrows
        l2xi  = norm(x[i,:]) #euclidean distance of the i'th row of X
        if l2xi !=0  #if the distance is not 0
            for j = 1:ncols #set the columns of out to non-zero
                out[i,j] = f(l2xi,alpha)/l2xi*x[i,j]
            end
        end
    end
    out
end


function ZAP(Y::AbstractArray{T,2},A::AbstractArray{T,2};maxIter=500,kappa=.1,neu=.1,threshold=1e-6,verbose=false,Q=11,alpha=1) where T
    #initialize guess
    A_inv = pinv(A)
    guess = A_inv*Y

    if verbose
        print("\nMax Iterations: ",maxIter,"\nCurrent Iteration:\n")
    end


    iteration=0
    for iteration = 1:maxIter

        if mod(iteration ,round(Int,Q))==0
            previous_guess = deepcopy(guess)

            if verbose
                print("\r"*string("",iteration ,"\tKappa = ",kappa,"\t",
                round(maximum([iteration /maxIter*100.,log(threshold,10)/log(kappa,10)*100.]),1),"%"))
            end
        end

        guess = guess - kappa * dJ(guess,alpha)
        guess = guess + A_inv*(Y-A*guess)
        if mod(iteration ,round(Q))==0 && sum(r2(guess))>=sum(r2(previous_guess))
            kappa=neu*kappa

            if kappa<= threshold
                break
            end
        end
    end
    if verbose
        print("\n\nDone.\n")
    end
    return guess

end
