function removeTicksUnusedAxes(axisString)
% remove right/upper ticks by plotting another box without ticks
%
% the axisString string allows the new box to behave the same as the original
% box if you used 'axis equal' or 'axis square'
%
% note: make sure to do xlim/ylim setting after this function if you want
% the box to be square

a = gca;
set(a, 'box', 'off', 'color', 'none');                                              % set box property to off and remove background color
b = axes('Position', get(a, 'Position'), 'box', 'on', 'xtick', [], 'ytick', []);    % create new, empty axes with box but without ticks
if ~strcmp(axisString, '')
    axis(axisString)    % set axis equal/square based on user input (if the original was 'axis equal' then axisString should be 'equal'
end
axes(a);                                                                            % set original axes as active
linkaxes([a b]);                                                                    % link axes in case of user zooming in plot
