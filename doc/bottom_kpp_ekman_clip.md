# Bottom-KPP Ekman-depth clipping

This fork provides an optional classic Ekman-depth cap for the CVMix bottom
K-Profile Parameterization (KPP). It limits the boundary-layer depth diagnosed
from the bulk Richardson number according to

```text
h_BBL = min(h_Ri, h_Ek)
h_Ek  = 0.7 u_*b / |f|
```

Here, `h_Ri` is the unmodified CVMix bottom-boundary-layer depth, `u_*b` is the
bottom friction velocity, and `f` is the Coriolis parameter supplied to GOTM.
The absolute value of `f` makes the cap independent of hemisphere.

## Configuration

The cap requires a build configured with `GOTM_USE_CVMIX=ON`. Enable it under
the CVMix bottom-layer settings:

```yaml
cvmix:
   surface_layer:
      use: false
   bottom_layer:
      use: true
      clip_mld: true
      check_Ekman_length: false
```

`clip_mld` defaults to `false`. Existing configurations therefore preserve
the standard CVMix behavior.

## Difference from `check_Ekman_length`

The two options should not be treated as synonyms:

- `check_Ekman_length` passes CVMix's native `lEkman` option to its
  boundary-layer-depth calculation. In the bundled CVMix implementation, that
  limit is applied only when its surface buoyancy forcing is positive.
- `clip_mld` applies the classic GOTM bottom-KPP Ekman cap whenever the bottom
  friction velocity and `|f|` are nonzero. It does not depend on the sign of
  the bottom buoyancy flux.

For the zero-bottom-buoyancy-flux simulations motivating this extension,
`check_Ekman_length` does not activate the CVMix cap, whereas `clip_mld` can
still limit the bottom boundary layer.

When clipping changes the diagnosed physical depth, the implementation also
recomputes CVMix's fractional boundary-layer index. This keeps the KPP shape
function and the vertical range receiving KPP coefficients consistent with the
clipped depth.

If `f` or `u_*b` is zero, no classic Ekman cap is applied. If the Richardson-
number depth is already shallower than `h_Ek`, it is left unchanged.

## Code verification

Configure GOTM with CVMix and run:

```bash
cmake -S . -B build -DGOTM_USE_CVMIX=ON
cmake --build build --target check_bottom_kpp_ekman_clip
```

The focused regression test verifies that disabled clipping leaves the native
depth unchanged, enabled clipping produces `min(h_Ri, h_Ek)`, both signs of
`f` produce the same limit, the fractional KPP index is updated, and zero
rotation or zero bottom stress is handled safely.
