# ODE Model Creator - API Documentation

Complete reference documentation for all classes and methods in the ODE Model Creator.

## Table of Contents

1. [Core Classes](#core-classes)
2. [Reaction Classes](#reaction-classes)
3. [Entity Classes](#entity-classes)
4. [Manager Classes](#manager-classes)
5. [I/O Classes](#io-classes)
6. [Utility Classes](#utility-classes)

## Core Classes

### ODEModelBuilder

**File**: `src/core/ODEModelBuilder.m`

Main facade class that orchestrates the entire ODE model creation workflow.

#### Constructor

```matlab
obj = ODEModelBuilder()
obj = ODEModelBuilder(config)
```

**Inputs**:
- `config` (optional) - ModelConfiguration object or file path

**Example**:
```matlab
% Default configuration
builder = ODEModelBuilder();

% Custom configuration
config = ModelConfiguration();
config.paths.outputDir = 'my_output';
builder = ODEModelBuilder(config);

% Load from file
builder = ODEModelBuilder('config/my_config.m');
```

#### Methods

##### loadModel

```matlab
loadModel(excelFile)
loadModel(excelFile, modelName)
```

Load a biological model from Excel file.

**Inputs**:
- `excelFile` (char) - Path to Excel file
- `modelName` (char, optional) - Custom model name

**Returns**: None (sets `obj.model`)

**Example**:
```matlab
builder.loadModel('models/FGFR2_signaling.xlsx');
builder.loadModel('models/PKC_pathway.xlsx', 'PKC_Signaling_v2');
```

##### generateRateEquations

```matlab
generateRateEquations()
```

Generate mathematical rate equations for all reactions in the model.

**Returns**: None (populates `obj.model.reactions` with rate equations)

**Example**:
```matlab
builder.loadModel('model.xlsx');
builder.generateRateEquations();

% Access generated equations
for i = 1:length(builder.model.reactions)
    rxn = builder.model.reactions{i};
    disp(rxn.rateEquation);
end
```

##### validateModel

```matlab
isValid = validateModel()
```

Validate the biological model for consistency and completeness.

**Returns**:
- `isValid` (logical) - True if validation passes

**Example**:
```matlab
if builder.validateModel()
    disp('Model is valid');
else
    disp('Model validation failed');
end
```

##### exportParameterTable

```matlab
exportParameterTable(outputFile)
```

Export parameter table to Excel file for review and editing.

**Inputs**:
- `outputFile` (char) - Path to output Excel file

**Returns**: None (creates Excel file)

**Example**:
```matlab
builder.exportParameterTable('output/table_parameter.xlsx');
```

##### exportStateVariableTable

```matlab
exportStateVariableTable(outputFile)
```

Export state variable table to Excel file for initial conditions.

**Inputs**:
- `outputFile` (char) - Path to output Excel file

**Returns**: None (creates Excel file)

**Example**:
```matlab
builder.exportStateVariableTable('output/table_statevariable.xlsx');
```

##### exportToIQM

```matlab
exportToIQM(outputFile)
```

Export model to IQMtools txtbc format.

**Inputs**:
- `outputFile` (char) - Path to output txtbc file

**Returns**: None (creates txtbc file)

**Example**:
```matlab
builder.exportToIQM('output/model.txtbc');
```

##### generateODEFile

```matlab
generateODEFile(outputFile)
```

Generate standalone ODE M-file.

**Inputs**:
- `outputFile` (char) - Path base for output files (without extension)

**Returns**: None (creates _ode.m file)

**Example**:
```matlab
builder.generateODEFile('output/model_ode');
% Creates: output/model_ode.m
```

##### compileMEX

```matlab
compileMEX(outputFile)
```

Compile MEX file for fast ODE integration (requires IQMtools).

**Inputs**:
- `outputFile` (char) - Path base for output files

**Returns**: None (creates MEX file)

**Example**:
```matlab
try
    builder.compileMEX('output/model_mex');
catch ME
    disp('MEX compilation not available');
end
```

##### runFullPipeline

```matlab
runFullPipeline(inputFile, outputDir)
```

Run complete pipeline from Excel to compiled code.

**Inputs**:
- `inputFile` (char) - Path to input Excel file
- `outputDir` (char) - Path to output directory

**Returns**: None (creates all output files)

**Example**:
```matlab
builder.runFullPipeline('models/FGFR2.xlsx', 'output/FGFR2_model');
% Creates all output files in output/FGFR2_model/
```

---

### BiologicalModel

**File**: `src/core/BiologicalModel.m`

Data model representing a complete biological network.

#### Constructor

```matlab
obj = BiologicalModel(name)
obj = BiologicalModel(name, description)
```

**Inputs**:
- `name` (char) - Model name
- `description` (char, optional) - Model description

**Example**:
```matlab
model = BiologicalModel('FGF_Signaling');
model = BiologicalModel('PKC_Cascade', 'Complete PKC pathway model');
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | char | Model name |
| `description` | char | Model description |
| `reactions` | cell | Array of Reaction objects |
| `stateVariables` | containers.Map | Map of StateVariable objects |
| `parameters` | containers.Map | Map of Parameter objects |
| `inputs` | cell | Array of InputSignal objects |
| `inhibitors` | cell | Array of Inhibitor objects |
| `readouts` | cell | Array of ReadoutVariable objects |
| `metadata` | struct | Model metadata (creation date, etc.) |

#### Methods

##### addReaction

```matlab
addReaction(reaction)
```

Add a reaction to the model.

**Inputs**:
- `reaction` (Reaction) - Reaction object to add

**Example**:
```matlab
reaction = MassActionReaction('R1', {'MA', 'A', 'B', 'C'});
model.addReaction(reaction);
```

##### addInput

```matlab
addInput(inputSignal)
```

Add an external input signal.

**Inputs**:
- `inputSignal` (InputSignal) - Input signal object

**Example**:
```matlab
input = InputSignal('FGF', 0, 100, 5);
model.addInput(input);
```

##### addInhibitor

```matlab
addInhibitor(inhibitor)
```

Add an inhibitor/drug.

**Inputs**:
- `inhibitor` (Inhibitor) - Inhibitor object

**Example**:
```matlab
inhibitor = Inhibitor('FGFR2i', 0, 1, 30);
model.addInhibitor(inhibitor);
```

##### addReadout

```matlab
addReadout(readoutVariable)
```

Add a readout/observable variable.

**Inputs**:
- `readoutVariable` (ReadoutVariable) - Readout variable object

**Example**:
```matlab
readout = ReadoutVariable('Total_AKT', {'AKT', 'pAKT', 'aAKT'});
model.addReadout(readout);
```

##### extractAllStateVariables

```matlab
extractAllStateVariables()
```

Extract all state variables from reactions and inputs.

**Example**:
```matlab
model.extractAllStateVariables();
fprintf('Found %d state variables\n', model.stateVariables.length());
```

##### extractAllParameters

```matlab
extractAllParameters()
```

Extract all parameters from reactions.

**Example**:
```matlab
model.extractAllParameters();
fprintf('Found %d parameters\n', model.parameters.length());
```

##### validate

```matlab
isValid = validate()
```

Validate model consistency.

**Returns**:
- `isValid` (logical) - True if validation passes

##### getSummary

```matlab
summary = getSummary()
```

Get text summary of model.

**Returns**:
- `summary` (char) - Formatted summary string

---

### ModelConfiguration

**File**: `src/core/ModelConfiguration.m`

Configuration management for paths, options, and settings.

#### Constructor

```matlab
obj = ModelConfiguration()
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `paths` | struct | Path configurations |
| `options` | struct | Processing options |

#### Methods

##### setDefaultPaths

```matlab
setDefaultPaths()
```

Set default paths for all directories.

**Example**:
```matlab
config = ModelConfiguration();
config.setDefaultPaths();
```

##### loadFromFile

```matlab
loadFromFile(configFile)
```

Load configuration from file.

**Inputs**:
- `configFile` (char) - Path to configuration file

##### saveToFile

```matlab
saveToFile(configFile)
```

Save configuration to file.

**Inputs**:
- `configFile` (char) - Path to save configuration

##### validate

```matlab
isValid = validate()
```

Validate configuration.

**Returns**:
- `isValid` (logical) - True if valid

---

## Reaction Classes

### Reaction (Abstract Base Class)

**File**: `src/reactions/Reaction.m`

Abstract base class for all reaction types.

#### Abstract Methods

All concrete reaction classes must implement:

##### generateRateEquation

```matlab
rateEq = generateRateEquation()
```

Generate the mathematical rate equation string.

**Returns**:
- `rateEq` (char) - Rate equation string

##### getParameterNames

```matlab
params = getParameterNames()
```

Get all parameter names used by this reaction.

**Returns**:
- `params` (cell) - Cell array of parameter names

#### Inherited Methods

##### setSpecies

```matlab
setSpecies(substrates, products)
setSpecies(substrates, products, modifiers)
```

Set species involved in reaction.

**Inputs**:
- `substrates` (cell or char) - Substrate species names
- `products` (cell or char) - Product species names
- `modifiers` (cell or char, optional) - Modifier species

##### setRegulators

```matlab
setRegulators(activators, inhibitors)
```

Set regulatory species.

**Inputs**:
- `activators` (cell or char) - Activator names
- `inhibitors` (cell or char) - Inhibitor names

##### getProcessString

```matlab
procStr = getProcessString()
```

Get IQM process string representation.

**Returns**:
- `procStr` (char) - Process string (e.g., "A+B=>C:R1")

##### getAllSpecies

```matlab
species = getAllSpecies()
```

Get all species involved in reaction.

**Returns**:
- `species` (cell) - Unique species names

---

### Concrete Reaction Classes

#### MassActionReaction (Type: MA)

**File**: `src/reactions/MassActionReaction.m`

Reversible reaction: A + B <=> C

```matlab
reaction = MassActionReaction('R1', {'MA', 'A', 'B', 'C'})
reaction = MassActionReaction('R1', {'MA', 'A', 'B', 'C', '+ACT', '-INH'})
```

**Rate Equation**: `vf = (ka*A*B) / inhibitor_terms - kd*C`

**Parameters**:
- `ka_A_B_C` - Forward rate constant
- `kd_C_A_B` - Reverse rate constant
- `Ki_A_B_C_INH` - Inhibition constants (if inhibitors present)

#### AssociationReaction (Type: ASSO)

**File**: `src/reactions/AssociationReaction.m`

Irreversible association: A + B => C

```matlab
reaction = AssociationReaction('R1', {'ASSO', 'A', 'B', 'C'})
```

**Rate Equation**: `vf = ka*A*B / inhibitor_terms`

**Parameters**:
- `ka_A_B_C` - Association rate constant
- `Ki_A_B_C_INH` - Inhibition constants

#### DissociationReaction (Type: DISSO)

**File**: `src/reactions/DissociationReaction.m`

Complex dissociation: C => A + B

```matlab
reaction = DissociationReaction('R1', {'DISSO', 'C', 'A', 'B'})
```

**Rate Equation**: `vf = (kd*C) / inhibitor_terms`

**Parameters**:
- `kd_C_A_B` - Dissociation rate
- `Ki_C_A_B_INH` - Inhibition constants

#### MichaelisMentenShortReaction (Type: MMS)

**File**: `src/reactions/MichaelisMentenShortReaction.m`

Enzyme-catalyzed forward reaction: A => B (requires activators)

```matlab
reaction = MichaelisMentenShortReaction('R1', {'MMS', 'A', 'B', '+ENZ', '-INH'})
```

**Rate Equation**: `vf = (sum(kc*ACT)*A) / inh_terms - Vm*B`

**Parameters**:
- `kc_A_B_ACT` - Catalytic rates
- `Vm_B_A` - Reverse velocity
- `Ki_A_B_EMZ_INH` - Inhibition constants

#### MichaelisMentenFullReaction (Type: MMF)

**File**: `src/reactions/MichaelisMentenFullReaction.m`

Full Michaelis-Menten: A <=> B (reversible with Km, requires activators)

```matlab
reaction = MichaelisMentenFullReaction('R1', {'MMF', 'A', 'B', '+ENZ', '-INH'})
```

**Rate Equation**: `vf = (sum(kc*ACT)*A/(Km_act+A)) / inh - (Vm*B/(Km_B+B))`

**Parameters**:
- `kc_A_B_ACT` - Catalytic rates
- `Km_A_B_ACT` - Forward Michaelis constant
- `Vm_B_A` - Reverse velocity
- `Km_B_A` - Reverse Michaelis constant
- `Ki_A_B_EMZ_INH` - Inhibition constants

#### Synthesis Reactions (SYN0, SYNS, SYNF)

**ConstitutiveSynthesisReaction (Type: SYN0)**
```matlab
reaction = ConstitutiveSynthesisReaction('R1', {'SYN0', 'A'})
% Rate: Vsyn_A / inh_terms
```

**SimpleSynthesisReaction (Type: SYNS)**
```matlab
reaction = SimpleSynthesisReaction('R1', {'SYNS', 'A', '+TF1', '+TF2', '-INH'})
% Rate: sum(ksyn*ACT) / inh_terms
```

**RegulatedSynthesisReaction (Type: SYNF)**
```matlab
reaction = RegulatedSynthesisReaction('R1', {'SYNF', 'A', '+TF', '-INH'})
% Rate: sum(ksyn*act/(Km+act)) / inh_terms
```

#### Degradation Reactions (DEG0, DEGS, DEGF)

**PassiveDegradationReaction (Type: DEG0)**
```matlab
reaction = PassiveDegradationReaction('R1', {'DEG0', 'A'})
% Rate: (kdeg*A) / inh_terms
```

**SimpleDegradationReaction (Type: DEGS)**
```matlab
reaction = SimpleDegradationReaction('R1', {'DEGS', 'A', '+PROTEASE', '-INH'})
% Rate: sum(kdeg*A*ACT) / (Km+A) / inh_terms
```

**RegulatedDegradationReaction (Type: DEGF)**
```matlab
reaction = RegulatedDegradationReaction('R1', {'DEGF', 'A', '+PROTEASE', '-INH'})
% Similar to DEGS with full regulation
```

#### Translocation Reactions (TRN, TRNF)

**TranslocationReaction (Type: TRN)**
```matlab
reaction = TranslocationReaction('R1', {'TRN', 'A_cyt', 'A_nuc', '-INH'})
% Rate: (ktrn_A_cyt_A_nuc*A_cyt) / inh - ktrn_A_nuc_A_cyt*A_nuc
```

**RegulatedTranslocationReaction (Type: TRNF)**
```matlab
reaction = RegulatedTranslocationReaction('R1', {'TRNF', 'A_cyt', 'A_nuc', '-INH'})
% Forward translocation with inhibition
```

#### CatalyticReaction (Type: CAT)

**File**: `src/reactions/CatalyticReaction.m`

Catalyst-dependent synthesis: => A

```matlab
reaction = CatalyticReaction('R1', {'CAT', 'A', 'CATALYST'})
% Rate: kcat_A_CATALYST * CATALYST
```

---

### ReactionFactory

**File**: `src/reactions/ReactionFactory.m`

Factory class for creating reaction objects.

#### Static Methods

##### create

```matlab
reaction = ReactionFactory.create(type, substrates, products, regulators)
reaction = ReactionFactory.create(type, dataArray)
```

Create a reaction object of specified type.

**Inputs**:
- `type` (char) - Reaction type code (MA, ASSO, MMS, etc.)
- `dataArray` (cell) - Complete data array from Excel
- OR:
- `substrates` (cell) - Substrate species
- `products` (cell) - Product species
- `regulators` (cell) - Activators and inhibitors

**Returns**:
- `reaction` (Reaction) - Concrete reaction object

**Example**:
```matlab
% From data array
rxn = ReactionFactory.create('MA', {'MA', 'A', 'B', 'C', '+ENZ'});

% Using parameters
rxn = ReactionFactory.create('MMS', {'A'}, {'B'}, {'+ENZ', '-INH'});
```

##### getSupportedTypes

```matlab
types = ReactionFactory.getSupportedTypes()
```

Get list of supported reaction types.

**Returns**:
- `types` (cell) - Cell array of type codes

**Example**:
```matlab
types = ReactionFactory.getSupportedTypes();
disp(types);
% MA, ASSO, DISSO, MMS, MMF, MMSF, MMFF, MMSR, MMFR,
% SYN0, SYNS, SYNF, DEG0, DEGS, DEGF, TRN, TRNF, CAT
```

---

## Entity Classes

### StateVariable

**File**: `src/entities/StateVariable.m`

Represents a state variable (species concentration) in the model.

#### Constructor

```matlab
obj = StateVariable(name)
obj = StateVariable(name, initialValue)
obj = StateVariable(name, initialValue, units, description)
```

**Example**:
```matlab
var1 = StateVariable('FGFR2', 100);
var2 = StateVariable('pFGFR2', 0, 'nM', 'Phosphorylated FGFR2');
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | char | Variable name |
| `initialValue` | double | Initial concentration |
| `units` | char | Units (optional) |
| `description` | char | Description (optional) |

---

### Parameter

**File**: `src/entities/Parameter.m`

Represents a model parameter.

#### Constructor

```matlab
obj = Parameter(name)
obj = Parameter(name, value)
obj = Parameter(name, value, units, description)
```

**Example**:
```matlab
param1 = Parameter('ka_A_B_C', 0.1);
param2 = Parameter('ka_A_B_C', 0.1, '1/(nM*min)', 'Association rate');
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | char | Parameter name |
| `value` | double | Parameter value |
| `defaultValue` | double | Default value |
| `units` | char | Units |
| `description` | char | Description |
| `reactionType` | char | Which reaction uses this |

---

### InputSignal

**File**: `src/entities/InputSignal.m`

Represents an external input signal (stimulus).

#### Constructor

```matlab
obj = InputSignal(name, initialValue, activationConcentration, activationTime)
```

**Example**:
```matlab
signal = InputSignal('FGF', 0, 100, 5);
% FGF = 0 until t=5, then FGF = 100
```

#### Methods

##### getIQMEquation

```matlab
eqStr = getIQMEquation()
```

Get IQM format equation string.

**Returns**:
- `eqStr` (char) - IQM equation

**Example**:
```matlab
signal = InputSignal('FGF', 0, 100, 5);
eqStr = signal.getIQMEquation();
% Returns: "FGF = 0 * piecewiseIQM(1, ge(time, 5), 0) + 100 * piecewiseIQM(1, ge(time, 5), 1)"
```

---

### Inhibitor

**File**: `src/entities/Inhibitor.m`

Represents a drug or inhibitor.

#### Constructor

```matlab
obj = Inhibitor(name, initialValue, treatmentConcentration, treatmentTime)
```

**Example**:
```matlab
inhibitor = Inhibitor('FGFR2i', 0, 1, 30);
% Drug applied at t=30 with concentration 1
```

#### Methods

##### getIQMEquation

```matlab
eqStr = getIQMEquation()
```

Similar to InputSignal.

---

### ReadoutVariable

**File**: `src/entities/ReadoutVariable.m`

Represents a complex observable as sum of components.

#### Constructor

```matlab
obj = ReadoutVariable(name, components)
```

**Inputs**:
- `name` (char) - Readout name
- `components` (cell) - Component species names

**Example**:
```matlab
readout = ReadoutVariable('Total_AKT', {'AKT', 'pAKT', 'aAKT'});
```

#### Methods

##### getIQMEquation

```matlab
eqStr = getIQMEquation()
```

Get equation string.

**Returns**:
- `eqStr` (char) - Equation like "Total_AKT = AKT + pAKT + aAKT"

---

## Manager Classes

### ParameterManager

**File**: `src/managers/ParameterManager.m`

Manages model parameters and default values.

#### Constructor

```matlab
obj = ParameterManager()
obj = ParameterManager(defaultValuesFile)
```

#### Methods

##### loadDefaults

```matlab
loadDefaults()
```

Load default parameter values from file.

##### extractFromModel

```matlab
extractFromModel(biologicalModel)
```

Extract parameters from biological model.

**Inputs**:
- `biologicalModel` (BiologicalModel) - Model to extract from

##### assignDefaultValues

```matlab
assignDefaultValues()
```

Assign default values to parameters.

##### exportToExcel

```matlab
exportToExcel(outputFile)
```

Export parameter table to Excel.

**Inputs**:
- `outputFile` (char) - Output file path

##### getParameterTable

```matlab
table = getParameterTable()
```

Get parameter table as MATLAB table.

**Returns**:
- `table` (table) - Parameter table

---

### StateVariableManager

**File**: `src/managers/StateVariableManager.m`

Manages state variables and initial conditions.

#### Constructor

```matlab
obj = StateVariableManager()
```

#### Methods

##### extractFromModel

```matlab
extractFromModel(biologicalModel)
```

Extract state variables from model.

**Inputs**:
- `biologicalModel` (BiologicalModel) - Model to extract from

##### removeInputsFromStates

```matlab
removeInputsFromStates(inputs)
```

Remove input signals from state variables.

**Inputs**:
- `inputs` (cell) - Array of InputSignal objects

##### validateAgainstReactions

```matlab
validateAgainstReactions(reactions)
```

Validate state variables against reactions.

**Inputs**:
- `reactions` (cell) - Array of Reaction objects

##### exportToExcel

```matlab
exportToExcel(outputFile)
```

Export state variable table to Excel.

**Inputs**:
- `outputFile` (char) - Output file path

##### getStateVariableTable

```matlab
table = getStateVariableTable()
```

Get state variable table.

**Returns**:
- `table` (table) - State variable table

---

## I/O Classes

### ExcelModelReader

**File**: `src/io/ExcelModelReader.m`

Reads and parses Excel input files.

#### Constructor

```matlab
obj = ExcelModelReader(filePath)
```

**Example**:
```matlab
reader = ExcelModelReader('models/FGFR2.xlsx');
```

#### Methods

##### readFile

```matlab
readFile()
```

Read and parse Excel file.

##### parseMapSheet

```matlab
parseMapSheet()
```

Parse reaction map sheet.

##### parseInputSheet

```matlab
parseInputSheet()
```

Parse input signals sheet.

##### parseInhibitorSheet

```matlab
parseInhibitorSheet()
```

Parse inhibitor sheet.

##### parseReadoutSheet

```matlab
parseReadoutSheet()
```

Parse readout variables sheet.

##### validate

```matlab
isValid = validate()
```

Validate parsed data.

**Returns**:
- `isValid` (logical) - True if valid

##### createModel

```matlab
model = createModel()
```

Create BiologicalModel from parsed data.

**Returns**:
- `model` (BiologicalModel) - Created model

**Example**:
```matlab
reader = ExcelModelReader('model.xlsx');
reader.readFile();
model = reader.createModel();
```

---

### IQMExporter

**File**: `src/io/IQMExporter.m`

Exports model to IQMtools format and generates ODE/MEX files.

#### Constructor

```matlab
obj = IQMExporter(biologicalModel, outputDir)
```

**Example**:
```matlab
exporter = IQMExporter(model, 'output/my_model');
```

#### Methods

##### exportToTxtbc

```matlab
exportToTxtbc(filename)
```

Export model to IQM txtbc format.

**Inputs**:
- `filename` (char) - Output filename

##### loadIntoIQMtools

```matlab
loadIntoIQMtools()
```

Load exported model into IQMtools.

##### generateODEFile

```matlab
generateODEFile(filename)
```

Generate ODE M-file.

**Inputs**:
- `filename` (char) - Base filename (without extension)

##### compileMEX

```matlab
compileMEX(filename)
```

Compile MEX file (requires IQMtools).

**Inputs**:
- `filename` (char) - Base filename

##### runFullExport

```matlab
runFullExport()
```

Run all export steps.

---

## Utility Classes

### PathHelper

**File**: `src/utils/PathHelper.m`

Utility functions for path handling.

#### Static Methods

```matlab
% Check if path exists
isValid = PathHelper.validatePath(path)

% Create directory if it doesn't exist
PathHelper.ensureDirectory(path)

% Get absolute path
absPath = PathHelper.getAbsolutePath(relativePath)

% Join path components
fullPath = PathHelper.joinPath(basePath, component1, component2, ...)
```

---

### ValidationHelper

**File**: `src/utils/ValidationHelper.m`

Utility functions for validation.

#### Static Methods

```matlab
% Validate species name
isValid = ValidationHelper.validateSpeciesName(name)

% Validate parameter name
isValid = ValidationHelper.validateParameterName(name)

% Check for duplicate names
hasDuplicates = ValidationHelper.hasDuplicates(names)
```

---

### LoggerUtility

**File**: `src/utils/LoggerUtility.m`

Logging utility for diagnostic output.

#### Static Methods

```matlab
% Log message
LoggerUtility.log(message)

% Log warning
LoggerUtility.warn(message)

% Log error
LoggerUtility.error(message)

% Set verbosity level
LoggerUtility.setVerboseMode(enabled)
```

---

## Usage Examples

### Example 1: Complete Pipeline

```matlab
% Create builder
builder = ODEModelBuilder();

% Load model
builder.loadModel('model.xlsx', 'MyModel');

% Generate equations
builder.generateRateEquations();

% Validate
if ~builder.validateModel()
    error('Validation failed');
end

% Export tables
builder.exportParameterTable('output/params.xlsx');
builder.exportStateVariableTable('output/states.xlsx');

% Export to IQM
builder.exportToIQM('output/model.txtbc');

% Generate code
builder.generateODEFile('output/model_ode');
builder.compileMEX('output/model_mex');
```

### Example 2: Programmatic Model Building

```matlab
% Create model
model = BiologicalModel('TestModel');
factory = ReactionFactory();

% Add reactions
r1 = factory.create('MA', {'A', 'B'}, {'C'}, {});
model.addReaction(r1);

r2 = factory.create('MMS', {'C'}, {'D'}, {'+A'});
model.addReaction(r2);

% Add signals
model.addInput(InputSignal('A', 0, 100, 5));

% Extract species
model.extractAllStateVariables();
model.extractAllParameters();

% Export
builder = ODEModelBuilder();
builder.model = model;
builder.exportToIQM('output/test.txtbc');
```

### Example 3: Custom Configuration

```matlab
% Create configuration
config = ModelConfiguration();
config.setDefaultPaths();

% Customize paths
config.paths.outputDir = 'my_output';
config.paths.defaultParameters = 'my_defaults.xlsx';

% Customize options
config.options.validateOnLoad = true;
config.options.generateMEX = false;

% Use in builder
builder = ODEModelBuilder(config);
builder.runFullPipeline('model.xlsx', 'my_output/model1');
```

---

**Last Updated**: November 2025

**Version**: 3.0.0
