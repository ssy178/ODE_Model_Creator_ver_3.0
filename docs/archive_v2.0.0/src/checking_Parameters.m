
%%  IQM parameters
Parameters = {};
for ii = 1:size(Reactions,1)
    for jj = 1:length(Process(ii).param)
        Parameters = [Parameters, Process(ii).param(jj)];
    end
end

% find duplicate
parameter_unique(:,1) = unique(deblank(Parameters));




delim = cell(size(parameter_unique));
delim(:) = {'_'};
C = cellfun(@strsplit,parameter_unique,delim,'UniformOutput',false);
% unique(cellfun(@(x) x{1},C,'UniformOutput',false));


% set defalt parameter values
default_parameter_values    = 'default_parameter_value.xlsx';
default_values              = readcell(default_parameter_values);
param_val                   = zeros(size(parameter_unique));

for ii = 1:size(default_values,1)
    param_xx            = contains(parameter_unique,{default_values{ii,1}});
    param_val(param_xx) = default_values{ii,2};
end


% save parameters
param_tbl = table(parameter_unique, param_val);

% if exist(strcat(model_dir,'\table_parameter.xlsx'),'file')
%     disp(strcat('[',strcat(model_name,'\table_parameter.xlsx]'),' already exist'))
% else
    writetable(param_tbl,strcat(model_dir,'\table_parameter.xlsx'), 'WriteVariableNames', false)
% end
