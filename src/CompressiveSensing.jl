module CompressiveSensing

# package code goes here

include("IRLS.jl")
include("UIRLS.jl")
include("GiniIndex.jl")
include("nGMCA.jl")

export IRLS,UIRLS,GI,nGMCA

end # module
