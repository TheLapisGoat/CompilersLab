compiler.out: lex.yy.o ass6_21CS10064_21CS10067.tab.o ass6_21CS10064_21CS10067_translator.o ass6_21CS10064_21CS10067_target_translator.o
	g++ lex.yy.o ass6_21CS10064_21CS10067.tab.o ass6_21CS10064_21CS10067_translator.o ass6_21CS10064_21CS10067_target_translator.o -o compiler.out

ass6_21CS10064_21CS10067_translator.o: ass6_21CS10064_21CS10067_translator.cxx ass6_21CS10064_21CS10067_translator.h
	g++ -c ass6_21CS10064_21CS10067_translator.cxx

ass6_21CS10064_21CS10067_target_translator.o: ass6_21CS10064_21CS10067_target_translator.cxx
	g++ -c ass6_21CS10064_21CS10067_target_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

ass6_21CS10064_21CS10067.tab.o: ass6_21CS10064_21CS10067.tab.c
	g++ -c ass6_21CS10064_21CS10067.tab.c

lex.yy.c: ass6_21CS10064_21CS10067.l ass6_21CS10064_21CS10067.tab.h ass6_21CS10064_21CS10067_translator.h
	flex ass6_21CS10064_21CS10067.l

ass6_21CS10064_21CS10067.tab.c ass6_21CS10064_21CS10067.tab.h: ass6_21CS10064_21CS10067.y
	bison -dtv --report=all ass6_21CS10064_21CS10067.y

ass6_21CS10064_21CS10067.o: ass6_21CS10064_21CS10067.c myl.h
	gcc -c ass6_21CS10064_21CS10067.c

libass6_21CS10064_21CS10067.a: ass6_21CS10064_21CS10067.o
	ar -rcs libass6_21CS10064_21CS10067.a ass6_21CS10064_21CS10067.o

clean:
	@rm -f compiler.out *.o lex.yy.* *.tab.* quads/* *.output assembly_files/* *.a bin/* test1 test2 test3 test4 test5
	@rmdir quads assembly_files

test: compiler.out libass6_21CS10064_21CS10067.a
	@mkdir quads
	@mkdir assembly_files

	@echo "Running Test 1:"
	./compiler.out 1 < testcases/ass6_21CS10064_21CS10067_test1.c > quads/ass6_21CS10064_21CS10067_quads1.out
	gcc -c assembly_files/ass6_21CS10064_21CS10067_1.s -o assembly_files/ass6_21CS10064_21CS10067_1.o
	gcc assembly_files/ass6_21CS10064_21CS10067_1.o -o test1 -L. -lass6_21CS10064_21CS10067 -no-pie

	@echo "Running Test 2:"
	./compiler.out 2 < testcases/ass6_21CS10064_21CS10067_test2.c > quads/ass6_21CS10064_21CS10067_quads2.out
	gcc -c assembly_files/ass6_21CS10064_21CS10067_2.s -o assembly_files/ass6_21CS10064_21CS10067_2.o
	gcc assembly_files/ass6_21CS10064_21CS10067_2.o -o test2 -L. -lass6_21CS10064_21CS10067 -no-pie

	@echo "Running Test 3:"
	./compiler.out 3 < testcases/ass6_21CS10064_21CS10067_test3.c > quads/ass6_21CS10064_21CS10067_quads3.out
	gcc -c assembly_files/ass6_21CS10064_21CS10067_3.s -o assembly_files/ass6_21CS10064_21CS10067_3.o
	gcc assembly_files/ass6_21CS10064_21CS10067_3.o -o test3 -L. -lass6_21CS10064_21CS10067 -no-pie

	@echo "Running Test 4:"
	./compiler.out 4 < testcases/ass6_21CS10064_21CS10067_test4.c > quads/ass6_21CS10064_21CS10067_quads4.out
	gcc -c assembly_files/ass6_21CS10064_21CS10067_4.s -o assembly_files/ass6_21CS10064_21CS10067_4.o
	gcc assembly_files/ass6_21CS10064_21CS10067_4.o -o test4 -L. -lass6_21CS10064_21CS10067 -no-pie

	@echo "Running Test 5:"
	./compiler.out 5 < testcases/ass6_21CS10064_21CS10067_test5.c > quads/ass6_21CS10064_21CS10067_quads5.out
	gcc -c assembly_files/ass6_21CS10064_21CS10067_5.s -o assembly_files/ass6_21CS10064_21CS10067_5.o
	gcc assembly_files/ass6_21CS10064_21CS10067_5.o -o test5 -L. -lass6_21CS10064_21CS10067 -no-pie

	@echo "The executables for the tests are test1, test2, test3, test4, test5 and can be run as ./testi where i is the test number"
	@echo "The assembly files can be found in the assembly_files directory"
	@echo "The quads can be found in the quads directory"
	@echo "The files can be cleaned using the command 'make clean'"