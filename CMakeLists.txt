cmake_minimum_required(VERSION 3.5)
project(trex_parser)

find_package(BISON 3.7.0)
find_package(FLEX 2.6.0)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

BISON_TARGET(y.tab.o trex_parser.y ${CMAKE_CURRENT_BINARY_DIR}/y.tab.c COMPILE_FLAGS -yd)
FLEX_TARGET(lex.yy.o trex_praser.l  ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c)
ADD_FLEX_BISON_DEPENDENCY(lex.yy.o y.tab.o)         # These are generated files. They will always have the same name

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_executable(trex_parser
  ${BISON_y.tab.o_OUTPUTS}
  ${FLEX_lex.yy.o_OUTPUTS}
  trex_parser.c
)
