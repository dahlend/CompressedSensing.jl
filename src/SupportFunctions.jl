function FindSol(Y,A,M,Mt)
    return A-Mt*(M*A-Y)
end

function InitSolution(MeasurementMatrix,MeasuredOutput,m)

    #Guess a random solution
    GuessedInput=zeros(m)
    GuessedInput[shuffle(1:m)[1:div(m,10)]]=rand(div(m,10))

    #project the guessed solution into the space of exact answers
    GuessedInput=FindSol(MeasuredOutput,
        GuessedInput,
        MeasurementMatrix,
        pinv(MeasurementMatrix))

    return GuessedInput
end

function plusOp(x)
    max(x,0)
end


function soft(x,l)
    sign(x)*plusOp(abs(x)-l)
end
