function y = calInfoCriteria(centralETR, Par, transitCount)

% calculate AIC, BIC, AICc and deviance 
% for all models defined in Par.model

y = struct;

modelArray = Par.model;


N_MODEL = numel(modelArray);
modelDev = nan(N_MODEL, 1);
modelAic = nan(N_MODEL, 1);
modelBic = nan(N_MODEL, 1);
modelAicc = nan(N_MODEL, 1);

for iModel = 1:N_MODEL

    model = modelArray{iModel};
    mdl = graduateRate(centralETR, model, Par, transitCount);
    
    modelDev(iModel) = mdl.Deviance;
    modelAic(iModel) = mdl.ModelCriterion.AIC;
    modelBic(iModel) = mdl.ModelCriterion.BIC;
    modelAicc(iModel) = mdl.ModelCriterion.AICc;
end

y.dev = modelDev;
y.aic = modelAic;
y.bic = modelBic;
y.aicc = modelAicc;

