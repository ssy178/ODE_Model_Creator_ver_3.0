# Reaction Type Reference - Complete Guide

Complete reference for all 18 reaction types supported by the ODE Model Creator, including mathematical formulations, parameters, and examples.

## Table of Contents

1. [Quick Reference Table](#quick-reference-table)
2. [Association & Dissociation Reactions](#association--dissociation-reactions)
3. [Michaelis-Menten Reactions](#michaelis-menten-reactions)
4. [Synthesis Reactions](#synthesis-reactions)
5. [Degradation Reactions](#degradation-reactions)
6. [Translocation Reactions](#translocation-reactions)
7. [Catalytic Reactions](#catalytic-reactions)

## Quick Reference Table

| Type Code | Reaction Type | Form | Parameters | Activators | Inhibitors |
|-----------|---------------|------|------------|------------|-----------|
| **MA** | Mass Action | A + B <=> C | ka, kd, Ki | Optional | Yes |
| **ASSO** | Association | A + B => C | ka, Ki | No | Yes |
| **DISSO** | Dissociation | C => A + B | kd, Ki | No | Yes |
| **MMS** | Michaelis-Menten Short | A => B | kc, Vm, Ki | **Required** | Yes |
| **MMF** | Michaelis-Menten Full | A <=> B | kc, Km, Vm, Ki | **Required** | Yes |
| **MMSF** | MM Short Feedback | A => B | kc, Ki | **Required** | Yes |
| **MMFF** | MM Full Feedback | A => B | kc, Km, Ki | **Required** | Yes |
| **MMSR** | MM Short Reverse | A => B | Vm, Ki | No | Yes |
| **MMFR** | MM Full Reverse | A => B | Vm, Km, Ki | No | Yes |
| **SYN0** | Constitutive Synthesis | => A | Vsyn, Ki | No | Yes |
| **SYNS** | Simple Synthesis | => A | ksyn, Ki | **Required** | Yes |
| **SYNF** | Regulated Synthesis | => A | ksyn, Km, Ki | **Required** | Yes |
| **DEG0** | Passive Degradation | A => | kdeg, Ki | No | Yes |
| **DEGS** | Simple Degradation | A => | kdeg, Km, Ki | **Required** | Yes |
| **DEGF** | Regulated Degradation | A => | kdeg, Km, Ki | **Required** | Yes |
| **TRN** | Translocation | A <=> B | ktrn, Ki | No | Yes |
| **TRNF** | Regulated Translocation | A => B | ktrn, Ki | No | Yes |
| **CAT** | Catalytic | => A | kcat | No | No |

---

## Association & Dissociation Reactions

### 1. Mass Action (MA)

**Biological Form**: Bimolecular reversible binding

**Reaction Equation**:
```
A + B <=> C
```

**Mathematical Form**:
```
d[A]/dt = ...
d[B]/dt = ...
d[C]/dt = vf - vr

where:
vf = ka * [A] * [B] * product((1 + [ACT_i]/Km_act_i))
vr = kd * [C] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `ka_A_B_C` - Forward (association) rate constant [1/(concentration*time)]
- `kd_C_A_B` - Reverse (dissociation) rate constant [1/time]
- `Ki_A_B_C_INH` - Inhibition constant for each inhibitor [concentration]

**Excel Format**:
```
Reaction_Type: MA
Substrate_1: A
Substrate_2: B
Product_1: C
Activator: (optional) +ACT1, +ACT2
Inhibitor: (optional) -INH1, -INH2
```

**MATLAB Code Example**:
```matlab
% Simple mass action
rxn = MassActionReaction('R1', {'MA', 'FGFR2', 'FGF', 'pFGFR2'});

% With inhibition
rxn = MassActionReaction('R2', {'MA', 'FGFR2', 'FGF', 'pFGFR2', '-FGFR2i'});
```

**IQM Output**:
```
A + B => C : R1
C + A => B : R1_R  % reverse reaction as separate process

REACTIONS:
R1: A+B=>C; (ka_A_B_C*A*B)/(1 + Ki_A_B_C_INH*FGFR2i)
R1_R: C=>A+B; (kd_C_A_B*C)
```

**Typical Use Cases**:
- Ligand-receptor binding: Growth factor + receptor => activated receptor
- Protein-protein interactions: Kinase + substrate => phosphorylated substrate
- Complex formation: Catalytic subunit + regulatory subunit => complex

---

### 2. Association (ASSO)

**Biological Form**: Bimolecular irreversible binding

**Reaction Equation**:
```
A + B => C
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = -vf
d[C]/dt = vf

where:
vf = ka * [A] * [B] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `ka_A_B_C` - Association rate constant
- `Ki_A_B_C_INH` - Inhibition constants (if inhibitors present)

**Excel Format**:
```
Reaction_Type: ASSO
Substrate_1: A
Substrate_2: B
Product_1: C
Inhibitor: (optional) -INH1
```

**MATLAB Code Example**:
```matlab
rxn = AssociationReaction('R1', {'ASSO', 'PKC', 'DAG', 'PKC_active'});
```

**Difference from MA**:
- ASSO is unidirectional (no reverse reaction)
- MA is bidirectional (includes dissociation)
- Use ASSO when reverse reaction is negligible
- Use MA when both forward and reverse are significant

---

### 3. Dissociation (DISSO)

**Biological Form**: Unimolecular complex dissociation

**Reaction Equation**:
```
C => A + B
```

**Mathematical Form**:
```
d[C]/dt = -vf
d[A]/dt = vf
d[B]/dt = vf

where:
vf = kd * [C] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kd_C_A_B` - Dissociation rate constant
- `Ki_C_A_B_INH` - Inhibition constants

**Excel Format**:
```
Reaction_Type: DISSO
Substrate_1: C
Product_1: A
Product_2: B
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
rxn = DissociationReaction('R1', {'DISSO', 'PKC_DAG', 'PKC', 'DAG'});
```

**Typical Use Cases**:
- Protein complex dissociation
- Cofactor release from enzymes
- Dissociation of membrane-associated complexes

---

## Michaelis-Menten Reactions

Michaelis-Menten reactions describe enzyme-catalyzed transformations with saturation kinetics.

### 4. Michaelis-Menten Short (MMS)

**Biological Form**: Enzyme-catalyzed unidirectional reaction with activators

**Reaction Equation**:
```
A => B  (activated by enzymes/factors)
```

**Mathematical Form**:
```
d[A]/dt = -vf + vr
d[B]/dt = vf - vr

where:
vf = sum(kc_i * [ACT_i]) * [A] / product((1 + Ki_j*[INH_j]))
vr = Vm * [B]  (optional reverse)
```

**Parameter List**:
- `kc_A_B_ACT` - Catalytic rate for each activator [1/(concentration*time)]
- `Vm_B_A` - Reverse reaction velocity (optional) [concentration/time]
- `Ki_A_B_EMZ_INH` - Inhibition constants

**Requirements**:
- **Must have at least one activator** (enzyme or regulator)
- Activators are summed (additive effects)

**Excel Format**:
```
Reaction_Type: MMS
Substrate_1: A
Product_1: B
Modifier: ENZ (enzyme)
Activator: +ACT1, +ACT2
Inhibitor: (optional) -INH
```

**MATLAB Code Example**:
```matlab
% AKT phosphorylation by FGFR2
rxn = MichaelisMentenShortReaction('R1', ...
    {'MMS', 'AKT', 'pAKT', 'pFGFR2', '+pFGFR2', '-PI3Ki'});
```

**Rate Equation Generated**:
```
(kc_AKT_pAKT_pFGFR2 * pFGFR2 * AKT) / (1 + Ki_AKT_pAKT_pFGFR2_PI3Ki * PI3Ki) - Vm_pAKT_AKT * pAKT
```

**Typical Use Cases**:
- Phosphorylation by kinases: AKT => pAKT (by pFGFR2)
- Ubiquitination by E3 ligases
- Proteolytic cleavage by proteases
- Any enzyme-catalyzed first-order reaction

---

### 5. Michaelis-Menten Full (MMF)

**Biological Form**: Reversible enzyme-catalyzed reaction with Michaelis constants

**Reaction Equation**:
```
A <=> B  (activated by enzymes)
```

**Mathematical Form**:
```
d[A]/dt = -vf + vr
d[B]/dt = vf - vr

where:
vf = sum(kc_i * [ACT_i]) * [A] / (Km_act + [A]) / product((1 + Ki_j*[INH_j]))
vr = Vm * [B] / (Km_B + [B])
```

**Parameter List**:
- `kc_A_B_ACT` - Catalytic rates (one per activator)
- `Km_A_B_ACT` - Michaelis constant for forward reaction
- `Vm_B_A` - Maximum velocity reverse
- `Km_B_A` - Michaelis constant for reverse reaction
- `Ki_A_B_EMZ_INH` - Inhibition constants

**Requirements**:
- Must have at least one activator

**Michaelis Constant Interpretation**:
- `Km` = substrate concentration at half-maximal velocity
- Lower Km = higher affinity
- Higher Km = lower affinity

**Excel Format**:
```
Reaction_Type: MMF
Substrate_1: A
Product_1: B
Modifier: ENZ
Activator: +ACT
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
rxn = MichaelisMentenFullReaction('R1', ...
    {'MMF', 'AKT', 'pAKT', '+pFGFR2', '-PI3Ki'});
```

---

### 6. Michaelis-Menten Short with Feedback (MMSF)

**Biological Form**: Enzyme reaction with feedback regulation

**Reaction Equation**:
```
A => B  (activated by enzyme, inhibited by own product or feedback)
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = vf

where:
vf = sum(kc_i * [ACT_i]) * [A] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kc_A_B_ACT` - Catalytic rates
- `Ki_A_B_EMZ_INH` - Inhibition (often by product B)

**Requirements**:
- Must have at least one activator

**Feedback Example**:
- Forward reaction: `AKT => pAKT` (activated by pFGFR2)
- Feedback inhibition: Product pAKT or pPI3K inhibits the reaction

**Excel Format**:
```
Reaction_Type: MMSF
Substrate_1: A
Product_1: B
Activator: +ACT
Inhibitor: (optional, often +B for feedback)
```

---

### 7. Michaelis-Menten Full with Feedback (MMFF)

**Biological Form**: MM reaction with Michaelis constant and feedback regulation

**Reaction Equation**:
```
A => B  (with saturation kinetics)
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = vf

where:
vf = sum(kc_i * [ACT_i]) * [A] / (Km_act + [A]) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kc_A_B_ACT` - Catalytic rates
- `Km_A_B_ACT` - Michaelis constant
- `Ki_A_B_EMZ_INH` - Inhibition constants

**Requirements**:
- Must have at least one activator

---

### 8. Michaelis-Menten Short Reverse (MMSR)

**Biological Form**: Reverse reaction (product degradation or reconversion)

**Reaction Equation**:
```
A => B  (reverse direction)
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = vf

where:
vf = Vm * [A] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `Vm_A_B` - Maximum velocity
- `Ki_A_B_INH` - Inhibition constants

**Requirements**:
- No activators required
- Simple Michaelis form: Vm only

**Typical Use Cases**:
- Protein dephosphorylation: pAKT => AKT (by phosphatase)
- Reverse translocation
- Product degradation

---

### 9. Michaelis-Menten Full Reverse (MMFR)

**Biological Form**: Reverse MM reaction with Michaelis constant

**Reaction Equation**:
```
A => B  (reverse with saturation)
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = vf

where:
vf = Vm * [A] / (Km + [A]) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `Vm_A_B` - Maximum velocity
- `Km_A_B` - Michaelis constant
- `Ki_A_B_INH` - Inhibition constants

**Difference from MMSR**:
- MMSR: Simple form (no Km term)
- MMFR: Full form (includes Km saturation)

---

## Synthesis Reactions

Synthesis reactions represent production of molecular species.

### 10. Constitutive Synthesis (SYN0)

**Biological Form**: Constant/basal production rate

**Reaction Equation**:
```
=> A  (no substrates)
```

**Mathematical Form**:
```
d[A]/dt = vf

where:
vf = Vsyn / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `Vsyn_A` - Synthesis/production rate [concentration/time]
- `Ki_syn_A_INH` - Inhibition constants (optional)

**Requirements**:
- No activators required
- No substrates required

**Excel Format**:
```
Reaction_Type: SYN0
Product_1: A
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
rxn = ConstitutiveSynthesisReaction('R1', {'SYN0', 'PKC'});
rxn = ConstitutiveSynthesisReaction('R2', {'SYN0', 'FGFR2', '-degradation'});
```

**Typical Use Cases**:
- Basal protein synthesis
- Constant mRNA transcription
- Background molecular production

---

### 11. Simple Synthesis (SYNS)

**Biological Form**: Regulated protein/gene synthesis

**Reaction Equation**:
```
=> A  (activated by transcription factors)
```

**Mathematical Form**:
```
d[A]/dt = vf

where:
vf = sum(ksyn_i * [TF_i]) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `ksyn_A_TF` - Synthesis rate per transcription factor (one per activator)
- `Ki_syn_A_INH` - Inhibition constants

**Requirements**:
- **Must have at least one activator** (transcription factor)
- Activators are summed (additive TF effects)

**Excel Format**:
```
Reaction_Type: SYNS
Product_1: A
Activator: +TF1, +TF2
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
% mRNA synthesis by transcription factors
rxn = SimpleSynthesisReaction('R1', ...
    {'SYNS', 'pCREB_protein', '+pCREB', '+pATF2'});
```

**Typical Use Cases**:
- mRNA synthesis regulated by transcription factors
- Protein synthesis from mRNA
- Inducible gene expression

---

### 12. Regulated Synthesis (SYNF)

**Biological Form**: Regulated synthesis with saturation kinetics

**Reaction Equation**:
```
=> A  (full Michaelis regulation)
```

**Mathematical Form**:
```
d[A]/dt = vf

where:
vf = sum(ksyn_i * [TF_i] / (Km_i + [TF_i])) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `ksyn_A_TF` - Maximum synthesis rates
- `Km_A_TF` - Michaelis constants for each TF
- `Ki_syn_A_INH` - Inhibition constants

**Requirements**:
- Must have at least one activator

**Michaelis Constants**:
- Capture saturation of gene expression
- When TF is abundant, synthesis saturates
- Lower Km = higher sensitivity to TF

---

## Degradation Reactions

Degradation reactions represent protein/molecular breakdown.

### 13. Passive Degradation (DEG0)

**Biological Form**: Constitutive degradation (no regulation)

**Reaction Equation**:
```
A =>  (no products specified)
```

**Mathematical Form**:
```
d[A]/dt = -vf

where:
vf = kdeg * [A] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kdeg_A` - Degradation rate constant [1/time]
- `Ki_deg_A_INH` - Degradation inhibition constants

**Requirements**:
- No activators
- No substrates

**Excel Format**:
```
Reaction_Type: DEG0
Substrate_1: A
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
rxn = PassiveDegradationReaction('R1', {'DEG0', 'pAKT'});
rxn = PassiveDegradationReaction('R2', {'DEG0', 'pAKT', '-degradation_inhibitor'});
```

**Typical Use Cases**:
- First-order decay
- Passive protein turnover
- Non-specific degradation

---

### 14. Simple Degradation (DEGS)

**Biological Form**: Protease-mediated degradation

**Reaction Equation**:
```
A =>  (degraded by protease)
```

**Mathematical Form**:
```
d[A]/dt = -vf

where:
vf = sum(kdeg_i * [PROTEASE_i]) * [A] / (Km + [A]) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kdeg_A_PROTEASE` - Degradation rates (one per protease)
- `Km_A_PROTEASE` - Michaelis constant
- `Ki_deg_A_PROTEASE_INH` - Inhibition constants

**Requirements**:
- **Must have at least one activator** (protease or degradation factor)

**Excel Format**:
```
Reaction_Type: DEGS
Substrate_1: A
Activator: +PROTEASE1, +PROTEASE2
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
% Phosphorylated protein degradation by proteases
rxn = SimpleDegradationReaction('R1', ...
    {'DEGS', 'pAKT', '+PP2A', '+PP1'});
```

**Typical Use Cases**:
- Protease-mediated degradation
- Caspase-dependent apoptosis
- Targeted degradation by ubiquitin-proteasome system

---

### 15. Regulated Degradation (DEGF)

**Biological Form**: Full MM regulation of degradation

**Reaction Equation**:
```
A =>  (full regulation)
```

**Mathematical Form**:
```
d[A]/dt = -vf

where:
vf = sum(kdeg_i * [PROTEASE_i]) * [A] / (Km + [A]) / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `kdeg_A_PROTEASE` - Degradation rates
- `Km_A_PROTEASE` - Michaelis constant (saturation)
- `Ki_deg_A_PROTEASE_INH` - Inhibition constants

**Requirements**:
- Must have at least one activator (protease)

**Difference from DEGS**:
- DEGS and DEGF have the same mathematical form in this implementation
- DEGF implies additional regulation complexity

---

## Translocation Reactions

Translocation reactions move molecules between compartments.

### 16. Translocation (TRN)

**Biological Form**: Bidirectional compartment transfer

**Reaction Equation**:
```
A <=> B  (A in compartment 1, B in compartment 2)
```

**Mathematical Form**:
```
d[A]/dt = -vf + vr
d[B]/dt = vf - vr

where:
vf = ktrn_A_B * [A] / product((1 + Ki_j*[INH_j]))
vr = ktrn_B_A * [B]
```

**Parameter List**:
- `ktrn_A_B` - Forward translocation rate (A to B)
- `ktrn_B_A` - Reverse translocation rate (B to A)
- `Ki_trn_A_B_INH` - Translocation inhibition

**Excel Format**:
```
Reaction_Type: TRN
Substrate_1: A_cytosol
Product_1: A_nucleus
Inhibitor: (optional)
```

**MATLAB Code Example**:
```matlab
% Nuclear translocation of activated protein
rxn = TranslocationReaction('R1', {'TRN', 'pSTAT3_cyt', 'pSTAT3_nuc'});
```

**Typical Use Cases**:
- Nuclear import/export
- Protein trafficking between compartments
- Membrane translocation
- Subcellular localization changes

**Note**:
- Naming convention: Use suffixes like `_cyt`, `_nuc`, `_mem`, `_extra` for compartments
- The two species (A and B) should represent the same molecule in different locations

---

### 17. Regulated Translocation (TRNF)

**Biological Form**: Signal-dependent compartment transfer

**Reaction Equation**:
```
A => B  (forward regulated translocation)
```

**Mathematical Form**:
```
d[A]/dt = -vf
d[B]/dt = vf

where:
vf = ktrn_A_B * [A] / product((1 + Ki_j*[INH_j]))
```

**Parameter List**:
- `ktrn_A_B` - Forward translocation rate
- `ktrn_B_A` - Reverse translocation rate (for reference)
- `Ki_trn_A_B_INH` - Translocation inhibition

**Difference from TRN**:
- TRN: Bidirectional (reversible)
- TRNF: Unidirectional (forward only) with possible feedback

---

## Catalytic Reactions

### 18. Catalytic (CAT)

**Biological Form**: Catalyst-dependent production

**Reaction Equation**:
```
=> A  (catalyst-mediated synthesis)
```

**Mathematical Form**:
```
d[A]/dt = vf

where:
vf = kcat * [CATALYST]
```

**Parameter List**:
- `kcat_A_CATALYST` - Catalytic rate constant

**Requirements**:
- No inhibitors supported
- Catalyst is specified as modifier

**Excel Format**:
```
Reaction_Type: CAT
Product_1: A
Modifier: CATALYST
```

**MATLAB Code Example**:
```matlab
rxn = CatalyticReaction('R1', {'CAT', 'pAKT', 'RTK'});
```

**Typical Use Cases**:
- Autocatalytic reactions
- Enzyme-mediated synthesis
- Catalyst-driven amplification
- Simple catalyst-dependent production

**Note**:
- Rate is directly proportional to catalyst concentration
- No saturation kinetics
- No feedback inhibition possible

---

## Creating Complex Reaction Networks

### Example: FGFR2 Signaling Pathway

```matlab
builder = ODEModelBuilder();
model = BiologicalModel('FGFR2_Signaling_Complete');
factory = ReactionFactory();

% 1. Receptor activation (MA: reversible binding)
r1 = factory.create('MA', {'FGFR2', 'FGF'}, {'pFGFR2'}, {'+FGF', '-FGFR2i'});
model.addReaction(r1);

% 2. AKT phosphorylation (MMS: kinase catalyzed)
r2 = factory.create('MMS', {'AKT'}, {'pAKT'}, {'+pFGFR2', '-PI3Ki'});
model.addReaction(r2);

% 3. MAPK phosphorylation (MMF: with saturation)
r3 = factory.create('MMF', {'MAPK'}, {'pMAPK'}, {'+pFGFR2', '-MEKi'});
model.addReaction(r3);

% 4. AKT dephosphorylation (MMSR: phosphatase)
r4 = factory.create('MMSR', {'pAKT'}, {'AKT'}, {});
model.addReaction(r4);

% 5. Gene expression (SYNS: TF regulated)
r5 = factory.create('SYNS', {}, {'Protein_X'}, {'+pAKT'});
model.addReaction(r5);

% 6. Protein degradation (DEGS: protease)
r6 = factory.create('DEGS', {'Protein_X'}, {}, {'+Proteasome'});
model.addReaction(r6);

% 7. Nuclear translocation (TRN: bidirectional)
r7 = factory.create('TRN', {'pAKT_cyt'}, {'pAKT_nuc'}, {});
model.addReaction(r7);

% Add signals
model.addInput(InputSignal('FGF', 0, 100, 5));
model.addInhibitor(Inhibitor('FGFR2i', 0, 1, 30));

% Extract and export
model.extractAllStateVariables();
model.extractAllParameters();
builder.model = model;
builder.exportToIQM('output/FGFR2_complete.txtbc');
```

---

## Choosing Between Similar Reaction Types

### Decision Tree

```
START: I need a reaction A -> B

1. Is there a substrate that doesn't appear as a product?
   - YES: Use Degradation (DEG0, DEGS, DEGF) or Consumption
   - NO: Go to 2

2. Is there a product that doesn't appear as a substrate?
   - YES: Use Synthesis (SYN0, SYNS, SYNF)
   - NO: Go to 3

3. Is the reaction reversible (both directions possible)?
   - YES: Go to 4
   - NO: Go to 5

4. Reversible reaction:
   - Are there activators/enzymes?
     - YES: Use MMF (Michaelis-Menten Full)
     - NO: Is it bimolecular (two reactants)?
       - YES: Use MA (Mass Action)
       - NO: Use TRN (Translocation - if moving between compartments)

5. Irreversible reaction:
   - Are there activators/enzymes?
     - YES: Go to 6
     - NO: Go to 7

6. Reaction with activators:
   - Do you need saturation kinetics (Km)?
     - YES: Use MMF or MMFF (depending on product/compartment)
     - NO: Use MMS or SYNS

7. Reaction without activators:
   - Is it bimolecular?
     - YES: Use ASSO (Association)
     - NO: Is it degradation?
       - YES: Use DEG0 (Passive Degradation)
       - NO: Use SYN0 (Constitutive Synthesis)
```

### Common Scenarios

| Scenario | Reaction Type | Why |
|----------|---------------|-----|
| Ligand binds receptor | MA | Reversible, bimolecular |
| Kinase phosphorylates substrate | MMS or MMF | Enzyme-catalyzed |
| Gene expressed by TF | SYNS or SYNF | Activated synthesis |
| Protein degraded | DEG0 | First-order decay |
| Protein translocates to nucleus | TRN | Movement between compartments |
| Enzyme activity | CAT | Catalyst-dependent |

---

## Mathematical Conventions

### Parameter Units

All parameters must be expressed in consistent units:

**Common Unit Systems**:
- Concentrations: nM (nanomolar) or µM (micromolar)
- Time: minutes or seconds
- Rate constants: 1/(concentration × time) for bimolecular, 1/time for unimolecular
- Velocities: concentration/time

### Rate Equation Conventions

1. **Rates are always positive** (consumption is shown as subtraction in ODE)
2. **Inhibition is multiplicative**: vf / (1 + Ki*[INH])
3. **Activation is additive**: sum(kcat*[ACT_i])
4. **Saturation uses Michaelis form**: v*[S]/(Km+[S])

---

**Last Updated**: November 2025

**Version**: 3.0.0

For implementation details, see [API_Documentation.md](API_Documentation.md)

For usage examples, see [UserGuide.md](UserGuide.md)
