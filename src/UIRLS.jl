include("SupportFunctions.jl")


#Define the p in the Lp minimization, previous work suggests p=0.5 results in
#equivalent results to 0 with signifigantly less time to convergence

#eps is a function that starts at 1 and converges to 0 as x goes from 1->inf
#this is needed by the IRLS algorithm to converge

function UIRLS(MeasurementMatrix::Array{Float64,2},MeasuredOutput::Array{Float64,1};
    eps=x->1/x^3,threshold=1e-5,lambda=1,p=.5,verbose=false,maxiter=1000,debug=false,force_positive=false)

    #identify the size of the input
    m=size(MeasurementMatrix,2)

    ######### First we need to calculate a valid solution ###############

    GuessedInput = InitSolution(MeasurementMatrix,MeasuredOutput,m)


    ###### Initialize some values used in the IRLS algorithm ############
    #Construct the weight matrix, used in the ridge regression
    wn = zeros(m,m)

    #Save a copy of the "previous" guess, which in this case is the original guess
    PrevGuess=GuessedInput

    #transpose the sampling matrix, this is used every iteration so it
    #is far more efficient to calculate it before hand.
    tMeasurementMatrix=MeasurementMatrix'
    AtA = tMeasurementMatrix*MeasurementMatrix



    #set the distance between iterations to infinite
    PrevDist = fill(Inf,int(maxiter/100)+1)

    #start on iteration 1
    iteration=1

    if verbose
        print("Iteration: \n","Begin")
    end

    converges=true

    #Begin Iterating
    while PrevDist[int(iteration/100)+1]>threshold

        #Calculate the diagonal weights
        for j in 1:m
            wn[j,j]=p*lambda / (eps(iteration)+PrevGuess[j]^2.)^(1.-p/2)
        end

        #Record Previous guess to convergence test later
        PrevGuess=GuessedInput

        #iterate through the IRLS steps
        GuessedInput=(AtA + wn)\(tMeasurementMatrix*MeasuredOutput)
        if force_positive
            GuessedInput=max(GuessedInput,zeros(m))
        end
        #CONVERGENCE TEST
        #Every 1% of maxiter, see if we are approaching convergence
        if mod(iteration,int(maxiter/100))==0
            #Measure convergence as euclidean distance between answers
            PrevDist[int(iteration/100)+1] = sqrt(sum((PrevGuess-GuessedInput).^2.))/m

            #Print progress if so desired
            if verbose
                print("\r"*string(iteration, "  Euclidean Distance between steps: "
                    ,PrevDist[int(iteration/100)+1]))
            end

            #most involved convergence test, see if the distance increases from one iteration
            #to the next, and if it does, break, converges=false since we didn't hit threshold
            if (int(iteration/100)+1>2) &&
                    (PrevDist[int(iteration/100)+1] > PrevDist[max(int(iteration/100),1)])
                converges=false
                break
            end
        end

        #if we pass iter iterations, give up
        if iteration>=maxiter
            converges=false
            break
        end

        iteration+=1
    end

    if verbose
        print("\nDone\n")
    end

    #if debugging, return additional information, such as distance to convergence and iteration number
    if debug
        return (GuessedInput,converges,iteration-1,PrevDist[1:(int(iteration/100)+1)])
    else
        return GuessedInput
    end

end


UIRLS(MeasurementMatrix,MeasuredOutput;x...)=
             UIRLS(convert(Array{Float64,2},MeasurementMatrix),
                   convert(Array{Float64,1},MeasuredOutput);x...)

function UIRLS(MeasurementMatrix::Array{Float16,2},MeasuredOutput::Array{Float16,1};
    eps=x->1/x^3,threshold=1e-5,lambda=1,p=.5,verbose=false,maxiter=1000,debug=false,force_positive=false)

    #identify the size of the input
    m=size(MeasurementMatrix,2)

    ######### First we need to calculate a valid solution ###############

    GuessedInput = InitSolution(MeasurementMatrix,MeasuredOutput,m)


    ###### Initialize some values used in the IRLS algorithm ############
    #Construct the weight matrix, used in the ridge regression
    wn = zeros(m,m)

    #Save a copy of the "previous" guess, which in this case is the original guess
    PrevGuess=GuessedInput

    #transpose the sampling matrix, this is used every iteration so it
    #is far more efficient to calculate it before hand.
    tMeasurementMatrix=MeasurementMatrix'
    AtA = tMeasurementMatrix*MeasurementMatrix



    #set the distance between iterations to infinite
    PrevDist = fill(Inf,int(maxiter/100)+1)

    #start on iteration 1
    iteration=1

    if verbose
        print("Iteration: \n","Begin")
    end

    converges=true

    #Begin Iterating
    while PrevDist[int(iteration/100)+1]>threshold

        #Calculate the diagonal weights
        for j in 1:m
            wn[j,j]=p*lambda / (eps(iteration)+PrevGuess[j]^2.)^(1.-p/2)
        end

        #Record Previous guess to convergence test later
        PrevGuess=GuessedInput

        #iterate through the IRLS steps
        GuessedInput=(AtA + wn)\(tMeasurementMatrix*MeasuredOutput)
        if force_positive
            GuessedInput=max(GuessedInput,zeros(m))
        end
        #CONVERGENCE TEST
        #Every 1% of maxiter, see if we are approaching convergence
        if mod(iteration,int(maxiter/100))==0
            #Measure convergence as euclidean distance between answers
            PrevDist[int(iteration/100)+1] = sqrt(sum((PrevGuess-GuessedInput).^2.))/m

            #Print progress if so desired
            if verbose
                print("\r"*string(iteration, "  Euclidean Distance between steps: "
                    ,PrevDist[int(iteration/100)+1]))
            end

            #most involved convergence test, see if the distance increases from one iteration
            #to the next, and if it does, break, converges=false since we didn't hit threshold
            if (int(iteration/100)+1>2) &&
                    (PrevDist[int(iteration/100)+1] > PrevDist[max(int(iteration/100),1)])
                converges=false
                break
            end
        end

        #if we pass iter iterations, give up
        if iteration>=maxiter
            converges=false
            break
        end

        iteration+=1
    end

    if verbose
        print("\nDone\n")
    end

    #if debugging, return additional information, such as distance to convergence and iteration number
    if debug
        return (GuessedInput,converges,iteration-1,PrevDist[1:(int(iteration/100)+1)])
    else
        return GuessedInput
    end

end
