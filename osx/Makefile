.SUFFIXES: .cpp .c

NAME	= a

CXX			= g++
CXXFLAGS	= -Wall -fpic -g -c -std=gnu++11
CXXSRC		= $(wildcard ./*.cpp)
CXXOBJ		= $(CXXSRC:%.cpp=%-cpp.o)
CXXDEP		= $(CXXOBJ:%-cpp.o=%-cpp.d)

C		= gcc
CFLAGS	= -Wall -fpic -g -c
CSRC	= $(wildcard ./*.c)
COBJ	= $(CSRC:%.c=%-c.o)
CDEP	= $(COBJ:%-c.o=%-c.d)

LIBS	=

AR 		= ar
ARFLAGS	= rv
RANLIB	= ranlib

VALGRIND = valgrind

all:
	g++ -std=c++11 -O2 simple_net.cpp -o "$(HOME)/bin/simple_net"
	g++ -std=c++11 -O2 simple_cpu.cpp -o "$(HOME)/bin/simple_cpu"
	g++ -std=c++11 -O2 simple_mem.cpp -o "$(HOME)/bin/simple_mem"
