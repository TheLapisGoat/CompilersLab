run: a.out
	./a.out < ass3_21CS10064_21CS10067_test.c

a.out: lex.yy.c
	gcc ass3_21CS10064_21CS10067.c lex.yy.c

lex.yy.c: ass3_21CS10064_21CS10067.l
	flex ass3_21CS10064_21CS10067.l

clean:
	rm -f a.out lex.yy.c