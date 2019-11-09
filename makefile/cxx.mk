.SUFFIXES: .cpp .c

NAME	= a

CPP			= g++
CPPFLAGS	= -Wall -fpic -g -c -std=gnu++11
CPPSRC		= $(wildcard ./*.cpp)
CPPOBJ		= $(CPPSRC:%.cpp=%-cpp.o)
CPPDEP		= $(CPPOBJ:%-cpp.o=%-cpp.d)

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

$(NAME).out: $(CPPOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(CPP) $(CPPOBJ) $(COBJ) $(LIBS) -o $@

lib$(NAME).so: $(CPPOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(CPP) -shared -Wl,-soname,lib$(NAME).so $(CPPOBJ) $(COBJ) -o $@

lib$(NAME).a: $(CPPOBJ) $(COBJ)
	@echo -e "\033[0;33m>>>\033[0m $@"
	@$(AR) $(ARFLAGS) $@ $(CPPOBJ) $(COBJ)
	@$(RANLIB) $@

-include $(CPPDEP)
-include $(CDEP)

.SECONDARY:
%-cpp.o: %.cpp
	@echo -e "\033[0;33m*\033[0m $< -> $@"
	@$(CPP) $(CPPFLAGS) $< -MMD -o $@

.SECONDARY:
%-c.o: %.c
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
