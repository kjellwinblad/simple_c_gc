IDIR = .
CC = cc

ifdef MODERN_CC
	EXTRA_C_FLAGS = -g -O03 -std=c99 -pedantic -Wall
else
	EXTRA_C_FLAGS =
endif

ifdef ADD_SAN
	CC = clang
	EXTRA_C_FLAGS = -std=c99 -Wall -pedantic -g -O00 -fsanitize-blacklist=.misc/clang_blacklist.txt -fsanitize=address -fno-omit-frame-pointer
	USE_GC_STRING = -use_gc
endif

ifdef MEM_SAN
	CC = clang
	EXTRA_C_FLAGS = -std=c99 -Wall -pedantic -g -O00 -fsanitize-blacklist=.misc/clang_blacklist.txt -fsanitize=memory -fno-omit-frame-pointer
endif

CFLAGS = -I$(IDIR) $(EXTRA_C_FLAGS)

ODIR = .
LDIR =

_DEPS = bitreversal.h simple_c_gc.h chained_hash_set.h sorted_list_set.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = simple_c_gc.o test.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
C_FILES = $(patsubst %.o,%.c,$(_OBJ))

$(ODIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

test.bin: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)


.PHONY: clean test run_test_continusly CMakeLists.txt cmake_compile clang_format add_san_test mem_san_test modern_test

test: test.bin
	./test.bin > /dev/null &&\
	printf "\n\n\033[0;32mALL TESTS PASSED!\033[0m\n\n\n" ||\
	printf "\n\n\033[0;31mTEST FAILED!\033[0m\n\n\n"

valgrind_test:
	make clean
	make EXTRA_C_FLAGS="-g -O01"
	valgrind --undef-value-errors=no ./test.bin > /dev/null &&\
	printf "\n\n\033[0;32mALL TESTS PASSED!\033[0m\n\n\n" ||\
	printf "\n\n\033[0;31mTEST FAILED!\033[0m\n\n\n"

add_san_test:
	make clean
	make ADD_SAN=1 test

mem_san_test:
	make clean
	make MEM_SAN=1 test

modern_test:
	make clean
	make MODERN_CC=1 test


run_test_continusly:
	inotifywait -e close_write,moved_to,create -m ./*.c ./*.h | while read -r directory events filename; do gtags ; make test ; done

CMakeLists.txt: $(C_FILES)
	echo "cmake_minimum_required (VERSION 2.6)" > CMakeLists.txt
	echo "project (SIMPLE_C_GC)" >> CMakeLists.txt
	echo "add_executable(cmake.out" >> CMakeLists.txt
	echo $(C_FILES) >> CMakeLists.txt
	echo ")" >> CMakeLists.txt


cmake_compile: CMakeLists.txt
	mkdir cmake_mkdir || true
	cd cmake_mkdir && cmake ..

clang_format:
	clang-format -style="{BasedOnStyle: LLVM}" -i *.c *.h

clean:
	rm -f $(ODIR)/*.o *~ core $(IDIR)/*~ test.bin CMakeLists.txt
