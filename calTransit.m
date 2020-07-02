function result = calTransit(dataset, Par)

result = struct;

stateArray = dataset.RxHSTATE;
stateNextArray = dataset.RxHSTATE2;

ageInput = dataset.RxAGE;
ageNextInput = dataset.RxAGE2;

N_H_STATE = Par.nHState;
N_OBS = Par.nOb;

ageMin = Par.ageMin;
ageMax = Par.ageMax;
N_AGE = Par.nAge;

DEAD_STATE = Par.DEAD_STATE;

%%

% Defining a matrix to deposit the central exposed to risk %
rawCETR = cell(N_H_STATE-1, 1);

for iHState = 1:N_H_STATE-1
    rawCETR{iHState} = zeros(N_OBS, N_AGE);
end

% Defining a matrix to deposit the number of transitions %
transitRawCell = cell(N_H_STATE - 1, N_H_STATE);
for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        if iHState ~= jHState
            transitRawCell{iHState, jHState} = zeros(N_OBS, N_AGE);
        end
    end
end


for iObs = 1:N_OBS
    
    state = stateArray(iObs);
    stateNext = stateNextArray(iObs);
    
    age = ageInput(iObs);
    ageNext = ageNextInput(iObs);
    
    Obs = struct('age', age, 'ageNext', ageNext);
    
    if state == stateNext || stateNext == DEAD_STATE
        rawCETR{state}(iObs, :) = calCentralETROneState(Obs, Par); 
        
    elseif state ~= stateNext
        [cetr1, cetr2] = calCentralETRTwoState(Obs, Par);
        rawCETR{state}(iObs, :) = cetr1;
        rawCETR{stateNext}(iObs, :) = cetr2;
    end
        
    % indicator of transitions
    if state ~= stateNext
        if ageNext < ageMax
            if stateNext ~= DEAD_STATE
                transitRawCell{state, stateNext}(iObs, floor(0.5*(ageNext + age)) - (ageMin-1)) = 1;
            else
                transitRawCell{state, stateNext}(iObs, floor(ageNext) - (ageMin-1)) = 1;
            end                
        else
            transitRawCell{state, stateNext}(iObs, N_AGE) = 1;
        end 
    end
    
end

% summarise central exposed to risk
centralETR = cellfun(@(x) sum(x, 1)', rawCETR, 'UniformOutput', false);

% summarise number of transitions
transitCell = cellfun(@(x) sum(x, 1)', transitRawCell, 'UniformOutput', false);


% compute raw transition rates
transitRateRawCell = cell(N_H_STATE - 1, N_H_STATE);
for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        
        if iHState ~= jHState
            transitRateRawCell{iHState, jHState} = transitCell{iHState, jHState} ./ centralETR{iHState};
        end
        
    end
end


%% save the results
result.age = (ageMin:ageMax)';
result.transitRate = transitRateRawCell;
result.transitCount = transitCell;
result.transitETR = centralETR;



