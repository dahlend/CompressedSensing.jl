#Define the absolute Gini Index, see [4] for a complete definition
function GI(x::Array)
    
    @assert eltype(x)<:Number

    #Reshape the incoming matrix into a sorted 1xn list of positive numbers
    x=abs(x[:])
    sort!(x)
    
    n=length(x)

    #s is the sum of all terms, g is the gini index
    g=0
    s=0
    for i = 1:n
        s += x[i]
        g += x[i]*i
    end
    
    g *= 2/n/s
    g -= (n+1)/n
    
    #return G
    g
end;
