function [ypred, yci] = predictRate(centralETR, model, Par, transitCount)


mdl = graduateRate(centralETR, model, Par, transitCount);

age = mdl.Variables.x1;
[ypred, yci] = predict(mdl, age);
