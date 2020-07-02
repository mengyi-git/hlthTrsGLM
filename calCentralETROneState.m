function y = calCentralETROneState(Obs, Par)

% calculate central expose to risk when
% RxHSTATE == RxHSTATE2 or RxHSTATE2 = DEAD_STATE
% in years

age = Obs.age;
ageNext = Obs.ageNext;
N_AGE = Par.nAge;

y = zeros(1, N_AGE);

for iAge = 1:N_AGE-1
    y(iAge) = max(0, min(Par.ageMin + iAge, ageNext) - max(Par.ageMin - 1 + iAge, age));
end

y(N_AGE) = max(0, ageNext - max(Par.ageMin - 1 + N_AGE, age));

