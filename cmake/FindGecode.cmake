#source from http://code.google.com/p/cpfloat-gecode/source/browse/trunk/cmake-support/FindGecode.cmake?r=9

#Works under the assumption than when gecode is installed at least the kernel component exists
# Look for the header file
find_path(GECODE_INCLUDE_DIR NAMES gecode/kernel.hh )
find_file(GECODE_CONFIG gecode/support/config.hpp)
# Look for the library
find_library(GECODE_LIBRARY NAMES gecodekernel)
find_library(GECODE_SUPPORT_LIBRARY NAMES gecodesupport)

if(GECODE_CONFIG)
  file(STRINGS ${GECODE_CONFIG} GECODE_LINE_VERSION REGEX "^#define GECODE_VERSION .*")
  string(REGEX MATCH "[0-9].[0-9].[0-9]" GECODE_VERSION ${GECODE_LINE_VERSION})
endif()

if(GECODE_INCLUDE_DIR AND GECODE_LIBRARY AND GECODE_SUPPORT_LIBRARY)
  set(GECODE_FOUND Yes)
endif()

if(GECODE_FOUND)
  set(GECODE_LIBRARIES ${GECODE_LIBRARY} ${GECODE_SUPPORT_LIBRARY})
  set(GECODE_INCLUDE_DIRS ${GECODE_INCLUDE_DIR})
  find_library(GECODE_DRIVER_LIBRARY gecodedriver)
  if(GECODE_DRIVER_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_DRIVER_LIBRARY})
  endif()
  find_library(GECODE_FZ_LIBRARY gecodeflatzinc)
  if(GECODE_FZ_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_FZ_LIBRARY})
  endif()
  find_library(GECODE_GIST_LIBRARY gecodegist)
  if(GECODE_GIST_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_GIST_LIBRARY})
  endif()
  find_library(GECODE_GRAPH_LIBRARY gecodegraph)
  if(GECODE_GRAPH_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_GRAPH_LIBRARY})
  endif()
  find_library(GECODE_INT_LIBRARY gecodeint)
  if(GECODE_INT_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_INT_LIBRARY})
  endif()
  find_library(GECODE_FLOAT_LIBRARY gecodefloat)
  if(GECODE_FLOAT_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_FLOAT_LIBRARY})
  endif()
  find_library(GECODE_MM_LIBRARY gecodeminimodel)
  if(GECODE_MM_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_MM_LIBRARY})
  endif()
  find_library(GECODE_SCHEDULING_LIBRARY gecodescheduling)
  if(GECODE_SCHEDULING_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_SCHEDULING_LIBRARY})
  endif()
  find_library(GECODE_SEARCH_LIBRARY gecodesearch)
  if(GECODE_SEARCH_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_SEARCH_LIBRARY})
  endif()
  find_library(GECODE_SET_LIBRARY gecodeset)
  if(GECODE_SET_LIBRARY)
    list(APPEND GECODE_LIBRARIES ${GECODE_SET_LIBRARY})
  endif()
endif()
