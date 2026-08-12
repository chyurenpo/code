# Slope-following bottom boundary layer forcing

The optional `slope_bbl` internal-pressure mode represents the buoyancy-anomaly
pressure force in a one-dimensional column whose vertical coordinate is normal
to a planar slope. It follows the rotated-coordinate equations in Umlauf and
Burchard (2011), *Journal of Physical Oceanography*, 41, 329–345,
doi:10.1175/2010JPO4438.1.

## Configuration

```yaml
mimic_3d:
   int_pressure:
      type: slope_bbl
      gradients:
         dtdx:
            method: constant
            constant_value: 5.096755012317e-05
         dtdy:
            method: constant
            constant_value: 0.0
         dsdx:
            method: constant
            constant_value: 0.0
         dsdy:
            method: constant
            constant_value: 0.0
      slope_bbl:
         factor_x: 1.000033334667e-02
         factor_y: 0.0
         evolving_reference: false
      t_adv: true
      s_adv: false
```

For a slope angle `alpha` in the x direction, use

```text
gravity = g cos(alpha)
factor_x = tan(alpha)
factor_y = 0
dT/dx = N_inf^2 sin(alpha)/(g alpha_T)
```

where `alpha_T` is the thermal expansion coefficient for a linear equation of
state. With GOTM buoyancy based on `g cos(alpha)`, the implemented acceleration

```text
factor_x * (buoy - buoy_reference)
```

is equal to the physical slope force

```text
(b - b_inf) sin(alpha).
```

The background tracer gradient and `t_adv` or `s_adv` represent advection of
the ambient stratification. They are configured independently of the pressure
forcing.

## Reference modes

With `evolving_reference: false`, the anomaly is measured relative to the
initial local profile:

```text
b_anomaly(z,t) = b(z,t) - b(z,0).
```

With `evolving_reference: true`, the buoyancy displacement at the uppermost
cell is also removed:

```text
b_anomaly(z,t) = b(z,t) - b(z,0)
                 - [b(z_top,t) - b(z_top,0)].
```

This second form represents an evolving no-mixing far-field profile when its
time dependence is a vertically uniform displacement. It should only be used
when the uppermost cell remains outside the turbulent boundary layer.

## Isolation from standard GOTM behavior

The feature is opt-in. Existing modes `none`, `gradients`, and `plume` do not
enter the `slope_bbl` calculation. The default for `evolving_reference` is
`false`.

The reference profile is currently captured on the first call to the internal
pressure routine. Consequently, an exact continuation from a restart file is
not yet supported: a restarted process establishes a new reference profile.
Continuous runs are unaffected.

## Focused regression test

Configure GOTM and run:

```bash
cmake --build build --target check_slope_bbl
```

The test checks that the initial balanced profile produces zero forcing and
that both fixed and evolving reference modes reproduce their analytical
buoyancy-anomaly forcing.
