# ODE Model Creator - Object-Oriented Architecture Design

## Overview
This document describes the refactored object-oriented architecture for the ODE Model Creator system.

## Design Principles
1. **Separation of Concerns**: Each class has a single, well-defined responsibility
2. **Open-Closed Principle**: Open for extension (new reaction types), closed for modification
3. **Dependency Injection**: Configuration and dependencies passed through constructors
4. **Encapsulation**: Internal details hidden, clean public APIs
5. **Testability**: Each component can be tested independently

---

## Class Hierarchy and Architecture

```
ODEModelBuilder (Main Facade)
    ├── ModelConfiguration (Configuration management)
    ├── BiologicalModel (Data model)
    │   ├── Reaction[] (Collection of reactions)
    │   ├── StateVariable[] (Collection of state variables)
    │   ├── Parameter[] (Collection of parameters)
    │   ├── InputSignal[] (External inputs)
    │   ├── Inhibitor[] (Drugs/inhibitors)
    │   └── ReadoutVariable[] (Complex observables)
    │
    ├── ExcelModelReader (Input parsing)
    ├── ReactionFactory (Reaction object creation)
    │   └── Creates concrete Reaction subclasses
    │
    ├── ParameterManager (Parameter handling)
    ├── StateVariableManager (State variable handling)
    └── IQMExporter (Output generation)

Reaction (Abstract Base Class)
    ├── MassActionReaction
    ├── AssociationReaction
    ├── DissociationReaction
    ├── MichaelisMentenShortReaction
    ├── MichaelisMentenFullReaction
    ├── MichaelisMentenShortWithFeedbackReaction
    ├── MichaelisMentenFullFeedbackReaction
    ├── MichaelisMentenShortReverseReaction
    ├── MichaelisMentenFullReverseReaction
    ├── ConstitutiveSynthesisReaction
    ├── SimpleSynthesisReaction
    ├── RegulatedSynthesisReaction
    ├── PassiveDegradationReaction
    ├── SimpleDegradationReaction
    ├── RegulatedDegradationReaction
    ├── TranslocationReaction
    ├── RegulatedTranslocationReaction
    └── CatalyticReaction
```

---

## Core Classes

### 1. ODEModelBuilder (Main Facade)

**Responsibility**: Main entry point that orchestrates the entire workflow

**Properties**:
- `config` (ModelConfiguration): Configuration settings
- `model` (BiologicalModel): The biological network model
- `reader` (ExcelModelReader): Input file parser
- `factory` (ReactionFactory): Reaction object factory
- `paramManager` (ParameterManager): Parameter handler
- `stateManager` (StateVariableManager): State variable handler
- `exporter` (IQMExporter): Output file generator

**Methods**:
```matlab
% Constructor
builder = ODEModelBuilder(configFile)

% Main workflow
builder.loadModel(excelFile)
builder.generateRateEquations()
builder.validateModel()
builder.exportParameterTable(outputFile)
builder.exportStateVariableTable(outputFile)
builder.exportToIQM(outputFile)
builder.generateODEFile(outputFile)
builder.compileMEX(outputFile)

% Convenience method - runs entire pipeline
builder.runFullPipeline(inputExcelFile, outputDir)
```

---

### 2. BiologicalModel (Data Model)

**Responsibility**: Represents the complete biological network model

**Properties**:
```matlab
name            % Model name
description     % Model description
reactions       % Cell array of Reaction objects
stateVariables  % Map of StateVariable objects (key: name)
parameters      % Map of Parameter objects (key: name)
inputs          % Cell array of InputSignal objects
inhibitors      % Cell array of Inhibitor objects
readouts        % Cell array of ReadoutVariable objects
metadata        % Struct with creation date, version, etc.
```

**Methods**:
```matlab
model = BiologicalModel(name)
model.addReaction(reaction)
model.addInput(inputSignal)
model.addInhibitor(inhibitor)
model.addReadout(readoutVariable)
model.extractAllStateVariables()
model.extractAllParameters()
isValid = model.validate()
summary = model.getSummary()
```

---

### 3. Reaction (Abstract Base Class)

**Responsibility**: Defines the interface for all reaction types

**Properties** (Abstract):
```matlab
type            % Reaction type string (e.g., 'MA', 'ASSO', 'MMS')
substrates      % Cell array of substrate species names
products        % Cell array of product species names
activators      % Cell array of activator names
inhibitors      % Cell array of inhibitor names
rateEquation    % String representation of rate equation
parameters      % Cell array of parameter names with defaults
metadata        % Additional reaction information
```

**Abstract Methods**:
```matlab
% Generate the mathematical rate equation string
rateEq = generateRateEquation(obj)

% Get all parameter names used by this reaction
params = getParameterNames(obj)

% Get all species involved in this reaction
species = getSpeciesNames(obj)

% Validate reaction structure
isValid = validate(obj)

% Get reaction description
desc = getDescription(obj)
```

---

### 4. Concrete Reaction Classes

Each reaction type implements the abstract Reaction class:

#### 4.1 MassActionReaction (Type: MA)
- **Reaction**: `A + B <=> C`
- **Parameters**: `ka_A_B_C` (forward), `kd_C_A_B` (reverse)
- **Rate Equation**: `ka_A_B_C * A * B - kd_C_A_B * C`

#### 4.2 AssociationReaction (Type: ASSO)
- **Reaction**: `A + B => C`
- **Parameters**: `ka_A_B_C`
- **Rate Equation**: `ka_A_B_C * A * B`

#### 4.3 MichaelisMentenShortReaction (Type: MMS)
- **Reaction**: `A => B` (enzyme-activated)
- **Parameters**: `kc_A_B_ENZ`, `Vm_B_A`
- **Rate Equation**: Complex Michaelis-Menten with activators/inhibitors

... (similar for all 18 types)

---

### 5. ReactionFactory

**Responsibility**: Creates appropriate Reaction objects based on type

**Static Methods**:
```matlab
% Create reaction from type and data
reaction = ReactionFactory.create(type, substrateData, productData, regulatorData)

% Examples:
reaction = ReactionFactory.create('MA', {'A', 'B'}, {'C'}, {'+ENZ', '-INH'})
reaction = ReactionFactory.create('MMS', {'FGFR2'}, {'pFGFR2'}, {'+FGF', '-FGFR2i'})

% Get list of supported reaction types
types = ReactionFactory.getSupportedTypes()

% Get reaction class from type string
className = ReactionFactory.getReactionClass('MMS')
```

---

### 6. ExcelModelReader

**Responsibility**: Reads and parses Excel input files

**Properties**:
```matlab
filePath        % Path to Excel file
rawData         % Cell array of raw data from sheets
mapSheet        % Parsed reaction map
inputSheet      % Parsed input signals
inhibitorSheet  % Parsed inhibitors
readoutSheet    % Parsed readout variables
```

**Methods**:
```matlab
reader = ExcelModelReader(filePath)
reader.readFile()
reader.parseMapSheet()
reader.parseInputSheet()
reader.parseInhibitorSheet()
reader.parseReadoutSheet()
isValid = reader.validate()
model = reader.createModel()  % Returns BiologicalModel object
```

---

### 7. ParameterManager

**Responsibility**: Manages model parameters and default values

**Properties**:
```matlab
parameters      % Map of Parameter objects
defaultValues   % Table loaded from default_parameter_value.xlsx
outputPath      % Path for exported parameter table
```

**Methods**:
```matlab
manager = ParameterManager(defaultValuesFile)
manager.loadDefaults()
manager.extractFromModel(biologicalModel)
manager.assignDefaultValues()
manager.exportToExcel(outputFile)
table = manager.getParameterTable()
manager.validateParameterNames()
```

---

### 8. StateVariableManager

**Responsibility**: Manages state variables and initial conditions

**Properties**:
```matlab
stateVariables  % Map of StateVariable objects
inputs          % Input signals to exclude from state variables
outputPath      % Path for exported state variable table
```

**Methods**:
```matlab
manager = StateVariableManager()
manager.extractFromModel(biologicalModel)
manager.removeInputsFromStates(inputs)
manager.validateAgainstReactions(reactions)
manager.exportToExcel(outputFile)
table = manager.getStateVariableTable()
```

---

### 9. IQMExporter

**Responsibility**: Exports model to IQM txtbc format and generates ODE/MEX files

**Properties**:
```matlab
model           % BiologicalModel object
outputDir       % Output directory path
txtbcFile       % Generated txtbc file path
odeFile         % Generated ODE m-file path
mexFile         % Generated MEX file path
iqmModel        % IQMtools model object
```

**Methods**:
```matlab
exporter = IQMExporter(biologicalModel, outputDir)
exporter.exportToTxtbc(filename)
exporter.loadIntoIQMtools()
exporter.generateODEFile(filename)
exporter.compileMEX(filename)
exporter.runFullExport()  % Runs all steps
```

---

### 10. ModelConfiguration

**Responsibility**: Manages configuration settings

**Properties**:
```matlab
paths           % Struct with all path configurations
options         % Struct with processing options
iqmToolsPath    % Path to IQMtools installation
defaultParamFile % Path to default parameter values
```

**Methods**:
```matlab
config = ModelConfiguration()
config.loadFromFile(configFile)
config.saveToFile(configFile)
isValid = config.validate()
config.setDefaultPaths()
```

---

## Supporting Classes

### 11. StateVariable

**Properties**:
```matlab
name            % Variable name (e.g., 'FGFR2', 'pFGFR2')
initialValue    % Initial concentration/amount
units           % Units (optional)
description     % Description (optional)
```

---

### 12. Parameter

**Properties**:
```matlab
name            % Parameter name (e.g., 'ka_FGFR2_pFGFR2_FGF')
value           % Numerical value
defaultValue    % Default value from database
units           % Units (optional)
description     % Description (optional)
reactionType    % Which reaction type uses this parameter
```

---

### 13. InputSignal

**Properties**:
```matlab
name            % Signal name (e.g., 'FGF', 'IGF')
initialValue    % Initial concentration
activationTime  % Time when signal is applied
```

**Methods**:
```matlab
signal = InputSignal(name, initialValue, activationTime)
eqStr = signal.getIQMEquation()
% Returns: "FGF = FGF_0 * piecewiseIQM(1, ge(time, FGF_on), 0)"
```

---

### 14. Inhibitor

**Properties**:
```matlab
name            % Inhibitor name (e.g., 'FGFR2i', 'PI3Ki')
initialValue    % Initial concentration
activationTime  % Time when inhibitor is applied
```

**Methods**:
```matlab
inhibitor = Inhibitor(name, initialValue, activationTime)
eqStr = inhibitor.getIQMEquation()
```

---

### 15. ReadoutVariable

**Properties**:
```matlab
name            % Readout variable name (e.g., 'Total_AKT')
components      % Cell array of component variable names
```

**Methods**:
```matlab
readout = ReadoutVariable(name, components)
eqStr = readout.getIQMEquation()
% Returns: "Total_AKT = AKT + pAKT + aAKT"
```

---

## Folder Structure (New)

```
ODEModelCreator/
├── README.md
├── CHANGELOG.md
├── LICENSE.txt
├── config/
│   ├── default_config.m
│   └── default_parameter_values.xlsx
│
├── src/
│   ├── core/
│   │   ├── ODEModelBuilder.m
│   │   ├── BiologicalModel.m
│   │   └── ModelConfiguration.m
│   │
│   ├── reactions/
│   │   ├── Reaction.m (abstract base class)
│   │   ├── ReactionFactory.m
│   │   ├── MassActionReaction.m
│   │   ├── AssociationReaction.m
│   │   ├── DissociationReaction.m
│   │   ├── MichaelisMentenShortReaction.m
│   │   ├── MichaelisMentenFullReaction.m
│   │   ├── MichaelisMentenShortWithFeedbackReaction.m
│   │   ├── MichaelisMentenFullFeedbackReaction.m
│   │   ├── MichaelisMentenShortReverseReaction.m
│   │   ├── MichaelisMentenFullReverseReaction.m
│   │   ├── ConstitutiveSynthesisReaction.m
│   │   ├── SimpleSynthesisReaction.m
│   │   ├── RegulatedSynthesisReaction.m
│   │   ├── PassiveDegradationReaction.m
│   │   ├── SimpleDegradationReaction.m
│   │   ├── RegulatedDegradationReaction.m
│   │   ├── TranslocationReaction.m
│   │   ├── RegulatedTranslocationReaction.m
│   │   └── CatalyticReaction.m
│   │
│   ├── io/
│   │   ├── ExcelModelReader.m
│   │   ├── IQMExporter.m
│   │   └── ExcelWriter.m
│   │
│   ├── managers/
│   │   ├── ParameterManager.m
│   │   └── StateVariableManager.m
│   │
│   ├── entities/
│   │   ├── StateVariable.m
│   │   ├── Parameter.m
│   │   ├── InputSignal.m
│   │   ├── Inhibitor.m
│   │   └── ReadoutVariable.m
│   │
│   └── utils/
│       ├── PathHelper.m
│       ├── ValidationHelper.m
│       └── LoggerUtility.m
│
├── examples/
│   ├── FGFR2_model_ver_01/
│   │   ├── FGFR2_model_ver_01.xlsx
│   │   └── run_example_01.m
│   │
│   ├── FGFR2_model_ver_02/
│   │   ├── FGFR2_model_ver_02.xlsx
│   │   └── run_example_02.m
│   │
│   └── template/
│       └── model_template.xlsx
│
├── tests/
│   ├── test_reactions/
│   │   ├── testMassActionReaction.m
│   │   ├── testAssociationReaction.m
│   │   └── ... (tests for each reaction type)
│   │
│   ├── test_integration/
│   │   └── testFullPipeline.m
│   │
│   └── test_data/
│       └── simple_model.xlsx
│
├── docs/
│   ├── UserGuide.md
│   ├── DeveloperGuide.md
│   ├── ReactionTypeReference.md
│   ├── ParameterNamingConventions.md
│   └── API_Documentation.md
│
└── output/
    └── .gitkeep
```

---

## Usage Examples

### Example 1: Basic Usage (Simplified Workflow)

```matlab
% Create builder with configuration
builder = ODEModelBuilder('config/default_config.m');

% Run complete pipeline
builder.runFullPipeline(...
    'examples/FGFR2_model_ver_02/FGFR2_model_ver_02.xlsx', ...
    'output/FGFR2_model_ver_02');

% Output files created:
% - output/FGFR2_model_ver_02/table_parameter.xlsx
% - output/FGFR2_model_ver_02/table_statevariable.xlsx
% - output/FGFR2_model_ver_02/FGFR2_model_ver_02.txtbc
% - output/FGFR2_model_ver_02/FGFR2_model_ver_02_ode.m
% - output/FGFR2_model_ver_02/FGFR2_model_ver_02_mex.mexw64
```

### Example 2: Step-by-Step Control

```matlab
% Create configuration
config = ModelConfiguration();
config.setDefaultPaths();

% Create builder
builder = ODEModelBuilder(config);

% Load model from Excel
builder.loadModel('examples/FGFR2_model_ver_02/FGFR2_model_ver_02.xlsx');

% Generate rate equations
builder.generateRateEquations();

% Validate model
if builder.validateModel()
    disp('Model validation successful');
end

% Export parameter and state variable tables
builder.exportParameterTable('output/table_parameter.xlsx');
builder.exportStateVariableTable('output/table_statevariable.xlsx');

% User edits tables manually here...
pause;

% Export to IQM format
builder.exportToIQM('output/model.txtbc');

% Generate ODE and MEX files
builder.generateODEFile('output/model_ode');
builder.compileMEX('output/model_mex');
```

### Example 3: Programmatic Model Creation

```matlab
% Create empty model
model = BiologicalModel('MyCustomModel');

% Add reactions programmatically
factory = ReactionFactory();

% Add mass action reaction: A + B <=> C
reaction1 = factory.create('MA', {'A', 'B'}, {'C'}, {});
model.addReaction(reaction1);

% Add Michaelis-Menten reaction: FGFR2 => pFGFR2 (activated by FGF)
reaction2 = factory.create('MMS', {'FGFR2'}, {'pFGFR2'}, {'+FGF'});
model.addReaction(reaction2);

% Add input signal
model.addInput(InputSignal('FGF', 10, 5000));

% Extract state variables and parameters
model.extractAllStateVariables();
model.extractAllParameters();

% Validate
if model.validate()
    % Export using builder
    builder = ODEModelBuilder(ModelConfiguration());
    builder.model = model;
    builder.exportToIQM('output/custom_model.txtbc');
end
```

---

## Benefits of OO Design

1. **Maintainability**: Clear separation of concerns, easy to understand
2. **Extensibility**: New reaction types can be added without modifying existing code
3. **Testability**: Each class can be unit tested independently
4. **Reusability**: Components can be used in different contexts
5. **Readability**: Code structure matches domain concepts
6. **Error Handling**: Better validation and error messages at each level
7. **Configuration**: Centralized configuration management
8. **Documentation**: Self-documenting through class interfaces

---

## Migration Path from Current Code

1. **Phase 1**: Create class structure and interfaces
2. **Phase 2**: Migrate reaction modules (18 files) to reaction classes
3. **Phase 3**: Create IO classes (ExcelModelReader, IQMExporter)
4. **Phase 4**: Create manager classes (ParameterManager, StateVariableManager)
5. **Phase 5**: Create main ODEModelBuilder facade
6. **Phase 6**: Create tests for all components
7. **Phase 7**: Create examples and documentation
8. **Phase 8**: Archive old code

---

## Design Patterns Used

1. **Facade Pattern**: ODEModelBuilder provides simple interface to complex subsystem
2. **Factory Pattern**: ReactionFactory creates appropriate reaction objects
3. **Strategy Pattern**: Different reaction types implement same interface differently
4. **Template Method Pattern**: Reaction base class defines workflow, subclasses implement details
5. **Builder Pattern**: BiologicalModel built incrementally
6. **Singleton Pattern**: ModelConfiguration (optional)

---

This OO architecture provides a robust, maintainable, and extensible foundation for the ODE Model Creator system.
