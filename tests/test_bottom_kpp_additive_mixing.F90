#include "cppdefs.h"
!
   program test_bottom_kpp_additive_mixing
!
! !DESCRIPTION:
!  Verify native replacement and opt-in additive coefficient assembly for
!  CVMix bottom KPP.
!
! !USES:
   use gotm_cvmix, only: assemble_bottom_kpp_coefficients
   implicit none
!
! !LOCAL VARIABLES:
   integer, parameter                     :: nlev=5,kbbl=4
   REALTYPE, parameter                    :: kOBL_depth=3.75*_ONE_
   REALTYPE, dimension(0:nlev)            :: num,nuh,nus
   REALTYPE, dimension(0:nlev)            :: interior_num,             &
                                              interior_nuh,             &
                                              interior_nus
   REALTYPE, dimension(1:nlev+1)          :: kpp_num,kpp_nuh,kpp_nus
   REALTYPE, dimension(0:nlev)            :: expected
   REALTYPE                               :: tolerance
!
!-----------------------------------------------------------------------
!BOC
   interior_num=(/100.0*_ONE_,10.0*_ONE_,20.0*_ONE_,30.0*_ONE_,      &
      40.0*_ONE_,50.0*_ONE_/)
   interior_nuh=2.0*_ONE_*interior_num
   interior_nus=3.0*_ONE_*interior_num

!  Mimic CVMix output: interfaces 2:ktup+1 contain new KPP values, while
!  the wall and interfaces above the KPP range retain their input values.
   kpp_num=(/100.0*_ONE_,1.0*_ONE_,2.0*_ONE_,3.0*_ONE_,              &
      40.0*_ONE_,50.0*_ONE_/)
   kpp_nuh=2.0*_ONE_*kpp_num
   kpp_nus=3.0*_ONE_*kpp_num
   tolerance=100.0*_ONE_*epsilon(_ONE_)

!  Native mode replaces the full GOTM bottom-layer range with the CVMix
!  output. Values CVMix did not replace are copied back unchanged.
   num=interior_num
   nuh=interior_nuh
   nus=interior_nus
   call assemble_bottom_kpp_coefficients(                             &
      nlev,kbbl,kOBL_depth,.false.,num,nuh,nus,                       &
      kpp_num,kpp_nuh,kpp_nus)
   expected=(/100.0*_ONE_,1.0*_ONE_,2.0*_ONE_,3.0*_ONE_,             &
      40.0*_ONE_,50.0*_ONE_/)
   call check_array(num,expected,tolerance,'native momentum')
   call check_array(nuh,2.0*_ONE_*expected,tolerance,'native heat')
   call check_array(nus,3.0*_ONE_*expected,tolerance,'native salt')

!  Additive mode adds KPP only at the interfaces CVMix replaced (1:ktup in
!  GOTM indexing). The wall and interfaces above that range stay unchanged.
   num=interior_num
   nuh=interior_nuh
   nus=interior_nus
   call assemble_bottom_kpp_coefficients(                             &
      nlev,kbbl,kOBL_depth,.true.,num,nuh,nus,                        &
      kpp_num,kpp_nuh,kpp_nus)
   expected=(/100.0*_ONE_,11.0*_ONE_,22.0*_ONE_,33.0*_ONE_,          &
      40.0*_ONE_,50.0*_ONE_/)
   call check_array(num,expected,tolerance,'additive momentum')
   call check_array(nuh,2.0*_ONE_*expected,tolerance,'additive heat')
   call check_array(nus,3.0*_ONE_*expected,tolerance,'additive salt')

   LEVEL1 'PASS: bottom-KPP additive interior mixing'

   contains

   subroutine check_array(actual,reference,tol,label)
      REALTYPE, intent(in)             :: actual(0:nlev),              &
                                           reference(0:nlev),tol
      character(len=*), intent(in)     :: label

      if (maxval(abs(actual-reference)).gt.tol) then
         STDERR 'bottom-KPP coefficient assembly: incorrect ',trim(label)
         error stop
      endif
   end subroutine check_array

   end program test_bottom_kpp_additive_mixing
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
