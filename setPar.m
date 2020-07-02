function Par = setPar(dataset)

% set up parameters based on dataset
Par = struct;

% total number of observations
N_OBS = size(dataset, 1); 

ageMin = floor(min(dataset.RxAGE)); 
ageMax = ceil(max(dataset.RxAGE2));

N_AGE = ageMax - ageMin + 1; % total number of integer ages


hStateArray = unique([dataset.RxHSTATE, dataset.RxHSTATE2]);
DEAD_STATE = hStateArray(end);
LTC_STATE = hStateArray(end-1);
N_H_STATE = numel(hStateArray);


Par.nOb = N_OBS;

Par.ageMin = ageMin;
Par.ageMax = ageMax;
Par.nAge = N_AGE;

Par.DEAD_STATE = DEAD_STATE;
Par.LTC_STATE = LTC_STATE;
Par.nHState = N_H_STATE;
