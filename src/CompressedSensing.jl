module CompressedSensing

# package code goes here

include("IRLS.jl")
include("UIRLS.jl")
include("GiniIndex.jl")
include("nGMCA.jl")
include("ZAP.jl")
include("Coherence.jl")


export IRLS,UIRLS,GI,nGMCA,ZAP,Coherence,CSExamples

function CSExamples()
	include("../examples/Example 1.jl")

end


end # module
