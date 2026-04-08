function [output] = FGFR2_model_ver_02_ode(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FGFR2_model_ver_02
% Generated: 05-Dec-2023 13:08:38
% 
% [output] = FGFR2_model_ver_02_ode() => output = initial conditions in column vector
% [output] = FGFR2_model_ver_02_ode('states') => output = state names in cell-array
% [output] = FGFR2_model_ver_02_ode('algebraic') => output = algebraic variable names in cell-array
% [output] = FGFR2_model_ver_02_ode('parameters') => output = parameter names in cell-array
% [output] = FGFR2_model_ver_02_ode('parametervalues') => output = parameter values in column vector
% [output] = FGFR2_model_ver_02_ode('variablenames') => output = variable names in cell-array
% [output] = FGFR2_model_ver_02_ode('variableformulas') => output = variable formulas in cell-array
% [output] = FGFR2_model_ver_02_ode(time,statevector) => output = time derivatives in column vector
% 
% State names and ordering:
% 
% statevector(1): AKT
% statevector(2): CDK2
% statevector(3): CDK46
% statevector(4): E2F
% statevector(5): E2FuRB
% statevector(6): ERBB3
% statevector(7): ERK
% statevector(8): FGFR2
% statevector(9): FOXO3
% statevector(10): FRS2
% statevector(11): IGF1R
% statevector(12): IRS
% statevector(13): MEK
% statevector(14): MYC
% statevector(15): PI3K
% statevector(16): RAF
% statevector(17): RAS
% statevector(18): RB
% statevector(19): RBSM
% statevector(20): S6K
% statevector(21): aPI3K
% statevector(22): aRAF
% statevector(23): aRAS
% statevector(24): aRBSM
% statevector(25): amTORC1
% statevector(26): amTORC2
% statevector(27): mTORC1
% statevector(28): mTORC2
% statevector(29): pAKT
% statevector(30): pCDK2
% statevector(31): pCDK46
% statevector(32): pERBB3
% statevector(33): pERK
% statevector(34): pFGFR2
% statevector(35): pFOXO3
% statevector(36): pFRS2
% statevector(37): pIGF1R
% statevector(38): pIRS
% statevector(39): pMEK
% statevector(40): pRB
% statevector(41): pS6K
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
		0];
	output = output(:);
	return
elseif nargin == 1,
	if strcmp(varargin{1},'states'),
		% Return state names in cell-array
		output = {'AKT', 'CDK2', 'CDK46', 'E2F', 'E2FuRB', 'ERBB3', 'ERK', 'FGFR2', 'FOXO3', 'FRS2', ...
			'IGF1R', 'IRS', 'MEK', 'MYC', 'PI3K', 'RAF', 'RAS', 'RB', 'RBSM', 'S6K', ...
			'aPI3K', 'aRAF', 'aRAS', 'aRBSM', 'amTORC1', 'amTORC2', 'mTORC1', 'mTORC2', 'pAKT', 'pCDK2', ...
			'pCDK46', 'pERBB3', 'pERK', 'pFGFR2', 'pFOXO3', 'pFRS2', 'pIGF1R', 'pIRS', 'pMEK', 'pRB', ...
			'pS6K'};
	elseif strcmp(varargin{1},'algebraic'),
		% Return algebraic variable names in cell-array
		output = {};
	elseif strcmp(varargin{1},'parameters'),
		% Return parameter names in cell-array
		output = {'Ki_AKT_pAKT_aPI3K_AKTi', 'Ki_E2F_RB_E2FuRB_MYC', 'Ki_ERBB3_pERBB3_HRG_pERK', 'Ki_FGFR2_pFGFR2_FGF_FGFR2i', 'Ki_IRS_pIRS_pIGF1R_pS6K', 'Ki_MEK_pMEK_aRAF_MEKi', 'Ki_PI3K_aPI3K_pFRS2_PI3Ki', 'Ki_PI3K_aPI3K_pFRS2_pERK', 'Ki_PI3K_aPI3K_pIRS_PI3Ki', 'Ki_RAF_aRAF_aRAS_pAKT', ...
			'Ki_RAS_aRAS_pFRS2_pERK', 'Ki_RBSM_aRBSM_pS6K_RBSMi', 'Ki_mTORC2_amTORC2_aPI3K_pRB', 'Km_MYC_aRBSM', 'Vm_aPI3K_PI3K', 'Vm_aRAF_RAF', 'Vm_aRAS_RAS', 'Vm_aRBSM_RBSM', 'Vm_amTORC1_mTORC1', 'Vm_amTORC2_mTORC2', ...
			'Vm_pAKT_AKT', 'Vm_pCDK2_CDK2', 'Vm_pCDK46_CDK46', 'Vm_pERBB3_ERBB3', 'Vm_pERK_ERK', 'Vm_pFGFR2_FGFR2', 'Vm_pFOXO3_FOXO3', 'Vm_pFRS2_FRS2', 'Vm_pIGF1R_IGF1R', 'Vm_pIRS_IRS', ...
			'Vm_pMEK_MEK', 'Vm_pRB_RB', 'Vm_pS6K_S6K', 'Vsyn_MYC', 'ka_E2F_RB_E2FuRB', 'kc_AKT_pAKT_aPI3K', 'kc_AKT_pAKT_amTORC2', 'kc_CDK2_pCDK2_E2F', 'kc_CDK46_pCDK46_MYC', 'kc_CDK46_pCDK46_aRBSM', ...
			'kc_ERBB3_pERBB3_FOXO3', 'kc_ERBB3_pERBB3_HRG', 'kc_ERBB3_pERBB3_pFGFR2', 'kc_ERK_pERK_pMEK', 'kc_FGFR2_pFGFR2_FGF', 'kc_FGFR2_pFGFR2_FOXO3', 'kc_FOXO3_pFOXO3_pAKT', 'kc_FRS2_pFRS2_pFGFR2', 'kc_IGF1R_pIGF1R_FOXO3', 'kc_IGF1R_pIGF1R_IGF', ...
			'kc_IRS_pIRS_pIGF1R', 'kc_MEK_pMEK_aRAF', 'kc_PI3K_aPI3K_pERBB3', 'kc_PI3K_aPI3K_pFRS2', 'kc_PI3K_aPI3K_pIRS', 'kc_RAF_aRAF_aRAS', 'kc_RAS_aRAS_pERBB3', 'kc_RAS_aRAS_pFRS2', 'kc_RBSM_aRBSM_MYC', 'kc_RBSM_aRBSM_amTORC1', ...
			'kc_RBSM_aRBSM_pERK', 'kc_RBSM_aRBSM_pS6K', 'kc_RB_pRB_pCDK2', 'kc_RB_pRB_pCDK46', 'kc_S6K_pS6K_amTORC1', 'kc_mTORC1_amTORC1_pAKT', 'kc_mTORC1_amTORC1_pCDK46', 'kc_mTORC2_amTORC2_aPI3K', 'kc_pFGFR2_FGFR2_pERK', 'kd_E2FuRB_E2F_RB', ...
			'kdeg_MYC', 'ksyn_MYC_aRBSM', 'IGF_0', 'IGF_on', 'FGF_0', 'FGF_on', 'HRG_0', 'HRG_on', 'FGFR2i_0', 'FGFR2i_on', ...
			'PI3Ki_0', 'PI3Ki_on', 'AKTi_0', 'AKTi_on', 'MEKi_0', 'MEKi_on', 'RBSMi_0', 'RBSMi_on'};
	elseif strcmp(varargin{1},'parametervalues'),
		% Return parameter values in column vector
		output = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, ...
			0.1, 0.1, 0.1, 10, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, ...
			0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.1, ...
			0.01, 0.05, 10, 5000, 10, 5000, 10, 5000, 0, 10000, ...
			0, 10000, 0, 10000, 0, 10000, 0, 10000];
	elseif strcmp(varargin{1},'variablenames'),
		% Return variable names in cell-array
		output = {'FGFR2_tot', 'IGF1R_tot', 'ERBB3_tot', 'FRS2_tot', 'RAS_tot', 'RAF_tot', 'MEK_tot', 'ERK_tot', 'PI3K_tot', 'mTORC2_tot', ...
			'AKT_tot', 'mTORC1_tot', 'S6K_tot', 'IRS_tot', 'RBSM_tot', 'FOXO3_tot', 'MYC_tot', 'CDK46_tot', 'E2F_tot', 'RB_tot', ...
			'CDK2_tot', 'IGF', 'FGF', 'HRG', 'FGFR2i', 'PI3Ki', 'AKTi', 'MEKi', 'RBSMi'};
	elseif strcmp(varargin{1},'variableformulas'),
		% Return variable formulas in cell-array
		output = {'FGFR2+pFGFR2', 'IGF1R+pIGF1R', 'ERBB3+pERBB3', 'FRS2+pFRS2', 'RAS+aRAS', 'RAF+aRAF', 'MEK+pMEK', 'ERK+pERK', 'PI3K+aPI3K', 'mTORC2+amTORC2', ...
			'AKT+pAKT', 'mTORC1+amTORC1', 'S6K+pS6K', 'IRS+pIRS', 'RBSM+aRBSM', 'FOXO3+pFOXO3', 'MYC', 'CDK46+pCDK46', 'E2F+E2FuRB', 'RB+E2FuRB+pRB', ...
			'CDK2+pCDK2', 'IGF_0*piecewiseIQM(1,ge(time,IGF_on),0)', 'FGF_0*piecewiseIQM(1,ge(time,FGF_on),0)', 'HRG_0*piecewiseIQM(1,ge(time,HRG_on),0)', 'FGFR2i_0*piecewiseIQM(1,ge(time,FGFR2i_on),0)', 'PI3Ki_0*piecewiseIQM(1,ge(time,PI3Ki_on),0)', 'AKTi_0*piecewiseIQM(1,ge(time,AKTi_on),0)', 'MEKi_0*piecewiseIQM(1,ge(time,MEKi_on),0)', 'RBSMi_0*piecewiseIQM(1,ge(time,RBSMi_on),0)'};
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
	if length(parameterValuesNew) ~= 88,
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
CDK2 = statevector(2);
CDK46 = statevector(3);
E2F = statevector(4);
E2FuRB = statevector(5);
ERBB3 = statevector(6);
ERK = statevector(7);
FGFR2 = statevector(8);
FOXO3 = statevector(9);
FRS2 = statevector(10);
IGF1R = statevector(11);
IRS = statevector(12);
MEK = statevector(13);
MYC = statevector(14);
PI3K = statevector(15);
RAF = statevector(16);
RAS = statevector(17);
RB = statevector(18);
RBSM = statevector(19);
S6K = statevector(20);
aPI3K = statevector(21);
aRAF = statevector(22);
aRAS = statevector(23);
aRBSM = statevector(24);
amTORC1 = statevector(25);
amTORC2 = statevector(26);
mTORC1 = statevector(27);
mTORC2 = statevector(28);
pAKT = statevector(29);
pCDK2 = statevector(30);
pCDK46 = statevector(31);
pERBB3 = statevector(32);
pERK = statevector(33);
pFGFR2 = statevector(34);
pFOXO3 = statevector(35);
pFRS2 = statevector(36);
pIGF1R = statevector(37);
pIRS = statevector(38);
pMEK = statevector(39);
pRB = statevector(40);
pS6K = statevector(41);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(parameterValuesNew),
	Ki_AKT_pAKT_aPI3K_AKTi = 0.1;
	Ki_E2F_RB_E2FuRB_MYC = 0.1;
	Ki_ERBB3_pERBB3_HRG_pERK = 0.1;
	Ki_FGFR2_pFGFR2_FGF_FGFR2i = 0.1;
	Ki_IRS_pIRS_pIGF1R_pS6K = 0.1;
	Ki_MEK_pMEK_aRAF_MEKi = 0.1;
	Ki_PI3K_aPI3K_pFRS2_PI3Ki = 0.1;
	Ki_PI3K_aPI3K_pFRS2_pERK = 0.1;
	Ki_PI3K_aPI3K_pIRS_PI3Ki = 0.1;
	Ki_RAF_aRAF_aRAS_pAKT = 0.1;
	Ki_RAS_aRAS_pFRS2_pERK = 0.1;
	Ki_RBSM_aRBSM_pS6K_RBSMi = 0.1;
	Ki_mTORC2_amTORC2_aPI3K_pRB = 0.1;
	Km_MYC_aRBSM = 10;
	Vm_aPI3K_PI3K = 0.01;
	Vm_aRAF_RAF = 0.01;
	Vm_aRAS_RAS = 0.01;
	Vm_aRBSM_RBSM = 0.01;
	Vm_amTORC1_mTORC1 = 0.01;
	Vm_amTORC2_mTORC2 = 0.01;
	Vm_pAKT_AKT = 0.01;
	Vm_pCDK2_CDK2 = 0.01;
	Vm_pCDK46_CDK46 = 0.01;
	Vm_pERBB3_ERBB3 = 0.01;
	Vm_pERK_ERK = 0.01;
	Vm_pFGFR2_FGFR2 = 0.01;
	Vm_pFOXO3_FOXO3 = 0.01;
	Vm_pFRS2_FRS2 = 0.01;
	Vm_pIGF1R_IGF1R = 0.01;
	Vm_pIRS_IRS = 0.01;
	Vm_pMEK_MEK = 0.01;
	Vm_pRB_RB = 0.01;
	Vm_pS6K_S6K = 0.01;
	Vsyn_MYC = 0.01;
	ka_E2F_RB_E2FuRB = 0.01;
	kc_AKT_pAKT_aPI3K = 0.01;
	kc_AKT_pAKT_amTORC2 = 0.01;
	kc_CDK2_pCDK2_E2F = 0.01;
	kc_CDK46_pCDK46_MYC = 0.01;
	kc_CDK46_pCDK46_aRBSM = 0.01;
	kc_ERBB3_pERBB3_FOXO3 = 0.01;
	kc_ERBB3_pERBB3_HRG = 0.01;
	kc_ERBB3_pERBB3_pFGFR2 = 0.01;
	kc_ERK_pERK_pMEK = 0.01;
	kc_FGFR2_pFGFR2_FGF = 0.01;
	kc_FGFR2_pFGFR2_FOXO3 = 0.01;
	kc_FOXO3_pFOXO3_pAKT = 0.01;
	kc_FRS2_pFRS2_pFGFR2 = 0.01;
	kc_IGF1R_pIGF1R_FOXO3 = 0.01;
	kc_IGF1R_pIGF1R_IGF = 0.01;
	kc_IRS_pIRS_pIGF1R = 0.01;
	kc_MEK_pMEK_aRAF = 0.01;
	kc_PI3K_aPI3K_pERBB3 = 0.01;
	kc_PI3K_aPI3K_pFRS2 = 0.01;
	kc_PI3K_aPI3K_pIRS = 0.01;
	kc_RAF_aRAF_aRAS = 0.01;
	kc_RAS_aRAS_pERBB3 = 0.01;
	kc_RAS_aRAS_pFRS2 = 0.01;
	kc_RBSM_aRBSM_MYC = 0.01;
	kc_RBSM_aRBSM_amTORC1 = 0.01;
	kc_RBSM_aRBSM_pERK = 0.01;
	kc_RBSM_aRBSM_pS6K = 0.01;
	kc_RB_pRB_pCDK2 = 0.01;
	kc_RB_pRB_pCDK46 = 0.01;
	kc_S6K_pS6K_amTORC1 = 0.01;
	kc_mTORC1_amTORC1_pAKT = 0.01;
	kc_mTORC1_amTORC1_pCDK46 = 0.01;
	kc_mTORC2_amTORC2_aPI3K = 0.01;
	kc_pFGFR2_FGFR2_pERK = 0.01;
	kd_E2FuRB_E2F_RB = 0.1;
	kdeg_MYC = 0.01;
	ksyn_MYC_aRBSM = 0.05;
	IGF_0 = 10;
	IGF_on = 5000;
	FGF_0 = 10;
	FGF_on = 5000;
	HRG_0 = 10;
	HRG_on = 5000;
	FGFR2i_0 = 0;
	FGFR2i_on = 10000;
	PI3Ki_0 = 0;
	PI3Ki_on = 10000;
	AKTi_0 = 0;
	AKTi_on = 10000;
	MEKi_0 = 0;
	MEKi_on = 10000;
	RBSMi_0 = 0;
	RBSMi_on = 10000;
else
	Ki_AKT_pAKT_aPI3K_AKTi = parameterValuesNew(1);
	Ki_E2F_RB_E2FuRB_MYC = parameterValuesNew(2);
	Ki_ERBB3_pERBB3_HRG_pERK = parameterValuesNew(3);
	Ki_FGFR2_pFGFR2_FGF_FGFR2i = parameterValuesNew(4);
	Ki_IRS_pIRS_pIGF1R_pS6K = parameterValuesNew(5);
	Ki_MEK_pMEK_aRAF_MEKi = parameterValuesNew(6);
	Ki_PI3K_aPI3K_pFRS2_PI3Ki = parameterValuesNew(7);
	Ki_PI3K_aPI3K_pFRS2_pERK = parameterValuesNew(8);
	Ki_PI3K_aPI3K_pIRS_PI3Ki = parameterValuesNew(9);
	Ki_RAF_aRAF_aRAS_pAKT = parameterValuesNew(10);
	Ki_RAS_aRAS_pFRS2_pERK = parameterValuesNew(11);
	Ki_RBSM_aRBSM_pS6K_RBSMi = parameterValuesNew(12);
	Ki_mTORC2_amTORC2_aPI3K_pRB = parameterValuesNew(13);
	Km_MYC_aRBSM = parameterValuesNew(14);
	Vm_aPI3K_PI3K = parameterValuesNew(15);
	Vm_aRAF_RAF = parameterValuesNew(16);
	Vm_aRAS_RAS = parameterValuesNew(17);
	Vm_aRBSM_RBSM = parameterValuesNew(18);
	Vm_amTORC1_mTORC1 = parameterValuesNew(19);
	Vm_amTORC2_mTORC2 = parameterValuesNew(20);
	Vm_pAKT_AKT = parameterValuesNew(21);
	Vm_pCDK2_CDK2 = parameterValuesNew(22);
	Vm_pCDK46_CDK46 = parameterValuesNew(23);
	Vm_pERBB3_ERBB3 = parameterValuesNew(24);
	Vm_pERK_ERK = parameterValuesNew(25);
	Vm_pFGFR2_FGFR2 = parameterValuesNew(26);
	Vm_pFOXO3_FOXO3 = parameterValuesNew(27);
	Vm_pFRS2_FRS2 = parameterValuesNew(28);
	Vm_pIGF1R_IGF1R = parameterValuesNew(29);
	Vm_pIRS_IRS = parameterValuesNew(30);
	Vm_pMEK_MEK = parameterValuesNew(31);
	Vm_pRB_RB = parameterValuesNew(32);
	Vm_pS6K_S6K = parameterValuesNew(33);
	Vsyn_MYC = parameterValuesNew(34);
	ka_E2F_RB_E2FuRB = parameterValuesNew(35);
	kc_AKT_pAKT_aPI3K = parameterValuesNew(36);
	kc_AKT_pAKT_amTORC2 = parameterValuesNew(37);
	kc_CDK2_pCDK2_E2F = parameterValuesNew(38);
	kc_CDK46_pCDK46_MYC = parameterValuesNew(39);
	kc_CDK46_pCDK46_aRBSM = parameterValuesNew(40);
	kc_ERBB3_pERBB3_FOXO3 = parameterValuesNew(41);
	kc_ERBB3_pERBB3_HRG = parameterValuesNew(42);
	kc_ERBB3_pERBB3_pFGFR2 = parameterValuesNew(43);
	kc_ERK_pERK_pMEK = parameterValuesNew(44);
	kc_FGFR2_pFGFR2_FGF = parameterValuesNew(45);
	kc_FGFR2_pFGFR2_FOXO3 = parameterValuesNew(46);
	kc_FOXO3_pFOXO3_pAKT = parameterValuesNew(47);
	kc_FRS2_pFRS2_pFGFR2 = parameterValuesNew(48);
	kc_IGF1R_pIGF1R_FOXO3 = parameterValuesNew(49);
	kc_IGF1R_pIGF1R_IGF = parameterValuesNew(50);
	kc_IRS_pIRS_pIGF1R = parameterValuesNew(51);
	kc_MEK_pMEK_aRAF = parameterValuesNew(52);
	kc_PI3K_aPI3K_pERBB3 = parameterValuesNew(53);
	kc_PI3K_aPI3K_pFRS2 = parameterValuesNew(54);
	kc_PI3K_aPI3K_pIRS = parameterValuesNew(55);
	kc_RAF_aRAF_aRAS = parameterValuesNew(56);
	kc_RAS_aRAS_pERBB3 = parameterValuesNew(57);
	kc_RAS_aRAS_pFRS2 = parameterValuesNew(58);
	kc_RBSM_aRBSM_MYC = parameterValuesNew(59);
	kc_RBSM_aRBSM_amTORC1 = parameterValuesNew(60);
	kc_RBSM_aRBSM_pERK = parameterValuesNew(61);
	kc_RBSM_aRBSM_pS6K = parameterValuesNew(62);
	kc_RB_pRB_pCDK2 = parameterValuesNew(63);
	kc_RB_pRB_pCDK46 = parameterValuesNew(64);
	kc_S6K_pS6K_amTORC1 = parameterValuesNew(65);
	kc_mTORC1_amTORC1_pAKT = parameterValuesNew(66);
	kc_mTORC1_amTORC1_pCDK46 = parameterValuesNew(67);
	kc_mTORC2_amTORC2_aPI3K = parameterValuesNew(68);
	kc_pFGFR2_FGFR2_pERK = parameterValuesNew(69);
	kd_E2FuRB_E2F_RB = parameterValuesNew(70);
	kdeg_MYC = parameterValuesNew(71);
	ksyn_MYC_aRBSM = parameterValuesNew(72);
	IGF_0 = parameterValuesNew(73);
	IGF_on = parameterValuesNew(74);
	FGF_0 = parameterValuesNew(75);
	FGF_on = parameterValuesNew(76);
	HRG_0 = parameterValuesNew(77);
	HRG_on = parameterValuesNew(78);
	FGFR2i_0 = parameterValuesNew(79);
	FGFR2i_on = parameterValuesNew(80);
	PI3Ki_0 = parameterValuesNew(81);
	PI3Ki_on = parameterValuesNew(82);
	AKTi_0 = parameterValuesNew(83);
	AKTi_on = parameterValuesNew(84);
	MEKi_0 = parameterValuesNew(85);
	MEKi_on = parameterValuesNew(86);
	RBSMi_0 = parameterValuesNew(87);
	RBSMi_on = parameterValuesNew(88);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FGFR2_tot = FGFR2+pFGFR2;
IGF1R_tot = IGF1R+pIGF1R;
ERBB3_tot = ERBB3+pERBB3;
FRS2_tot = FRS2+pFRS2;
RAS_tot = RAS+aRAS;
RAF_tot = RAF+aRAF;
MEK_tot = MEK+pMEK;
ERK_tot = ERK+pERK;
PI3K_tot = PI3K+aPI3K;
mTORC2_tot = mTORC2+amTORC2;
AKT_tot = AKT+pAKT;
mTORC1_tot = mTORC1+amTORC1;
S6K_tot = S6K+pS6K;
IRS_tot = IRS+pIRS;
RBSM_tot = RBSM+aRBSM;
FOXO3_tot = FOXO3+pFOXO3;
MYC_tot = MYC;
CDK46_tot = CDK46+pCDK46;
E2F_tot = E2F+E2FuRB;
RB_tot = RB+E2FuRB+pRB;
CDK2_tot = CDK2+pCDK2;
IGF = IGF_0*piecewiseIQM(1,ge(time,IGF_on),0);
FGF = FGF_0*piecewiseIQM(1,ge(time,FGF_on),0);
HRG = HRG_0*piecewiseIQM(1,ge(time,HRG_on),0);
FGFR2i = FGFR2i_0*piecewiseIQM(1,ge(time,FGFR2i_on),0);
PI3Ki = PI3Ki_0*piecewiseIQM(1,ge(time,PI3Ki_on),0);
AKTi = AKTi_0*piecewiseIQM(1,ge(time,AKTi_on),0);
MEKi = MEKi_0*piecewiseIQM(1,ge(time,MEKi_on),0);
RBSMi = RBSMi_0*piecewiseIQM(1,ge(time,RBSMi_on),0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REACTION KINETICS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R1 = (kc_FGFR2_pFGFR2_FGF*FGF+kc_FGFR2_pFGFR2_FOXO3*FOXO3)*FGFR2/((1+Ki_FGFR2_pFGFR2_FGF_FGFR2i*FGFR2i))-Vm_pFGFR2_FGFR2*pFGFR2;
R2 = (kc_pFGFR2_FGFR2_pERK*pERK)*pFGFR2;
R3 = (kc_ERBB3_pERBB3_HRG*HRG+kc_ERBB3_pERBB3_pFGFR2*pFGFR2+kc_ERBB3_pERBB3_FOXO3*FOXO3)*ERBB3/((1+Ki_ERBB3_pERBB3_HRG_pERK*pERK))-Vm_pERBB3_ERBB3*pERBB3;
R4 = (kc_IGF1R_pIGF1R_IGF*IGF+kc_IGF1R_pIGF1R_FOXO3*FOXO3)*IGF1R-Vm_pIGF1R_IGF1R*pIGF1R;
R5 = (kc_FRS2_pFRS2_pFGFR2*pFGFR2)*FRS2-Vm_pFRS2_FRS2*pFRS2;
R6 = (kc_PI3K_aPI3K_pIRS*pIRS+kc_PI3K_aPI3K_pERBB3*pERBB3)*PI3K/((1+Ki_PI3K_aPI3K_pIRS_PI3Ki*PI3Ki))-Vm_aPI3K_PI3K*aPI3K;
R7 = (kc_PI3K_aPI3K_pFRS2*pFRS2)*PI3K/((1+Ki_PI3K_aPI3K_pFRS2_pERK*pERK)*(1+Ki_PI3K_aPI3K_pFRS2_PI3Ki*PI3Ki));
R8 = (kc_mTORC2_amTORC2_aPI3K*aPI3K)*mTORC2/((1+Ki_mTORC2_amTORC2_aPI3K_pRB*pRB))-Vm_amTORC2_mTORC2*amTORC2;
R9 = (kc_AKT_pAKT_aPI3K*aPI3K+kc_AKT_pAKT_amTORC2*amTORC2)*AKT/((1+Ki_AKT_pAKT_aPI3K_AKTi*AKTi))-Vm_pAKT_AKT*pAKT;
R10 = (kc_mTORC1_amTORC1_pAKT*pAKT+kc_mTORC1_amTORC1_pCDK46*pCDK46)*mTORC1-Vm_amTORC1_mTORC1*amTORC1;
R11 = (kc_S6K_pS6K_amTORC1*amTORC1)*S6K-Vm_pS6K_S6K*pS6K;
R12 = (kc_IRS_pIRS_pIGF1R*pIGF1R)*IRS/((1+Ki_IRS_pIRS_pIGF1R_pS6K*pS6K))-Vm_pIRS_IRS*pIRS;
R13 = (kc_RAS_aRAS_pERBB3*pERBB3)*RAS-Vm_aRAS_RAS*aRAS;
R14 = (kc_RAS_aRAS_pFRS2*pFRS2)*RAS/((1+Ki_RAS_aRAS_pFRS2_pERK*pERK))-Vm_aRAS_RAS*aRAS;
R15 = (kc_RAF_aRAF_aRAS*aRAS)*RAF/((1+Ki_RAF_aRAF_aRAS_pAKT*pAKT))-Vm_aRAF_RAF*aRAF;
R16 = (kc_MEK_pMEK_aRAF*aRAF)*MEK/((1+Ki_MEK_pMEK_aRAF_MEKi*MEKi))-Vm_pMEK_MEK*pMEK;
R17 = (kc_ERK_pERK_pMEK*pMEK)*ERK-Vm_pERK_ERK*pERK;
R18 = (kc_FOXO3_pFOXO3_pAKT*pAKT)*FOXO3-Vm_pFOXO3_FOXO3*pFOXO3;
R19 = (kc_RBSM_aRBSM_pS6K*pS6K+kc_RBSM_aRBSM_amTORC1*amTORC1+kc_RBSM_aRBSM_pERK*pERK+kc_RBSM_aRBSM_MYC*MYC)*RBSM/((1+Ki_RBSM_aRBSM_pS6K_RBSMi*RBSMi))-Vm_aRBSM_RBSM*aRBSM;
R20 = Vsyn_MYC;
R21 = kdeg_MYC*MYC;
R22 = (ksyn_MYC_aRBSM*aRBSM/(Km_MYC_aRBSM+aRBSM));
R23 = (kc_CDK46_pCDK46_aRBSM*aRBSM+kc_CDK46_pCDK46_MYC*MYC)*CDK46-Vm_pCDK46_CDK46*pCDK46;
R24 = (ka_E2F_RB_E2FuRB*E2F*RB)/((1+Ki_E2F_RB_E2FuRB_MYC*MYC))-kd_E2FuRB_E2F_RB*E2FuRB;
R25 = (kc_RB_pRB_pCDK46*pCDK46+kc_RB_pRB_pCDK2*pCDK2)*RB-Vm_pRB_RB*pRB;
R26 = (kc_CDK2_pCDK2_E2F*E2F)*CDK2-Vm_pCDK2_CDK2*pCDK2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIFFERENTIAL EQUATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AKT_dot = -R9;
CDK2_dot = -R26;
CDK46_dot = -R23;
E2F_dot = -R24;
E2FuRB_dot = +R24;
ERBB3_dot = -R3;
ERK_dot = -R17;
FGFR2_dot = -R1+R2;
FOXO3_dot = -R18;
FRS2_dot = -R5;
IGF1R_dot = -R4;
IRS_dot = -R12;
MEK_dot = -R16;
MYC_dot = +R20-R21+R22;
PI3K_dot = -R6-R7;
RAF_dot = -R15;
RAS_dot = -R13-R14;
RB_dot = -R24-R25;
RBSM_dot = -R19;
S6K_dot = -R11;
aPI3K_dot = +R6+R7;
aRAF_dot = +R15;
aRAS_dot = +R13+R14;
aRBSM_dot = +R19;
amTORC1_dot = +R10;
amTORC2_dot = +R8;
mTORC1_dot = -R10;
mTORC2_dot = -R8;
pAKT_dot = +R9;
pCDK2_dot = +R26;
pCDK46_dot = +R23;
pERBB3_dot = +R3;
pERK_dot = +R17;
pFGFR2_dot = +R1-R2;
pFOXO3_dot = +R18;
pFRS2_dot = +R5;
pIGF1R_dot = +R4;
pIRS_dot = +R12;
pMEK_dot = +R16;
pRB_dot = +R25;
pS6K_dot = +R11;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RETURN VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE ODEs
output(1) = AKT_dot;
output(2) = CDK2_dot;
output(3) = CDK46_dot;
output(4) = E2F_dot;
output(5) = E2FuRB_dot;
output(6) = ERBB3_dot;
output(7) = ERK_dot;
output(8) = FGFR2_dot;
output(9) = FOXO3_dot;
output(10) = FRS2_dot;
output(11) = IGF1R_dot;
output(12) = IRS_dot;
output(13) = MEK_dot;
output(14) = MYC_dot;
output(15) = PI3K_dot;
output(16) = RAF_dot;
output(17) = RAS_dot;
output(18) = RB_dot;
output(19) = RBSM_dot;
output(20) = S6K_dot;
output(21) = aPI3K_dot;
output(22) = aRAF_dot;
output(23) = aRAS_dot;
output(24) = aRBSM_dot;
output(25) = amTORC1_dot;
output(26) = amTORC2_dot;
output(27) = mTORC1_dot;
output(28) = mTORC2_dot;
output(29) = pAKT_dot;
output(30) = pCDK2_dot;
output(31) = pCDK46_dot;
output(32) = pERBB3_dot;
output(33) = pERK_dot;
output(34) = pFGFR2_dot;
output(35) = pFOXO3_dot;
output(36) = pFRS2_dot;
output(37) = pIGF1R_dot;
output(38) = pIRS_dot;
output(39) = pMEK_dot;
output(40) = pRB_dot;
output(41) = pS6K_dot;
% return a column vector 
output = output(:);
return


