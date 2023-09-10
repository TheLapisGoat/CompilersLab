run: parser asgn4_21CS10064_21CS10067_test.c
	./parser < asgn4_21CS10064_21CS10067_test.c

parser: lex.yy.o y.tab.o asgn4_21CS10064_21CS10067.o
	gcc lex.yy.o y.tab.o asgn4_21CS10064_21CS10067.o -lfl -o parser

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

asgn4_21CS10064_21CS10067.o: asgn4_21CS10064_21CS10067.c
	gcc -c asgn4_21CS10064_21CS10067.c

lex.yy.c: asgn4_21CS10064_21CS10067.l y.tab.h
	flex asgn4_21CS10064_21CS10067.l

y.tab.c y.tab.h: asgn4_21CS10064_21CS10067.y
	bison -dty --report=all asgn4_21CS10064_21CS10067.y

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o asgn4_21CS10064_21CS10067.o parser y.output