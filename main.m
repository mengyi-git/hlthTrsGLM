clear

fileName = 'rndhrs_f_transit.csv';

% import data
dataset = readtable(fileName);
Par = setPar(dataset);

%% calculate raw transition rates

transitResult = calTransit(dataset, Par);


%% model comparison: graduation using all the candidate models

% define the age range on which the graduation is performed
% this might be different from the age range in the data set
ageMinGrad = 65;
ageMaxGrad = 99;

Par.ageMinGrad = ageMinGrad;
Par.ageMaxGrad = ageMaxGrad;

% find all possible transitions
transitT = groupcounts(dataset, {'RxHSTATE', 'RxHSTATE2'});
transitT = transitT(transitT.RxHSTATE ~= transitT.RxHSTATE2, :);
transitPair = [transitT.RxHSTATE, transitT.RxHSTATE2];

% define the models
Par.model = {'linear', 'purequadratic', 'poly3'};
N_MODEL = numel(Par.model);

ageStartIndex = ageMinGrad - Par.ageMin + 1;
ageEndIndex = ageMaxGrad - Par.ageMin + 1;
ageIndex = ageStartIndex:ageEndIndex;

N_H_STATE = Par.nHState;

% store information criteria
icResult = cell(N_H_STATE-1, N_H_STATE);

% calculate information criteria and
% perform the likelihood ratio test
for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        
        if ismember([iHState, jHState], transitPair, 'rows')
            centralETR = transitResult.transitETR{iHState}(ageIndex);
            transitCount = transitResult.transitCount{iHState, jHState}(ageIndex);
            
            y = calInfoCriteria(centralETR, Par, transitCount);
            
            % p-value for the likelihood ratio test
            dDev = -diff(y.dev);            
            pValue = chi2cdf(dDev, ones(N_MODEL - 1, 1), 'upper');
            
            y.dDev = dDev;
            y.pValue = pValue;
            icResult{iHState, jHState} = y;

        end
    end
end

% -- print AIC BIC AICc D_c, \Delta D_c --
% - manually select the optimal model - 
icList = {'aic', 'bic', 'dev'};
N_IC = numel(icList);

for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        if ismember([iHState, jHState], transitPair, 'rows')
            fprintf('State %d to State %d \n', iHState, jHState)
            y = icResult{iHState, jHState};
            
            for iModel = 1:N_MODEL
                for iInfoC = 1:N_IC
                    ic = icList{iInfoC};
                    fprintf('%10.4f', y.(ic)(iModel))
                end
                
                if iModel > 1
                    pValue = y.pValue(iModel - 1);
                    fprintf('%10.4f %s ', y.dDev(iModel-1), calSignt(pValue))
                end
            fprintf('\n')
            end
            
        end
    end
    fprintf('\n')
end


%% select the optimal model

% each row: stateFrom, stateTo, optModel
optModelPrep = [1 2 3; 1 3 1; 1 4 2; 2 1 2; 2 3 2; 2 4 2; 3 1 1; 3 2 3; 3 4 1];

optModel = nan(N_H_STATE - 1, N_H_STATE);
for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        rowIndex = optModelPrep(:, 1) == iHState & optModelPrep(:, 2) == jHState;

        if sum(rowIndex) ~= 0
            optModel(iHState, jHState) = optModelPrep(rowIndex, end);
        end
    end
end


%% graduation using the optimal model

transitRateCell = cell(N_H_STATE-1, N_H_STATE);
transitRateCICell = cell(N_H_STATE-1, N_H_STATE);

for iHState = 1:N_H_STATE-1
    for jHState = 1:N_H_STATE
        if ismember([iHState, jHState], transitPair, 'rows')
            
            iModelSelect = Par.model{optModel(iHState, jHState)};
            
            % extract cETR and transitCount
            centralETR = transitResult.transitETR{iHState}(ageIndex);
            transitCount = transitResult.transitCount{iHState, jHState}(ageIndex);
            
            [ypred, yci] = predictRate(centralETR, iModelSelect, Par, transitCount);
            
            transitRateCell{iHState, jHState} = ypred;
            transitRateCICell{iHState, jHState} = yci;
                
        end
    end
end

% transition rate on the diagonal
for iHState = 1:N_H_STATE-1
    iTransitRate = cat(2, transitRateCell{iHState, :});
    transitRateCell{iHState, iHState} = -sum(iTransitRate, 2);
end

% rearrange transitRateCell
N_AGE = size(transitRateCell{1}, 1);
transitRateByAge = cell(N_AGE, 2);
transitRateByAge(:, 1) = num2cell((Par.ageMinGrad:Par.ageMaxGrad)');
for iAgeIndex = 1:N_AGE
    iTransitRate = zeros(N_H_STATE, N_H_STATE);
    
    for iHState = 1:N_H_STATE-1
        for jHState = 1:N_H_STATE
            if ~isempty(transitRateCell{iHState, jHState})
                iTransitRate(iHState, jHState) = transitRateCell{iHState, jHState}(iAgeIndex);
            end
        end
    end
    
    transitRateByAge{iAgeIndex, end} = iTransitRate;
end

% convert transition rate to transition probability
transitProbCell = transitRateByAge;
transitProbCell(:, end) = cellfun(@(x) expm(x), transitRateByAge(:, end), 'UniformOutput', false);

% % uncomment to save the single-year transition probability
% save('trsProb.mat', 'transitProbCell')
