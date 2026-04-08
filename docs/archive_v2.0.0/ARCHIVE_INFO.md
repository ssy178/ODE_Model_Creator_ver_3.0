# Archive of ODE Model Creator v2.0.0

This directory contains the original procedural implementation of the ODE Model Creator (version 2.0.0) that has been replaced by the new object-oriented version 3.0.0.

## Archived Date
2025-11-08

## Reason for Archiving
The codebase was refactored from a procedural approach to a modern object-oriented design for better:
- Maintainability
- Extensibility
- Testability
- Code organization
- Documentation

## Archived Contents

### Main Scripts
- `step1_model_creator_master.m` - Original step 1: Load Excel, generate rate equations
- `step2_generate_IQM_txtbc.m` - Original step 2: Export to IQM txtbc format
- `step3_make_MEX_file.m` - Original step 3: Compile MEX file

### Source Code Directory (`src/`)
- `generate_RateEquation_update.m` - Original reaction dispatcher
- `checking_StateVariables.m` - Original state variable validation
- `checking_Parameters.m` - Original parameter management
- `default_parameter_value.xlsx` - Default parameter values database
- `rateEquations/` - Directory with 18 original reaction modules:
  - MA.m, ASSO.m, DISSO.m, MMS.m, MMF.m, MMSF.m, MMFF.m
  - MMSR.m, MMFR.m, SYN0.m, SYNS.m, SYNF.m
  - DEG0.m, DEGS.m, DEGF.m, TRN.m, TRNF.m, CAT.m

### User Files Directory (`user files/`)
- `FGFR2_model_ver_01/` - Example model 1 with generated outputs
- `FGFR2_model_ver_02/` - Example model 2 with generated outputs

### Documentation
- `naming convensions -ver1.0.0.docx` - Original naming conventions document

## New Location of Functionality

All functionality from v2.0.0 has been reimplemented in the new OO architecture located in:
`../ODEModelCreator/`

### Migration Mapping

#### Old → New
- `step1_model_creator_master.m` → `ODEModelBuilder.loadModel()` + `generateRateEquations()`
- `step2_generate_IQM_txtbc.m` → `IQMExporter.exportToTxtbc()`
- `step3_make_MEX_file.m` → `IQMExporter.compileMEX()`
- `generate_RateEquation_update.m` → `ReactionFactory.create()`
- `checking_StateVariables.m` → `StateVariableManager`
- `checking_Parameters.m` → `ParameterManager`
- Individual reaction .m files → Reaction class hierarchy (18 classes)

#### Recommended Usage in v3.0.0

**Old v2.0.0 workflow:**
```matlab
% Step 1
run step1_model_creator_master.m
% Manually edit tables
% Step 2
run step2_generate_IQM_txtbc.m
% Step 3
run step3_make_MEX_file.m
```

**New v3.0.0 workflow:**
```matlab
builder = ODEModelBuilder();
builder.runFullPipeline('model.xlsx', 'output/');
```

## Restoration

If you need to restore the original v2.0.0 functionality:
1. Copy files from this archive back to the parent directory
2. Add paths: `addpath(genpath('archive_v2.0.0/src'))`
3. Run the original scripts as before

## Important Notes

- The new v3.0.0 generates **identical output** to v2.0.0
- All 18 reaction types are **backward compatible**
- Parameter names and rate equations are **exactly the same**
- Excel input file format is **unchanged**
- IQM txtbc output format is **identical**

## Support

For questions about the archived v2.0.0 code:
- See the original `naming convensions -ver1.0.0.docx` document
- Refer to inline comments in the archived .m files

For the new v3.0.0 system:
- See `../ODEModelCreator/README.md`
- See `../ODEModelCreator/docs/UserGuide.md`
- See `../ODEModelCreator/CHANGELOG.md` for migration guide

## Verification

The archived code was verified to be working on the archive date with:
- MATLAB R2019b or later
- IQMtools v1.2.2.2
- Both FGFR2 example models

---
Archive created by automated refactoring process on 2025-11-08
