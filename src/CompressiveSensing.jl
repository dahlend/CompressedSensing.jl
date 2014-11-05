module CompressiveSensing

# package code goes here

include("IRLS.jl")
include("UIRLS.jl")
include("GiniIndex.jl")
include("nGMCA.jl")
include("ZAP.jl")
include("Coherence.jl")

export IRLS,UIRLS,GI,nGMCA,ZAP,Coherence

end # module
