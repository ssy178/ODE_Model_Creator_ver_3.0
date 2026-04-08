# ODE Model Creator v3.0.0

A MATLAB-based object-oriented framework for automatically generating ordinary differential equation (ODE) models from biological network specifications defined in Excel spreadsheets.

## Overview

The ODE Model Creator streamlines the process of converting biological network diagrams and reaction specifications into executable ODE models compatible with IQMtools. It provides an intuitive Excel-based interface for model specification and automates the generation of complex rate equations, parameter tables, and computational code.

## Key Features

### Model Definition & Processing
- **Excel-Based Model Definition**: Define biological networks using intuitive spreadsheet format
- **18+ Reaction Types**: Support for mass action, enzymatic (Michaelis-Menten), synthesis, degradation, translocation, catalytic, and synergistic reactions
- **Automatic Rate Equation Generation**: Mathematically correct ODE equations generated automatically
- **Regulatory Effects**: Support for activation and inhibition of reactions
- **Input Signals & Inhibitors**: Define time-dependent stimuli and drug treatments
- **Readout Variables**: Create complex observables as linear combinations of state variables

### User-Defined Input Tables
- **Custom Parameter Value Files**: Load user-specified parameter values from Excel tables
- **Custom Initial Value Files**: Load user-specified initial conditions for state variables
- **Input File Validation**: Automatic validation with 80% match rate threshold and detailed warning messages when incorrect files are selected
- **Random Initialization**: Automatic random value assignment (0-100 range) when no user files are provided

### Code Generation
- **IQMtools Integration**: Direct export to IQM txtbc format
- **ODE M-file Generation**: Generate MATLAB ODE functions for native integration
- **MEX File Compilation**: Automated compilation to MEX files for fast ODE integration
- **Simulation Script Generation**: Automatic generation of ready-to-run simulation scripts with random parameter perturbation support

## Installation

### Requirements

- MATLAB R2016b or later
- IQMtools (free version or commercial)
- Microsoft Excel or compatible spreadsheet application
- C Compiler (for MEX file compilation, e.g., MinGW-w64 for Windows)

### Setup Steps

1. **Download the Package**
   ```bash
   # Extract the ODE Model Creator to your desired location
   unzip ODEModelCreator.zip
   cd ODEModelCreator
   ```

2. **Configure MATLAB Path**
   ```matlab
   % Add all subdirectories to MATLAB path
   addpath(genpath('path/to/ODEModelCreator/src'))
   addpath('path/to/ODEModelCreator/config')
   addpath('path/to/IQMtools/installation')

   % Save path for persistence
   savepath
   ```

3. **Verify Installation**
   ```matlab
   % Test that main classes are accessible
   builder = ODEModelBuilder();
   fprintf('ODE Model Creator is ready!\n');
   ```

4. **Configure Default Parameters** (Optional)
   - Edit `config/default_parameter_values.xlsx` to set parameter defaults for your models
   - Edit `config/default_config.m` to customize paths and options

## Quick Start Guide

### Interactive Pipeline (Recommended)

The easiest way to use the ODE Model Creator is through the interactive pipeline script:

```matlab
% Run the interactive generation script
run_ode_generation
```

This script will:
1. **Prompt for network map file** - Select your Excel model file
2. **Ask for custom parameter file** (optional) - Load user-defined parameter values
3. **Ask for initial value file** (optional) - Load user-defined state variable initial values
4. **Generate all outputs** - Parameter tables, state variable tables, IQM model, ODE file, MEX file
5. **Create simulation script** - Ready-to-run simulation with random parameter perturbation

### Programmatic Usage

```matlab
% Create builder instance
builder = ODEModelBuilder();

% Configure options
options = struct();
options.validateModel = true;
options.parameterValueMode = 'file';  % 'default' or 'file'
options.parameterValueFile = 'path/to/my_parameters.xlsx';
options.initialValueMode = 'file';    % 'default', 'file', or 'random'
options.initialValueFile = 'path/to/my_initial_values.xlsx';

% Run complete pipeline
builder.runFullPipeline('path/to/network_map.xlsx', 'output/ModelName', options);
```

### Step-by-Step Control

```matlab
% Create builder instance
builder = ODEModelBuilder();

% Step 1: Load model from Excel
builder.loadModel('path/to/your/model.xlsx', 'MyModel');

% Step 2: Generate rate equations automatically
builder.generateRateEquations();

% Step 3: Validate the model
if builder.validateModel()
    fprintf('Model validation successful!\n');
end

% Step 4: Export parameter table (with optional user file)
options.parameterValueMode = 'file';
options.parameterValueFile = 'my_params.xlsx';
builder.exportParameterTable('output/table_parameter.xlsx', options);

% Step 5: Export state variable table (with optional user file)
options.initialValueMode = 'file';
options.initialValueFile = 'my_initvals.xlsx';
builder.exportStateVariableTable('output/table_statevariable.xlsx', options);

% Step 6: Export to IQM txtbc format
builder.exportToIQM('output/MyModel.txtbc');

% Step 7: Generate ODE M-file
builder.generateODEFile('output/MyModel_ode');

% Step 8: Compile MEX file for fast integration
builder.compileMEX('output/MyModel_mex');
```


## Generated Simulation Script

The ODE Model Creator automatically generates a ready-to-run simulation script for each model. This script includes:

- **Model data** - All parameter names/values and state variable names/initial values
- **Random parameter perturbation** - ±20% variation for sensitivity analysis
- **MEX-based simulation** - Fast integration using compiled MEX file
- **Automatic plotting** - Visualization of simulation results

### Example Generated Script Usage

```matlab
% Navigate to output directory
cd('output/EGFR_NFkB_ver_01')

% Run the auto-generated simulation
run_simulation_EGFR_NFkB_ver_01
```

## Requirements

### Minimum System Requirements

- **Operating System**: Windows, macOS, or Linux
- **MATLAB**: R2016b or later (required for object-oriented features)
- **Memory**: 512 MB minimum, 2 GB recommended
- **Disk Space**: 500 MB for installation, additional space for model outputs

### MATLAB Toolboxes

- MATLAB core (required)
- **Spreadsheet Link EX** (recommended for Excel integration, not required)
- **Optimization Toolbox** (optional, for parameter optimization workflows)


## License

This repository is licensed for academic and non-commercial research use only. See [LICENSE](LICENSE) for full terms.


## Developer

**Sungyoung Shin**
SAiGENCI – South Australian immunoGENomics Cancer Institute
The University of Adelaide, Adelaide, SA 5005, Australia
Email: [Sungyoung.shin@adelaide.edu.au](mailto:Sungyoung.shin@adelaide.edu.au)