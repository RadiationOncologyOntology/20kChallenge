function [state,instance,sites] = checkConvergence(sites,state,instance)
% This function checks whether the algorithm has converged (according to Boyd's
%   criteria) and then aborts the ADMM process.
%   http://web.stanford.edu/~boyd/papers/admm_distr_stats.html

%%
% read variables
x = [sites(:).x];
z = [sites(:).z];
u = [sites(:).u];
zOld = [sites(:).zOld];

% number of sites
numeroSites = size(x,2);

% load user input parameters (rho, tolerances)
rho = instance.rho;
absTol = instance.absTol;
relTol = instance.relTol;

% determine number of coefficients (number of features + intercept)
numeroCoefficients = size(x,1);

% compute metrics for convergence criterion
r_norm  = norm(x - z,'fro');
s_norm  = norm(rho*(z - zOld),'fro');

% determine primal and dual convergence parameters
eps_pri = sqrt(numeroSites*numeroCoefficients)*absTol + relTol*max(norm(x,'fro'), norm(z,'fro'));
eps_dual= sqrt(numeroSites*numeroCoefficients)*absTol + relTol*norm(rho*u,'fro');

disp('Convergence info:')
disp(['Primal residual norm - primal residual tolerance: ' num2str(r_norm - eps_pri)])
disp(['Dual residual norm - dual residual tolerance:     ' num2str(s_norm - eps_dual)])

% determine whether convergence criterion has been reached
if (r_norm < eps_pri && s_norm < eps_dual)
    state.hasConverged = true;
end

%% dynamic rho schedule. deactivated for now
% rhoOld = instance.rho;
% [instance] = updateRho(r_norm,s_norm,instance);
% rhoNew = instance.rho;

% adjust u after updating rho
% for i_trainSites = 1:size(u,2)
% sites(i_trainSites).u = 1/(rhoNew/rhoOld) .* sites(i_trainSites).u; % if rho is halved, u needs to be doubled (Boyd et al. (2011), page 21)
% end

end