# Changelog - ODE Model Creator

All notable changes to the ODE Model Creator project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-11-08

### Overview

Complete refactoring from procedural MATLAB scripts to a professional object-oriented architecture. This major release provides a robust, maintainable, and extensible foundation for biological ODE model creation.

### Major Changes

#### Architecture

- **Complete OO Refactoring**: Migrated from procedural scripts to object-oriented design
- **Design Patterns**: Implemented Factory, Facade, Strategy, and Builder patterns
- **Modular Structure**: Organized code into logical modules (core, reactions, io, managers, entities, utils)
- **Separation of Concerns**: Each class has a single, well-defined responsibility

#### New Class Structure

**Core Classes**:
- `ODEModelBuilder` - Main facade orchestrating the workflow
- `BiologicalModel` - Represents the complete biological network
- `ModelConfiguration` - Configuration management system
- `ReactionFactory` - Factory for creating reaction objects

**Reaction Classes** (18 total):
- Abstract base class `Reaction` defining common interface
- 2 existing classes: `MassActionReaction`, `AssociationReaction`
- 16 new classes implementing all reaction types:
  - `DissociationReaction`
  - `MichaelisMentenShortReaction`
  - `MichaelisMentenFullReaction`
  - `MichaelisMentenShortFeedbackReaction`
  - `MichaelisMentenFullFeedbackReaction`
  - `MichaelisMentenShortReverseReaction`
  - `MichaelisMentenFullReverseReaction`
  - `ConstitutiveSynthesisReaction`
  - `SimpleSynthesisReaction`
  - `RegulatedSynthesisReaction`
  - `PassiveDegradationReaction`
  - `SimpleDegradationReaction`
  - `RegulatedDegradationReaction`
  - `TranslocationReaction`
  - `RegulatedTranslocationReaction`
  - `CatalyticReaction`

**Manager Classes**:
- `ParameterManager` - Handles parameter extraction and defaults
- `StateVariableManager` - Manages state variables and initial conditions

**I/O Classes**:
- `ExcelModelReader` - Excel file parsing
- `IQMExporter` - IQM format export and code generation

**Entity Classes**:
- `StateVariable` - Represents a molecular species
- `Parameter` - Represents a kinetic parameter
- `InputSignal` - External stimuli
- `Inhibitor` - Drugs/inhibitors
- `ReadoutVariable` - Observable/measurement variables

**Utility Classes**:
- `PathHelper` - Path and directory utilities
- `ValidationHelper` - Input validation utilities
- `LoggerUtility` - Consistent logging

### Features

#### New Capabilities

- **Unified Reaction Interface**: All 18 reaction types implement common interface
- **Flexible Input**: Support for both Excel-based and programmatic model creation
- **Better Validation**: Comprehensive input validation at all levels
- **Configuration System**: Centralized configuration management
- **Improved Error Handling**: Descriptive error messages and validation feedback
- **Type Safety**: Better class structure with clear contracts

#### Enhanced Workflow

```matlab
% Simple one-liner
builder = ODEModelBuilder();
builder.runFullPipeline('model.xlsx', 'output/model');

% Or step-by-step with more control
builder = ODEModelBuilder();
builder.loadModel('model.xlsx');
builder.generateRateEquations();
builder.validateModel();
builder.exportParameterTable('output/params.xlsx');
builder.exportStateVariableTable('output/states.xlsx');
builder.exportToIQM('output/model.txtbc');
builder.generateODEFile('output/model_ode');
builder.compileMEX('output/model_mex');
```

### Breaking Changes

#### Migration Required

The refactoring introduces breaking changes from version 2.0.0:

1. **No More Direct Script Execution**:
   - Old: Run `model_creator_master.m` directly
   - New: Use `ODEModelBuilder` class
   - Migration: Wrap old script calls in builder methods

2. **Excel Format Unchanged**:
   - Input Excel files remain compatible
   - Same sheet names and column headers
   - No changes needed to existing model files

3. **Output Structure Changes**:
   - Parameter/state variable tables now generated automatically
   - File organization improved
   - Output paths controlled via configuration

4. **Configuration File Changes**:
   - Old: Manual path setup in scripts
   - New: `ModelConfiguration` object with `setDefaultPaths()`
   - Migration: Create config file or use default paths

5. **Reaction Creation Changes**:
   - Old: Direct reaction module function calls
   - New: `ReactionFactory.create()` or class constructors
   - Migration: Use factory for programmatic creation

#### Migration Guide: v2.0.0 to v3.0.0

##### Before (v2.0.0)
```matlab
% Old procedural style
addpath('src/rateEquations');
addpath('src/io');

% Manually read Excel
[reactions, params, states] = load_from_excel('model.xlsx');

% Manually generate equations
for i = 1:length(reactions)
    reactions{i} = generate_rate_eq(reactions{i});
end

% Manually export
export_to_iqm(reactions, 'output/model.txtbc');
```

##### After (v3.0.0)
```matlab
% New OO style - much simpler
addpath(genpath('src'));

builder = ODEModelBuilder();
builder.runFullPipeline('model.xlsx', 'output/model');
```

#### Detailed Migration Steps

**Step 1: Update MATLAB Path**
```matlab
% Old
addpath('src/rateEquations');
addpath('src/io');
addpath('src/utilities');

% New
addpath(genpath('src'));
addpath('config');
```

**Step 2: Replace Script Calls with Builder**
```matlab
% Old - run_model_creator.m
clear all; clc;
% ... manual setup code ...

% New
clear all; clc;
builder = ODEModelBuilder();
builder.runFullPipeline('models/mymodel.xlsx', 'output/mymodel');
```

**Step 3: Configuration Management**
```matlab
% Old - manual path setup
iqm_path = 'C:\IQMtools';
output_path = 'output';
param_defaults = 'config/defaults.xlsx';

% New
config = ModelConfiguration();
config.setDefaultPaths();
config.paths.iqmTools = 'C:\IQMtools';
builder = ODEModelBuilder(config);
```

**Step 4: Custom Reaction Creation**
```matlab
% Old - direct module use
reaction = MA_reaction(substrates, products, params);

% New - using factory
factory = ReactionFactory();
reaction = factory.create('MA', substrates, products, {});
% Or directly
reaction = MassActionReaction('R1', dataArray);
```

**Step 5: Parameter Management**
```matlab
% Old - manual parameter extraction
params = extract_parameters(reactions);
params = assign_defaults(params, defaults_table);

% New - automatic
builder.model.extractAllParameters();
paramManager = ParameterManager('config/defaults.xlsx');
paramManager.extractFromModel(builder.model);
paramManager.assignDefaultValues();
```

### Deprecated Features

The following v2.0.0 functions are deprecated in v3.0.0:

- `step1_model_creator_master.m` - Use `ODEModelBuilder.runFullPipeline()` instead
- `step2_generate_IQM_txtbc.m` - Use `ODEModelBuilder.exportToIQM()` instead
- `step3_make_MEX_file.m` - Use `ODEModelBuilder.compileMEX()` instead
- Direct reaction module functions - Use `ReactionFactory.create()` instead

### Removed Features

- Legacy MATLAB 2015 compatibility code
- Deprecated parameter parsing functions
- Old configuration file format

### New Files Added

#### Source Files (32 total)
```
src/
├── core/
│   ├── ODEModelBuilder.m
│   ├── BiologicalModel.m
│   └── ModelConfiguration.m
├── reactions/
│   ├── Reaction.m
│   ├── ReactionFactory.m
│   ├── MassActionReaction.m
│   ├── AssociationReaction.m
│   └── [16 more reaction classes]
├── io/
│   ├── ExcelModelReader.m
│   └── IQMExporter.m
├── managers/
│   ├── ParameterManager.m
│   └── StateVariableManager.m
├── entities/
│   ├── StateVariable.m
│   ├── Parameter.m
│   ├── InputSignal.m
│   ├── Inhibitor.m
│   └── ReadoutVariable.m
└── utils/
    ├── PathHelper.m
    ├── ValidationHelper.m
    └── LoggerUtility.m
```

#### Documentation Files
```
docs/
├── UserGuide.md
├── API_Documentation.md
├── ReactionTypeReference.md
└── ParameterNamingConventions.md
```

#### Configuration Files
```
config/
├── default_config.m
└── default_parameter_values.xlsx
```

### Bug Fixes

Since v2.0.0:
- Fixed parameter naming inconsistencies across reaction types
- Improved error handling for malformed Excel input
- Better validation of reaction data
- Fixed MEX compilation issues on Windows
- Improved IQMtools integration

### Performance

- Faster Excel file parsing
- Reduced memory usage through better object management
- Lazy loading of IQMtools components
- More efficient parameter extraction

### Documentation

#### New Documentation
- Complete API reference with method signatures
- User guide with step-by-step workflows
- Comprehensive reaction type reference with examples
- Parameter naming convention guide

#### Improved Documentation
- Inline code comments with examples
- Class-level documentation
- Method signatures with input/output specifications
- Usage examples for all major classes

### Development

#### Code Quality
- MATLAB code style guidelines followed
- Consistent naming conventions
- Clear separation of concerns
- Comprehensive method documentation

#### Testing
- Unit tests for all reaction types
- Integration tests for full pipeline
- Test data and fixtures provided
- Example models included

### Dependencies

#### Required
- MATLAB R2016b or later (for OO features)
- IQMtools (for MEX compilation)

#### Optional
- Spreadsheet Link EX (for enhanced Excel integration)
- Optimization Toolbox (for parameter fitting workflows)

### Upgrade Instructions

#### For Users

1. **Backup existing models**: Save all Excel model files
2. **Update MATLAB path**: Use new directory structure
3. **Update scripts**: Replace old script calls with builder
4. **Test with example**: Run `examples/FGFR2_model_ver_02/run_example_02.m`
5. **Validate models**: Check that output files are identical to v2.0.0

#### For Developers

1. **Study new architecture**: Review `OO_DESIGN_ARCHITECTURE.md`
2. **Explore examples**: Check examples/ folder for usage patterns
3. **Review API docs**: Read `API_Documentation.md` for class details
4. **Run tests**: Execute test suite to validate installation
5. **Read source code**: Study implementation of key classes

### Known Issues

- MEX compilation may fail on some Linux systems (use ODE file instead)
- IQMtools path must be set before MEX compilation
- Excel files with merged cells may cause parsing errors

### Future Roadmap

#### Version 3.1 (Planned)
- GUI for model creation
- Parameter estimation integration
- Sensitivity analysis tools
- Visualization utilities

#### Version 3.2 (Planned)
- Support for stochastic simulations
- SBML import/export
- Advanced model validation
- Simulation result visualization

#### Version 4.0 (Future)
- Complete rewrite in Python
- Cloud-based model sharing
- Advanced analysis tools
- Machine learning integration

### Contributors

**Version 3.0.0 Refactoring**:
- Object-Oriented Architecture Team
- MATLAB Code Implementation
- Documentation Development

**Original Version 2.0.0**:
- Original development team and contributors

### Acknowledgments

- Built on the foundation of ODE Model Creator v2.0.0
- Inspired by MATLAB best practices and design patterns
- Thanks to IQMtools for excellent ODE integration tools

---

## [2.0.0] - Previous Release

### Legacy v2.0.0 Features
- Procedural MATLAB implementation
- Support for 18 reaction types
- Excel-based model specification
- IQMtools integration
- Parameter and state variable extraction

### Why Upgrade to 3.0.0?

| Feature | v2.0.0 | v3.0.0 |
|---------|--------|--------|
| Code Organization | Procedural | Object-Oriented |
| Maintainability | Difficult | Easy |
| Extensibility | Requires code modification | Add new classes |
| Error Messages | Generic | Descriptive |
| Documentation | Minimal | Comprehensive |
| Testing | Manual | Automated |
| Configuration | Manual setup | Centralized |
| Reusability | Limited | Excellent |

### Migration Support

For help migrating from v2.0.0:
1. See migration guide above
2. Review example models in `examples/`
3. Check `docs/UserGuide.md` for new workflow
4. Consult `docs/API_Documentation.md` for class details

---

## Version Numbering

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version (3.x.x) - Incompatible API changes
- **MINOR** version (x.1.x) - Backward-compatible new features
- **PATCH** version (x.x.1) - Bug fixes

---

## How to Upgrade

### From v2.0.0 to v3.0.0

```bash
# 1. Download v3.0.0
cd ODE_Model_Creator
git checkout v3.0.0

# 2. Back up your models
cp -r models models_v2.0.0_backup

# 3. Update MATLAB path in your scripts
# See migration guide above

# 4. Test with example
matlab -r "run examples/FGFR2_model_ver_02/run_example_02.m"

# 5. Validate output
# Check that generated files match v2.0.0 output
```

---

## Feedback and Reporting

### Bug Reports

Found a bug in v3.0.0? Please report it with:
- MATLAB version
- Exact error message
- Minimal reproducible example
- Model file (if possible)

### Feature Requests

Have an idea for v3.1 or beyond? Submit via:
- Issue tracker with detailed description
- Use case explanation
- Expected behavior

### Questions

Need help? Check:
1. `docs/UserGuide.md` - Common tasks
2. `docs/API_Documentation.md` - Class reference
3. `examples/` - Working examples
4. GitHub issues - Common problems

---

## Release History

### Release Dates
- v3.0.0: November 8, 2025 (Current)
- v2.0.0: Previous version
- v1.0.0: Initial release

### Support Status
- v3.0.0: Actively Maintained
- v2.0.0: Legacy (limited support)
- v1.0.0: Deprecated

---

**Last Updated**: November 2025

**Current Version**: 3.0.0

For the latest changes, visit the project repository.
