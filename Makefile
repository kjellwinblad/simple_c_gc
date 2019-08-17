IDIR = .
CC = cc
CFLAGS = -I$(IDIR)

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


.PHONY: clean test run_test_continusly CMakeLists.txt cmake_compile

test: test.bin
	./test.bin > /dev/null &&\
	printf "\n\n\033[0;32mALL TESTS PASSED!\033[0m\n\n\n" ||\
	printf "\n\n\033[0;31mTEST FAILED!\033[0m\n\n\n"

test_valgrind: test.bin
	valgrind --undef-value-errors=no ./test.bin > /dev/null &&\
	printf "\n\n\033[0;32mALL TESTS PASSED!\033[0m\n\n\n" ||\
	printf "\n\n\033[0;31mTEST FAILED!\033[0m\n\n\n"

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

clean:
	rm -f $(ODIR)/*.o *~ core $(IDIR)/*~ test.bin CMakeLists.txt
