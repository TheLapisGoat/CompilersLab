#include <stdio.h>
#define KEYWORD 2           
#define IDENTIFIER 3
#define INTEGER_CONSTANT 4
#define FLOATING_CONSTANT 5
#define ENUMERATION_CONSTANT 6
#define CHARACTER_CONSTANT 7
#define STRING_LITERAL 8
#define PUNCTUATOR 9
#define MULTI_LINE_COMMENT 10
#define SINGLE_LINE_COMMENT 11
#define INVALID_TOKEN 12

extern int yylex();
extern char* yytext;

int main() {
    int token;
    while(token = yylex()) {
        switch(token) {
            case KEYWORD: 
                printf("<KEYWORD, %d, %s>\n", token, yytext); 
                break;
            case IDENTIFIER: 
                printf("<IDENTIFIER, %d, %s>\n", token, yytext); 
                break;
            case INTEGER_CONSTANT: 
                printf("<INTEGER CONSTANT, %d, %s>\n", token, yytext); 
                break;
            case FLOATING_CONSTANT: 
                printf("<FLOAT CONSTANT, %d, %s>\n", token, yytext); 
                break;
            case CHARACTER_CONSTANT: 
                printf("<CHARACTER CONSTANT, %d, %s>\n", token, yytext); 
                break;
            case STRING_LITERAL: 
                printf("<STRING LITERAL, %d, %s>\n", token, yytext); 
                break;
            case PUNCTUATOR: 
                printf("<PUNCTUATOR, %d, %s>\n", token, yytext); 
                break;
            case MULTI_LINE_COMMENT: 
                printf("<MULTI LINE COMMENT, %d>\n", token);  
                break;
            case SINGLE_LINE_COMMENT: 
                printf("<SINGLE LINE COMMENT, %d>\n", token); 
                break;
            case INVALID_TOKEN:
                printf("<INVALID TOKEN, %d, %s>\n", token, yytext);
                break;
        }
    }
    return 0;
}

int yywrap(void){
    return (1);
}