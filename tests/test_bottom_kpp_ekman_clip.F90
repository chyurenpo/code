#include "cppdefs.h"
!
   program test_bottom_kpp_ekman_clip
!
! !DESCRIPTION:
!  Verify the optional classic Ekman-depth cap for CVMix bottom KPP.
!
! !USES:
   use cvmix_kinds_and_types, only: cvmix_data_type
   use gotm_cvmix, only: apply_bottom_kpp_ekman_clip
   implicit none
!
! !LOCAL VARIABLES:
   integer, parameter                     :: nlev=4
   type(cvmix_data_type)                  :: vars
   REALTYPE, target, dimension(nlev+1)    :: interfaces
   REALTYPE, target, dimension(nlev)      :: centers
   REALTYPE                               :: tolerance
!
!-----------------------------------------------------------------------
!BOC
   interfaces=(/_ZERO_,-5.0*_ONE_,-10.0*_ONE_,-15.0*_ONE_,           &
      -20.0*_ONE_/)
   centers=(/-2.5*_ONE_,-7.5*_ONE_,-12.5*_ONE_,-17.5*_ONE_/)
   vars%zw_iface=>interfaces
   vars%zt_cntr=>centers
   tolerance=100.0*_ONE_*epsilon(_ONE_)

!  Disabled clipping must preserve the native CVMix diagnosis.
   vars%BoundaryLayerDepth=18.0*_ONE_
   vars%kOBL_depth=4.75*_ONE_
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ONE_/1000.0,_ONE_/10000.0,.false.)
   call check(vars%BoundaryLayerDepth,18.0*_ONE_,tolerance,            &
      'disabled depth')
   call check(vars%kOBL_depth,4.75*_ONE_,tolerance,'disabled index')

!  With clipping enabled, h_Ek=0.7*0.001/0.0001=7 m. The fractional
!  CVMix index must be recomputed for the clipped depth.
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ONE_/1000.0,_ONE_/10000.0,.true.)
   call check(vars%BoundaryLayerDepth,7.0*_ONE_,tolerance,             &
      'clipped depth')
   call check(vars%kOBL_depth,2.25*_ONE_,tolerance,'clipped index')

!  The cap depends on |f|, so changing the Coriolis sign must not change it.
   vars%BoundaryLayerDepth=18.0*_ONE_
   vars%kOBL_depth=4.75*_ONE_
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ONE_/1000.0,-_ONE_/10000.0,.true.)
   call check(vars%BoundaryLayerDepth,7.0*_ONE_,tolerance,             &
      'negative-f depth')

!  A native diagnosis shallower than h_Ek must remain unchanged.
   vars%BoundaryLayerDepth=5.0*_ONE_
   vars%kOBL_depth=1.75*_ONE_
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ONE_/1000.0,_ONE_/10000.0,.true.)
   call check(vars%BoundaryLayerDepth,5.0*_ONE_,tolerance,             &
      'already-shallow depth')
   call check(vars%kOBL_depth,1.75*_ONE_,tolerance,                    &
      'already-shallow index')

!  Zero rotation or zero bottom stress must safely leave the depth unchanged.
   vars%BoundaryLayerDepth=18.0*_ONE_
   vars%kOBL_depth=4.75*_ONE_
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ONE_/1000.0,_ZERO_,.true.)
   call check(vars%BoundaryLayerDepth,18.0*_ONE_,tolerance,            &
      'zero-f depth')
   call apply_bottom_kpp_ekman_clip(                                  &
      vars,_ZERO_,_ONE_/10000.0,.true.)
   call check(vars%BoundaryLayerDepth,18.0*_ONE_,tolerance,            &
      'zero-stress depth')

   LEVEL1 'PASS: bottom-KPP classic Ekman-depth cap'

   contains

   subroutine check(actual,expected,tol,label)
      REALTYPE, intent(in)             :: actual,expected,tol
      character(len=*), intent(in)     :: label

      if (abs(actual-expected).gt.tol) then
         STDERR 'bottom-KPP Ekman clip: incorrect ',trim(label)
         STDERR 'actual: ',actual,' expected: ',expected,              &
            ' difference: ',abs(actual-expected)
         error stop
      endif
   end subroutine check

   end program test_bottom_kpp_ekman_clip
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
