.SUFFIXES: .cpp .c

NAME	= a

CXX			= g++
CXXFLAGS	= -Wall -fpic -g -c -std=gnu++11
CXXSRC		= $(wildcard ./*.cpp)
CXXOBJ		= $(CXXSRC:%.cpp=%.o)
CXXDEP		= $(CXXOBJ:%.o=%.d)

C		= gcc
CFLAGS	= -Wall -fpic -g -c
CSRC	= $(wildcard ./*.c)
COBJ	= $(CSRC:%.c=%.o)
CDEP	= $(COBJ:%.o=%.d)

LIBS	=

AR 		= ar
ARFLAGS	= rv
RANLIB	= ranlib

VALGRIND = valgrind

$(NAME).out: $(CXXOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(CXX) $(CXXOBJ) $(COBJ) $(LIBS) -o $@

lib$(NAME).so: $(CXXOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(CXX) -shared -Wl,-soname,lib$(NAME).so $(CXXOBJ) $(COBJ) -o $@

lib$(NAME).a: $(CXXOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(AR) $(ARFLAGS) $@ $(CXXOBJ) $(COBJ)
	@$(RANLIB) $@

-include $(CXXDEP)
-include $(CDEP)

.SECONDARY:
%.o: %.cpp
	@echo -e "\033[0;33m*\033[0m $< -> $@"
	@$(CXX) $(CXXFLAGS) $< -MMD -o $@

.SECONDARY:
%.o: %.c
	@echo -e "\033[0;33m*\033[0m $< -> $@"
	@$(C) $(CFLAGS) $< -MMD -o $@

.PHONY:
clean:
	-rm *.d *.o $(NAME).out lib$(NAME).so lib$(NAME).a

.PHONY:
mem_test: a.out
	@$(VALGRIND)	\
		--tool=memcheck \
		--leak-check=yes \
		--show-reachable=yes \
		--num-callers=20 \
		--track-fds=yes \
		./a.out
