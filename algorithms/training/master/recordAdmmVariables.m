function [instance] = recordAdmmVariables(sites,instance)
%   Record x, z, u, objectives, SSE in the instance struct for debugging/analysis.


x = [sites(:).x];
z = [sites(:).z];
u = [sites(:).u];

siteObj = [sites(:).obj]; % it is computed in updateX (on the site)
siteRegObj = [sites(:).regObj]; % it is computed in updateZ (on the master) but placed in the sites struct because the other part of the objective is there
siteSumSquareError = [sites(:).sumSquareError];

numeroSites = length(sites);

if ~isfield(instance,'objLossLog')
    instance.objLossLog = [];
end

if ~isfield(instance,'objRegLog')
    instance.objRegLog = [];
end

if ~isfield(instance,'objLog')
    instance.objLog = [];
end

if ~isfield(instance,'sumSquareErrorLog')
    instance.sumSquareErrorLog = [];
end

if ~isfield(instance,'rootMeanSquareErrorLog')
    instance.rootMeanSquareErrorLog = [];
end

% objective based previous ADMM iteration's z
objLoss = sum(siteObj);
objReg = siteRegObj(1); % the regularization objective is global
obj = objLoss + objReg;

instance.objLossLog = [instance.objLossLog objLoss];
instance.objRegLog = [instance.objRegLog objReg];
instance.objLog = [instance.objLog obj];

% SSE based previous ADMM iteration's z
sumSquareError = sum(siteSumSquareError);
instance.sumSquareErrorLog = [instance.sumSquareErrorLog sumSquareError];

% RMSE based previous ADMM iteration's z
rootMeanSquareError = sumSquareError/sum(instance.patientCount);
instance.rootMeanSquareErrorLog = [instance.rootMeanSquareErrorLog rootMeanSquareError];

if ~isfield(instance,'xLog')
    instance.xLog = cell(numeroSites,1);
end

if ~isfield(instance,'zLog')
    instance.zLog = [];
end

if ~isfield(instance,'uLog')
    instance.uLog = cell(numeroSites,1);
end

if ~isfield(instance,'rhoLog')
    instance.rhoLog = [];
end

for i_sites = 1:numeroSites
    instance.xLog{i_sites} = [instance.xLog{i_sites} x(:,i_sites)];
    instance.uLog{i_sites} = [instance.uLog{i_sites} u(:,i_sites)];
end

% z is global
instance.zLog = [instance.zLog z(:,1)];

% rho is a global parameter
instance.rhoLog = [instance.rhoLog instance.rho];

end