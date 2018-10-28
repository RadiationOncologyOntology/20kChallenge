function [sites] = updateZAndU(sites,instance)
%   This function updates the learning variables retrieved from all sites
%   according to Boyd's updating rules.
%   (http://web.stanford.edu/~boyd/papers/admm_distr_stats.html)

%%
% read variables
x = [sites(:).x];
z = [sites(:).z];
u = [sites(:).u];

% columns within z must be the same because this is a variable updated
% at the master and a copy is sent to each site. The same holds for u.

% read input parameters for ADMM (alpha, lambda)
alpha = instance.alpha;
lambda = instance.lambda;
rho = instance.rho;

% determine the number of coefficients/sites included in training
numeroCoeff = size(x,1);
numeroSites = size(x,2);

% compute regularization penalty in objective 
% (computed before updating z because the first part of the 
% objective (objLoss) is computed on the site in the previous iteration. 
% If we placed this after the z-update, the objectives would be out of sync.
A = eye(numeroCoeff);
A(1,1) = 0;
regObj = nan(1,numeroSites);
for i_sites =  1:numeroSites
    regObj(i_sites) = lambda * norm(A*z(:,i_sites),1); % ||A*z||_{1}
end

%% updating rules
% z-update
xHat = alpha*x + (1-alpha)*z;
[z] = bfgs_update(mean(xHat,2),mean(z,2),mean(u,2),rho,lambda,numeroSites); % This is different from Boyd's MATLAB example. We optimize the same objective as MATLAB's lassoglm
z = repmat(z,1,numeroSites);
% u-update
u = u + (xHat - z);

% assign variables to sites struct
for i_sites = 1:numeroSites
    % move z to zOld;
    sites(i_sites).zOld = sites(i_sites).z;
    % assign newly updated u & z values
    sites(i_sites).u = u(:,i_sites);
    sites(i_sites).z = z(:,i_sites);
    sites(i_sites).regObj = regObj(i_sites);
end
end

function [z] = bfgs_update(x,z,u,rho,lambda,numeroSites)
% solve the z update
%   minimize ||A*z||_{1} + N * rho/2 * ||z - x - u||_{2}^{2}
% via L-BFGS
z0 = z;
options = struct('GradObj','on','Display','off','LargeScale','off','HessUpdate','bfgs','InitialHessType','identity','GoalsExactAchieve',0);
[z,fval2,exitflag,output,grad] = fminlbfgs(@(z) myZUpdateFunction(x,z,u,rho,lambda,numeroSites),z0,options);

%% fminlbfgs() comes with the following license:
% Copyright (c) 2009, Dirk-Jan Kroon
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

end

function [val, grad] = myZUpdateFunction(x,z,u,rho,lambda,numeroSites)
% This function computes the value of the z-update function and its
% gradient at a given point.

% function value at given point
numeroCoeff = size(x,1);
A = eye(numeroCoeff);
A(1,1) = 0;
val = lambda * norm(A*z,1) + numeroSites * rho/2 * (z - x - u)' * (z - x - u); % ||A*z||_{1} + N * rho/2 * ||z - x - u||_{2}^{2}

% gradient at given point
absAz = abs(A*z);
absAz(1) = 0.000000000000000000000000000000000000000000000000000000000000000001; % to avoid division by 0, I replace 0 by a very small number
grad = lambda * 1./absAz .* (A*A*z) + numeroSites * rho * (z - x - u);
end
