function [y1, y2] = calCentralETRTwoState(Obs, Par)

% calculate central expose to risk when
% RxHSTATE ~= RxHSTATE2
% in years
% assume the transtion occurred in the midpoint

N_AGE = Par.nAge;

age = Obs.age;
ageNext = Obs.ageNext;

y1 = zeros(1, N_AGE);
y2 = zeros(1, N_AGE);

% midpoint assumed
for iAge = 1:N_AGE-1
    y1(iAge) = max(0, min(Par.ageMin + iAge, 0.5*(ageNext + age)) - max(Par.ageMin - 1 + iAge, age));
    y2(iAge) = max(0, min(Par.ageMin + iAge, ageNext) - max(Par.ageMin - 1 + iAge, 0.5*(ageNext + age)));
end

y1(N_AGE) = max(0, 0.5*(ageNext + age)- max(Par.ageMin - 1 + N_AGE, age));
y2(N_AGE) = max(0, ageNext - max(Par.ageMin - 1 + N_AGE, 0.5*(ageNext + age)));
