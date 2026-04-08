%% Synthesis (TF) - Short

% devide cell into chacter and numeric
dat_array = proc(cellfun(@ischar,proc));

Process(ii).proc = strcat('=>',dat_array{2},':','R',num2str(ii));
Process(ii).species = {dat_array{2},dat_array{3}};



% {CAT,cycEmRNA,E2F}
if strcmp(proc_type,'CAT')
    
    if ~(length(dat_array) == 3)
        msg = strcat('reaction syntax error (reaction number): ',num2str(ii),'-',proc_type);
        error(msg);
    end
    
    Process(ii).rate_eq = strcat('vf = ','kcat_',dat_array{2},'_',dat_array{3},'*',dat_array{3});
    Process(ii).param = {strcat('kcat_',dat_array{2},'_',dat_array{3})};
    
    
    
elseif strcmp(proc_type,'CATi')
    
    
    % (1): type
    % (2-3): states
    % (>=4) : regulator
    loc_regulator   = 4;
    len_elements    = length(dat_array);
    
    if length(dat_array) < loc_regulator
        msg = strcat('reaction syntax error (reaction number): ',num2str(ii),'-',proc_type);
        error(msg);
    end
    
    str_p1 = strcat('vf = ','kcat_',dat_array{2},'_',dat_array{3},'*',dat_array{3},'/(');
    
    if length(dat_array) >= (loc_regulator+1)
        
        for kk = loc_regulator:length(dat_array)
            str_px = strcat('(','1 + Ki_cat_',dat_array{2},'_',dat_array{3},'_',dat_array{kk},'*',dat_array{kk},')*');
            str_p1 = [str_p1 str_px];
        end
        % note '*' -> ')'
        str_p1(end) = ')';
        
        
    else
        str_px = strcat('(','1 + Ki_cat_',dat_array{2},'_',dat_array{3},'_',dat_array{length(dat_array)},'*',dat_array{length(dat_array)},'))');
        str_p1 = [str_p1 str_px];
    end
    
    Process(ii).rate_eq = str_p1;
    Process(ii).param{1} = strcat('kcat_',dat_array{2},'_',dat_array{3});
    
    rr = 2;
    for kk = loc_regulator:len_elements
        Process(ii).param{rr} = strcat('Ki_cat_',dat_array{2},'_',dat_array{3},'_',dat_array{kk});
        rr = rr+1;
    end
end