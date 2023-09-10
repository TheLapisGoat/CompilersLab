%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    extern int yylex();
    extern int yylineno;
    extern char* yytext;
    void yyerror(char *);
%}

%union{
    char *idValue;
    int intValue;
    float floatValue;
    char *charValue;
    char *stringValue;
}

%token <idValue> IDENTIFIER
%token <intValue> INTEGER_CONSTANT
%token <floatValue> FLOATING_CONSTANT
%token <charValue> CHARACTER_CONSTANT
%token <stringValue> STRING_LITERAL

%token AUTO
%token BREAK
%token CASE
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOAT
%token FOR
%token GOTO
%token IF
%token INLINE
%token INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE
%token BOOL
%token COMPLEX
%token IMAGINARY

%token LEFT_SQUARE_BRACKET
%token INCREMENT
%token SLASH
%token QUESTION_MARK
%token ASSIGNMENT
%token COMMA
%token RIGHT_SQUARE_BRACKET
%token LEFT_PARENTHESES
%token LEFT_CURLY_BRACKET
%token RIGHT_CURLY_BRACKET
%token DOT
%token ARROW
%token ASTERISK
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token MODULO
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_EQUAL_THAN
%token GREATER_EQUAL_THAN
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token ASTERISK_ASSIGNMENT
%token SLASH_ASSIGNMENT
%token MODULO_ASSIGNMENT
%token PLUS_ASSIGNMENT
%token MINUS_ASSIGNMENT
%token LEFT_SHIFT_ASSIGNMENT
%token HASH
%token DECREMENT
%token RIGHT_PARENTHESES
%token AMPERSAND
%token EQUALS
%token BITWISE_XOR
%token BITWISE_OR
%token LOGICAL_AND
%token LOGICAL_OR
%token RIGHT_SHIFT_ASSIGNMENT
%token NOT_EQUALS
%token BITWISE_AND_ASSIGNMENT
%token BITWISE_OR_ASSIGNMENT
%token BITWISE_XOR_ASSIGNMENT

%token INVALID_TOKEN

%nonassoc RIGHT_PARENTHESES
%nonassoc ELSE

%start translation_unit

%%

/* Expressions */

primary_expression
                : IDENTIFIER
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> IDENTIFIER\n", yylineno); printf("IDENTIFIER = %s\n", $1); }
                | INTEGER_CONSTANT
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> INTEGER_CONSTANT\n", yylineno); printf("INTEGER_CONSTANT = %d\n", $1); }
                | FLOATING_CONSTANT
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> FLOATING_CONSTANT\n", yylineno); printf("FLOATING_CONSTANT = %f\n", $1); }
                | CHARACTER_CONSTANT
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> CHARACTER_CONSTANT\n", yylineno); printf("CHARACTER_CONSTANT = %s\n", $1); }
                | STRING_LITERAL
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> STRING_LITERAL\n", yylineno); printf("STRING_LITERAL = %s\n", $1); }
                | LEFT_PARENTHESES expression RIGHT_PARENTHESES
                { printf("\nLine %d : EXPRESSION Rule : primary_expression -> ( expression )\n", yylineno); }
                ;

postfix_expression
                : primary_expression
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> primary_expression\n", yylineno); }
                | postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression [ expression ]\n", yylineno); }
                | postfix_expression LEFT_PARENTHESES argument_expression_list_opt RIGHT_PARENTHESES
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression ( argument_expression_list_opt )\n", yylineno); }
                | postfix_expression DOT IDENTIFIER
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression . IDENTIFIER\n", yylineno); }
                | postfix_expression ARROW IDENTIFIER
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression -> IDENTIFIER\n", yylineno); }
                | postfix_expression INCREMENT
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression ++\n", yylineno); }
                | postfix_expression DECREMENT
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression --\n", yylineno); }
                | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> ( type_name ) { initializer_list }\n", yylineno); }
                | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
                { printf("\nLine %d : EXPRESSION Rule : postfix_expression -> ( type_name ) { initializer_list , }\n", yylineno); }
                ;

argument_expression_list_opt
                : /* empty */
                { printf("\nLine %d : EXPRESSION Rule : argument_expression_list_opt -> epsilon\n", yylineno); }
                | argument_expression_list
                { printf("\nLine %d : EXPRESSION Rule : argument_expression_list_opt -> argument_expression_list\n", yylineno); }
                ;

argument_expression_list
                : assignment_expression
                { printf("\nLine %d : EXPRESSION Rule : argument_expression_list -> assignment_expression\n", yylineno); }
                | argument_expression_list COMMA assignment_expression
                { printf("\nLine %d : EXPRESSION Rule : argument_expression_list -> argument_expression_list , assignment_expression\n", yylineno); }
                ;

unary_expression
                : postfix_expression
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> postfix_expression\n", yylineno); }
                | INCREMENT unary_expression
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> ++ unary_expression\n", yylineno); }
                | DECREMENT unary_expression
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> -- unary_expression\n", yylineno); }
                | unary_operator cast_expression
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> unary_operator cast_expression\n", yylineno); }
                | SIZEOF unary_expression
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> sizeof unary_expression\n", yylineno); }
                | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
                { printf("\nLine %d : EXPRESSION Rule : unary_expression -> sizeof ( type_name )\n", yylineno); }
                ;

unary_operator
                : ASTERISK
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> *\n", yylineno); }
                | AMPERSAND
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> &\n", yylineno); }
                | PLUS
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> +\n", yylineno); }
                | MINUS
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> -\n", yylineno); }
                | TILDE
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> ~\n", yylineno); }
                | EXCLAMATION
                { printf("\nLine %d : EXPRESSION Rule : unary_operator -> !\n", yylineno); }
                ;

cast_expression
                : unary_expression
                { printf("\nLine %d : EXPRESSION Rule : cast_expression -> unary_expression\n", yylineno); }
                | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
                { printf("\nLine %d : EXPRESSION Rule : cast_expression -> ( type_name ) cast_expression\n", yylineno); }
                ;

multiplicative_expression
                : cast_expression
                { printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> cast_expression\n", yylineno); }
                | multiplicative_expression ASTERISK cast_expression
                { printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression * cast_expression\n", yylineno); }
                | multiplicative_expression SLASH cast_expression
                { printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression / cast_expression\n", yylineno); }
                | multiplicative_expression MODULO cast_expression
                { printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression %% cast_expression\n", yylineno); }
                ;

additive_expression
                : multiplicative_expression
                { printf("\nLine %d : EXPRESSION Rule : additive_expression -> multiplicative_expression\n", yylineno); }
                | additive_expression PLUS multiplicative_expression
                { printf("\nLine %d : EXPRESSION Rule : additive_expression -> additive_expression + multiplicative_expression\n", yylineno); }
                | additive_expression MINUS multiplicative_expression
                { printf("\nLine %d : EXPRESSION Rule : additive_expression -> additive_expression - multiplicative_expression\n", yylineno); }
                ;

shift_expression
                : additive_expression
                { printf("\nLine %d : EXPRESSION Rule : shift_expression -> additive_expression\n", yylineno); }
                | shift_expression LEFT_SHIFT additive_expression
                { printf("\nLine %d : EXPRESSION Rule : shift_expression -> shift_expression << additive_expression\n", yylineno); }
                | shift_expression RIGHT_SHIFT additive_expression
                { printf("\nLine %d : EXPRESSION Rule : shift_expression -> shift_expression >> additive_expression\n", yylineno); }
                ;

relational_expression
                : shift_expression
                { printf("\nLine %d : EXPRESSION Rule : relational_expression -> shift_expression\n", yylineno); }
                | relational_expression LESS_THAN shift_expression
                { printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression < shift_expression\n", yylineno); }
                | relational_expression GREATER_THAN shift_expression
                { printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression > shift_expression\n", yylineno); }
                | relational_expression LESS_EQUAL_THAN shift_expression
                { printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression <= shift_expression\n", yylineno); }
                | relational_expression GREATER_EQUAL_THAN shift_expression
                { printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression >= shift_expression\n", yylineno); }
                ;

equality_expression
                : relational_expression
                { printf("\nLine %d : EXPRESSION Rule : equality_expression -> relational_expression\n", yylineno); }
                | equality_expression EQUALS relational_expression
                { printf("\nLine %d : EXPRESSION Rule : equality_expression -> equality_expression == relational_expression\n", yylineno); }
                | equality_expression NOT_EQUALS relational_expression
                { printf("\nLine %d : EXPRESSION Rule : equality_expression -> equality_expression != relational_expression\n", yylineno); }
                ;

AND_expression
                : equality_expression
                { printf("\nLine %d : EXPRESSION Rule : AND_expression -> equality_expression\n", yylineno); }
                | AND_expression AMPERSAND equality_expression
                { printf("\nLine %d : EXPRESSION Rule : AND_expression -> AND_expression & equality_expression\n", yylineno); }
                ;

exclusive_OR_expression
                : AND_expression
                { printf("\nLine %d : EXPRESSION Rule : exclusive_OR_expression -> AND_expression\n", yylineno); }
                | exclusive_OR_expression BITWISE_XOR AND_expression
                { printf("\nLine %d : EXPRESSION Rule : exclusive_OR_expression -> exclusive_OR_expression ^ AND_expression\n", yylineno); }
                ;

inclusive_OR_expression
                : exclusive_OR_expression
                { printf("\nLine %d : EXPRESSION Rule : inclusive_OR_expression -> exclusive_OR_expression\n", yylineno); }
                | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
                { printf("\nLine %d : EXPRESSION Rule : inclusive_OR_expression -> inclusive_OR_expression | exclusive_OR_expression\n", yylineno); }
                ;

logical_AND_expression
                : inclusive_OR_expression
                { printf("\nLine %d : EXPRESSION Rule : logical_AND_expression -> inclusive_OR_expression\n", yylineno); }
                | logical_AND_expression LOGICAL_AND inclusive_OR_expression
                { printf("\nLine %d : EXPRESSION Rule : logical_AND_expression -> logical_AND_expression && inclusive_OR_expression\n", yylineno); }
                ;

logical_OR_expression
                : logical_AND_expression
                { printf("\nLine %d : EXPRESSION Rule : logical_OR_expression -> logical_AND_expression\n", yylineno); }
                | logical_OR_expression LOGICAL_OR logical_AND_expression
                { printf("\nLine %d : EXPRESSION Rule : logical_OR_expression -> logical_OR_expression || logical_AND_expression\n", yylineno); }
                ;

conditional_expression
                : logical_OR_expression
                { printf("\nLine %d : EXPRESSION Rule : conditional_expression -> logical_OR_expression\n", yylineno); }
                | logical_OR_expression QUESTION_MARK expression COLON conditional_expression
                { printf("\nLine %d : EXPRESSION Rule : conditional_expression -> logical_OR_expression ? expression : conditional_expression\n", yylineno); }
                ;

assignment_expression
                : conditional_expression
                { printf("\nLine %d : EXPRESSION Rule : assignment_expression -> conditional_expression\n", yylineno); }
                | unary_expression assignment_operator assignment_expression
                { printf("\nLine %d : EXPRESSION Rule : assignment_expression -> unary_expression assignment_operator assignment_expression\n", yylineno); }
                ;

assignment_operator
                : ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> =\n", yylineno); }
                | ASTERISK_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> *=\n", yylineno); }
                | SLASH_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> /=\n", yylineno); }
                | MODULO_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> %%=\n", yylineno); }
                | PLUS_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> +=\n", yylineno); }
                | MINUS_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> -=\n", yylineno); }
                | LEFT_SHIFT_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> <<=\n", yylineno); }
                | RIGHT_SHIFT_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> >>=\n", yylineno); }
                | BITWISE_AND_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> &=\n", yylineno); }
                | BITWISE_XOR_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> ^=\n", yylineno); }
                | BITWISE_OR_ASSIGNMENT
                { printf("\nLine %d : EXPRESSION Rule : assignment_operator -> |=\n", yylineno); }
                ;

expression
                : assignment_expression
                { printf("\nLine %d : EXPRESSION Rule : expression -> assignment_expression\n", yylineno); }
                | expression COMMA assignment_expression
                { printf("\nLine %d : EXPRESSION Rule : expression -> expression , assignment_expression\n", yylineno); }
                ;

constant_expression
                : conditional_expression
                { printf("\nLine %d : EXPRESSION Rule : constant_expression -> conditional_expression\n", yylineno); }
                ;

/* Declarations */

declaration
                : declaration_specifiers init_declarator_list_opt SEMI_COLON
                { printf("\nLine %d : DECLARATION Rule : declaration -> declaration_specifiers init_declarator_list_opt ;\n", yylineno); }
                ;

declaration_specifiers
                : storage_class_specifier declaration_specifiers_opt
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> storage_class_specifier declaration_specifiers_opt\n", yylineno); }
                | type_specifier declaration_specifiers_opt
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> type_specifier declaration_specifiers_opt\n", yylineno); }
                | type_qualifier declaration_specifiers_opt
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> type_qualifier declaration_specifiers_opt\n", yylineno); }
                | function_specifier declaration_specifiers_opt
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> function_specifier declaration_specifiers_opt\n", yylineno); }
                ;

declaration_specifiers_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers_opt -> epsilon\n", yylineno); }
                | declaration_specifiers
                { printf("\nLine %d : DECLARATION Rule : declaration_specifiers_opt -> declaration_specifiers\n", yylineno); }
                ;

init_declarator_list_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : init_declarator_list_opt -> epsilon\n", yylineno); }
                | init_declarator_list
                { printf("\nLine %d : DECLARATION Rule : init_declarator_list_opt -> init_declarator_list\n", yylineno); }
                ;

init_declarator_list
                : init_declarator
                { printf("\nLine %d : DECLARATION Rule : init_declarator_list -> init_declarator\n", yylineno); }
                | init_declarator_list COMMA init_declarator
                { printf("\nLine %d : DECLARATION Rule : init_declarator_list -> init_declarator_list , init_declarator\n", yylineno); }
                ;

init_declarator
                : declarator
                { printf("\nLine %d : DECLARATION Rule : init_declarator -> declarator\n", yylineno); }
                | declarator ASSIGNMENT initializer
                { printf("\nLine %d : DECLARATION Rule : init_declarator -> declarator = initializer\n", yylineno); }
                ;

storage_class_specifier
                : EXTERN
                { printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> extern\n", yylineno); }
                | STATIC
                { printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> static\n", yylineno); }
                | AUTO
                { printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> auto\n", yylineno); }
                | REGISTER
                { printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> register\n", yylineno); }
                ;

type_specifier
                : VOID
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> void\n", yylineno); }
                | CHAR
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> char\n", yylineno); }
                | SHORT
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> short\n", yylineno); }
                | INT
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> int\n", yylineno); }
                | LONG
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> long\n", yylineno); }
                | FLOAT
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> float\n", yylineno); }
                | DOUBLE
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> double\n", yylineno); }
                | SIGNED
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> signed\n", yylineno); }
                | UNSIGNED
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> unsigned\n", yylineno); }
                | BOOL
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> _Bool\n", yylineno); }
                | COMPLEX
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> _Complex\n", yylineno); }
                | IMAGINARY
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> _Imaginary\n", yylineno); }
                | enum_specifier
                { printf("\nLine %d : DECLARATION Rule : type_specifier -> enum_specifier\n", yylineno); }
                ;

specifier_qualifier_list
                : type_specifier specifier_qualifier_list_opt
                { printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt\n", yylineno); }
                | type_qualifier specifier_qualifier_list_opt
                { printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt\n", yylineno); }
                ;

specifier_qualifier_list_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list_opt -> epsilon\n", yylineno); }
                | specifier_qualifier_list
                { printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list_opt -> specifier_qualifier_list\n", yylineno); }
                ;

enum_specifier
                : ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET
                { printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum identifier_opt { enumerator_list }\n", yylineno); }
                | ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list COMMA RIGHT_CURLY_BRACKET
                { printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum identifier_opt { enumerator_list , }\n", yylineno); }
                | ENUM IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum IDENTIFIER\n", yylineno); }
                ;

identifier_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : identifier_opt -> epsilon\n", yylineno); }
                | IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : identifier_opt -> IDENTIFIER\n", yylineno); }
                ;

enumerator_list
                : enumerator
                { printf("\nLine %d : DECLARATION Rule : enumerator_list -> enumerator\n", yylineno); }
                | enumerator_list COMMA enumerator
                { printf("\nLine %d : DECLARATION Rule : enumerator_list -> enumerator_list , enumerator\n", yylineno); }
                ;

enumerator
                : IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : enumerator -> IDENTIFIER\n", yylineno); }
                | IDENTIFIER ASSIGNMENT constant_expression
                { printf("\nLine %d : DECLARATION Rule : enumerator -> IDENTIFIER = constant_expression\n", yylineno); }
                ;

type_qualifier
                : CONST
                { printf("\nLine %d : DECLARATION Rule : type_qualifier -> const\n", yylineno); }
                | RESTRICT
                { printf("\nLine %d : DECLARATION Rule : type_qualifier -> restrict\n", yylineno); }
                | VOLATILE
                { printf("\nLine %d : DECLARATION Rule : type_qualifier -> volatile\n", yylineno); }
                ;

function_specifier
                : INLINE
                { printf("\nLine %d : DECLARATION Rule : function_specifier -> inline\n", yylineno); }
                ;

declarator
                : pointer_opt direct_declarator
                { printf("\nLine %d : DECLARATION Rule : declarator -> pointer direct_declarator\n", yylineno); }
                ;

pointer_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : pointer_opt -> epsilon\n", yylineno); }
                | pointer
                { printf("\nLine %d : DECLARATION Rule : pointer_opt -> pointer\n", yylineno); }
                ;

direct_declarator
                : IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> IDENTIFIER\n", yylineno); }
                | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> ( declarator )\n", yylineno); }
                | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt assignment_expression_opt RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list_opt assignment_expression_opt ]\n", yylineno); }
                | direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list_opt assignment_expression RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ static type_qualifier_list_opt assignment_expression ]\n", yylineno); }
                | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list static assignment_expression ]\n", yylineno); }
                | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt ASTERISK RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list_opt * ]\n", yylineno); }
                | direct_declarator LEFT_PARENTHESES parameter_type_list RIGHT_PARENTHESES
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator ( parameter_type_list )\n", yylineno); }
                | direct_declarator LEFT_PARENTHESES identifier_list_opt RIGHT_PARENTHESES
                { printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator ( identifier_list_opt )\n", yylineno); }
                ;

type_qualifier_list_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : type_qualifier_list_opt -> epsilon\n", yylineno); }
                | type_qualifier_list
                { printf("\nLine %d : DECLARATION Rule : type_qualifier_list_opt -> type_qualifier_list\n", yylineno); }
                ;

assignment_expression_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : assignment_expression_opt -> epsilon\n", yylineno); }
                | assignment_expression
                { printf("\nLine %d : DECLARATION Rule : assignment_expression_opt -> assignment_expression\n", yylineno); }
                ;

identifier_list_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : identifier_list_opt -> epsilon\n", yylineno); }
                | identifier_list
                { printf("\nLine %d : DECLARATION Rule : identifier_list_opt -> identifier_list\n", yylineno); }
                ;

pointer
                : ASTERISK type_qualifier_list_opt pointer
                { printf("\nLine %d : DECLARATION Rule : pointer -> * type_qualifier_list_opt pointer\n", yylineno); }
                | ASTERISK type_qualifier_list_opt
                { printf("\nLine %d : DECLARATION Rule : pointer -> * type_qualifier_list_opt\n", yylineno); }
                ;

type_qualifier_list
                : type_qualifier
                { printf("\nLine %d : DECLARATION Rule : type_qualifier_list -> type_qualifier\n", yylineno); }
                | type_qualifier_list type_qualifier
                { printf("\nLine %d : DECLARATION Rule : type_qualifier_list -> type_qualifier_list type_qualifier\n", yylineno); }
                ;

parameter_type_list
                : parameter_list
                { printf("\nLine %d : DECLARATION Rule : parameter_type_list -> parameter_list\n", yylineno); }
                | parameter_list COMMA ELLIPSIS
                { printf("\nLine %d : DECLARATION Rule : parameter_type_list -> parameter_list , ...\n", yylineno); }
                ;

parameter_list
                : parameter_declaration
                { printf("\nLine %d : DECLARATION Rule : parameter_list -> parameter_declaration\n", yylineno); }
                | parameter_list COMMA parameter_declaration
                { printf("\nLine %d : DECLARATION Rule : parameter_list -> parameter_list , parameter_declaration\n", yylineno); }
                ;

parameter_declaration
                : declaration_specifiers declarator
                { printf("\nLine %d : DECLARATION Rule : parameter_declaration -> declaration_specifiers declarator\n", yylineno); }
                | declaration_specifiers
                { printf("\nLine %d : DECLARATION Rule : parameter_declaration -> declaration_specifiers\n", yylineno); }
                ;

identifier_list
                : IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : identifier_list -> IDENTIFIER\n", yylineno); }
                | identifier_list COMMA IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : identifier_list -> identifier_list , IDENTIFIER\n", yylineno); }
                ;

type_name
                : specifier_qualifier_list
                { printf("\nLine %d : DECLARATION Rule : type_name -> specifier_qualifier_list\n", yylineno); }
                ;

initializer
                : assignment_expression
                { printf("\nLine %d : DECLARATION Rule : initializer -> assignment_expression\n", yylineno); }
                | LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
                { printf("\nLine %d : DECLARATION Rule : initializer -> { initializer_list }\n", yylineno); }
                | LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
                { printf("\nLine %d : DECLARATION Rule : initializer -> { initializer_list , }\n", yylineno); }
                ;

initializer_list
                : designation_opt initializer
                { printf("\nLine %d : DECLARATION Rule : initializer_list -> designation_opt initializer\n", yylineno); }
                | initializer_list COMMA designation_opt initializer
                { printf("\nLine %d : DECLARATION Rule : initializer_list -> initializer_list , designation_opt initializer\n", yylineno); }
                ;

designation_opt
                : /* empty */
                { printf("\nLine %d : DECLARATION Rule : designation_opt -> epsilon\n", yylineno); }
                | designation
                { printf("\nLine %d : DECLARATION Rule : designation_opt -> designation\n", yylineno); }
                ;

designation
                : designator_list ASSIGNMENT
                { printf("\nLine %d : DECLARATION Rule : designation -> designator_list =\n", yylineno); }
                ;

designator_list
                : designator
                { printf("\nLine %d : DECLARATION Rule : designator_list -> designator\n", yylineno); }
                | designator_list designator
                { printf("\nLine %d : DECLARATION Rule : designator_list -> designator_list designator\n", yylineno); }
                ;

designator
                : LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
                { printf("\nLine %d : DECLARATION Rule : designator -> [ constant_expression ]\n", yylineno); }
                | DOT IDENTIFIER
                { printf("\nLine %d : DECLARATION Rule : designator -> . IDENTIFIER\n", yylineno); }
                ;

/* Statements */

statement
                : labeled_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> labeled_statement\n", yylineno); }
                | compound_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> compound_statement\n", yylineno); }
                | expression_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> expression_statement\n", yylineno); }
                | selection_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> selection_statement\n", yylineno); }
                | iteration_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> iteration_statement\n", yylineno); }
                | jump_statement
                { printf("\nLine %d : STATEMENT Rule : statement -> jump_statement\n", yylineno); }
                ;

labeled_statement
                : IDENTIFIER COLON statement
                { printf("\nLine %d : STATEMENT Rule : labeled_statement -> IDENTIFIER : statement\n", yylineno); }
                | CASE constant_expression COLON statement
                { printf("\nLine %d : STATEMENT Rule : labeled_statement -> case constant_expression : statement\n", yylineno); }
                | DEFAULT COLON statement
                { printf("\nLine %d : STATEMENT Rule : labeled_statement -> default : statement\n", yylineno); }
                ;

compound_statement
                : LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                { printf("\nLine %d : STATEMENT Rule : compound_statement -> { block_item_list_opt }\n", yylineno); }
                ;

block_item_list_opt
                : /* empty */
                { printf("\nLine %d : STATEMENT Rule : block_item_list_opt -> epsilon\n", yylineno); }
                | block_item_list
                { printf("\nLine %d : STATEMENT Rule : block_item_list_opt -> block_item_list\n", yylineno); }
                ;

block_item_list
                : block_item
                { printf("\nLine %d : STATEMENT Rule : block_item_list -> block_item\n", yylineno); }
                | block_item_list block_item
                { printf("\nLine %d : STATEMENT Rule : block_item_list -> block_item_list block_item\n", yylineno); }
                ;

block_item
                : declaration
                { printf("\nLine %d : STATEMENT Rule : block_item -> declaration\n", yylineno); }
                | statement
                { printf("\nLine %d : STATEMENT Rule : block_item -> statement\n", yylineno); }
                ;

expression_statement
                : expression_opt SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : expression_statement -> expression_opt ;\n", yylineno); }
                ;

expression_opt
                : /* empty */
                { printf("\nLine %d : STATEMENT Rule : expression_opt -> epsilon\n", yylineno); }
                | expression
                { printf("\nLine %d : STATEMENT Rule : expression_opt -> expression\n", yylineno); }
                ;

selection_statement
                : IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                { printf("\nLine %d : STATEMENT Rule : selection_statement -> if ( expression ) statement\n", yylineno); }
                | IF LEFT_PARENTHESES expression RIGHT_PARENTHESES statement ELSE statement
                { printf("\nLine %d : STATEMENT Rule : selection_statement -> if ( expression ) statement else statement\n", yylineno); }
                | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                { printf("\nLine %d : STATEMENT Rule : selection_statement -> switch ( expression ) statement\n", yylineno); }
                ;

iteration_statement
                : WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                { printf("\nLine %d : STATEMENT Rule : iteration_statement -> while ( expression ) statement\n", yylineno); }
                | DO statement WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : iteration_statement -> do statement while ( expression ) ;\n", yylineno); }
                | FOR LEFT_PARENTHESES expression_opt SEMI_COLON expression_opt SEMI_COLON expression_opt RIGHT_PARENTHESES statement
                { printf("\nLine %d : STATEMENT Rule : iteration_statement -> for ( expression_opt ; expression_opt ; expression_opt ) statement\n", yylineno); }
                | FOR LEFT_PARENTHESES declaration expression_opt SEMI_COLON expression_opt RIGHT_PARENTHESES statement
                { printf("\nLine %d : STATEMENT Rule : iteration_statement -> for ( declaration expression_opt ; expression_opt ) statement\n", yylineno); }
                ;

jump_statement
                : GOTO IDENTIFIER SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : jump_statement -> goto IDENTIFIER ;\n", yylineno); }
                | CONTINUE SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : jump_statement -> continue ;\n", yylineno); }
                | BREAK SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : jump_statement -> break ;\n", yylineno); }
                | RETURN expression_opt SEMI_COLON
                { printf("\nLine %d : STATEMENT Rule : jump_statement -> return expression_opt ;\n", yylineno); }
                ;

/* External Definitions */

translation_unit
                : external_declaration
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : translation_unit -> external_declaration\n", yylineno); }
                | translation_unit external_declaration
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : translation_unit -> translation_unit external_declaration\n", yylineno); }
                ;

external_declaration
                : function_definition
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : external_declaration -> function_definition\n", yylineno); }
                | declaration
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : external_declaration -> declaration\n", yylineno); }
                ;

function_definition
                : declaration_specifiers declarator declaration_list_opt compound_statement
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : function_definition -> declaration_specifiers declarator declaration_list_opt compound_statement\n", yylineno); }
                ;

declaration_list_opt
                : /* empty */
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list_opt -> epsilon\n", yylineno); }
                | declaration_list
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list_opt -> declaration_list\n", yylineno); }
                ;

declaration_list
                : declaration
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list -> declaration\n", yylineno); }
                | declaration_list declaration
                { printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list -> declaration_list declaration\n", yylineno); }
                ;

%%

void yyerror(char *s) {
    printf("\nERROR in Line %d : %s\n", yylineno, s);
}