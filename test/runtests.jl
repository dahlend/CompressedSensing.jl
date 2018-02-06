using CompressedSensing
using Base.Test


srand(0)

#Setup a signal and measurement for testing
n = 100; m = 40; s = 20
Signal=zeros(n)
Signal[shuffle(1:n)[1:s]]=randn(s)
Measure = randn(m,n)
Noise=randn(m)*.1

#try to rebuild the signal
IRLS_GuessSignal = IRLS(Measure,Measure*Signal,threshold=1e-10,maxiter=5000)

#see if answer is within 5 digits
@test IRLS_GuessSignal ≈ Signal atol=1e-5
info("IRLS() PASSED")


UIRLS_GuessSignal=UIRLS(Measure,Measure*Signal+Noise,lambda=.1,maxiter=5000)

@test cor(UIRLS_GuessSignal, Signal)>0.9
info("UIRLS() PASSED")


A = zeros(100)
A[1]=1

@test GI(A)==.99
info("GI() PASSED")
