function [sites,state,instance] = stageLearning(functionInput,sites,state,instance)
% This stage updates z & u, and checks whether ADMM converged.

% update learning parameters
[sites] = updateZAndU(sites,instance);
% check convergence
[state,instance,sites] = checkConvergence(sites,state,instance);

% record (ADMM) variables, metrics
[instance] = recordAdmmVariables(sites,instance);

% create progress figure
if instance.displayProgress == true
    createProgressFigures(functionInput,instance);
end

% if solution has converged or iteration limit is reached, stop learning
% otherwise continue learning.
if state.hasConverged == true || state.itNumber == (instance.maxIter - 1)
    % not necessary because stage does not matter anymore (we write the result file here)
    state.stage = 2;
    % write output
    writeResult(functionInput,instance)
    % write the last value of z to log
    writeToLog(['zFinal: ' num2str(instance.zLog(:,end)')],functionInput);
else
    % not necessary because stage is already 1
    state.stage = 1;
end
end