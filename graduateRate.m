function mdl = graduateRate(centralETR, model, Par, transitCount)

% fit the GLM 
% Input
%   centralETR: central expose to risk
%   model: name of the model
%   Par: parameters
%   transitCount: number of transitions

age = (Par.ageMinGrad:Par.ageMaxGrad)';

mdl = fitglm(age, transitCount, model, ...
    'DispersionFlag', false, 'Distribution', 'poisson', 'link', 'log', ...
    'offset', log(centralETR));




