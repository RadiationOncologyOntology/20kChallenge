function [instance] = updateRho(r_norm,s_norm,instance)
% penalty parameter (rho) variation according to Boyd et al. (2010), page
% 20, formula 3.13)
mu = 10;
tauIncr = 2;
tauDecr = 2;

if r_norm > mu * s_norm % when the primal residual is much larger, increase rho
    instance.rho = tauIncr * instance.rho;
elseif s_norm > mu * r_norm % when the dual residual is much larger, decrease rho
    instance.rho = instance.rho / tauDecr;
else
    % chance nothing
end
end