function [output] = EGFR_NFkB_ver_01_ode(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EGFR_NFkB_ver_01
% Generated: 15-Jan-2026 17:42:41
% 
% [output] = EGFR_NFkB_ver_01_ode() => output = initial conditions in column vector
% [output] = EGFR_NFkB_ver_01_ode('states') => output = state names in cell-array
% [output] = EGFR_NFkB_ver_01_ode('algebraic') => output = algebraic variable names in cell-array
% [output] = EGFR_NFkB_ver_01_ode('parameters') => output = parameter names in cell-array
% [output] = EGFR_NFkB_ver_01_ode('parametervalues') => output = parameter values in column vector
% [output] = EGFR_NFkB_ver_01_ode('variablenames') => output = variable names in cell-array
% [output] = EGFR_NFkB_ver_01_ode('variableformulas') => output = variable formulas in cell-array
% [output] = EGFR_NFkB_ver_01_ode(time,statevector) => output = time derivatives in column vector
% 
% State names and ordering:
% 
% statevector(1): AKT
% statevector(2): AKT_p
% statevector(3): AP1
% statevector(4): AP1_a
% statevector(5): AURKA
% statevector(6): AURKAm
% statevector(7): COX2
% statevector(8): COX2m
% statevector(9): EGF
% statevector(10): EGFR
% statevector(11): EGFR_p
% statevector(12): EGFm
% statevector(13): ERK
% statevector(14): ERK_p
% statevector(15): IKB
% statevector(16): IKBm
% statevector(17): IKK
% statevector(18): IKK_a
% statevector(19): IL6
% statevector(20): IL6m
% statevector(21): JAK
% statevector(22): JAK_a
% statevector(23): Myc
% statevector(24): NFkB
% statevector(25): NFkBnIKB
% statevector(26): PGE2
% statevector(27): PI3K
% statevector(28): PI3K_a
% statevector(29): PIP2
% statevector(30): PIP3
% statevector(31): PKC
% statevector(32): PKC_a
% statevector(33): PTEN
% statevector(34): RAS
% statevector(35): RAS_a
% statevector(36): STAT3
% statevector(37): STAT3_p
% statevector(38): TNFR1
% statevector(39): TNFR1_a
% statevector(40): TNFR1_p
% statevector(41): TNFa
% statevector(42): TNFam
% statevector(43): TTP
% statevector(44): ZFP36
% statevector(45): mTORC1
% statevector(46): mTORC1_a
% statevector(47): mTORC2
% statevector(48): mTORC2_a
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global time
parameterValuesNew = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLE VARIABLE INPUT ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0,
	% Return initial conditions of the state variables (and possibly algebraic variables)
	output = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
		0, 0, 0, 0, 0, 0, 0, 0];
	output = output(:);
	return
elseif nargin == 1,
	if strcmp(varargin{1},'states'),
		% Return state names in cell-array
		output = {'AKT', 'AKT_p', 'AP1', 'AP1_a', 'AURKA', 'AURKAm', 'COX2', 'COX2m', 'EGF', 'EGFR', ...
			'EGFR_p', 'EGFm', 'ERK', 'ERK_p', 'IKB', 'IKBm', 'IKK', 'IKK_a', 'IL6', 'IL6m', ...
			'JAK', 'JAK_a', 'Myc', 'NFkB', 'NFkBnIKB', 'PGE2', 'PI3K', 'PI3K_a', 'PIP2', 'PIP3', ...
			'PKC', 'PKC_a', 'PTEN', 'RAS', 'RAS_a', 'STAT3', 'STAT3_p', 'TNFR1', 'TNFR1_a', 'TNFR1_p', ...
			'TNFa', 'TNFam', 'TTP', 'ZFP36', 'mTORC1', 'mTORC1_a', 'mTORC2', 'mTORC2_a'};
	elseif strcmp(varargin{1},'algebraic'),
		% Return algebraic variable names in cell-array
		output = {};
	elseif strcmp(varargin{1},'parameters'),
		% Return parameter names in cell-array
		output = {'Ki_PI3K_PI3K_a_EGFR_p_OSM', 'Ki_PKC_PKC_a_EGFR_p_OSM', 'Ki_RAS_RAS_a_EGFR_p_OSM', 'Ki_TNFR1_TNFR1_p_EGFR_p_OSM', 'Ki_syn_PTEN_NFkB', 'Vm_AKT_p_AKT', 'Vm_AP1_a_AP1', 'Vm_EGFR_p_EGFR', 'Vm_ERK_p_ERK', 'Vm_IKK_a_IKK', ...
			'Vm_JAK_a_JAK', 'Vm_PI3K_a_PI3K', 'Vm_PIP2_PIP3', 'Vm_PIP3_PIP2', 'Vm_PKC_a_PKC', 'Vm_RAS_a_RAS', 'Vm_STAT3_p_STAT3', 'Vm_TNFR1_a_TNFR1', 'Vm_TNFR1_p_TNFR1', 'Vm_mTORC1_a_mTORC1', ...
			'Vm_mTORC2_a_mTORC2', 'Vsyn_AURKAm', 'Vsyn_COX2m', 'Vsyn_EGFm', 'Vsyn_IKBm', 'Vsyn_IL6m', 'Vsyn_Myc', 'Vsyn_NFkB', 'Vsyn_PGE2', 'Vsyn_PTEN', ...
			'Vsyn_TNFam', 'Vsyn_ZFP36', 'ka_IKB_NFkB_NFkBnIKB', 'kalpha_COX2m_NFkB_STAT3_p', 'kalpha_EGFm_NFkB_STAT3_p', 'kalpha_IKBm_NFkB_STAT3_p', 'kalpha_IL6m_NFkB_STAT3_p', 'kalpha_TNFam_NFkB_STAT3_p', 'kalpha_ZFP36_NFkB_STAT3_p', 'kc_AKT_AKT_p_PI3K_a', ...
			'kc_AKT_AKT_p_mTORC2_a', 'kc_AP1_AP1_a_ERK_p', 'kc_EGFR_EGFR_p_EGF', 'kc_ERK_ERK_p_RAS_a', 'kc_IKK_IKK_a_AKT_p', 'kc_IKK_IKK_a_PKC_a', 'kc_IKK_IKK_a_TNFR1_a', 'kc_JAK_JAK_a_EGFR_p', 'kc_JAK_JAK_a_IL6', 'kc_PI3K_PI3K_a_EGFR_p', ...
			'kc_PIP2_PIP3_PI3K_a', 'kc_PIP3_PIP2_PTEN', 'kc_PKC_PKC_a_EGFR_p', 'kc_PKC_PKC_a_PGE2', 'kc_RAS_RAS_a_EGFR_p', 'kc_STAT3_STAT3_p_JAK_a', 'kc_TNFR1_TNFR1_a_TNFa', 'kc_TNFR1_TNFR1_p_EGFR_p', 'kc_mTORC1_mTORC1_a_AKT_p', 'kc_mTORC2_mTORC2_a_IKK_a', ...
			'kd_NFkBnIKB_IKB_NFkB', 'kdeg_AURKA', 'kdeg_AURKAm', 'kdeg_COX2', 'kdeg_COX2m', 'kdeg_EGF', 'kdeg_EGFm', 'kdeg_IKB', 'kdeg_IKB_AURKA', 'kdeg_IKB_IKK_a', ...
			'kdeg_IKBm', 'kdeg_IL6', 'kdeg_IL6m', 'kdeg_IL6m_TTP', 'kdeg_Myc', 'kdeg_NFkB', 'kdeg_NFkB_TTP', 'kdeg_PGE2', 'kdeg_PTEN', 'kdeg_TNFa', ...
			'kdeg_TNFam', 'kdeg_TNFam_TTP', 'kdeg_TTP', 'kdeg_ZFP36', 'ksyn_AURKA_AURKAm', 'ksyn_AURKAm_Myc', 'ksyn_COX2_COX2m', 'ksyn_COX2m_NFkB', 'ksyn_EGF_EGFm', 'ksyn_EGFm_AP1_a', ...
			'ksyn_EGFm_NFkB', 'ksyn_IKB_IKBm', 'ksyn_IKBm_NFkB', 'ksyn_IL6_IL6m', 'ksyn_IL6m_NFkB', 'ksyn_Myc_mTORC1_a', 'ksyn_PGE2_COX2', 'ksyn_TNFa_TNFam', 'ksyn_TNFam_NFkB', 'ksyn_TTP_ZFP36', ...
			'ksyn_ZFP36_NFkB', 'OSM_0', 'OSM_on'};
	elseif strcmp(varargin{1},'parametervalues'),
		% Return parameter values in column vector
		output = [0.1, 0.1, 0.1, 0.1, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, ...
			0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, ...
			0.1, 0.1, 0.1, 0.1, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, ...
			0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, ...
			0.05, 100, 10000];
	elseif strcmp(varargin{1},'variablenames'),
		% Return variable names in cell-array
		output = {'AKT_tot', 'AP1_tot', 'EGFR_tot', 'ERK_tot', 'IKB_tot', 'IKK_tot', 'JAK_tot', 'mTORC1_tot', 'mTORC2_tot', 'NFkB_tot', ...
			'PI3K_tot', 'PIP_tot', 'PKC_tot', 'RAS_tot', 'STAT3_tot', 'TNFR1_tot', 'OSM'};
	elseif strcmp(varargin{1},'variableformulas'),
		% Return variable formulas in cell-array
		output = {'AKT+AKT_p', 'AP1+AP1_a', 'EGFR+EGFR_p', 'ERK+ERK_p', 'IKB+NFkBnIKB', 'IKK+IKK_a', 'JAK+JAK_a', 'mTORC1+mTORC1_a', 'mTORC2+mTORC2_a', 'NFkB+NFkBnIKB', ...
			'PI3K+PI3K_a', 'PIP2+PIP3', 'PKC+PKC_a', 'RAS+RAS_a', 'STAT3+STAT3_p', 'TNFR1+TNFR1_a+TNFR1_p', 'OSM_0*piecewiseIQM(1,ge(time,OSM_on),0)'};
	else
		error('Wrong input arguments! Please read the help text to the ODE file.');
	end
	output = output(:);
	return
elseif nargin == 2,
	time = varargin{1};
	statevector = varargin{2};
elseif nargin == 3,
	time = varargin{1};
	statevector = varargin{2};
	parameterValuesNew = varargin{3};
	if length(parameterValuesNew) ~= 103,
		parameterValuesNew = [];
	end
elseif nargin == 4,
	time = varargin{1};
	statevector = varargin{2};
	parameterValuesNew = varargin{4};
else
	error('Wrong input arguments! Please read the help text to the ODE file.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AKT = statevector(1);
AKT_p = statevector(2);
AP1 = statevector(3);
AP1_a = statevector(4);
AURKA = statevector(5);
AURKAm = statevector(6);
COX2 = statevector(7);
COX2m = statevector(8);
EGF = statevector(9);
EGFR = statevector(10);
EGFR_p = statevector(11);
EGFm = statevector(12);
ERK = statevector(13);
ERK_p = statevector(14);
IKB = statevector(15);
IKBm = statevector(16);
IKK = statevector(17);
IKK_a = statevector(18);
IL6 = statevector(19);
IL6m = statevector(20);
JAK = statevector(21);
JAK_a = statevector(22);
Myc = statevector(23);
NFkB = statevector(24);
NFkBnIKB = statevector(25);
PGE2 = statevector(26);
PI3K = statevector(27);
PI3K_a = statevector(28);
PIP2 = statevector(29);
PIP3 = statevector(30);
PKC = statevector(31);
PKC_a = statevector(32);
PTEN = statevector(33);
RAS = statevector(34);
RAS_a = statevector(35);
STAT3 = statevector(36);
STAT3_p = statevector(37);
TNFR1 = statevector(38);
TNFR1_a = statevector(39);
TNFR1_p = statevector(40);
TNFa = statevector(41);
TNFam = statevector(42);
TTP = statevector(43);
ZFP36 = statevector(44);
mTORC1 = statevector(45);
mTORC1_a = statevector(46);
mTORC2 = statevector(47);
mTORC2_a = statevector(48);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(parameterValuesNew),
	Ki_PI3K_PI3K_a_EGFR_p_OSM = 0.1;
	Ki_PKC_PKC_a_EGFR_p_OSM = 0.1;
	Ki_RAS_RAS_a_EGFR_p_OSM = 0.1;
	Ki_TNFR1_TNFR1_p_EGFR_p_OSM = 0.1;
	Ki_syn_PTEN_NFkB = 0.1;
	Vm_AKT_p_AKT = 0.01;
	Vm_AP1_a_AP1 = 0.01;
	Vm_EGFR_p_EGFR = 0.01;
	Vm_ERK_p_ERK = 0.01;
	Vm_IKK_a_IKK = 0.01;
	Vm_JAK_a_JAK = 0.01;
	Vm_PI3K_a_PI3K = 0.01;
	Vm_PIP2_PIP3 = 0.01;
	Vm_PIP3_PIP2 = 0.01;
	Vm_PKC_a_PKC = 0.01;
	Vm_RAS_a_RAS = 0.01;
	Vm_STAT3_p_STAT3 = 0.01;
	Vm_TNFR1_a_TNFR1 = 0.01;
	Vm_TNFR1_p_TNFR1 = 0.01;
	Vm_mTORC1_a_mTORC1 = 0.01;
	Vm_mTORC2_a_mTORC2 = 0.01;
	Vsyn_AURKAm = 0.01;
	Vsyn_COX2m = 0.01;
	Vsyn_EGFm = 0.01;
	Vsyn_IKBm = 0.01;
	Vsyn_IL6m = 0.01;
	Vsyn_Myc = 0.01;
	Vsyn_NFkB = 0.01;
	Vsyn_PGE2 = 0.01;
	Vsyn_PTEN = 0.01;
	Vsyn_TNFam = 0.01;
	Vsyn_ZFP36 = 0.01;
	ka_IKB_NFkB_NFkBnIKB = 0.01;
	kalpha_COX2m_NFkB_STAT3_p = 0.01;
	kalpha_EGFm_NFkB_STAT3_p = 0.01;
	kalpha_IKBm_NFkB_STAT3_p = 0.01;
	kalpha_IL6m_NFkB_STAT3_p = 0.01;
	kalpha_TNFam_NFkB_STAT3_p = 0.01;
	kalpha_ZFP36_NFkB_STAT3_p = 0.01;
	kc_AKT_AKT_p_PI3K_a = 0.01;
	kc_AKT_AKT_p_mTORC2_a = 0.01;
	kc_AP1_AP1_a_ERK_p = 0.01;
	kc_EGFR_EGFR_p_EGF = 0.01;
	kc_ERK_ERK_p_RAS_a = 0.01;
	kc_IKK_IKK_a_AKT_p = 0.01;
	kc_IKK_IKK_a_PKC_a = 0.01;
	kc_IKK_IKK_a_TNFR1_a = 0.01;
	kc_JAK_JAK_a_EGFR_p = 0.01;
	kc_JAK_JAK_a_IL6 = 0.01;
	kc_PI3K_PI3K_a_EGFR_p = 0.01;
	kc_PIP2_PIP3_PI3K_a = 0.01;
	kc_PIP3_PIP2_PTEN = 0.01;
	kc_PKC_PKC_a_EGFR_p = 0.01;
	kc_PKC_PKC_a_PGE2 = 0.01;
	kc_RAS_RAS_a_EGFR_p = 0.01;
	kc_STAT3_STAT3_p_JAK_a = 0.01;
	kc_TNFR1_TNFR1_a_TNFa = 0.01;
	kc_TNFR1_TNFR1_p_EGFR_p = 0.01;
	kc_mTORC1_mTORC1_a_AKT_p = 0.01;
	kc_mTORC2_mTORC2_a_IKK_a = 0.01;
	kd_NFkBnIKB_IKB_NFkB = 0.1;
	kdeg_AURKA = 0.1;
	kdeg_AURKAm = 0.1;
	kdeg_COX2 = 0.1;
	kdeg_COX2m = 0.1;
	kdeg_EGF = 0.1;
	kdeg_EGFm = 0.1;
	kdeg_IKB = 0.1;
	kdeg_IKB_AURKA = 0.1;
	kdeg_IKB_IKK_a = 0.1;
	kdeg_IKBm = 0.1;
	kdeg_IL6 = 0.1;
	kdeg_IL6m = 0.1;
	kdeg_IL6m_TTP = 0.1;
	kdeg_Myc = 0.1;
	kdeg_NFkB = 0.1;
	kdeg_NFkB_TTP = 0.1;
	kdeg_PGE2 = 0.1;
	kdeg_PTEN = 0.1;
	kdeg_TNFa = 0.1;
	kdeg_TNFam = 0.1;
	kdeg_TNFam_TTP = 0.1;
	kdeg_TTP = 0.1;
	kdeg_ZFP36 = 0.1;
	ksyn_AURKA_AURKAm = 0.05;
	ksyn_AURKAm_Myc = 0.05;
	ksyn_COX2_COX2m = 0.05;
	ksyn_COX2m_NFkB = 0.05;
	ksyn_EGF_EGFm = 0.05;
	ksyn_EGFm_AP1_a = 0.05;
	ksyn_EGFm_NFkB = 0.05;
	ksyn_IKB_IKBm = 0.05;
	ksyn_IKBm_NFkB = 0.05;
	ksyn_IL6_IL6m = 0.05;
	ksyn_IL6m_NFkB = 0.05;
	ksyn_Myc_mTORC1_a = 0.05;
	ksyn_PGE2_COX2 = 0.05;
	ksyn_TNFa_TNFam = 0.05;
	ksyn_TNFam_NFkB = 0.05;
	ksyn_TTP_ZFP36 = 0.05;
	ksyn_ZFP36_NFkB = 0.05;
	OSM_0 = 100;
	OSM_on = 10000;
else
	Ki_PI3K_PI3K_a_EGFR_p_OSM = parameterValuesNew(1);
	Ki_PKC_PKC_a_EGFR_p_OSM = parameterValuesNew(2);
	Ki_RAS_RAS_a_EGFR_p_OSM = parameterValuesNew(3);
	Ki_TNFR1_TNFR1_p_EGFR_p_OSM = parameterValuesNew(4);
	Ki_syn_PTEN_NFkB = parameterValuesNew(5);
	Vm_AKT_p_AKT = parameterValuesNew(6);
	Vm_AP1_a_AP1 = parameterValuesNew(7);
	Vm_EGFR_p_EGFR = parameterValuesNew(8);
	Vm_ERK_p_ERK = parameterValuesNew(9);
	Vm_IKK_a_IKK = parameterValuesNew(10);
	Vm_JAK_a_JAK = parameterValuesNew(11);
	Vm_PI3K_a_PI3K = parameterValuesNew(12);
	Vm_PIP2_PIP3 = parameterValuesNew(13);
	Vm_PIP3_PIP2 = parameterValuesNew(14);
	Vm_PKC_a_PKC = parameterValuesNew(15);
	Vm_RAS_a_RAS = parameterValuesNew(16);
	Vm_STAT3_p_STAT3 = parameterValuesNew(17);
	Vm_TNFR1_a_TNFR1 = parameterValuesNew(18);
	Vm_TNFR1_p_TNFR1 = parameterValuesNew(19);
	Vm_mTORC1_a_mTORC1 = parameterValuesNew(20);
	Vm_mTORC2_a_mTORC2 = parameterValuesNew(21);
	Vsyn_AURKAm = parameterValuesNew(22);
	Vsyn_COX2m = parameterValuesNew(23);
	Vsyn_EGFm = parameterValuesNew(24);
	Vsyn_IKBm = parameterValuesNew(25);
	Vsyn_IL6m = parameterValuesNew(26);
	Vsyn_Myc = parameterValuesNew(27);
	Vsyn_NFkB = parameterValuesNew(28);
	Vsyn_PGE2 = parameterValuesNew(29);
	Vsyn_PTEN = parameterValuesNew(30);
	Vsyn_TNFam = parameterValuesNew(31);
	Vsyn_ZFP36 = parameterValuesNew(32);
	ka_IKB_NFkB_NFkBnIKB = parameterValuesNew(33);
	kalpha_COX2m_NFkB_STAT3_p = parameterValuesNew(34);
	kalpha_EGFm_NFkB_STAT3_p = parameterValuesNew(35);
	kalpha_IKBm_NFkB_STAT3_p = parameterValuesNew(36);
	kalpha_IL6m_NFkB_STAT3_p = parameterValuesNew(37);
	kalpha_TNFam_NFkB_STAT3_p = parameterValuesNew(38);
	kalpha_ZFP36_NFkB_STAT3_p = parameterValuesNew(39);
	kc_AKT_AKT_p_PI3K_a = parameterValuesNew(40);
	kc_AKT_AKT_p_mTORC2_a = parameterValuesNew(41);
	kc_AP1_AP1_a_ERK_p = parameterValuesNew(42);
	kc_EGFR_EGFR_p_EGF = parameterValuesNew(43);
	kc_ERK_ERK_p_RAS_a = parameterValuesNew(44);
	kc_IKK_IKK_a_AKT_p = parameterValuesNew(45);
	kc_IKK_IKK_a_PKC_a = parameterValuesNew(46);
	kc_IKK_IKK_a_TNFR1_a = parameterValuesNew(47);
	kc_JAK_JAK_a_EGFR_p = parameterValuesNew(48);
	kc_JAK_JAK_a_IL6 = parameterValuesNew(49);
	kc_PI3K_PI3K_a_EGFR_p = parameterValuesNew(50);
	kc_PIP2_PIP3_PI3K_a = parameterValuesNew(51);
	kc_PIP3_PIP2_PTEN = parameterValuesNew(52);
	kc_PKC_PKC_a_EGFR_p = parameterValuesNew(53);
	kc_PKC_PKC_a_PGE2 = parameterValuesNew(54);
	kc_RAS_RAS_a_EGFR_p = parameterValuesNew(55);
	kc_STAT3_STAT3_p_JAK_a = parameterValuesNew(56);
	kc_TNFR1_TNFR1_a_TNFa = parameterValuesNew(57);
	kc_TNFR1_TNFR1_p_EGFR_p = parameterValuesNew(58);
	kc_mTORC1_mTORC1_a_AKT_p = parameterValuesNew(59);
	kc_mTORC2_mTORC2_a_IKK_a = parameterValuesNew(60);
	kd_NFkBnIKB_IKB_NFkB = parameterValuesNew(61);
	kdeg_AURKA = parameterValuesNew(62);
	kdeg_AURKAm = parameterValuesNew(63);
	kdeg_COX2 = parameterValuesNew(64);
	kdeg_COX2m = parameterValuesNew(65);
	kdeg_EGF = parameterValuesNew(66);
	kdeg_EGFm = parameterValuesNew(67);
	kdeg_IKB = parameterValuesNew(68);
	kdeg_IKB_AURKA = parameterValuesNew(69);
	kdeg_IKB_IKK_a = parameterValuesNew(70);
	kdeg_IKBm = parameterValuesNew(71);
	kdeg_IL6 = parameterValuesNew(72);
	kdeg_IL6m = parameterValuesNew(73);
	kdeg_IL6m_TTP = parameterValuesNew(74);
	kdeg_Myc = parameterValuesNew(75);
	kdeg_NFkB = parameterValuesNew(76);
	kdeg_NFkB_TTP = parameterValuesNew(77);
	kdeg_PGE2 = parameterValuesNew(78);
	kdeg_PTEN = parameterValuesNew(79);
	kdeg_TNFa = parameterValuesNew(80);
	kdeg_TNFam = parameterValuesNew(81);
	kdeg_TNFam_TTP = parameterValuesNew(82);
	kdeg_TTP = parameterValuesNew(83);
	kdeg_ZFP36 = parameterValuesNew(84);
	ksyn_AURKA_AURKAm = parameterValuesNew(85);
	ksyn_AURKAm_Myc = parameterValuesNew(86);
	ksyn_COX2_COX2m = parameterValuesNew(87);
	ksyn_COX2m_NFkB = parameterValuesNew(88);
	ksyn_EGF_EGFm = parameterValuesNew(89);
	ksyn_EGFm_AP1_a = parameterValuesNew(90);
	ksyn_EGFm_NFkB = parameterValuesNew(91);
	ksyn_IKB_IKBm = parameterValuesNew(92);
	ksyn_IKBm_NFkB = parameterValuesNew(93);
	ksyn_IL6_IL6m = parameterValuesNew(94);
	ksyn_IL6m_NFkB = parameterValuesNew(95);
	ksyn_Myc_mTORC1_a = parameterValuesNew(96);
	ksyn_PGE2_COX2 = parameterValuesNew(97);
	ksyn_TNFa_TNFam = parameterValuesNew(98);
	ksyn_TNFam_NFkB = parameterValuesNew(99);
	ksyn_TTP_ZFP36 = parameterValuesNew(100);
	ksyn_ZFP36_NFkB = parameterValuesNew(101);
	OSM_0 = parameterValuesNew(102);
	OSM_on = parameterValuesNew(103);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AKT_tot = AKT+AKT_p;
AP1_tot = AP1+AP1_a;
EGFR_tot = EGFR+EGFR_p;
ERK_tot = ERK+ERK_p;
IKB_tot = IKB+NFkBnIKB;
IKK_tot = IKK+IKK_a;
JAK_tot = JAK+JAK_a;
mTORC1_tot = mTORC1+mTORC1_a;
mTORC2_tot = mTORC2+mTORC2_a;
NFkB_tot = NFkB+NFkBnIKB;
PI3K_tot = PI3K+PI3K_a;
PIP_tot = PIP2+PIP3;
PKC_tot = PKC+PKC_a;
RAS_tot = RAS+RAS_a;
STAT3_tot = STAT3+STAT3_p;
TNFR1_tot = TNFR1+TNFR1_a+TNFR1_p;
OSM = OSM_0*piecewiseIQM(1,ge(time,OSM_on),0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REACTION KINETICS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R1 = (kc_AKT_AKT_p_PI3K_a*PI3K_a+kc_AKT_AKT_p_mTORC2_a*mTORC2_a)*AKT-Vm_AKT_p_AKT*AKT_p;
R2 = (kc_AP1_AP1_a_ERK_p*ERK_p)*AP1-Vm_AP1_a_AP1*AP1_a;
R3 = kdeg_AURKA*AURKA;
R4 = (ksyn_AURKA_AURKAm*AURKAm);
R5 = kdeg_AURKAm*AURKAm;
R6 = Vsyn_AURKAm;
R7 = (ksyn_AURKAm_Myc*Myc);
R8 = kdeg_COX2*COX2;
R9 = (ksyn_COX2_COX2m*COX2m);
R10 = kdeg_COX2m*COX2m;
R11 = Vsyn_COX2m;
R12 = (ksyn_COX2m_NFkB*NFkB*(1+kalpha_COX2m_NFkB_STAT3_p*STAT3_p));
R13 = kdeg_EGF*EGF;
R14 = (ksyn_EGF_EGFm*EGFm);
R15 = kdeg_EGFm*EGFm;
R16 = Vsyn_EGFm;
R17 = (ksyn_EGFm_NFkB*NFkB*(1+kalpha_EGFm_NFkB_STAT3_p*STAT3_p));
R18 = (ksyn_EGFm_AP1_a*AP1_a);
R19 = (kc_EGFR_EGFR_p_EGF*EGF)*EGFR-Vm_EGFR_p_EGFR*EGFR_p;
R20 = (kc_ERK_ERK_p_RAS_a*RAS_a)*ERK-Vm_ERK_p_ERK*ERK_p;
R21 = (ka_IKB_NFkB_NFkBnIKB*IKB*NFkB)-kd_NFkBnIKB_IKB_NFkB*NFkBnIKB;
R22 = kdeg_IKB*IKB;
R23 = (kdeg_IKB_IKK_a*IKB*IKK_a+kdeg_IKB_AURKA*IKB*AURKA);
R24 = (ksyn_IKB_IKBm*IKBm);
R25 = kdeg_IKBm*IKBm;
R26 = Vsyn_IKBm;
R27 = (ksyn_IKBm_NFkB*NFkB*(1+kalpha_IKBm_NFkB_STAT3_p*STAT3_p));
R28 = (kc_IKK_IKK_a_TNFR1_a*TNFR1_a+kc_IKK_IKK_a_PKC_a*PKC_a+kc_IKK_IKK_a_AKT_p*AKT_p)*IKK-Vm_IKK_a_IKK*IKK_a;
R29 = kdeg_IL6*IL6;
R30 = (ksyn_IL6_IL6m*IL6m);
R31 = kdeg_IL6m*IL6m;
R32 = (kdeg_IL6m_TTP*IL6m*TTP);
R33 = Vsyn_IL6m;
R34 = (ksyn_IL6m_NFkB*NFkB*(1+kalpha_IL6m_NFkB_STAT3_p*STAT3_p));
R35 = (kc_JAK_JAK_a_IL6*IL6+kc_JAK_JAK_a_EGFR_p*EGFR_p)*JAK-Vm_JAK_a_JAK*JAK_a;
R36 = (kc_mTORC1_mTORC1_a_AKT_p*AKT_p)*mTORC1-Vm_mTORC1_a_mTORC1*mTORC1_a;
R37 = (kc_mTORC2_mTORC2_a_IKK_a*IKK_a)*mTORC2-Vm_mTORC2_a_mTORC2*mTORC2_a;
R38 = kdeg_Myc*Myc;
R39 = Vsyn_Myc;
R40 = (ksyn_Myc_mTORC1_a*mTORC1_a);
R41 = Vsyn_NFkB;
R42 = kdeg_NFkB*NFkB;
R43 = (kdeg_NFkB_TTP*NFkB*TTP);
R44 = kdeg_PGE2*PGE2;
R45 = Vsyn_PGE2;
R46 = (ksyn_PGE2_COX2*COX2);
R47 = (kc_PI3K_PI3K_a_EGFR_p*EGFR_p)*PI3K/((1+Ki_PI3K_PI3K_a_EGFR_p_OSM*OSM))-Vm_PI3K_a_PI3K*PI3K_a;
R48 = (kc_PIP2_PIP3_PI3K_a*PI3K_a)*PIP2-Vm_PIP3_PIP2*PIP3;
R49 = (kc_PIP3_PIP2_PTEN*PTEN)*PIP3-Vm_PIP2_PIP3*PIP2;
R50 = (kc_PKC_PKC_a_EGFR_p*EGFR_p)*PKC/((1+Ki_PKC_PKC_a_EGFR_p_OSM*OSM))-Vm_PKC_a_PKC*PKC_a;
R51 = (kc_PKC_PKC_a_PGE2*PGE2)*PKC-Vm_PKC_a_PKC*PKC_a;
R52 = kdeg_PTEN*PTEN;
R53 = Vsyn_PTEN/((1+Ki_syn_PTEN_NFkB*NFkB));
R54 = (kc_RAS_RAS_a_EGFR_p*EGFR_p)*RAS/((1+Ki_RAS_RAS_a_EGFR_p_OSM*OSM))-Vm_RAS_a_RAS*RAS_a;
R55 = (kc_STAT3_STAT3_p_JAK_a*JAK_a)*STAT3-Vm_STAT3_p_STAT3*STAT3_p;
R56 = kdeg_TNFa*TNFa;
R57 = (ksyn_TNFa_TNFam*TNFam);
R58 = kdeg_TNFam*TNFam;
R59 = (kdeg_TNFam_TTP*TNFam*TTP);
R60 = Vsyn_TNFam;
R61 = (ksyn_TNFam_NFkB*NFkB*(1+kalpha_TNFam_NFkB_STAT3_p*STAT3_p));
R62 = (kc_TNFR1_TNFR1_a_TNFa*TNFa)*TNFR1-Vm_TNFR1_a_TNFR1*TNFR1_a;
R63 = (kc_TNFR1_TNFR1_p_EGFR_p*EGFR_p)*TNFR1/((1+Ki_TNFR1_TNFR1_p_EGFR_p_OSM*OSM))-Vm_TNFR1_p_TNFR1*TNFR1_p;
R64 = kdeg_TTP*TTP;
R65 = (ksyn_TTP_ZFP36*ZFP36);
R66 = kdeg_ZFP36*ZFP36;
R67 = Vsyn_ZFP36;
R68 = (ksyn_ZFP36_NFkB*NFkB*(1+kalpha_ZFP36_NFkB_STAT3_p*STAT3_p));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIFFERENTIAL EQUATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AKT_dot = -R1;
AKT_p_dot = +R1;
AP1_dot = -R2;
AP1_a_dot = +R2;
AURKA_dot = -R3+R4;
AURKAm_dot = -R5+R6+R7;
COX2_dot = -R8+R9;
COX2m_dot = -R10+R11+R12;
EGF_dot = -R13+R14;
EGFR_dot = -R19;
EGFR_p_dot = +R19;
EGFm_dot = -R15+R16+R17+R18;
ERK_dot = -R20;
ERK_p_dot = +R20;
IKB_dot = -R21-R22-R23+R24;
IKBm_dot = -R25+R26+R27;
IKK_dot = -R28;
IKK_a_dot = +R28;
IL6_dot = -R29+R30;
IL6m_dot = -R31-R32+R33+R34;
JAK_dot = -R35;
JAK_a_dot = +R35;
Myc_dot = -R38+R39+R40;
NFkB_dot = -R21+R41-R42-R43;
NFkBnIKB_dot = +R21;
PGE2_dot = -R44+R45+R46;
PI3K_dot = -R47;
PI3K_a_dot = +R47;
PIP2_dot = -R48+R49;
PIP3_dot = +R48-R49;
PKC_dot = -R50-R51;
PKC_a_dot = +R50+R51;
PTEN_dot = -R52+R53;
RAS_dot = -R54;
RAS_a_dot = +R54;
STAT3_dot = -R55;
STAT3_p_dot = +R55;
TNFR1_dot = -R62-R63;
TNFR1_a_dot = +R62;
TNFR1_p_dot = +R63;
TNFa_dot = -R56+R57;
TNFam_dot = -R58-R59+R60+R61;
TTP_dot = -R64+R65;
ZFP36_dot = -R66+R67+R68;
mTORC1_dot = -R36;
mTORC1_a_dot = +R36;
mTORC2_dot = -R37;
mTORC2_a_dot = +R37;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RETURN VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE ODEs
output(1) = AKT_dot;
output(2) = AKT_p_dot;
output(3) = AP1_dot;
output(4) = AP1_a_dot;
output(5) = AURKA_dot;
output(6) = AURKAm_dot;
output(7) = COX2_dot;
output(8) = COX2m_dot;
output(9) = EGF_dot;
output(10) = EGFR_dot;
output(11) = EGFR_p_dot;
output(12) = EGFm_dot;
output(13) = ERK_dot;
output(14) = ERK_p_dot;
output(15) = IKB_dot;
output(16) = IKBm_dot;
output(17) = IKK_dot;
output(18) = IKK_a_dot;
output(19) = IL6_dot;
output(20) = IL6m_dot;
output(21) = JAK_dot;
output(22) = JAK_a_dot;
output(23) = Myc_dot;
output(24) = NFkB_dot;
output(25) = NFkBnIKB_dot;
output(26) = PGE2_dot;
output(27) = PI3K_dot;
output(28) = PI3K_a_dot;
output(29) = PIP2_dot;
output(30) = PIP3_dot;
output(31) = PKC_dot;
output(32) = PKC_a_dot;
output(33) = PTEN_dot;
output(34) = RAS_dot;
output(35) = RAS_a_dot;
output(36) = STAT3_dot;
output(37) = STAT3_p_dot;
output(38) = TNFR1_dot;
output(39) = TNFR1_a_dot;
output(40) = TNFR1_p_dot;
output(41) = TNFa_dot;
output(42) = TNFam_dot;
output(43) = TTP_dot;
output(44) = ZFP36_dot;
output(45) = mTORC1_dot;
output(46) = mTORC1_a_dot;
output(47) = mTORC2_dot;
output(48) = mTORC2_a_dot;
% return a column vector 
output = output(:);
return


