# GOTM with slope-following bottom-boundary-layer forcing

This repository is a research fork of the
[General Ocean Turbulence Model (GOTM)](https://github.com/gotm-model/code).
It adds an optional internal-pressure forcing for a one-dimensional water
column aligned with a planar slope.

## Changes in this fork

- Added the opt-in internal-pressure mode `slope_bbl`.
- Represented the along-slope pressure force using the buoyancy anomaly
  relative to a reference profile.
- Added independent x- and y-direction slope factors.
- Added fixed and evolving reference-profile options.
- Added focused regression tests for both reference modes.
- Preserved the behavior of the existing `none`, `gradients`, and `plume`
  internal-pressure modes.

The formulation, configuration parameters, equations, assumptions, current
restart limitation, and regression-test instructions are described in
[Slope-following bottom-boundary-layer forcing](doc/slope_bbl.md).

## Build and test

GOTM uses CMake and requires a Fortran compiler. A minimal out-of-source build
and the focused slope-BBL test can be run with:

```bash
cmake -S . -B build
cmake --build build
cmake --build build --target check_slope_bbl
```

The slope-following forcing is disabled unless `int_pressure.type` is set to
`slope_bbl`; standard GOTM configurations therefore retain their existing
behavior.

## Upstream project and license

GOTM is a one-dimensional water-column model for marine and limnological
applications, with a range of parameterizations for vertical turbulent
mixing. For the official model, documentation, and development history, see
the [upstream GOTM repository](https://github.com/gotm-model/code) and the
[GOTM website](https://gotm.net).

This fork retains the license and copyright terms distributed with the
upstream GOTM source code. See [COPYING](COPYING).

## AI-assistance disclosure

OpenAI Codex was used to assist with code organization, documentation drafting,
and regression-test preparation for this extension. The repository author is
responsible for the scientific formulation, configuration choices, review,
validation, and interpretation of results. AI-assisted changes should be
independently reviewed and validated before use in scientific or operational
work.
