function [sites] = updateX(outcome,features,sites,instance)
%   Run the x-update according to Boyd. (http://web.stanford.edu/~boyd/papers/admm_distr_stats.html)
%   Instead of cvx, fminlbfgs() is used. See license statement below.
%% prepare input parameters

% use variables passed on by the master algo
xOld = sites.x;
u = sites.u;
z = sites.z;
rho = instance.rho;

% the number of patients from all sites
numeroPatients = sum(instance.patientCount);

% transpose vectors if it is a row vector
if size(u,1)<size(u,2)
    u = transpose(u);
end

%transpose vectors if it is a row vector
if size(z,1)<size(z,2)
    z = transpose(z);
end

%% optimize
xNew = bfgs_update(u, z, rho, xOld,features,outcome,numeroPatients);
%% export parameters of the learned model
% put x and the deviance objective in the sites struct, which is passed to the master
sites.x = xNew;
constantAndFeatures = [ones(size(features,1),1) features];
sites.obj = -2/numeroPatients*sum(outcome.*log(1./(1 + exp(-(constantAndFeatures*z)))) + (1-outcome).*log(1-1./(1 + exp(-(constantAndFeatures*z)))));
end

function [x] = bfgs_update(u, z, rho, x0,features,outcome,numeroPatients)
% solve the x-update
%   minimize [ -logistic(x_i) + (rho/2)||x_i - z^k + u^k||^2 ]
% via L-BFGS

options = struct('GradObj','on','Display','off','LargeScale','off','HessUpdate','bfgs','InitialHessType','identity','GoalsExactAchieve',0);
[x,fval2,exitflag,output,grad] = fminlbfgs(@(x) myLogRegFunction(x,z,u,rho,features,outcome,numeroPatients),x0,options);

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

function [val, grad] = myLogRegFunction(x,z,u,rho,features,outcome,numeroPatients)
numeroPatientsLocalSite = size(features,1);
features = [ones(numeroPatientsLocalSite,1) features];
val = -2/numeroPatients*sum(outcome.*log(1./(1 + exp(-(features*x)))) + (1-outcome).*log(1-1./(1 + exp(-(features*x)))))...
    + (1/2)*(x - z + u)'*rho*(x - z + u);

gradSum = 0;
for i_cases = 1:numeroPatientsLocalSite
    gradSum = gradSum + ( features(i_cases,:) * (outcome(i_cases) + (outcome(i_cases)-1)*exp(features(i_cases,:)*x))  )./(1 + exp(features(i_cases,:)*x));
end
   grad = -2/numeroPatients * gradSum' + rho*(x - z + u);
end



