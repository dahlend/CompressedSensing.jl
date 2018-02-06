#Define the absolute Gini Index, see [4] for a complete definition
function GI(x::AbstractArray{T}) where T<:Number

    y = sort(x)
    
    n=length(x)

    #g is the gini index
    g=zero(T)
    for k = 1:n
        g += y[k]*(n-k+1/2)/n
    end
    
    g = 1 - 2*g/sum(abs.(x))

    #return g
    g
end
