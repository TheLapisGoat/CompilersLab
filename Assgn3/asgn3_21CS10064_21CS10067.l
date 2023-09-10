%{
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
%}

%x IN_MULTILINE_COMMENT
%x IN_SINGLELINE_COMMENT

KEYWORD                 "auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"_Bool"|"continue"|"if"|"static"|"_Complex"|"default"|"inline"|"struct"|"_Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"

IDENTIFIER_NONDIGIT     [a-zA-Z_]
DIGIT                   [0-9]
IDENTIFIER              {IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*

NONZERO_DIGIT           [1-9]
INTEGER_CONSTANT        {NONZERO_DIGIT}{DIGIT}*

DIGIT_SEQUENCE          {DIGIT}+
FRACTIONAL_CONSTANT     {DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}\.
SIGN                    [+-]
EXPONENT_PART           [eE]{SIGN}?{DIGIT_SEQUENCE}
FLOATING_CONSTANT       {FRACTIONAL_CONSTANT}{EXPONENT_PART}?|{DIGIT_SEQUENCE}{EXPONENT_PART}

ENUMERATION_CONSTANT    {IDENTIFIER}

ESCAPE_SEQUENCE         \\['"?\\abfnrtv]
C_CHAR                  [^'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE         {C_CHAR}+
CHARACTER_CONSTANT      '{C_CHAR_SEQUENCE}'

S_CHAR                  [^"\\\n]|{ESCAPE_SEQUENCE}.
S_CHAR_SEQUENCE         {S_CHAR}+
STRING_LITERAL          \"{S_CHAR_SEQUENCE}\"

PUNCTUATOR              "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"

%%

{KEYWORD}               {return KEYWORD;}
{IDENTIFIER}            {return IDENTIFIER;}
{INTEGER_CONSTANT}      {return INTEGER_CONSTANT;}
{FLOATING_CONSTANT}     {return FLOATING_CONSTANT;}
{ENUMERATION_CONSTANT}  {return ENUMERATION_CONSTANT;}
{CHARACTER_CONSTANT}    {return CHARACTER_CONSTANT;}
{STRING_LITERAL}        {return STRING_LITERAL;}
{PUNCTUATOR}            {return PUNCTUATOR;}

"/*"                    {BEGIN(IN_MULTILINE_COMMENT);}
"//"                    {BEGIN(IN_SINGLELINE_COMMENT);}

<IN_MULTILINE_COMMENT>{
    "\n"                {}
    "*/"                {BEGIN(INITIAL); return MULTI_LINE_COMMENT;}
    .                   {}
}

<IN_SINGLELINE_COMMENT>{
    "\n"                  {BEGIN(INITIAL); return SINGLE_LINE_COMMENT;}
    .                   {}
}

[ \n\t]                 {}

.                       {return INVALID_TOKEN;}

%%