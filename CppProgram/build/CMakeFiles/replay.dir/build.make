# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.7

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build

# Include any dependencies generated for this target.
include CMakeFiles/replay.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/replay.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/replay.dir/flags.make

CMakeFiles/replay.dir/replayTrajectories.cpp.o: CMakeFiles/replay.dir/flags.make
CMakeFiles/replay.dir/replayTrajectories.cpp.o: ../replayTrajectories.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/replay.dir/replayTrajectories.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/replay.dir/replayTrajectories.cpp.o -c /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/replayTrajectories.cpp

CMakeFiles/replay.dir/replayTrajectories.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/replay.dir/replayTrajectories.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/replayTrajectories.cpp > CMakeFiles/replay.dir/replayTrajectories.cpp.i

CMakeFiles/replay.dir/replayTrajectories.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/replay.dir/replayTrajectories.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/replayTrajectories.cpp -o CMakeFiles/replay.dir/replayTrajectories.cpp.s

CMakeFiles/replay.dir/replayTrajectories.cpp.o.requires:

.PHONY : CMakeFiles/replay.dir/replayTrajectories.cpp.o.requires

CMakeFiles/replay.dir/replayTrajectories.cpp.o.provides: CMakeFiles/replay.dir/replayTrajectories.cpp.o.requires
	$(MAKE) -f CMakeFiles/replay.dir/build.make CMakeFiles/replay.dir/replayTrajectories.cpp.o.provides.build
.PHONY : CMakeFiles/replay.dir/replayTrajectories.cpp.o.provides

CMakeFiles/replay.dir/replayTrajectories.cpp.o.provides.build: CMakeFiles/replay.dir/replayTrajectories.cpp.o


CMakeFiles/replay.dir/cartesianClient.cpp.o: CMakeFiles/replay.dir/flags.make
CMakeFiles/replay.dir/cartesianClient.cpp.o: ../cartesianClient.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/replay.dir/cartesianClient.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/replay.dir/cartesianClient.cpp.o -c /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/cartesianClient.cpp

CMakeFiles/replay.dir/cartesianClient.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/replay.dir/cartesianClient.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/cartesianClient.cpp > CMakeFiles/replay.dir/cartesianClient.cpp.i

CMakeFiles/replay.dir/cartesianClient.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/replay.dir/cartesianClient.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/cartesianClient.cpp -o CMakeFiles/replay.dir/cartesianClient.cpp.s

CMakeFiles/replay.dir/cartesianClient.cpp.o.requires:

.PHONY : CMakeFiles/replay.dir/cartesianClient.cpp.o.requires

CMakeFiles/replay.dir/cartesianClient.cpp.o.provides: CMakeFiles/replay.dir/cartesianClient.cpp.o.requires
	$(MAKE) -f CMakeFiles/replay.dir/build.make CMakeFiles/replay.dir/cartesianClient.cpp.o.provides.build
.PHONY : CMakeFiles/replay.dir/cartesianClient.cpp.o.provides

CMakeFiles/replay.dir/cartesianClient.cpp.o.provides.build: CMakeFiles/replay.dir/cartesianClient.cpp.o


# Object files for target replay
replay_OBJECTS = \
"CMakeFiles/replay.dir/replayTrajectories.cpp.o" \
"CMakeFiles/replay.dir/cartesianClient.cpp.o"

# External object files for target replay
replay_EXTERNAL_OBJECTS =

bin/replay: CMakeFiles/replay.dir/replayTrajectories.cpp.o
bin/replay: CMakeFiles/replay.dir/cartesianClient.cpp.o
bin/replay: CMakeFiles/replay.dir/build.make
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_math.so.2.3.66.2
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_dev.so.2.3.66.2
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_init.so.2.3.66.2
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_name.so.2.3.66.2
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_sig.so.2.3.66.2
bin/replay: /home/odermy/Software/src/yarp/build/lib/libYARP_OS.so.2.3.66.2
bin/replay: CMakeFiles/replay.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking CXX executable bin/replay"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/replay.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/replay.dir/build: bin/replay

.PHONY : CMakeFiles/replay.dir/build

CMakeFiles/replay.dir/requires: CMakeFiles/replay.dir/replayTrajectories.cpp.o.requires
CMakeFiles/replay.dir/requires: CMakeFiles/replay.dir/cartesianClient.cpp.o.requires

.PHONY : CMakeFiles/replay.dir/requires

CMakeFiles/replay.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/replay.dir/cmake_clean.cmake
.PHONY : CMakeFiles/replay.dir/clean

CMakeFiles/replay.dir/depend:
	cd /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build /home/odermy/Desktop/delivrables/icub-learning-trajectories/CppProgram/build/CMakeFiles/replay.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/replay.dir/depend

