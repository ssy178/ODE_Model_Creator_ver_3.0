# ODE Model Creator - User Guide

A comprehensive guide to using the ODE Model Creator for building biological network models.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Excel File Format Specification](#excel-file-format-specification)
3. [Step-by-Step Workflow](#step-by-step-workflow)
4. [Parameter Naming Conventions](#parameter-naming-conventions)
5. [Advanced Features](#advanced-features)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

## Getting Started

### Initial Setup

Before your first use:

1. **Add to MATLAB Path**
   ```matlab
   % Add the entire src directory to MATLAB path
   addpath(genpath('path/to/ODEModelCreator/src'));
   savepath;
   ```

2. **Verify Installation**
   ```matlab
   % Check that main classes are accessible
   which ODEModelBuilder
   which Reaction
   which ReactionFactory
   ```

3. **Review Example Models**
   ```matlab
   % Navigate to examples folder and open FGFR2_model_ver_02.xlsx
   % This shows the correct format for biological network specifications
   ```

### First Model Creation

```matlab
% Create builder
builder = ODEModelBuilder();

% Quick test - run the example pipeline
builder.runFullPipeline(...
    'examples/FGFR2_model_ver_02/FGFR2_model_ver_02.xlsx', ...
    'output/test_run');

% Check output directory for generated files
```

## Excel File Format Specification

### Overview

The ODE Model Creator expects an Excel file with specific sheets and format. Each sheet contains different components of your biological network.

### Sheet 1: Reaction Map

**Name**: The first sheet (typically named "Map" or "Reactions")

**Purpose**: Define all chemical reactions in your network

**Structure**:

| Column | Header | Description | Example |
|--------|--------|-------------|---------|
| A | Reaction_ID | Unique identifier for each reaction | R1, R2, R3 |
| B | Reaction_Type | Type code for the reaction | MA, ASSO, MMS, MMF, etc. |
| C | Substrate_1 | First substrate/reactant | FGFR2 |
| D | Substrate_2 | Second substrate (if applicable) | FGF |
| E | Product_1 | First product | pFGFR2 |
| F | Product_2 | Second product (if applicable) | (leave blank if not used) |
| G | Modifier | Enzyme or modifier (if applicable) | FGFR2 |
| H | Activator_1 | First activator (with + prefix) | +FGF |
| I | Activator_2 | Second activator (optional) | +EGF |
| J | Inhibitor_1 | First inhibitor (with - prefix) | -FGFR2i |
| K | Inhibitor_2 | Second inhibitor (optional) | -EGFR_inh |

**Example Reaction Map**:

```
| R1  | MA  | FGFR2  | FGF   | pFGFR2 |      | FGFR2 | +FGF       |           | -FGFR2i    |
| R2  | MMS | pFGFR2 |       | pAKT   |      | AKT   | +pFGFR2    |           | -PI3Ki     |
| R3  | DEGS| pAKT   |       |        |      |       |            | -PP2A     |            |
| R4  | TRN | pAKT_C |       | pAKT_N |      |       |            |           | -TRNF_inh  |
```

**Important Notes**:
- Column headers are case-insensitive
- Blank cells for unused columns are acceptable
- Species names are case-sensitive within your model
- Reaction types must match supported types (see [ReactionTypeReference.md](ReactionTypeReference.md))
- Activators must be prefixed with "+"
- Inhibitors must be prefixed with "-"

### Sheet 2: Input Signals

**Name**: Usually "Input" or "Inputs"

**Purpose**: Define external stimuli that vary with time

**Structure**:

| Column | Header | Description | Example |
|--------|--------|-------------|---------|
| A | Signal_Name | Name of the input signal | FGF, IGF1, TNFα |
| B | Initial_Value | Initial concentration (typically 0) | 0 |
| C | Activation_Concentration | Concentration after activation | 100 |
| D | Activation_Time | Time at which signal turns on (in minutes) | 5 |

**Example Input Sheet**:

```
| FGF   | 0 | 100 | 5     |
| IGF1  | 0 | 50  | 10    |
| TNFα  | 0 | 75  | 15    |
```

**Notes**:
- Signals start at Initial_Value for time < Activation_Time
- At Activation_Time, signal jumps to Activation_Concentration
- Signal names must match activators used in reaction map (+FGF, +IGF1, etc.)
- Values can be any positive number

### Sheet 3: Inhibitors (Drugs/Interventions)

**Name**: Usually "Inhibitor" or "Drugs"

**Purpose**: Define pharmacological inhibitors or therapeutic agents

**Structure**:

| Column | Header | Description | Example |
|--------|--------|-------------|---------|
| A | Inhibitor_Name | Name of the inhibitor | FGFR2i, PI3Ki, MEKi |
| B | Initial_Value | Initial concentration (typically 0) | 0 |
| C | Treatment_Concentration | Concentration after treatment | 1 |
| D | Treatment_Time | Time at which drug is applied (in minutes) | 30 |

**Example Inhibitor Sheet**:

```
| FGFR2i  | 0 | 1 | 30 |
| PI3Ki   | 0 | 1 | 30 |
| MEKi    | 0 | 1 | 35 |
```

**Notes**:
- Inhibitor names must match those used in reactions (-FGFR2i, -PI3Ki, etc.)
- Typical treatment time is after signal activation
- Concentration units should be consistent with your model

### Sheet 4: Readout Variables (Optional)

**Name**: Usually "Readout" or "Observables"

**Purpose**: Define complex observables as linear combinations of state variables

**Structure**:

| Column | Header | Description | Example |
|--------|--------|-------------|---------|
| A | Readout_Name | Name of the readout | Total_AKT, Total_pAKT |
| B | Component_1 | First component species | AKT |
| C | Component_2 | Second component | pAKT |
| D | Component_3 | Third component (optional) | aAKT |

**Example Readout Sheet**:

```
| Total_AKT    | AKT     | pAKT     | aAKT      |
| pAKT_pooled  | pAKT_C  | pAKT_N   |           |
| Active_MAPK  | pMAPK   | ppMAPK   |           |
```

**Notes**:
- Readout variables are NOT state variables, just calculations
- Components must be valid state variables
- Useful for comparing to experimental data
- Readouts are summed: `Total_AKT = AKT + pAKT + aAKT`

## Step-by-Step Workflow

### Complete Workflow Example

This example walks through creating an ODE model for FGF receptor signaling.

#### Step 1: Create Excel File

Create a new Excel file with the following sheets:

**Sheet 1: Map**
```
R1,MA,FGFR2,FGF,pFGFR2,FGFR2,+FGF,-FGFR2i
R2,MMS,pFGFR2,,pAKT,AKT,+pFGFR2,-PI3Ki
R3,DEG0,pAKT,,,,,,-PI3Ki
```

**Sheet 2: Input**
```
FGF,0,100,5
```

**Sheet 3: Inhibitor**
```
FGFR2i,0,1,30
PI3Ki,0,1,30
```

#### Step 2: Initialize MATLAB

```matlab
% Clear workspace
clear all; close all; clc;

% Add paths
addpath(genpath('path/to/ODEModelCreator/src'));

% Create builder instance
builder = ODEModelBuilder();

% Display welcome message
disp('================================');
disp('  ODE Model Creator v3.0.0');
disp('  MATLAB OO Framework');
disp('================================');
```

#### Step 3: Load Model from Excel

```matlab
% Load the model from your Excel file
fprintf('\nStep 1: Loading model from Excel...\n');
builder.loadModel('path/to/your/model.xlsx', 'FGF_Signaling_Model');

% Display model summary
fprintf('\nModel loaded: %s\n', builder.model.name);
fprintf('Number of reactions: %d\n', length(builder.model.reactions));
```

#### Step 4: Generate Rate Equations

```matlab
% Automatically generate mathematical rate equations
fprintf('\nStep 2: Generating rate equations...\n');
builder.generateRateEquations();

% Display first few reactions
for i = 1:min(3, length(builder.model.reactions))
    rxn = builder.model.reactions{i};
    fprintf('\nReaction %s:\n', rxn.reactionID);
    fprintf('  Type: %s\n', rxn.type);
    fprintf('  Process: %s\n', rxn.getProcessString());
    fprintf('  Rate Equation: %s\n', rxn.rateEquation);
    fprintf('  Parameters: %s\n', sprintf('%s ', rxn.parameters{:}));
end
```

#### Step 5: Validate the Model

```matlab
% Validate model consistency
fprintf('\nStep 3: Validating model...\n');
if builder.validateModel()
    fprintf('Model validation PASSED!\n');
else
    fprintf('Model validation FAILED!\n');
    return;
end
```

#### Step 6: Export Parameter Table

```matlab
% Export parameter table for review and editing
fprintf('\nStep 4: Exporting parameter table...\n');
outputDir = 'output/FGF_Signaling_Model';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

paramFile = fullfile(outputDir, 'table_parameter.xlsx');
builder.exportParameterTable(paramFile);
fprintf('Parameter table exported to: %s\n', paramFile);

% Display parameter summary
fprintf('\nParameter Summary:\n');
fprintf('Total parameters: %d\n', length(builder.model.parameters));
fprintf('Parameters with defaults: %d\n', ...
    sum(~cellfun(@isempty, cellfun(@(p) p.defaultValue, ...
    values(builder.model.parameters), 'UniformOutput', false))));
```

#### Step 7: Export State Variable Table

```matlab
% Export state variable table
fprintf('\nStep 5: Exporting state variable table...\n');
stateFile = fullfile(outputDir, 'table_statevariable.xlsx');
builder.exportStateVariableTable(stateFile);
fprintf('State variable table exported to: %s\n', stateFile);

% Display state variable summary
fprintf('\nState Variable Summary:\n');
fprintf('Total state variables: %d\n', length(builder.model.stateVariables));
```

#### Step 8: [Optional] Manual Editing

```matlab
% OPTIONAL: User can edit the exported Excel files to:
% 1. Adjust parameter values
% 2. Set initial conditions for state variables
% 3. Add units and descriptions
%
% To continue after editing:
pause('on');
fprintf('\nEdit the Excel files if needed, then press ENTER to continue...\n');
pause;
```

#### Step 9: Export to IQM Format

```matlab
% Export to IQMtools txtbc format
fprintf('\nStep 6: Exporting to IQM format...\n');
iqmFile = fullfile(outputDir, 'FGF_Signaling_Model.txtbc');
builder.exportToIQM(iqmFile);
fprintf('IQM model exported to: %s\n', iqmFile);
```

#### Step 10: Generate ODE File

```matlab
% Generate standalone ODE M-file
fprintf('\nStep 7: Generating ODE M-file...\n');
odeFile = fullfile(outputDir, 'FGF_Signaling_Model_ode');
builder.generateODEFile(odeFile);
fprintf('ODE M-file generated: %s.m\n', odeFile);
```

#### Step 11: Compile MEX File (Optional)

```matlab
% Generate compiled MEX file for faster integration
fprintf('\nStep 8: Compiling MEX file...\n');
try
    mexFile = fullfile(outputDir, 'FGF_Signaling_Model_mex');
    builder.compileMEX(mexFile);
    fprintf('MEX file compiled: %s.mexw64\n', mexFile);
catch ME
    fprintf('MEX compilation failed (non-critical):\n%s\n', ME.message);
end
```

#### Step 12: Run ODE Model (Optional)

```matlab
% Test the generated ODE model
fprintf('\nStep 9: Testing ODE model integration...\n');

% Create time vector (0 to 100 minutes)
tspan = [0 100];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);

% Get initial conditions from model
x0 = [];  % Initial condition vector from builder.model

% Run integration
[t, x] = ode45(@(t, x) FGF_Signaling_Model_ode(t, x, []), tspan, x0, options);

% Plot results
figure('Position', [100 100 1200 600]);
subplot(1, 2, 1);
plot(t, x);
xlabel('Time (min)');
ylabel('Concentration');
legend(builder.model.stateVariables.keys);
grid on;

subplot(1, 2, 2);
semilogy(t, x + 1e-10);
xlabel('Time (min)');
ylabel('Concentration (log scale)');
legend(builder.model.stateVariables.keys);
grid on;
```

### Quick Reference: One-Line Execution

```matlab
builder = ODEModelBuilder();
builder.runFullPipeline('model.xlsx', 'output/my_model');
```

## Parameter Naming Conventions

The ODE Model Creator uses strict naming conventions for parameters to ensure clarity and correctness.

### General Format

```
[parameter_type]_[species/entities]_[modifiers]
```

### Reaction Type Specific Conventions

#### 1. Association Reactions (ASSO, MA, DISSO)

**Forward Rate (Association)**:
- `ka_A_B_C` - Rate constant for A + B => C
- `ka_A_B_C_ENZ` - Enhanced association with enzyme
- `ka_A_B_C_ACT1_ACT2` - Multiple activators (additive)

**Reverse Rate (Dissociation)**:
- `kd_C_A_B` - Dissociation rate for C => A + B
- `kd_C_INH` - Inhibited dissociation rate

**Inhibition Constants**:
- `Ki_A_B_C_INH` - Inhibition constant for inhibitor INH
- `Ki_A_B_C_INH1_INH2` - Multiple inhibitors

#### 2. Michaelis-Menten Reactions (MMS, MMF, MMSF, MMFF, MMSR, MMFR)

**Catalytic Rate**:
- `kc_A_B_ENZ` - Catalytic rate for enzyme ENZ
- `kc_A_B_ENZ_ACT1_ACT2` - Multiple activators (summed)

**Michaelis Constant**:
- `Km_A_B_ENZ` - For forward reaction
- `Km_B_A_ENZ` - For reverse reaction

**Maximum Velocity**:
- `Vm_B_A` - Reverse maximum velocity
- `Vm_A_B` - Forward maximum velocity

**Inhibition Constants**:
- `Ki_A_B_ENZ_INH` - Inhibition constant
- Denominator term: `(1 + Ki*[INH])`

#### 3. Synthesis Reactions (SYN0, SYNS, SYNF)

**Synthesis Rate**:
- `ksyn_A` - Constitutive synthesis rate (SYN0)
- `Vsyn_A` - Maximum synthesis rate (SYN0, alternative)

**Activated Synthesis**:
- `ksyn_A_TF` - Synthesis rate with transcription factor TF
- `ksyn_A_TF1_TF2` - Multiple transcription factors

**Michaelis Constants**:
- `Km_A_TF1_TF2` - Used when multiple TFs present

**Inhibition Constants**:
- `Ki_syn_A_INH` - Inhibition of synthesis

#### 4. Degradation Reactions (DEG0, DEGS, DEGF)

**Degradation Rate**:
- `kdeg_A` - Passive degradation rate (DEG0)
- `kdeg_A_PROTEASE` - Protease-mediated degradation rate

**Michaelis Constant**:
- `Km_A_PROTEASE` - Michaelis constant for protease substrate

**Inhibition Constants**:
- `Ki_deg_A_PROTEASE_INH` - Protease inhibition

#### 5. Translocation Reactions (TRN, TRNF)

**Forward Rate**:
- `ktrn_A_B` - Forward translocation from A to B

**Reverse Rate**:
- `ktrn_B_A` - Reverse translocation from B to A

**Inhibition Constants**:
- `Ki_trn_A_B_INH` - Translocation inhibition

#### 6. Catalytic Reactions (CAT)

**Catalytic Rate**:
- `kcat_A_CATALYST` - Rate constant for catalyst-dependent synthesis

### Examples

#### Example 1: Simple Binding

Reaction: `FGFR2 + FGF => pFGFR2`
- Type: ASSO (Association)
- Parameters:
  - `ka_FGFR2_FGF_pFGFR2` - Forward rate
  - `Ki_FGFR2_FGF_pFGFR2_FGFR2i` - Inhibition (if inhibited by FGFR2i)

#### Example 2: Enzyme with Activators and Inhibitors

Reaction: `pFGFR2 => pAKT` (activated by pFGFR2, inhibited by PI3Ki)
- Type: MMS (Michaelis-Menten Short)
- Parameters:
  - `kc_pFGFR2_pAKT_pFGFR2` - Catalytic rate
  - `Vm_pAKT_pFGFR2` - Reverse velocity
  - `Ki_pFGFR2_pAKT_pFGFR2_PI3Ki` - Inhibition

#### Example 3: Regulated Synthesis

Reaction: `=> PKC` (activated by pAKT)
- Type: SYNS (Simple Synthesis)
- Parameters:
  - `ksyn_PKC_pAKT` - Synthesis rate with pAKT
  - `Ki_syn_PKC_PP_inh` - Inhibition by phosphatase inhibitor

#### Example 4: Regulated Degradation

Reaction: `pAKT =>` (degraded by PP2A, activated by PKC)
- Type: DEGF (Regulated Degradation Full)
- Parameters:
  - `kdeg_pAKT_PKC` - Degradation rate with PKC as regulator
  - `Km_pAKT_PP2A` - Michaelis constant
  - `Ki_deg_pAKT_PP2A_inh` - Phosphatase inhibition

## Advanced Features

### Programmatic Model Creation

Instead of using Excel files, you can create models directly in MATLAB:

```matlab
% Create empty model
model = BiologicalModel('MyCustomModel');

% Create factory
factory = ReactionFactory();

% Add reaction 1: A + B <=> C (Mass Action)
r1 = factory.create('MA', {'A', 'B'}, {'C'}, {});
model.addReaction(r1);

% Add reaction 2: C => D (Enzymatic)
r2 = factory.create('MMS', {'C'}, {'D'}, {'+A', '-Inhibitor'});
model.addReaction(r2);

% Add input signal
model.addInput(InputSignal('A', 0, 100, 5));

% Add inhibitor
model.addInhibitor(Inhibitor('Inhibitor', 0, 1, 30));

% Extract species and parameters
model.extractAllStateVariables();
model.extractAllParameters();

% Export
builder = ODEModelBuilder();
builder.model = model;
builder.exportToIQM('output/custom_model.txtbc');
```

### Custom Configuration

```matlab
% Create custom configuration
config = ModelConfiguration();

% Set custom paths
config.paths.iqmTools = 'C:\Users\YourName\IQMtools';
config.paths.defaultParameters = 'config/my_params.xlsx';
config.paths.outputDir = 'my_output';

% Set custom options
config.options.validateOnLoad = true;
config.options.generateMEX = false;
config.options.verboseOutput = true;

% Use in builder
builder = ODEModelBuilder(config);
```

### Working with Multiple Models

```matlab
% Load and process multiple models
modelFiles = {
    'model_v01.xlsx'
    'model_v02.xlsx'
    'model_v03.xlsx'
};

builder = ODEModelBuilder();

for i = 1:length(modelFiles)
    fprintf('\nProcessing model %d/%d\n', i, length(modelFiles));

    % Load and run pipeline
    builder.runFullPipeline(modelFiles{i}, ...
        sprintf('output/model_v%02d', i));
end
```

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: "Excel file not found"

**Symptoms**:
```
Error: Cannot read Excel file 'path/to/model.xlsx'
```

**Solutions**:
1. Check file path is correct and quotes are used for paths with spaces
   ```matlab
   builder.loadModel('path/to my models/model.xlsx');  % Correct
   builder.loadModel(path/to my models/model.xlsx);    % Wrong
   ```

2. Verify file exists and is readable
   ```matlab
   exist('path/to/model.xlsx', 'file')  % Should return 2
   ```

3. Try using absolute path instead of relative
   ```matlab
   builder.loadModel('C:\Users\...\model.xlsx');
   ```

#### Issue 2: "Unrecognized reaction type"

**Symptoms**:
```
Error: Unknown reaction type 'XYZ' in reaction R5
```

**Solutions**:
1. Check reaction type code in Excel matches supported types
   ```matlab
   % List supported types
   ReactionFactory.getSupportedTypes()
   ```

2. Common typos:
   - `MM` instead of `MMS` or `MMF`
   - `SYN` instead of `SYNS` or `SYNF`
   - `DEG` instead of `DEG0` or `DEGS`

#### Issue 3: "Parameter name mismatch"

**Symptoms**:
```
Warning: Parameter 'ka_A_B_C_ACT' used in reaction but not found in defaults
```

**Solutions**:
1. Check parameter naming follows conventions (see [Parameter Naming Conventions](#parameter-naming-conventions))

2. Verify activator/inhibitor names match exactly (case-sensitive)
   ```
   Reaction uses: +PKC
   Parameter should use: PKC (not Pkc or pkc)
   ```

3. Ensure all regulators are defined in Input/Inhibitor sheets

#### Issue 4: "MEX compilation failed"

**Symptoms**:
```
Error using mex: ... compilation error
```

**Solutions**:
1. Check IQMtools is properly installed and accessible
   ```matlab
   which iqm
   ```

2. Verify MATLAB C/C++ compiler is installed
   ```matlab
   mex -setup
   ```

3. Try using ODE file instead of MEX
   ```matlab
   % Use the generated _ode.m file directly
   [t, x] = ode45(@FGF_Signaling_Model_ode, tspan, x0, options);
   ```

#### Issue 5: "Excel file has wrong format"

**Symptoms**:
```
Error: Could not parse reaction map sheet
Expected columns: Reaction_ID, Reaction_Type, ...
```

**Solutions**:
1. Verify Excel file has correct sheet names:
   - First sheet: Reactions/Map
   - Second sheet: Input
   - Third sheet: Inhibitor
   - Fourth sheet: Readout (optional)

2. Check first row contains headers
   ```
   Row 1: Reaction_ID | Reaction_Type | ...
   Row 2: R1           | MA            | ...
   ```

3. Ensure no blank rows at top of sheet

4. Use provided template in `examples/template/model_template.xlsx`

### Getting Help

If you encounter issues not listed above:

1. **Check MATLAB Console Output** - Full error details are usually displayed
2. **Enable Verbose Logging**
   ```matlab
   builder = ODEModelBuilder();
   builder.config.options.verboseOutput = true;
   ```

3. **Review Example Models** - Look at working examples in `examples/` folder

4. **Check Documentation**:
   - [API_Documentation.md](API_Documentation.md) - Class and method reference
   - [ReactionTypeReference.md](ReactionTypeReference.md) - Detailed reaction info

5. **Validate Excel File** - Open template and compare your file structure

## Best Practices

### Excel File Design

1. **Use Consistent Naming**
   - Pick a naming convention for species and stick with it
   - Use underscores for multi-word names: `pFGFR2_cytosolic`
   - Avoid special characters: `@`, `#`, `$`, etc.

2. **Organize Reactions Logically**
   - Group related reactions together
   - Use sequential reaction IDs (R1, R2, R3, ...)
   - Add comments in unused columns

3. **Document Your Model**
   - Add descriptions in comments
   - Include units in headers (e.g., "Concentration (nM)")
   - Keep version history in Excel filename

### MATLAB Code Design

1. **Use Builder Pattern**
   ```matlab
   % Good - uses builder
   builder = ODEModelBuilder();
   builder.loadModel('model.xlsx');
   builder.generateRateEquations();

   % Less clear - direct model manipulation
   model = ExcelModelReader('model.xlsx').createModel();
   ```

2. **Validate Early**
   ```matlab
   if ~builder.validateModel()
       error('Model validation failed');
   end
   ```

3. **Use Try-Catch for Robustness**
   ```matlab
   try
       builder.exportToIQM(iqmFile);
   catch ME
       fprintf('Export failed: %s\n', ME.message);
   end
   ```

4. **Save Output Paths for Later Use**
   ```matlab
   outputDir = 'output/my_model';
   paramFile = fullfile(outputDir, 'table_parameter.xlsx');
   iqmFile = fullfile(outputDir, 'my_model.txtbc');
   ```

### Model Development Workflow

1. **Start with Simple Model**
   - Begin with basic reactions
   - Test and validate before adding complexity

2. **Iterate Incrementally**
   - Add reactions one at a time
   - Regenerate and check each iteration

3. **Use Version Control**
   - Keep numbered versions: `model_v01.xlsx`, `model_v02.xlsx`
   - Document changes between versions

4. **Test Against Experimental Data**
   - Once ODE model is generated, run simulations
   - Compare predictions to experimental measurements
   - Refine parameters as needed

5. **Create Reproducible Scripts**
   ```matlab
   % Save complete workflow in a script
   % This makes it easy to regenerate model from Excel file
   % Useful for parameter sweeps and sensitivity analysis
   ```

---

**For detailed API documentation**, see [API_Documentation.md](API_Documentation.md)

**For reaction type details**, see [ReactionTypeReference.md](ReactionTypeReference.md)

**Last Updated**: November 2025
