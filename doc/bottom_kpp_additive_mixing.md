# Additive interior mixing in bottom KPP

This fork provides an optional coefficient-assembly mode for CVMix bottom KPP.
It retains the previously computed interior mixing coefficient and adds the
KPP boundary-layer contribution:

```text
K_total = K_interior + K_KPP
```

The option applies independently to momentum, temperature, and salinity. It
is intended for controlled comparisons with models in which a prescribed
background transport remains active everywhere. For example, when only CVMix
constant background mixing is enabled:

```text
nu_total    = nu_background    + nu_KPP
kappa_total = kappa_background + kappa_KPP
```

## Configuration

The feature requires a build configured with `GOTM_USE_CVMIX=ON`. Enable it
under the CVMix bottom-layer settings:

```yaml
cvmix:
   surface_layer:
      use: false
   bottom_layer:
      use: true
      add_interior_mixing: true
      match_technique: simple
   interior:
      use: true
      background:
         use: true
         viscosity: 5.0e-5
         diffusivity: 1.0e-5
```

`add_interior_mixing` defaults to `false`. The default therefore preserves
the native GOTM/CVMix replacement behavior:

```text
K_total = K_KPP
```

## Scope of the addition

Despite the motivating background-only example, the option is named
`add_interior_mixing` because it retains the complete coefficient calculated
by all enabled CVMix interior processes, not only constant background mixing.
Users should therefore consider the combined effect when interior shear,
convection, tidal mixing, or double diffusion is also enabled.

The additive option is most direct with `match_technique: simple`. Gradient
or full matching already uses interior coefficients when constructing the KPP
shape near the boundary-layer edge. Enabling additive assembly with either of
those matching modes retains the interior coefficient in addition to a KPP
profile that is already influenced by it; that combination should therefore
be treated as a distinct formulation and evaluated deliberately.

CVMix replaces only the interfaces inside its diagnosed KPP range. Additive
assembly is consequently applied only at those interfaces. The wall interface
and interfaces above the KPP range are left unchanged, avoiding duplicate
addition of an interior coefficient that CVMix did not replace.

This option is not standard ROMS bottom-KPP behavior. ROMS and native
GOTM/CVMix replace the interior coefficient inside the boundary layer while
using interior values for boundary matching. Enable additive assembly only
when that alternative formulation is intended.

The option modifies CVMix turbulent-coefficient assembly. It is distinct from
GOTM's `physical_constants.avmolu`, `avmolt`, and `avmols`, which are molecular
coefficients added later by the mean-flow equations.

## Code verification

Configure GOTM with CVMix and run:

```bash
cmake -S . -B build -DGOTM_USE_CVMIX=ON
cmake --build build --target check_bottom_kpp_additive_mixing
```

The focused regression test verifies native replacement, opt-in addition for
momentum and both tracers, and unchanged coefficients outside the interfaces
that CVMix replaces.
