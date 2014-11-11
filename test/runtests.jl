using CompressedSensing
using Base.Test


srand(0)

#Setup a signal and measurement for testing
Signal=zeros(100)
Signal[int(rand(20)*9+1)]=randn(20)
Measure = randn(40,100)
Noise=randn(40)*.1

#try to rebuild the signal
IRLS_GuessSignal = IRLS(Measure,[Measure*Signal],threshold=1e-10,maxiter=5000)

#see if answer is within 5 digits
@test_approx_eq_eps IRLS_GuessSignal Signal 1e-5
info("IRLS() PASSED")


UIRLS_GuessSignal=UIRLS(Measure,Measure*Signal+Noise,lambda=.1,maxiter=2000)

@test cor(UIRLS_GuessSignal, Signal)>.995
info("UIRLS() PASSED")


A = zeros(100)
A[1]=1

@test GI(A)==.99
info("GI() PASSED")
