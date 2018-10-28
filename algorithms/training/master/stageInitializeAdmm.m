function [sites,state,instance] = stageInitializeAdmm(sites,state,instance)
% This stage merges patient counts from each site and provides the initial
% values for the ADMM variables x, u, z.

% merge patient counts
[instance] = mergePatientCounts(sites,instance);

% set stage to 1 so that sites start learning
state.stage = 1;

% initialize learning parameters
for i_sites = 1:length(sites)
    sites(i_sites).x = instance.xInitialization;
    sites(i_sites).u = instance.uInitialization;
    sites(i_sites).z = instance.zInitialization;
end

% initialize logs
for i_sites = 1:length(sites)
    instance.xLog{i_sites} = instance.xInitialization;
    instance.uLog{i_sites} = instance.uInitialization;
end
instance.zLog = instance.zInitialization;
instance.rhoLog = instance.rho;
end