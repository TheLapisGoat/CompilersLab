parser.out: lex.yy.o y.tab.o ass5_21CS10064_21CS10067_translator.o
	g++ lex.yy.o y.tab.o ass5_21CS10064_21CS10067_translator.o -o parser.out

ass5_21CS10064_21CS10067_translator.o: ass5_21CS10064_21CS10067_translator.cxx ass5_21CS10064_21CS10067_translator.h
	g++ -c ass5_21CS10064_21CS10067_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass5_21CS10064_21CS10067.l y.tab.h ass5_21CS10064_21CS10067_translator.h
	flex ass5_21CS10064_21CS10067.l

y.tab.c y.tab.h: ass5_21CS10064_21CS10067.y
	bison -dty --report=all ass5_21CS10064_21CS10067.y

clean:
	rm parser.out ass5_21CS10064_21CS10067_translator.o lex.yy.* y.tab.* y.output ass5_21CS10064_21CS10067_quads*.out

test: parser.out
	@echo "Running Test 1:"
	./parser.out < ass5_21CS10064_21CS10067_test1.c > ass5_21CS10064_21CS10067_quads1.out
	@echo "Test output is in ass5_21CS1006Statement4_21CS10067_quads1.out"

	@echo "Running Test 2:"
	./parser.out < ass5_21CS10064_21CS10067_test2.c > ass5_21CS10064_21CS10067_quads2.out
	@echo "Test output is in ass5_21CS10064_21CS10067_quads2.out"

	@echo "Running Test 3:"
	./parser.out < ass5_21CS10064_21CS10067_test3.c > ass5_21CS10064_21CS10067_quads3.out
	@echo "Test output is in ass5_21CS10064_21CS10067_quads3.out"

	@echo "Running Test 4:"
	./parser.out < ass5_21CS10064_21CS10067_test4.c > ass5_21CS10064_21CS10067_quads4.out
	@echo "Test output is in ass5_21CS10064_21CS10067_quads4.out"

	@echo "Running Test 5:"
	./parser.out < ass5_21CS10064_21CS10067_test5.c > ass5_21CS10064_21CS10067_quads5.out
	@echo "Test output is in ass5_21CS10064_21CS10067_quads5.out"
