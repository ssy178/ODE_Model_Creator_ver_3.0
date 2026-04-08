# Parameter Naming Conventions

Standardized naming conventions for parameters in the ODE Model Creator to ensure consistency, clarity, and automatic parameter extraction.

## Table of Contents

1. [General Principles](#general-principles)
2. [Naming Pattern Structure](#naming-pattern-structure)
3. [Reaction Type Conventions](#reaction-type-conventions)
4. [Species and Entity Naming](#species-and-entity-naming)
5. [Special Cases and Exceptions](#special-cases-and-exceptions)
6. [Validation Rules](#validation-rules)
7. [Examples](#examples)

## General Principles

### Core Rules

1. **Consistency**: Use the same naming scheme across all reactions
2. **Clarity**: Names should indicate what the parameter controls
3. **Uniqueness**: Each parameter should have a unique name
4. **Completeness**: All species and modifiers involved should be in the name
5. **Case Sensitivity**: Names are case-sensitive; use exact capitalization
6. **No Spaces**: Use underscores (_) to separate components, never spaces

### Naming Philosophy

Parameter names follow the format:
```
[parameter_class]_[primary_species]_[secondary_species]_[modifiers]
```

Where:
- **parameter_class** - Type of parameter (ka, kd, kc, etc.)
- **primary_species** - Main species involved
- **secondary_species** - Additional species (optional)
- **modifiers** - Activators, inhibitors, or context (optional)

### Best Practices

- Keep names concise but descriptive
- Avoid abbreviations for species names (spell out full names)
- Use underscores, not hyphens or spaces
- Avoid special characters except underscore
- All capital letters for species abbreviations if used
- Lowercase for parameter type prefix

---

## Naming Pattern Structure

### Basic Structure

```
[type]_[components]_[modifiers]
 ↓       ↓              ↓
 |       |              └─ Optional: ACT, INH, etc.
 |       └─ Species involved
 └─ Parameter class
```

### Parameter Class Prefixes

| Prefix | Meaning | Used In | Example |
|--------|---------|---------|---------|
| `ka_` | Association rate | MA, ASSO | `ka_FGFR2_FGF_pFGFR2` |
| `kd_` | Dissociation rate | MA, DISSO | `kd_pFGFR2_FGFR2_FGF` |
| `kc_` | Catalytic rate | MM reactions | `kc_AKT_pAKT_pFGFR2` |
| `Km_` | Michaelis constant | MM reactions | `Km_AKT_pAKT_pFGFR2` |
| `Vm_` | Max velocity | MM reactions | `Vm_pAKT_AKT` |
| `ksyn_` | Synthesis rate | SYN reactions | `ksyn_PKC_pAKT` |
| `Vsyn_` | Max synthesis | SYN0 | `Vsyn_PKC` |
| `kdeg_` | Degradation rate | DEG reactions | `kdeg_pAKT_PP2A` |
| `ktrn_` | Translocation rate | TRN reactions | `ktrn_pSTAT3_cyt_nuc` |
| `kcat_` | Catalytic rate | CAT | `kcat_PKC_Kinase` |
| `Ki_` | Inhibition constant | All reactions | `Ki_AKT_pAKT_PI3Ki` |

---

## Reaction Type Conventions

### Mass Action (MA) and Association (ASSO)

**Pattern**:
```
ka_[substrate1]_[substrate2]_[product]_[activators]_[modifiers]
kd_[product]_[substrate1]_[substrate2]_[modifiers]
Ki_[substrates]_[product]_[inhibitor]
```

**Examples**:
- `ka_FGFR2_FGF_pFGFR2` - Forward rate (FGFR2 + FGF → pFGFR2)
- `ka_FGFR2_FGF_pFGFR2_ENZ` - With enzyme enhancer
- `kd_pFGFR2_FGFR2_FGF` - Reverse rate
- `Ki_FGFR2_FGF_pFGFR2_FGFR2i` - Inhibition by FGFR2i

**Special Cases**:
- Multiple substrates: List in alphabetical order
- Multiple products: Not typical for MA, but if present list all
- Enzymes/enhancers: Add as subscript to ka (e.g., `ka_A_B_C_ENZ`)

### Dissociation (DISSO)

**Pattern**:
```
kd_[complex]_[product1]_[product2]_[modifiers]
Ki_[complex]_[products]_[inhibitor]
```

**Examples**:
- `kd_pFGFR2_FGFR2_FGF` - Dissociation of complex
- `Ki_pFGFR2_FGFR2_FGF_EGFR_inhibitor` - Inhibition

### Michaelis-Menten Short (MMS)

**Pattern**:
```
kc_[substrate]_[product]_[activator]
Vm_[product]_[substrate]
Ki_[substrate]_[product]_[enzyme]_[inhibitor]
```

**Examples**:
- `kc_AKT_pAKT_pFGFR2` - Catalytic rate with pFGFR2 as enzyme
- `kc_AKT_pAKT_pFGFR2_pPLCγ` - Multiple activators (additive)
- `Vm_pAKT_AKT` - Reverse reaction rate
- `Ki_AKT_pAKT_pFGFR2_PI3Ki` - Inhibition by PI3Ki

**Rules for Multiple Activators**:
- List activators in alphabetical order
- Create separate parameters for each: `kc_AKT_pAKT_ACT1`, `kc_AKT_pAKT_ACT2`
- Sum them in rate equation: `(kc_1*ACT1 + kc_2*ACT2)*AKT`

### Michaelis-Menten Full (MMF)

**Pattern**:
```
kc_[substrate]_[product]_[activator]
Km_[substrate]_[product]_[activator]
Vm_[product]_[substrate]
Km_[product]_[substrate]
Ki_[substrate]_[product]_[enzyme]_[inhibitor]
```

**Examples**:
- `kc_AKT_pAKT_pFGFR2` - Forward catalytic rate
- `Km_AKT_pAKT_pFGFR2` - Forward Michaelis constant
- `Vm_pAKT_AKT` - Reverse Vmax
- `Km_pAKT_AKT` - Reverse Michaelis constant

### Synthesis Reactions (SYN0, SYNS, SYNF)

**Constitutive (SYN0)**:
```
Vsyn_[product]
Ki_syn_[product]_[inhibitor]
```

**Examples**:
- `Vsyn_PKC` - Synthesis rate
- `Ki_syn_PKC_proteasome` - Synthesis inhibition

**Simple Synthesis (SYNS)**:
```
ksyn_[product]_[transcription_factor]
Ki_syn_[product]_[TF]_[inhibitor]
```

**Examples**:
- `ksyn_pCREB_pCREB` - CREB-induced synthesis (CREB is both substrate and TF)
- `ksyn_IL6_STAT3` - IL-6 synthesis by STAT3
- `ksyn_IL6_STAT3_SOCS` - With inhibition by SOCS

**Regulated Synthesis (SYNF)**:
```
ksyn_[product]_[TF1]_[TF2]
Km_[product]_[TF1]_[TF2]
Ki_syn_[product]_[inhibitor]
```

**Examples**:
- `ksyn_pAKT_pMAPK_pAKT` - Multiple TF activation
- `Km_pAKT_pMAPK` - Saturation constant
- `Ki_syn_pAKT_phosphatase_inhibitor`

### Degradation Reactions (DEG0, DEGS, DEGF)

**Constitutive (DEG0)**:
```
kdeg_[substrate]
Ki_deg_[substrate]_[inhibitor]
```

**Examples**:
- `kdeg_pAKT` - First-order degradation
- `Ki_deg_pAKT_degradation_inhibitor`

**Protease-Mediated (DEGS, DEGF)**:
```
kdeg_[substrate]_[protease]
Km_[substrate]_[protease]
Ki_deg_[substrate]_[protease]_[inhibitor]
```

**Examples**:
- `kdeg_pAKT_PP2A` - Dephosphorylation by phosphatase
- `Km_pAKT_PP2A` - Michaelis constant for phosphatase
- `Ki_deg_pAKT_PP2A_phosphatase_inhibitor`

### Translocation Reactions (TRN, TRNF)

**Pattern**:
```
ktrn_[source_compartment]_[target_compartment]
ktrn_[target_compartment]_[source_compartment]  (reverse)
Ki_trn_[source]_[target]_[inhibitor]
```

**Compartment Suffixes**:
- `_cyt` - Cytoplasm
- `_nuc` - Nucleus
- `_mem` - Membrane
- `_extra` - Extracellular
- `_mit` - Mitochondria

**Examples**:
- `ktrn_pSTAT3_cyt_nuc` - Nuclear import
- `ktrn_pSTAT3_nuc_cyt` - Nuclear export
- `Ki_trn_pSTAT3_cyt_nuc_transport_inhibitor`

### Catalytic Reactions (CAT)

**Pattern**:
```
kcat_[product]_[catalyst]
```

**Examples**:
- `kcat_pAKT_RTK` - RTK-dependent AKT phosphorylation
- `kcat_Calcium_Calmodulin` - Calmodulin-dependent process

---

## Species and Entity Naming

### Species Naming Conventions

**Basic Rules**:
1. Use full descriptive names when possible
2. Use standard abbreviations for well-known molecules
3. Include modification status (p, pp, a, etc.)
4. Use subscripts for compartments

**Examples**:

| Use | Don't Use |
|-----|-----------|
| `FGFR2` | `R` |
| `pFGFR2` | `FGF-R-P` |
| `ppFGFR2` | `FGFR2-pp` |
| `pAKT_cyt` | `AKT_phos` |
| `pAKT_nuc` | `nuclear_AKT` |

**Modification Prefixes**:
- `p` - Phosphorylated (e.g., `pAKT`)
- `pp` - Doubly phosphorylated (e.g., `ppMAPK`)
- `a` - Active form (e.g., `aAKT`)
- `u` - Ubiquitinated (e.g., `uProtein`)

**Compartment Suffixes**:
- `_cyt` - Cytoplasm (e.g., `pAKT_cyt`)
- `_nuc` - Nucleus (e.g., `pAKT_nuc`)
- `_mem` - Membrane (e.g., `EGFR_mem`)
- `_extra` - Extracellular (e.g., `EGF_extra`)
- `_mit` - Mitochondria (e.g., `cyt_c_mit`)

### Enzyme/Regulator Naming

For enzymes and regulators used as modifiers in reactions:

**Kinases**:
- `MEK` - MAPK/Erk kinase
- `AKT` - Serine/threonine kinase (also called PKB)
- `PKC` - Protein kinase C
- `pFGFR2` - When used as enzyme (already phosphorylated)

**Phosphatases**:
- `PP2A` - Protein phosphatase 2A
- `PP1` - Protein phosphatase 1
- `DUSP` - Dual specificity phosphatase

**Transcription Factors**:
- `pCREB` - Phosphorylated CREB
- `pSTAT3` - Phosphorylated STAT3
- `pNFkB` - Phosphorylated NFkB

**Inhibitors/Drugs**:
- `[PROTEIN]i` - Inhibitor of PROTEIN (e.g., `FGFR2i`, `PI3Ki`, `MEKi`)
- `[PROTEIN]_inhibitor` - Alternative format
- Common: `FGFR2i`, `PI3Ki`, `MEKi`, `ERKi`, `Sorafenib`, `Sunitinib`

---

## Special Cases and Exceptions

### Multiple Substrates

**For bimolecular reactions (A + B → C)**:
1. List substrates in alphabetical order
2. Separate with underscores
3. List products after substrates

**Example**:
```
For: EGFR + GRB2 → EGFR_GRB2_complex
Parameter: ka_EGFR_GRB2_EGFR_GRB2_complex
(Not: ka_GRB2_EGFR... or ka_EGFR_GRB2_complex)
```

### Multiple Activators

**When multiple enzymes/factors activate a reaction**:
1. Create separate parameters for each
2. Each gets its own kc or ksyn value
3. Parameters are summed in the rate equation

**Example**:
```
Reaction: AKT => pAKT (activated by pFGFR2 and pPLCγ)
Parameters:
  kc_AKT_pAKT_pFGFR2
  kc_AKT_pAKT_pPLCγ
Rate Equation:
  (kc_AKT_pAKT_pFGFR2 * pFGFR2 + kc_AKT_pAKT_pPLCγ * pPLCγ) * AKT
```

### Multiple Inhibitors

**When multiple inhibitors affect a reaction**:
1. Each inhibitor gets its own Ki
2. Multiplicative terms in denominator
3. Listed in alphabetical order

**Example**:
```
Reaction: pAKT => AKT
Inhibited by: PP2A_inhibitor and PI3K_inhibitor
Parameters:
  Ki_pAKT_AKT_PP2A_inhibitor
  Ki_pAKT_AKT_PI3K_inhibitor
Rate denominator:
  (1 + Ki_1*[INH1]) * (1 + Ki_2*[INH2])
```

### Rate Equations with Complex Terms

**For reactions with saturation (Michaelis-Menten)**:

```
Rate = (kc * [substrate]) / (Km + [substrate])

Named as:
  kc_[substrate]_[product]_[enzyme]
  Km_[substrate]_[product]_[enzyme]
```

**For reactions with feedback regulation**:

```
Named similarly but may include feedback species:
  kc_[substrate]_[product]_[enzyme]_[feedback]
  (where feedback could be product or other regulator)
```

---

## Validation Rules

### Automated Validation

The ODE Model Creator validates parameter names against these rules:

1. **Format Check**: Must match pattern `[a-zA-Z]+_[a-zA-Z0-9_]+`
2. **Uniqueness**: No duplicate parameter names
3. **Consistency**: All species names used must be valid
4. **Reaction Consistency**: Parameter matches reaction type

### Valid Characters

- Letters: a-z, A-Z
- Numbers: 0-9
- Underscore: _ (separator only)
- NOT allowed: spaces, hyphens (-), dots (.), special chars

### Validation Examples

**Valid Names**:
- `ka_A_B_C`
- `kc_AKT_pAKT_pFGFR2`
- `Km_substrate_product_enzyme`
- `Ki_species_product_inhibitor`
- `ktrn_pSTAT3_cyt_nuc`

**Invalid Names**:
- `ka-A-B-C` (hyphens)
- `ka A B C` (spaces)
- `ka.A.B.C` (dots)
- `kaABC` (no separator - ambiguous)
- `Ka_A_B_C` (capital K - should be lowercase k)

---

## Examples

### Complete Pathway Example

FGF Receptor Signaling with all parameter naming:

```
Reaction 1: FGFR2 + FGF <=> pFGFR2
Type: MA (Mass Action)
Parameters:
  ka_FGFR2_FGF_pFGFR2    (forward rate)
  kd_pFGFR2_FGFR2_FGF    (reverse rate)
  Ki_FGFR2_FGF_pFGFR2_FGFR2i  (inhibition)

Reaction 2: AKT + pFGFR2 => pAKT
Type: MMS (Michaelis-Menten Short)
Parameters:
  kc_AKT_pAKT_pFGFR2     (catalytic rate)
  Vm_pAKT_AKT            (reverse rate)
  Ki_AKT_pAKT_pFGFR2_PI3Ki  (inhibition)

Reaction 3: => PKC_protein (synthesis)
Type: SYNS (Simple Synthesis)
Parameters:
  ksyn_PKC_protein_pAKT   (synthesis rate by pAKT)
  Ki_syn_PKC_protein_PP    (inhibition by phosphatase)

Reaction 4: pAKT => (degradation)
Type: DEGS (Simple Degradation)
Parameters:
  kdeg_pAKT_PP2A         (degradation by phosphatase)
  Km_pAKT_PP2A           (Michaelis constant)
  Ki_deg_pAKT_PP2A_inhibitor  (degradation inhibition)

Reaction 5: pAKT_cyt <=> pAKT_nuc (translocation)
Type: TRN (Translocation)
Parameters:
  ktrn_pAKT_cyt_nuc      (nuclear import)
  ktrn_pAKT_nuc_cyt      (nuclear export)
  Ki_trn_pAKT_cyt_nuc_transport_inhibitor
```

### Quick Reference Template

```
// Copy and modify for your model

// Association/Dissociation
ka_[subs1]_[subs2]_[prod]
kd_[prod]_[subs1]_[subs2]
Ki_[subs]_[prod]_[INH]

// Michaelis-Menten
kc_[subs]_[prod]_[enz]
Km_[subs]_[prod]_[enz]
Vm_[prod]_[subs]
Ki_[subs]_[prod]_[enz]_[INH]

// Synthesis
ksyn_[prod]_[TF]
Vsyn_[prod]
Km_[prod]_[TF]
Ki_syn_[prod]_[INH]

// Degradation
kdeg_[subs]
kdeg_[subs]_[protease]
Km_[subs]_[protease]
Ki_deg_[subs]_[protease]_[INH]

// Translocation
ktrn_[subs]_[comp1]_[comp2]
Ki_trn_[subs]_[comp1]_[comp2]_[INH]

// Catalytic
kcat_[prod]_[catalyst]
```

---

## Common Mistakes to Avoid

| Mistake | Example | Correct |
|---------|---------|---------|
| Capital K | `Ka_A_B_C` | `ka_A_B_C` |
| Missing underscore | `kaABC` | `ka_A_B_C` |
| Spaces | `ka A B C` | `ka_A_B_C` |
| Inconsistent names | `ka_A_B_c` | `ka_A_B_C` |
| Abbreviations | `ka_R_L_RL` | `ka_Receptor_Ligand_Complex` |
| Wrong order | `ka_C_A_B` | `ka_A_B_C` (alphabetical) |
| Double underscores | `ka__A__B__C` | `ka_A_B_C` |
| Hyphens | `ka-A-B-C` | `ka_A_B_C` |

---

## Automatic Parameter Extraction

The parameter manager automatically extracts parameter names from:
1. Reaction equations
2. Species lists
3. Regulator definitions

### How It Works

```
Reaction: AKT + pFGFR2 => pAKT  (inhibited by PI3Ki)
↓
Extract species: AKT, pFGFR2, pAKT, PI3Ki
↓
Infer parameters from reaction type (MMS):
  - kc_AKT_pAKT_pFGFR2
  - Vm_pAKT_AKT
  - Ki_AKT_pAKT_pFGFR2_PI3Ki
↓
Load from default_parameter_values.xlsx
↓
Use defaults if available, else flag as undefined
```

---

## Excel Naming in Parameter Table

When you export the parameter table, use these columns:

| Column | Example | Notes |
|--------|---------|-------|
| Parameter_Name | `ka_A_B_C` | Must follow conventions |
| Parameter_Type | `Association Rate` | Descriptive |
| Reaction_ID | `R1` | Which reaction |
| Reaction_Type | `MA` | Type code |
| Default_Value | `0.1` | From defaults file |
| Fitted_Value | `0.095` | From experiments |
| Units | `1/(nM*min)` | Consistent units |
| Description | `Forward rate A+B→C` | Clear description |
| Lower_Bound | `0.001` | For optimization |
| Upper_Bound | `1.0` | For optimization |

---

## Summary

### Key Points

1. Use consistent, standardized parameter names
2. Include all relevant species and modifiers in the name
3. Follow the patterns specific to each reaction type
4. Use alphabetical order for multiple components
5. Avoid spaces, hyphens, and special characters
6. Keep names descriptive but concise

### Checklist for New Parameters

- [ ] Follows reaction-type-specific pattern
- [ ] All species names match exactly (case-sensitive)
- [ ] No spaces or special characters
- [ ] Unique within the model
- [ ] Descriptive and clear
- [ ] Properly formatted in parameter table
- [ ] Assigned default value if available

---

**Last Updated**: November 2025

**For more information**:
- See [ReactionTypeReference.md](ReactionTypeReference.md) for reaction-specific details
- See [UserGuide.md](UserGuide.md) for workflow examples
- See [API_Documentation.md](API_Documentation.md) for technical details
