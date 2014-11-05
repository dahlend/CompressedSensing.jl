function Coherence(B::Array{Float64,2})
    u=Inf
    for k=1:size(B,2)
        for j=1:(k-1)
            len=(sum(B[:,k].^2).^.5)*(sum(B[:,j].^2).^.5)
            innerProd=abs(sum(B[:,k].*B[:,j]))
            u= minimum([u,innerProd/len])
        end
    end
    return u
end

Coherence(B) = Coherence(convert(Array{Float64,2},B))