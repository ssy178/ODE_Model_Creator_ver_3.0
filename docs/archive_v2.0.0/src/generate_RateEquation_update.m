%% Generate IQM syntax

for ii = 1:size(Reactions,1)
    
    proc         = Reactions(ii,:);
    proc_type    = proc{1};
    
    switch proc_type
        
        case {'MA'}
            MA
        case {'ASSO'}
            ASSO
        case {'DISSO'}
            DISSO
        case {'MMS'}
            MMS
        case {'MMF'}
            MMF
        case {'MMSF'}
            MMSF
        case {'MMFF'}
            MMFF
        case {'MMSR'}
            MMSR
        case {'MMFR'}
            MMFR
        case {'SYN0'}
            SYN0
        case {'SYNS'}
            SYNS
        case {'SYNF'}
            SYNF
        case {'DEG0'}
            DEG0
        case {'DEGS'}
            DEGS
        case {'DEGF'}
            DEGF
        case {'TRN'}
            TRN
        case {'TRNF'}
            TRNF
        otherwise
            disp(strcat('process ID (incorrect): ',{' '},num2str(ii),'_',proc_type))
    end
    
end


