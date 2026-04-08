# Reaction Classes Quick Reference

## All 18 Reaction Classes (Complete List)

### Pre-existing Classes (2)
1. **MassActionReaction** (MA) - Reversible A + B <=> C
2. **AssociationReaction** (ASSO) - Irreversible A + B => C

### Newly Implemented Classes (16)

#### Dissociation
3. **DissociationReaction** (DISSO) - C => A + B

#### Michaelis-Menten (8 classes)
4. **MichaelisMentenShortReaction** (MMS) - Forward enzyme kinetics
5. **MichaelisMentenFullReaction** (MMF) - Reversible with Km
6. **MichaelisMentenShortFeedbackReaction** (MMSF) - Forward with feedback
7. **MichaelisMentenFullFeedbackReaction** (MMFF) - Full with feedback
8. **MichaelisMentenShortReverseReaction** (MMSR) - Reverse simple
9. **MichaelisMentenFullReverseReaction** (MMFR) - Reverse with Km

#### Synthesis (3 classes)
10. **ConstitutiveSynthesisReaction** (SYN0) - Constant => A
11. **SimpleSynthesisReaction** (SYNS) - TF regulated => A
12. **RegulatedSynthesisReaction** (SYNF) - Full TF regulation => A

#### Degradation (3 classes)
13. **PassiveDegradationReaction** (DEG0) - Constitutive A =>
14. **SimpleDegradationReaction** (DEGS) - Active protease A =>
15. **RegulatedDegradationReaction** (DEGF) - Full regulated A =>

#### Translocation (2 classes)
16. **TranslocationReaction** (TRN) - Bidirectional A <=> B
17. **RegulatedTranslocationReaction** (TRNF) - Regulated A => B

#### Catalysis (1 class)
18. **CatalyticReaction** (CAT) - Catalyst-dependent => A

---

## Reaction Type Characteristics

### Requires Activators
- MMS, MMF, MMSF, MMFF
- SYNS, SYNF
- DEGS, DEGF

### Supports Inhibitors
- All except CAT

### Reversible Reactions
- MA (Mass Action)
- MMF (Michaelis-Menten Full)
- TRN (Translocation)

### Forward-Only Reactions
- ASSO (Association)
- DISSO (Dissociation)
- MMS, MMSF, MMSR, MMFR (Michaelis-Menten variants)
- SYN0, SYNS, SYNF (Synthesis)
- DEG0, DEGS, DEGF (Degradation)
- TRNF (Regulated Translocation)
- CAT (Catalytic)

---

## Parameter Naming Patterns

| Reaction Type | Parameter Pattern |
|---|---|
| Association/Dissociation | ka_*, kd_*, Ki_* |
| Michaelis-Menten | kc_*, Vm_*, Km_*, Ki_* |
| Synthesis | ksyn_*, Vsyn_*, Km_*, Ki_syn_* |
| Degradation | kdeg_*, Km_*, Ki_deg_* |
| Translocation | ktrn_*, Ki_trn_* |
| Catalytic | kcat_* |

---

## File Locations

**All classes located at:**
```
G:\My Drive\University of Adelaide\02_RESEARCH\03_Pipelines_and_Tools\
ODE Model Creator\ver 2.0.0\ODEModelCreator\src\reactions\
```

**Total Implementation:**
- 16 new files
- ~2,000 lines of code (new)
- ~2,500 total lines (including existing classes)

---

## Example Usage

```matlab
% Create a Michaelis-Menten Short reaction with activator and inhibitor
dataArray = {'MMS', 'Substrate', 'Product', 'Enzyme', '+Activator', '-Inhibitor'};
reaction = MichaelisMentenShortReaction('R1', dataArray);

% Access reaction properties
processString = reaction.getProcessString();      % 'Substrate=>Product:R1'
rateEquation = reaction.generateRateEquation();   % Rate equation string
parameters = reaction.getParameterNames();        % Cell array of param names

% Display reaction
disp(reaction);  % Detailed formatted output
```

---

## Integration Checklist

- [ ] Update ReactionFactory.m with all 16 new type mappings
- [ ] Add unit tests for each reaction class
- [ ] Validate rate equations against original MATLAB code
- [ ] Test with various activator/inhibitor combinations
- [ ] Verify parameter name generation
- [ ] Test process string generation
- [ ] Integration test with full ODE model creation
- [ ] Update user documentation
- [ ] Create example models using new reaction types

---

## Contact & Support

For issues or modifications needed, refer to:
- Original MATLAB code: `/src/rateEquations/`
- Base class implementation: `Reaction.m`
- Factory pattern: `ReactionFactory.m`

Implementation completed: November 8, 2025
