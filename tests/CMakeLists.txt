include_directories(BEFORE ${PROJECT_SOURCE_DIR}/include)

add_executable(test_airsea EXCLUDE_FROM_ALL
               test_airsea.F90
              )
target_link_libraries(test_airsea PRIVATE util airsea input_manager)

add_executable(test_albedo EXCLUDE_FROM_ALL
               test_albedo.F90
              )
target_link_libraries(test_albedo PRIVATE util airsea input_manager)

add_executable(test_bulk EXCLUDE_FROM_ALL
               test_bulk.F90
              )
target_link_libraries(test_bulk PRIVATE util airsea input_manager)

#add_executable(test_eqstate EXCLUDE_FROM_ALL
#               test_eqstate.F90
#              )
#target_link_libraries(test_eqstate PRIVATE util)

add_executable(test_time EXCLUDE_FROM_ALL
               test_time.F90
              )
target_link_libraries(test_time PRIVATE util)

add_executable(test_slope_bbl EXCLUDE_FROM_ALL
               test_slope_bbl.F90
              )
target_link_libraries(test_slope_bbl PRIVATE meanflow observations)

add_custom_target(check_slope_bbl
                  COMMAND $<TARGET_FILE:test_slope_bbl> fixed
                  COMMAND $<TARGET_FILE:test_slope_bbl> evolving
                  DEPENDS test_slope_bbl
                 )

add_custom_target(gotm_tests)
add_dependencies(gotm_tests test_airsea test_albedo test_time check_slope_bbl)

set_property(TARGET gotm_tests test_airsea test_albedo test_bulk test_time
                    test_slope_bbl check_slope_bbl PROPERTY FOLDER tests)
