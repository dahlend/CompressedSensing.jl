using CompressiveSensing
using Base.Test


srand(0)

#Setup a signal and measurement for testing
Signal=zeros(100)
Signal[int(rand(20)*9+1)]=randn(20)
Measure = randn(40,100)
#try to rebuild the signal
GuessSignal = IRLS(Measure,[Measure*Signal],threshold=1e-10,maxiter=5000)[1] 

#see if answer is within 5 digits
@test_approx_eq_eps GuessSignal Signal 1e-5
info("IRLS() PASSED")

