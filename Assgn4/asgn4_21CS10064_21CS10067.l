%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int yylex();
%}

%option yylineno

%x IN_MULTILINE_COMMENT
%x IN_SINGLELINE_COMMENT

/* KEYWORDS */

AUTO                   "auto"
BREAK                  "break"
CASE                   "case"
CHAR                   "char"
CONST                  "const"
CONTINUE               "continue"
DEFAULT                "default"
DO                     "do"
DOUBLE                 "double"
ELSE                   "else"
ENUM                   "enum"
EXTERN                 "extern"
FLOAT                  "float"
FOR                    "for"
GOTO                   "goto"
IF                     "if"
INLINE                 "inline"
INT                    "int"
LONG                   "long"
REGISTER               "register"
RESTRICT               "restrict"
RETURN                 "return"
SHORT                  "short"
SIGNED                 "signed"
SIZEOF                 "sizeof"
STATIC                 "static"
STRUCT                 "struct"
SWITCH                 "switch"
TYPEDEF                "typedef"
UNION                  "union"
UNSIGNED               "unsigned"
VOID                   "void"
VOLATILE               "volatile"
WHILE                  "while"
BOOL                   "_Bool"
COMPLEX                "_Complex"
IMAGINARY              "_Imaginary"

IDENTIFIER_NONDIGIT     [a-zA-Z_]
DIGIT                   [0-9]
IDENTIFIER              {IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*

NONZERO_DIGIT           [1-9]
INTEGER_CONSTANT        {NONZERO_DIGIT}{DIGIT}*|0

DIGIT_SEQUENCE          {DIGIT}+
FRACTIONAL_CONSTANT     {DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}\.
SIGN                    [+-]
EXPONENT_PART           [eE]{SIGN}?{DIGIT_SEQUENCE}
FLOATING_CONSTANT       {FRACTIONAL_CONSTANT}{EXPONENT_PART}?|{DIGIT_SEQUENCE}{EXPONENT_PART}

/* ENUMERATION_CONSTANT    {IDENTIFIER} */

ESCAPE_SEQUENCE         \\(['"?\\abfnrtv])
C_CHAR                  [^'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE         {C_CHAR}+
CHARACTER_CONSTANT      \'{C_CHAR_SEQUENCE}\'

S_CHAR                  [^"\\\n]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE         {S_CHAR}+
STRING_LITERAL          \"{S_CHAR_SEQUENCE}\"

WHITESPACE              [ \t]
NEWLINE                 \n

%%

"/*"                    {BEGIN(IN_MULTILINE_COMMENT);}
<IN_MULTILINE_COMMENT>{
    "\n"                {printf("\nParsing Line Number: %d \n", yylineno);}
    "*/"                {BEGIN(INITIAL);}
    .                   {}
}

"//"                    {BEGIN(IN_SINGLELINE_COMMENT);}
<IN_SINGLELINE_COMMENT>{
    "\n"                {printf("\nParsing Line Number: %d \n", yylineno); BEGIN(INITIAL);}
    <<EOF>>             {BEGIN(INITIAL);}
    .                   {}
}

{AUTO}                  {return AUTO;}
{BREAK}                 {return BREAK;}
{CASE}                  {return CASE;}
{CHAR}                  {return CHAR;}
{CONST}                 {return CONST;}
{CONTINUE}              {return CONTINUE;}
{DEFAULT}               {return DEFAULT;}
{DO}                    {return DO;}
{DOUBLE}                {return DOUBLE;}
{ELSE}                  {return ELSE;}
{ENUM}                  {return ENUM;}
{EXTERN}                {return EXTERN;}
{FLOAT}                 {return FLOAT;}
{FOR}                   {return FOR;}
{GOTO}                  {return GOTO;}
{IF}                    {return IF;}
{INLINE}                {return INLINE;}
{INT}                   {return INT;}
{LONG}                  {return LONG;}
{REGISTER}              {return REGISTER;}
{RESTRICT}              {return RESTRICT;}
{RETURN}                {return RETURN;}
{SHORT}                 {return SHORT;}
{SIGNED}                {return SIGNED;}
{SIZEOF}                {return SIZEOF;}
{STATIC}                {return STATIC;}
{STRUCT}                {return STRUCT;}
{SWITCH}                {return SWITCH;}
{TYPEDEF}               {return TYPEDEF;}
{UNION}                 {return UNION;}
{UNSIGNED}              {return UNSIGNED;}
{VOID}                  {return VOID;}
{VOLATILE}              {return VOLATILE;}
{WHILE}                 {return WHILE;}
{BOOL}                  {return BOOL;}
{COMPLEX}               {return COMPLEX;}
{IMAGINARY}             {return IMAGINARY;}

{IDENTIFIER}            {yylval.idValue = strdup(yytext); return IDENTIFIER;}

{INTEGER_CONSTANT}      {yylval.intValue = atoi(yytext); return INTEGER_CONSTANT;}
{FLOATING_CONSTANT}     {yylval.floatValue = atof(yytext); return FLOATING_CONSTANT;}
{CHARACTER_CONSTANT}    {yylval.charValue = strdup(yytext); return CHARACTER_CONSTANT;}
{STRING_LITERAL}        {yylval.stringValue = strdup(yytext); return STRING_LITERAL;}

"["                             {return LEFT_SQUARE_BRACKET;}
"++"                            {return INCREMENT;}
"/"                             {return SLASH;}
"?"                             {return QUESTION_MARK;}
"="                             {return ASSIGNMENT;}
","                             {return COMMA;}
"]"                             {return RIGHT_SQUARE_BRACKET;}
"("                             {return LEFT_PARENTHESES;}
"{"                             {return LEFT_CURLY_BRACKET;}
"}"                             {return RIGHT_CURLY_BRACKET;}
"."                             {return DOT;}
"->"                            {return ARROW;}
"*"                             {return ASTERISK;}
"+"                             {return PLUS;}
"-"                             {return MINUS;}
"~"                             {return TILDE;}
"!"                             {return EXCLAMATION;}
"%"                             {return MODULO;}
"<<"                            {return LEFT_SHIFT;}
">>"                            {return RIGHT_SHIFT;}
"<"                             {return LESS_THAN;}
">"                             {return GREATER_THAN;}
"<="                            {return LESS_EQUAL_THAN;}
">="                            {return GREATER_EQUAL_THAN;}
":"                             {return COLON;}
";"                             {return SEMI_COLON;}
"..."                           {return ELLIPSIS;}
"*="                            {return ASTERISK_ASSIGNMENT;}
"/="                            {return SLASH_ASSIGNMENT;}
"%="                            {return MODULO_ASSIGNMENT;}
"+="                            {return PLUS_ASSIGNMENT;}
"-="                            {return MINUS_ASSIGNMENT;}
"<<="                           {return LEFT_SHIFT_ASSIGNMENT;}
"#"                             {return HASH;}
"--"                            {return DECREMENT;}
")"                             {return RIGHT_PARENTHESES;}
"&"                             {return AMPERSAND;}
"=="                            {return EQUALS;}
"^"                             {return BITWISE_XOR;}
"|"                             {return BITWISE_OR;}
"&&"                            {return LOGICAL_AND;}
"||"                            {return LOGICAL_OR;}
">>="                           {return RIGHT_SHIFT_ASSIGNMENT;}
"!="                            {return NOT_EQUALS;}
"&="                            {return BITWISE_AND_ASSIGNMENT;}
"|="                            {return BITWISE_OR_ASSIGNMENT;}
"^="                            {return BITWISE_XOR_ASSIGNMENT;}

{WHITESPACE}            {}
{NEWLINE}               {printf("\nParsing Line Number: %d \n", yylineno);}

.                       {return INVALID_TOKEN;}

%%

int yywrap() {
    return 1;
}
