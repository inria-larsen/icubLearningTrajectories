cmake_minimum_required(VERSION 2.8.9)
project(learningTrajectoriesWithGeomagic)

find_package(YARP         REQUIRED)
find_package(ICUBcontrib  REQUIRED)
find_package(ICUB)
list(APPEND CMAKE_MODULE_PATH ${YARP_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${ICUB_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${ICUBCONTRIB_MODULE_PATH})

include(ICUBcontribOptions)
include(ICUBcontribHelpers)
icubcontrib_set_default_prefix()

include_directories(${ICUB_INCLUDE_DIRS} ${YARP_INCLUDE_DIRS} include)
    
add_definitions(-D_USE_MATH_DEFINES)

add_executable(recordTrajectoriesWithGeomagic recordTrajectories.cpp cartesianClient.cpp)
target_link_libraries(recordTrajectoriesWithGeomagic ${YARP_LIBRARIES} pthread)

add_executable(sendForces sendForces.cpp)
target_link_libraries(sendForces ${YARP_LIBRARIES} pthread)

add_executable(replayTrajectories replayTrajectories.cpp cartesianClient.cpp)
target_link_libraries(replayTrajectories ${YARP_LIBRARIES} pthread)


add_executable(replayTrajectoriesWithGeom replayTrajectoriesWithGeom.cpp cartesianClient.cpp)
target_link_libraries(replayTrajectoriesWithGeom ${YARP_LIBRARIES} pthread)

add_executable(grasper GRASPER.cpp)
target_link_libraries(grasper ${YARP_LIBRARIES})


install(TARGETS sendForces DESTINATION bin)
install(TARGETS recordTrajectoriesWithGeomagic DESTINATION bin)
install(TARGETS replayTrajectories DESTINATION bin)
install(TARGETS replayTrajectoriesWithGeom DESTINATION bin)
install(TARGETS grasper DESTINATION bin)

