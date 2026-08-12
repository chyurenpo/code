#include "cppdefs.h"
!
   program test_slope_bbl
!
! !DESCRIPTION:
!  Verify fixed and evolving reference profiles for the slope-BBL internal
!  pressure forcing. Run this executable in a fresh process for each mode,
!  because the reference profile intentionally persists during a GOTM run.
!
! !USES:
   use meanflow, only: buoy
   use observations, only: int_press_type,idpdx,idpdy
   use observations, only: slope_bbl_factor_x,slope_bbl_factor_y
   use observations, only: slope_bbl_evolving_reference
   implicit none
!
! !LOCAL VARIABLES:
   integer, parameter                  :: nlev=3
   character(len=16)                   :: mode
   REALTYPE                            :: offset,tolerance
   REALTYPE, dimension(0:nlev)         :: reference,anomaly
   REALTYPE, dimension(0:nlev)         :: expected_x,expected_y
!
!-----------------------------------------------------------------------
!BOC
   call get_command_argument(1,mode)
   select case (trim(mode))
   case ('fixed')
      slope_bbl_evolving_reference=.false.
   case ('evolving')
      slope_bbl_evolving_reference=.true.
   case default
      error stop 'usage: test_slope_bbl fixed|evolving'
   end select

   allocate(buoy(0:nlev),idpdx(0:nlev),idpdy(0:nlev))

   int_press_type=3
   slope_bbl_factor_x=0.2*_ONE_
   slope_bbl_factor_y=-0.1*_ONE_
   reference=(/_ZERO_,_ONE_,2.0*_ONE_,3.0*_ONE_/)
   anomaly=(/_ZERO_,0.1*_ONE_,0.2*_ONE_,0.3*_ONE_/)

!  The first call captures the balanced reference profile and must produce
!  no pressure anomaly.
   buoy=reference
   idpdx=_ONE_
   idpdy=_ONE_
   call internal_pressure(nlev)

   tolerance=100.0*_ONE_*epsilon(_ONE_)
   if (maxval(abs(idpdx)).gt.tolerance) &
      error stop 'slope_bbl: initial x forcing is not zero'
   if (maxval(abs(idpdy)).gt.tolerance) &
      error stop 'slope_bbl: initial y forcing is not zero'

!  The second call checks the local anomaly. In evolving mode, the uniform
!  far-field displacement diagnosed at the top cell is removed everywhere.
   buoy=reference+anomaly
   call internal_pressure(nlev)

   offset=_ZERO_
   if (slope_bbl_evolving_reference) offset=anomaly(nlev)
   expected_x=slope_bbl_factor_x*(anomaly-offset)
   expected_y=slope_bbl_factor_y*(anomaly-offset)
   expected_x(0)=_ZERO_
   expected_y(0)=_ZERO_

   if (maxval(abs(idpdx-expected_x)).gt.tolerance) &
      error stop 'slope_bbl: incorrect x forcing'
   if (maxval(abs(idpdy-expected_y)).gt.tolerance) &
      error stop 'slope_bbl: incorrect y forcing'

   LEVEL1 'PASS: slope_bbl ',trim(mode),' reference'

   deallocate(buoy,idpdx,idpdy)
   end program test_slope_bbl
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
