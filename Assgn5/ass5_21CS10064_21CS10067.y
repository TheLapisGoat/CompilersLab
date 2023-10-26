%{
    #include "ass5_21CS10064_21CS10067_translator.h"
    extern int yylex();
    extern int yylineno;
    void yyerror(string);
%}

%union {
    int intVal;
    char *floatVal;
    char *charVal;
    char *stringVal;
    char *identifierVal;
    int instructionNumber;
    int parameterCount;
    char unaryOperator;
    Symbol *symbol;
    Expression *expression;
    Statement *statement;
    Array *array;
    SymbolType *symbolType;
}

%token AUTO
%token BREAK
%token CASE
%token CHARTYPE
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOATTYPE
%token FOR
%token GOTO
%token IF
%token INLINE
%token INTTYPE
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
%token VOIDTYPE
%token VOLATILE
%token WHILE
%token _BOOL
%token _COMPLEX
%token _IMAGINARY

/*
IDENTIFIER points to its entry in the symbol table
The remaining are constants from the code
*/

%token<symbol> IDENTIFIER
%token<intVal> INTEGER_CONSTANT
%token<floatVal> FLOATING_CONSTANT
%token<charVal> CHARACTER_CONSTANT
%token<stringVal> STRING_LITERAL

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
%token BITWISE_AND
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

%start translation_unit
%right THEN ELSE

// Store unary operator as character
%type<unaryOperator> 
    unary_operator

// Store parameter count as integer
%type<parameterCount> 
    argument_expression_list 
    argument_expression_list_opt

// Expressions
%type<expression>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement
    expression_opt

// Arrays
%type<array> 
    postfix_expression
	unary_expression
	cast_expression

// Statements
%type <statement>  
    statement
    loop_statement
	compound_statement
	selection_statement
	iteration_statement
	labeled_statement 
	jump_statement
	block_item
	block_item_list
	block_item_list_opt
    N

// symbol type
%type<symbolType> 
    pointer

// Symbol
%type<symbol> 
    initialiser
    direct_declarator 
    init_declarator 
    declarator

// Instruction number for backpatching
%type <instructionNumber> 
    M

%%

//The following are production rules for Three Address Code Generation in a Compiler. I have commented the code according to what each instruction does

/* Expressions */
primary_expression: 
                    IDENTIFIER 
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> IDENTIFIER\n", yylineno);
                            $$ = new Expression();          // Create a new expression
                            $$->loc = $1;                   // Store the symbol in the expression
                            $$->type = "not_bool";          // Set the type of the expression
                        }
                    | INTEGER_CONSTANT 
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> INTEGER_CONSTANT\n", yylineno);
                            $$ = new Expression();                                                      // Create a new expression
                            $$->loc = SymbolTable::genTemp(new SymbolType("int"), int2string($1));      // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);                                               // Emit the instruction
                        }
                    | FLOATING_CONSTANT 
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> FLOATING_CONSTANT\n", yylineno);
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new SymbolType("float"), $1);            // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);
                        }
                    | CHARACTER_CONSTANT 
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> CHARACTER_CONSTANT\n", yylineno);
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new SymbolType("char"), $1);         // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);
                        }
                    | STRING_LITERAL 
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> STRING_LITERAL\n", yylineno);
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new SymbolType("ptr"), $1);              // Generate a temporary symbol for the constant
                            $$->loc->type->arrType = new SymbolType("char");                        // Set the type of the temporary symbol
                        }
                    | LEFT_PARENTHESES expression RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : primary_expression -> ( expression )\n", yylineno);
                            $$ = $2;
                        }
                    ;

postfix_expression:
                    primary_expression
                        { 
                            $$ = new Array();                       // Create a new array
                            $$->Array = $1->loc;                    // Store the symbol in the array
                            $$->type = $1->loc->type;               // Set the type of the array
                            $$->loc = $$->Array;                    // Set the location of the array
                        }
                    | postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression [ expression ]\n", yylineno);
                            $$ = new Array();                                           // Create a new array
                            $$->type = $1->type->arrType;                               // Set the type of the array
                            $$->Array = $1->Array;                                      // Store the symbol in the array
                            $$->loc = SymbolTable::genTemp(new SymbolType("int"));      // Generate a temporary symbol for the index
                            $$->atype = "arr";                                          // Set the atype of the array

                            if($1->atype == "arr") {                                                    // If the Array is of type array
                                Symbol* symbol = SymbolTable::genTemp(new SymbolType("int"));           // Generate a temporary symbol
                                int temp_size = sizeOfType($$->type);                                   // Get the size of the type
                                emit("*", symbol->name, $3->loc->name, int2string(temp_size));          // Instruction to multiply the index with the size of the type
                                emit("+", $$->loc->name, $1->loc->name, symbol->name);                  // Instruction to add the base address of the array to the index
                            }
                            else {                          
                                int temp_size = sizeOfType($$->type);                                   // Get the size of the type
                                emit("*", $$->loc->name, $3->loc->name, int2string(temp_size));         // Instruction to multiply the index with the size of the type
                            }
                        }
                    | postfix_expression LEFT_PARENTHESES argument_expression_list_opt RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression ( argument_expression_list_opt )\n", yylineno);
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->type);                         // Generate a temporary symbol for the function
                            emit("call", $$->Array->name, $1->Array->name, int2string($3));     // Instruction to call the function
                        }
                    | postfix_expression DOT IDENTIFIER
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression . IDENTIFIER\n", yylineno);
                        }
                    | postfix_expression ARROW IDENTIFIER
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression -> IDENTIFIER\n", yylineno);
                        }
                    | postfix_expression INCREMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression ++\n", yylineno);
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->Array->type);              // Generate a temporary symbol
                            emit("=", $$->Array->name, $1->Array->name);                    // Instruction to copy the value of the array to the temporary symbol
                            emit("+", $1->Array->name, $1->Array->name, "1");               // Instruction to increment the value of the array
                        }
                    | postfix_expression DECREMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> postfix_expression --\n", yylineno);
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->Array->type);              // Generate a temporary symbol
                            emit("=", $$->Array->name, $1->Array->name);                    // Instruction to copy the value of the array to the temporary symbol
                            emit("-", $1->Array->name, $1->Array->name, "1");               // Instruction to decrement the value of the array
                        }
                    | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initialiser_list RIGHT_CURLY_BRACKET
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> ( type_name ) { initialiser_list }\n", yylineno);
                        }
                    | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initialiser_list COMMA RIGHT_CURLY_BRACKET
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : postfix_expression -> ( type_name ) { initialiser_list , }\n", yylineno);
                        }
                    ;

argument_expression_list_opt:
                                argument_expression_list
                                    { 
                                        printf("\nLine %d : EXPRESSION Rule : argument_expression_list_opt -> argument_expression_list\n", yylineno);
                                        $$ = $1;
                                    }
                                | 
                                    { 
                                        printf("\nLine %d : EXPRESSION Rule : argument_expression_list_opt -> epsilon\n", yylineno);
                                        $$ = 0;
                                    }
                                ;

argument_expression_list:
                            assignment_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : argument_expression_list -> assignment_expression\n", yylineno);
                                    emit("param", $1->loc->name);                   // Instruction to list the parameter
                                    $$ = 1;
                                }
                            | argument_expression_list COMMA assignment_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : argument_expression_list -> argument_expression_list , assignment_expression\n", yylineno);
                                    emit("param", $3->loc->name);           // Instruction to list the parameter
                                    $$ = $1 + 1;                            // Increment the parameter count
                                }
                            ;

unary_expression:
                    postfix_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> postfix_expression\n", yylineno);
                            $$ = $1;
                        }
                    | INCREMENT unary_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> ++ unary_expression\n", yylineno);
                            emit("+", $2->Array->name, $2->Array->name, "1");       // Instruction to increment the value of the Array
                            $$ = $2;  
                        }
                    | DECREMENT unary_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> -- unary_expression\n", yylineno);
                            emit("-", $2->Array->name, $2->Array->name, "1");           // Instruction to decrement the value of the Array
                            $$ = $2;
                        }
                    | unary_operator cast_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> unary_operator cast_expression\n", yylineno);
                            $$ = new Array();                   // Create a new Array
                            switch ($1) {                                                   
                                case '&':   // Address
                                    $$->Array = SymbolTable::genTemp(new SymbolType("ptr"));
                                    $$->Array->type->arrType = $2->Array->type;                 
                                    emit("= &", $$->Array->name, $2->Array->name);              
                                    break;
                                case '*':   // Dereferencing
                                    $$->atype = "ptr";
                                    $$->loc = SymbolTable::genTemp($2->Array->type->arrType);   
                                    $$->Array = $2->Array;                                      
                                    emit("= *", $$->loc->name, $2->Array->name);                
                                    break;
                                case '+':   // Unary plus
                                    $$ = $2;
                                    break;
                                case '-':   // Unary minus
                                    $$->Array = SymbolTable::genTemp(new SymbolType($2->Array->type->type));    
                                    emit("= -", $$->Array->name, $2->Array->name);
                                    break;
                                case '~':   // Bitwise not
                                    $$->Array = SymbolTable::genTemp(new SymbolType($2->Array->type->type));    
                                    emit("= ~", $$->Array->name, $2->Array->name);                              
                                    break;
                                case '!':   // Logical not 
                                    $$->Array = SymbolTable::genTemp(new SymbolType($2->Array->type->type));    
                                    emit("= !", $$->Array->name, $2->Array->name);                       
                                    break;
                            }
                        }
                    | SIZEOF unary_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> sizeof unary_expression\n", yylineno);
                        }
                    | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : unary_expression -> sizeof ( type_name )\n", yylineno);
                        }
                    ;

unary_operator:
                BITWISE_AND
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> &\n", yylineno);
                        $$ = '&'; 
                    }
                | ASTERISK
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> *\n", yylineno);
                        $$ = '*'; 
                    }
                | PLUS
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> +\n", yylineno);
                        $$ = '+'; 
                    }
                | MINUS
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> -\n", yylineno);
                        $$ = '-'; 
                    }
                | TILDE
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> ~\n", yylineno);
                        $$ = '~'; 
                    }
                | EXCLAMATION
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : unary_operator -> !\n", yylineno);
                        $$ = '!'; 
                    }
                ;

cast_expression:
                unary_expression
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : cast_expression -> unary_expression\n", yylineno);
                        $$ = $1;
                    }
                | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression /* can be ignored */
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : cast_expression -> ( type_name ) cast_expression\n", yylineno);
                        $$ = new Array();                                       // Create a new Array       
                        $$->Array = convertType($4->Array, varType);            // Convert the type of the Array
                    }
                ;

multiplicative_expression:
                            cast_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> cast_expression\n", yylineno);
                                    $$ = new Expression();          
                                    if($1->atype == "arr") {        
                                        $$->loc = SymbolTable::genTemp($1->loc->type);  
                                        emit("=[]", $$->loc->name, $1->Array->name, $1->loc->name);
                                    }
                                    else if($1->atype == "ptr") { 
                                        $$->loc = $1->loc; 
                                    }
                                    else {
                                        $$->loc = $1->Array;
                                    }
                                }
                            | multiplicative_expression ASTERISK cast_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression * cast_expression\n", yylineno);
                                    if(typecheck($1->loc, $3->Array)) {
                                        $$ = new Expression();                                                 
                                        $$->loc = SymbolTable::genTemp(new SymbolType($1->loc->type->type));   
                                        emit("*", $$->loc->name, $1->loc->name, $3->Array->name);               
                                    }
                                    else {
                                        yyerror("Incompatible types");
                                    }
                                }
                            | multiplicative_expression SLASH cast_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression / cast_expression\n", yylineno);
                                    if(typecheck($1->loc, $3->Array)) {   
                                        $$ = new Expression();                                                 
                                        $$->loc = SymbolTable::genTemp(new SymbolType($1->loc->type->type));    
                                        emit("/", $$->loc->name, $1->loc->name, $3->Array->name);
                                    }
                                    else {
                                        yyerror("Incompatible types");
                                    }
                                }
                            | multiplicative_expression MODULO cast_expression
                                { 
                                    // printf("\nLine %d : EXPRESSION Rule : multiplicative_expression -> multiplicative_expression %% cast_expression\n", yylineno);
                                    if(typecheck($1->loc, $3->Array)) {     
                                        $$ = new Expression();                                                  
                                        $$->loc = SymbolTable::genTemp(new SymbolType($1->loc->type->type));    
                                        emit("%", $$->loc->name, $1->loc->name, $3->Array->name);               
                                    }
                                    else {
                                        yyerror("Incompatible types");
                                    }
                                }
                            ;

additive_expression:
                    multiplicative_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : additive_expression -> multiplicative_expression\n", yylineno);
                            $$ = $1;
                        }
                    | additive_expression PLUS multiplicative_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : additive_expression -> additive_expression + multiplicative_expression\n", yylineno);
                            if(typecheck($1->loc, $3->loc)) {      
                                $$ = new Expression();                                                
                                $$->loc = SymbolTable::genTemp(new SymbolType($1->loc->type->type));    
                                emit("+", $$->loc->name, $1->loc->name, $3->loc->name);                 
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    | additive_expression MINUS multiplicative_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : additive_expression -> additive_expression - multiplicative_expression\n", yylineno);
                            if(typecheck($1->loc, $3->loc)) {      
                                $$ = new Expression();                                                 
                                $$->loc = SymbolTable::genTemp(new SymbolType($1->loc->type->type));    
                                emit("-", $$->loc->name, $1->loc->name, $3->loc->name);                 
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    ;

shift_expression:
                    additive_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : shift_expression -> additive_expression\n", yylineno);
                            $$ = $1;
                        }
                    | shift_expression LEFT_SHIFT additive_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : shift_expression -> shift_expression << additive_expression\n", yylineno);
                            if($3->loc->type->type == "int") {    
                                $$ = new Expression();                                     
                                $$->loc = SymbolTable::genTemp(new SymbolType("int"));      
                                emit("<<", $$->loc->name, $1->loc->name, $3->loc->name);    
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    | shift_expression RIGHT_SHIFT additive_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : shift_expression -> shift_expression >> additive_expression\n", yylineno);
                            if($3->loc->type->type == "int") {    
                                $$ = new Expression();                                     
                                $$->loc = SymbolTable::genTemp(new SymbolType("int"));      
                                emit(">>", $$->loc->name, $1->loc->name, $3->loc->name);    
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    ;

relational_expression:
                        shift_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : relational_expression -> shift_expression\n", yylineno);
                                $$ = $1;
                            }
                        | relational_expression LESS_THAN shift_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression < shift_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                 
                                    $$ = new Expression();                       
                                    $$->type = "bool";
                                    $$->trueList = makeList(nextInstruction());           
                                    $$->falseList = makeList(nextInstruction() + 1);      
                                    emit("<", "", $1->loc->name, $3->loc->name);    
                                    emit("goto", "");                               
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        | relational_expression GREATER_THAN shift_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression > shift_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                 
                                    $$ = new Expression();                       
                                    $$->type = "bool";
                                    $$->trueList = makeList(nextInstruction());           
                                    $$->falseList = makeList(nextInstruction() + 1);      
                                    emit(">", "", $1->loc->name, $3->loc->name);    
                                    emit("goto", "");                               
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        | relational_expression LESS_EQUAL_THAN shift_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression <= shift_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                 
                                    $$ = new Expression();                       
                                    $$->type = "bool";
                                    $$->trueList = makeList(nextInstruction());           
                                    $$->falseList = makeList(nextInstruction() + 1);      
                                    emit("<=", "", $1->loc->name, $3->loc->name);    
                                    emit("goto", "");                               
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        | relational_expression GREATER_EQUAL_THAN shift_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : relational_expression -> relational_expression >= shift_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                 
                                    $$ = new Expression();                       
                                    $$->type = "bool";
                                    $$->trueList = makeList(nextInstruction());           
                                    $$->falseList = makeList(nextInstruction() + 1);      
                                    emit(">=", "", $1->loc->name, $3->loc->name);    
                                    emit("goto", "");                               
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

equality_expression:
                    relational_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : equality_expression -> relational_expression\n", yylineno);
                            $$ = $1;
                        }
                    | equality_expression EQUALS relational_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : equality_expression -> equality_expression == relational_expression\n", yylineno);
                            if(typecheck($1->loc, $3->loc)) {                   
                                bool2int($1);                           
                                bool2int($3);
                                $$ = new Expression();
                                $$->type = "bool";
                                $$->trueList = makeList(nextInstruction());          
                                $$->falseList = makeList(nextInstruction() + 1);     
                                emit("==", "", $1->loc->name, $3->loc->name);  
                                emit("goto", "");                               
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    | equality_expression NOT_EQUALS relational_expression
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : equality_expression -> equality_expression != relational_expression\n", yylineno);
                            if(typecheck($1->loc, $3->loc)) {                   
                                bool2int($1);                           
                                bool2int($3);
                                $$ = new Expression();
                                $$->type = "bool";
                                $$->trueList = makeList(nextInstruction());          
                                $$->falseList = makeList(nextInstruction() + 1);     
                                emit("!=", "", $1->loc->name, $3->loc->name);  
                                emit("goto", "");                               
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    ;

AND_expression:
                equality_expression
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : AND_expression -> equality_expression\n", yylineno);
                        $$ = $1;
                    }
                | AND_expression BITWISE_AND equality_expression
                    { 
                        // printf("\nLine %d : EXPRESSION Rule : AND_expression -> AND_expression & equality_expression\n", yylineno);
                        if(typecheck($1->loc, $3->loc)) {                               
                            bool2int($1);                                      
                            bool2int($3);
                            $$ = new Expression();
                            $$->type = "not_bool";                                     
                            $$->loc = SymbolTable::genTemp(new SymbolType("int"));     
                            emit("&", $$->loc->name, $1->loc->name, $3->loc->name);    
                        }
                        else {
                            yyerror("Incompatible types");
                        }
                    }
                ;

exclusive_OR_expression:
                        AND_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : exclusive_OR_expression -> AND_expression\n", yylineno);
                                $$ = $1;
                            }
                        | exclusive_OR_expression BITWISE_XOR AND_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : exclusive_OR_expression -> exclusive_OR_expression ^ AND_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                               
                                    bool2int($1);                                      
                                    bool2int($3);
                                    $$ = new Expression();
                                    $$->type = "not_bool";                                     
                                    $$->loc = SymbolTable::genTemp(new SymbolType("int"));     
                                    emit("^", $$->loc->name, $1->loc->name, $3->loc->name);    
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : inclusive_OR_expression -> exclusive_OR_expression\n", yylineno);
                                $$ = $1;
                            }
                        | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : inclusive_OR_expression -> inclusive_OR_expression | exclusive_OR_expression\n", yylineno);
                                if(typecheck($1->loc, $3->loc)) {                               
                                    bool2int($1);                                      
                                    bool2int($3);
                                    $$ = new Expression();
                                    $$->type = "not_bool";                                     
                                    $$->loc = SymbolTable::genTemp(new SymbolType("int"));     
                                    emit("|", $$->loc->name, $1->loc->name, $3->loc->name);    
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;


M:  
        {
            // printf("\nLine %d : EXPRESSION Rule : M -> epsilon\n", yylineno);
            $$ = nextInstruction();
        }   
    ;

N: 
        {
            // printf("\nLine %d : EXPRESSION Rule : N -> epsilon\n", yylineno);
            $$ = new Statement();
            $$->nextList = makeList(nextInstruction());
            emit("goto", "");
        }
	;

logical_AND_expression:
                        inclusive_OR_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : logical_AND_expression -> inclusive_OR_expression\n", yylineno);
                                $$ = $1;
                            }
                        | logical_AND_expression LOGICAL_AND M inclusive_OR_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : logical_AND_expression -> logical_AND_expression && inclusive_OR_expression\n", yylineno);
                                if(typecheck($1->loc, $4->loc)) {                               
                                    bool2int($1);                                      
                                    bool2int($4);
                                    $$ = new Expression();
                                    $$->type = "bool";
                                    backpatch($1->trueList, $3);
                                    $$->trueList = $4->trueList;
                                    $$->falseList = merge($1->falseList, $4->falseList);                    
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

logical_OR_expression:
                        logical_AND_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : logical_OR_expression -> logical_AND_expression\n", yylineno);
                                $$ = $1;
                            }
                        | logical_OR_expression LOGICAL_OR M logical_AND_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : logical_OR_expression -> logical_OR_expression || logical_AND_expression\n", yylineno);
                                if(typecheck($1->loc, $4->loc)) {                               
                                    bool2int($1);                                      
                                    bool2int($4);
                                    $$ = new Expression();
                                    $$->type = "bool";
                                    backpatch($1->falseList, $3);
                                    $$->trueList = merge($1->trueList, $4->trueList);
                                    $$->falseList = $4->falseList;                    
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

conditional_expression:
                        logical_OR_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : conditional_expression -> logical_OR_expression\n", yylineno);
                                $$ = $1;
                            }
                        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : conditional_expression -> logical_OR_expression ? expression : conditional_expression\n", yylineno);  
                                $$->loc = SymbolTable::genTemp($5->loc->type);
                                $$->loc->update($5->loc->type);
                                backpatch($1->trueList, $4);                        
                                backpatch($1->falseList, $8);
                                emit("=", $$->loc->name, $9->loc->name);
                                list<int> l1 = makeList(nextInstruction());
                                emit("goto", "");                                   
                                backpatch($6->nextList, nextInstruction());               
                                emit("=", $$->loc->name, $5->loc->name);
                                list<int> l2 = makeList(nextInstruction());               
                                l1 = merge(l1, l2);                                 
                                emit("goto", "");                                   
                                backpatch($2->nextList, nextInstruction());               
                                int2bool($1);                                                      
                                backpatch(l1, nextInstruction());
                            }
                        ;

assignment_expression:
                        conditional_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : assignment_expression -> conditional_expression\n", yylineno);
                                $$ = $1;
                            }
                        | unary_expression assignment_operator assignment_expression
                            { 
                                // printf("\nLine %d : EXPRESSION Rule : assignment_expression -> unary_expression assignment_operator assignment_expression\n", yylineno);
                                if($1->atype == "arr") {        
                                    $3->loc = convertType($3->loc, $1->type->type);
                                    emit("[]=", $1->Array->name, $1->loc->name, $3->loc->name);
                                }
                                else if($1->atype == "ptr") {
                                    emit("*=", $1->Array->name, $3->loc->name);
                                }
                                else {
                                    $3->loc = convertType($3->loc, $1->Array->type->type);
                                    emit("=", $1->Array->name, $3->loc->name);
                                }
                                $$ = $3;
                            }
                        ;

assignment_operator:
                    ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> =\n", yylineno);
                        }
                    | ASTERISK_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> *=\n", yylineno);
                        }
                    | SLASH_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> /=\n", yylineno);          
                        }
                    | MODULO_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> %%=\n", yylineno);
                        }
                    | PLUS_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> +=\n", yylineno);
                        }
                    | MINUS_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> -=\n", yylineno);
                        }
                    | LEFT_SHIFT_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> <<=\n", yylineno);
                        }
                    | RIGHT_SHIFT_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> >>=\n", yylineno);
                        }
                    | BITWISE_AND_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> &=\n", yylineno);
                        }
                    | BITWISE_XOR_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> ^=\n", yylineno);
                        }
                    | BITWISE_OR_ASSIGNMENT
                        { 
                            // printf("\nLine %d : EXPRESSION Rule : assignment_operator -> |=\n", yylineno);
                        }
                    ;

expression:
            assignment_expression
                { 
                    // printf("\nLine %d : EXPRESSION Rule : expression -> assignment_expression\n", yylineno);
                    $$ = $1;
                }
            | expression COMMA assignment_expression
                {
                    // printf("\nLine %d : EXPRESSION Rule : expression -> expression , assignment_expression\n", yylineno);
                }
            ;

constant_expression:
                    conditional_expression
                        {
                            // printf("\nLine %d : EXPRESSION Rule : constant_expression -> conditional_expression\n", yylineno);
                        }
                    ;

/* Declarations */

declaration:
            declaration_specifiers init_declarator_list_opt SEMI_COLON
                {
                    // printf("\nLine %d : DECLARATION Rule : declaration -> declaration_specifiers init_declarator_list_opt ;\n", yylineno);
                }
            ;

init_declarator_list_opt:
                            init_declarator_list
                                {
                                    // printf("\nLine %d : DECLARATION Rule : init_declarator_list_opt -> init_declarator_list\n", yylineno);
                                }
                            |
                                {
                                    // printf("\nLine %d : DECLARATION Rule : init_declarator_list_opt -> epsilon\n", yylineno);
                                }
                            ;

declaration_specifiers:
                        storage_class_specifier declaration_specifiers_opt
                            {
                                // printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> storage_class_specifier declaration_specifiers_opt\n", yylineno);
                            }
                        | type_specifier declaration_specifiers_opt
                            {
                                // printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> type_specifier declaration_specifiers_opt\n", yylineno);
                            }
                        | type_qualifier declaration_specifiers_opt
                            {
                                // printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> type_qualifier declaration_specifiers_opt\n", yylineno);
                            }
                        | function_specifier declaration_specifiers_opt
                            {
                                // printf("\nLine %d : DECLARATION Rule : declaration_specifiers -> function_specifier declaration_specifiers_opt\n", yylineno);
                            }
                        ;

declaration_specifiers_opt:
                            declaration_specifiers
                                {
                                    // printf("\nLine %d : DECLARATION Rule : declaration_specifiers_opt -> declaration_specifiers\n", yylineno);
                                }
                            |
                                {
                                    // printf("\nLine %d : DECLARATION Rule : declaration_specifiers_opt -> epsilon\n", yylineno);
                                }
                            ;

init_declarator_list:
                        init_declarator
                            {
                                // printf("\nLine %d : DECLARATION Rule : init_declarator_list -> init_declarator\n", yylineno);
                            }
                        | init_declarator_list COMMA init_declarator
                            {
                                // printf("\nLine %d : DECLARATION Rule : init_declarator_list -> init_declarator_list , init_declarator\n", yylineno);
                            }
                        ;

init_declarator:
                declarator
                    { 
                        // printf("\nLine %d : DECLARATION Rule : init_declarator -> declarator\n", yylineno);
                        $$ = $1;
                    }
                | declarator ASSIGNMENT initialiser
                    { 
                        // printf("\nLine %d : DECLARATION Rule : init_declarator -> declarator = initialiser\n", yylineno);
                        if($3->value != "") {
                            $1->value = $3->value;
                        }
                        emit("=", $1->name, $3->name);
                    }
                ;

storage_class_specifier:
                        EXTERN
                            {
                                // printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> extern\n", yylineno);
                            }
                        | STATIC
                            {
                                // printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> static\n", yylineno);
                            }
                        | AUTO
                            {
                                // printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> auto\n", yylineno);
                            }
                        | REGISTER
                            {
                                // printf("\nLine %d : DECLARATION Rule : storage_class_specifier -> register\n", yylineno);
                            }
                        ;

type_specifier:
                VOIDTYPE
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> void\n", yylineno);
                        varType = "void";
                    }
                | CHARTYPE
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> char\n", yylineno);
                        varType = "char";
                    }
                | SHORT
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> short\n", yylineno);
                    }
                | INTTYPE
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> int\n", yylineno); 
                        varType = "int";
                    }
                | LONG
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> long\n", yylineno);
                    }
                | FLOATTYPE
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> float\n", yylineno);
                        varType = "float";
                    }
                | DOUBLE
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> double\n", yylineno);
                    }
                | SIGNED
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> signed\n", yylineno);
                    }
                | UNSIGNED
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> unsigned\n", yylineno);
                    }
                | _BOOL
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> _Bool\n", yylineno);
                    }
                | _COMPLEX
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> _Complex\n", yylineno);
                    }
                | _IMAGINARY
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> _Imaginary\n", yylineno);
                    }
                | enum_specifier 
                    {
                        // printf("\nLine %d : DECLARATION Rule : type_specifier -> enum_specifier\n", yylineno);
                    }
                ;

specifier_qualifier_list:
                            type_specifier specifier_qualifier_list_opt
                                { 
                                    // printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt\n", yylineno);
                                }
                            | type_qualifier specifier_qualifier_list_opt
                                { 
                                    // printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt\n", yylineno);
                                }
                            ;

specifier_qualifier_list_opt:
                                specifier_qualifier_list
                                    { 
                                        // printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list_opt -> specifier_qualifier_list\n", yylineno);
                                    }
                                | 
                                    { 
                                        // printf("\nLine %d : DECLARATION Rule : specifier_qualifier_list_opt -> epsilon\n", yylineno);
                                    }
                                ;

enum_specifier:
                ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET 
                    { 
                        // printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum identifier_opt { enumerator_list }\n", yylineno);
                    }
                | ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list COMMA RIGHT_CURLY_BRACKET
                    { 
                        // printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum identifier_opt { enumerator_list , }\n", yylineno);
                    }
                | ENUM IDENTIFIER
                    { 
                        // printf("\nLine %d : DECLARATION Rule : enum_specifier -> enum IDENTIFIER\n", yylineno);
                    }
                ;

identifier_opt:
                IDENTIFIER 
                    { 
                        // printf("\nLine %d : DECLARATION Rule : identifier_opt -> IDENTIFIER\n", yylineno);
                    }
                | 
                    { 
                        // printf("\nLine %d : DECLARATION Rule : identifier_opt -> epsilon\n", yylineno);
                    }
                ;

enumerator_list:
                enumerator 
                    { 
                        // printf("\nLine %d : DECLARATION Rule : enumerator_list -> enumerator\n", yylineno);
                    }
                | enumerator_list COMMA enumerator
                    { 
                        // printf("\nLine %d : DECLARATION Rule : enumerator_list -> enumerator_list , enumerator\n", yylineno);
                    }
                ;

enumerator:
            IDENTIFIER 
                { 
                    // printf("\nLine %d : DECLARATION Rule : enumerator -> IDENTIFIER\n", yylineno);
                }
            | IDENTIFIER ASSIGNMENT constant_expression
                { 
                    // printf("\nLine %d : DECLARATION Rule : enumerator -> IDENTIFIER = constant_expression\n", yylineno);
                }
            ;

type_qualifier:
                CONST
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_qualifier -> const\n", yylineno);
                    }
                | RESTRICT
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_qualifier -> restrict\n", yylineno);
                    }
                | VOLATILE
                    { 
                        // printf("\nLine %d : DECLARATION Rule : type_qualifier -> volatile\n", yylineno);
                    }
                ;

function_specifier:
                    INLINE
                        { 
                            // printf("\nLine %d : DECLARATION Rule : function_specifier -> inline\n", yylineno);
                        }
                    ;

/*

Declarations

*/
declarator:
            pointer direct_declarator
                { 
                    // printf("\nLine %d : DECLARATION Rule : declarator -> pointer direct_declarator\n", yylineno);
                    SymbolType* temp = $1;
                    while(temp->arrType != NULL) {
                        temp = temp->arrType;
                    }
                    temp->arrType = $2->type;  
                    $$ = $2->update($1);
                }
            | direct_declarator
                { 
                    // printf("\nLine %d : DECLARATION Rule : declarator -> direct_declarator\n", yylineno);
                }
            ;

direct_declarator:
                    IDENTIFIER 
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> IDENTIFIER\n", yylineno);
                            $$ = $1->update(new SymbolType(varType));   
                            currentSymbol = $$;   
                        }
                    | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> ( declarator )\n", yylineno);
                            $$ = $2;
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list assignment_expression ]\n", yylineno); 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list ]\n", yylineno);
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ assignment_expression ]\n", yylineno);
                            SymbolType* cur_type = $1->type;
                            SymbolType* prev = NULL;
                            while(cur_type->type == "arr") {
                                prev = cur_type;
                                cur_type = cur_type->arrType;
                            }
                            if(prev == NULL) {
                                int temp = atoi($3->loc->value.c_str());                
                                SymbolType* tp = new SymbolType("arr", $1->type, temp); 
                                $$ = $1->update(tp);                                    
                            }
                            else {
                                int temp = atoi($3->loc->value.c_str());                
                                prev->arrType = new SymbolType("arr", cur_type, temp);         
                                $$ = $1->update($1->type);                             
                            }
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ ]\n", yylineno);
                            SymbolType* cur_type = $1->type;
                            SymbolType* prev = NULL;
                            while(cur_type->type == "arr") {
                                prev = cur_type;
                                cur_type = cur_type->arrType;
                            }
                            if(prev == NULL) {
                                SymbolType* tp = new SymbolType("arr", $1->type, 0);
                                $$ = $1->update(tp);
                            }
                            else {
                                prev->arrType = new SymbolType("arr", cur_type, 0);
                                $$ = $1->update($1->type);
                            }
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ static type_qualifier_list assignment_expression ]\n", yylineno); 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET STATIC assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ static assignment_expression ]\n", yylineno);
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list static assignment_expression ]\n", yylineno);
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list ASTERISK RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ type_qualifier_list * ]\n", yylineno);
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET ASTERISK RIGHT_SQUARE_BRACKET
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator [ * ]\n", yylineno);
                        }
                    | direct_declarator LEFT_PARENTHESES change_table parameter_type_list RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator ( parameter_type_list )\n", yylineno);
                            currentST->name = $1->name;
                            if($1->type->type != "void") {
                                Symbol* s = currentST->lookup("return");   
                                s->update($1->type);
                            }
                            $1->nestedTable = currentST;
                            currentST->parent = globalST;  
                            changeTable(globalST);        
                            currentSymbol = $$; 
                        }
                    | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator ( identifier_list )\n", yylineno);
                        }
                    | direct_declarator LEFT_PARENTHESES change_table RIGHT_PARENTHESES
                        { 
                            // printf("\nLine %d : DECLARATION Rule : direct_declarator -> direct_declarator ( )\n", yylineno);
                            currentST->name = $1->name;
                            if($1->type->type != "void") {
                                Symbol* s = currentST->lookup("return");   
                                s->update($1->type);
                            }
                            $1->nestedTable = currentST;
                            currentST->parent = globalST;  
                            changeTable(globalST);        
                            currentSymbol = $$; 
                        }
                    ;

type_qualifier_list_opt:
                        type_qualifier_list
                            { 
                                // printf("\nLine %d : DECLARATION Rule : type_qualifier_list_opt -> type_qualifier_list\n", yylineno);
                            }
                        |
                            { 
                                // printf("\nLine %d : DECLARATION Rule : type_qualifier_list_opt -> epsilon\n", yylineno);
                            }
                        ;

pointer:
        ASTERISK type_qualifier_list_opt
            { 
                // printf("\nLine %d : DECLARATION Rule : pointer -> * type_qualifier_list_opt\n", yylineno);
                $$ = new SymbolType("ptr");
            }
        | ASTERISK type_qualifier_list_opt pointer
            { 
                // printf("\nLine %d : DECLARATION Rule : pointer -> * type_qualifier_list_opt pointer\n", yylineno);
                $$ = new SymbolType("ptr", $3);
            }
        ;

type_qualifier_list:
                    type_qualifier
                        { 
                            // printf("\nLine %d : DECLARATION Rule : type_qualifier_list -> type_qualifier\n", yylineno);
                        }
                    | type_qualifier_list type_qualifier
                        { 
                            // printf("\nLine %d : DECLARATION Rule : type_qualifier_list -> type_qualifier_list type_qualifier\n", yylineno);
                        }
                    ;

parameter_type_list:
                    parameter_list
                        { 
                            // printf("\nLine %d : DECLARATION Rule : parameter_type_list -> parameter_list\n", yylineno);
                        }
                    | parameter_list COMMA ELLIPSIS
                        { 
                            // printf("\nLine %d : DECLARATION Rule : parameter_type_list -> parameter_list , ...\n", yylineno);
                        }
                    ;

parameter_list:
                parameter_declaration
                    { 
                        // printf("\nLine %d : DECLARATION Rule : parameter_list -> parameter_declaration\n", yylineno);
                    }
                | parameter_list COMMA parameter_declaration
                    { 
                        // printf("\nLine %d : DECLARATION Rule : parameter_list -> parameter_list , parameter_declaration\n", yylineno);
                    }
                ;

parameter_declaration:
                        declaration_specifiers declarator
                            { 
                                // printf("\nLine %d : DECLARATION Rule : parameter_declaration -> declaration_specifiers declarator\n", yylineno);
                            }
                        | declaration_specifiers
                            { 
                                // printf("\nLine %d : DECLARATION Rule : parameter_declaration -> declaration_specifiers\n", yylineno);
                            }
                        ;

identifier_list:
                IDENTIFIER 
                    { 
                        // printf("\nLine %d : DECLARATION Rule : identifier_list -> IDENTIFIER\n", yylineno);
                    }
                | identifier_list COMMA IDENTIFIER
                    { 
                        // printf("\nLine %d : DECLARATION Rule : identifier_list -> identifier_list , IDENTIFIER\n", yylineno);
                    }
                ;

type_name:
            specifier_qualifier_list
                { 
                    // printf("\nLine %d : DECLARATION Rule : type_name -> specifier_qualifier_list\n", yylineno);
                }
            ;

initialiser:
            assignment_expression
                { 
                    // printf("\nLine %d : DECLARATION Rule : initialiser -> assignment_expression\n", yylineno);
                    $$ = $1->loc;
                }
            | LEFT_CURLY_BRACKET initialiser_list RIGHT_CURLY_BRACKET
                { 
                    // printf("\nLine %d : DECLARATION Rule : initialiser -> { initialiser_list }\n", yylineno);
                }  
            | LEFT_CURLY_BRACKET initialiser_list COMMA RIGHT_CURLY_BRACKET
                { 
                    // printf("\nLine %d : DECLARATION Rule : initialiser -> { initialiser_list , }\n", yylineno);
                }
            ;

initialiser_list:
                    designation_opt initialiser
                        { 
                            // printf("\nLine %d : DECLARATION Rule : initialiser_list -> designation_opt initialiser\n", yylineno);
                        }
                    | initialiser_list COMMA designation_opt initialiser
                        { 
                            // printf("\nLine %d : DECLARATION Rule : initialiser_list -> initialiser_list , designation_opt initialiser\n", yylineno);
                        }
                    ;

designation_opt:
                designation
                    { 
                        // printf("\nLine %d : DECLARATION Rule : designation_opt -> designation\n", yylineno);
                    }
                |
                    { 
                        // printf("\nLine %d : DECLARATION Rule : designation_opt -> epsilon\n", yylineno);
                    }
                ;

designation:
            designator_list ASSIGNMENT
                { 
                    // printf("\nLine %d : DECLARATION Rule : designation -> designator_list =\n", yylineno);
                }
            ;

designator_list:
                designator
                    { 
                        // printf("\nLine %d : DECLARATION Rule : designator_list -> designator\n", yylineno);
                    }
                | designator_list designator
                    { 
                        // printf("\nLine %d : DECLARATION Rule : designator_list -> designator_list designator\n", yylineno);
                    }
                ;

designator:
            LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
                { 
                    // printf("\nLine %d : DECLARATION Rule : designator -> [ constant_expression ]\n", yylineno);
                }
            | DOT IDENTIFIER
                { 
                    // printf("\nLine %d : DECLARATION Rule : designator -> . IDENTIFIER\n", yylineno);
                }   
            ;

/* Statements */

statement:
            labeled_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> labeled_statement\n", yylineno);
                }
            | compound_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> compound_statement\n", yylineno);
                    $$ = $1; 
                }
            | expression_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> expression_statement\n", yylineno);
                    $$ = new Statement();
                    $$->nextList = $1->nextList;
                }
            | selection_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> selection_statement\n", yylineno);
                    $$ = $1;
                }
            | iteration_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> iteration_statement\n", yylineno);
                    $$ = $1;
                }
            | jump_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : statement -> jump_statement\n", yylineno);
                    $$ = $1;
                }
            ;

labeled_statement:
                    IDENTIFIER COLON statement
                        { 
                            // printf("\nLine %d : STATEMENT Rule : labeled_statement -> IDENTIFIER : statement\n", yylineno);
                        }
                    | CASE constant_expression COLON statement
                        { 
                            // printf("\nLine %d : STATEMENT Rule : labeled_statement -> case constant_expression : statement\n", yylineno);
                        }    
                    | DEFAULT COLON statement
                        { 
                            // printf("\nLine %d : STATEMENT Rule : labeled_statement -> default : statement\n", yylineno);
                        }
                    ;

loop_statement:
                labeled_statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : loop_statement -> labeled_statement\n", yylineno);
                }
                | expression_statement
                {
                    // printf("\nLine %d : STATEMENT Rule : loop_statement -> expression_statement\n", yylineno);
                    $$ = new Statement();          
                    $$->nextList = $1->nextList;    
                }
                | selection_statement
                {
                    // printf("\nLine %d : STATEMENT Rule : loop_statement -> selection_statement\n", yylineno);
                    $$ = $1;    
                }
                | iteration_statement
                {
                    // printf("\nLine %d : STATEMENT Rule : loop_statement -> iteration_statement\n", yylineno);
                    $$ = $1;    
                }
                | jump_statement
                {
                    // printf("\nLine %d : STATEMENT Rule : loop_statement -> jump_statement\n", yylineno);
                    $$ = $1;
                }
                ;

change_table:
                {   
                    if(currentSymbol->nestedTable != NULL) {
                        changeTable(currentSymbol->nestedTable);
                        emit("label", currentST->name);
                    }
                    else {
                        changeTable(new SymbolTable(""));
                    }
                }
                ;

compound_statement:
                    LEFT_CURLY_BRACKET D change_table block_item_list_opt RIGHT_CURLY_BRACKET
                        { 
                            // printf("\nLine %d : STATEMENT Rule : compound_statement -> { block_item_list_opt }\n", yylineno);
                            $$ = $4;
                            changeTable(currentST->parent);  
                        }
                    ;

block_item_list_opt:
                    block_item_list
                        { 
                            // printf("\nLine %d : STATEMENT Rule : block_item_list_opt -> block_item_list\n", yylineno);
                            $$ = $1;
                        }
                    |
                        { 
                            // printf("\nLine %d : STATEMENT Rule : block_item_list_opt -> epsilon\n", yylineno);
                            $$ = new Statement();
                        }
                    ;

block_item_list:
                block_item
                    {
                        // printf("\nLine %d : STATEMENT Rule : block_item_list -> block_item\n", yylineno);
                        $$ = $1;
                    }
                | block_item_list M block_item
                    { 
                        // printf("\nLine %d : STATEMENT Rule : block_item_list -> block_item_list M block_item\n", yylineno);
                        $$ = $3;
                        backpatch($1->nextList, $2);
                    }
                ;

block_item:
            declaration
                { 
                    // printf("\nLine %d : STATEMENT Rule : block_item -> declaration\n", yylineno);
                    $$ = new Statement();
                }
            | statement
                { 
                    // printf("\nLine %d : STATEMENT Rule : block_item -> statement\n", yylineno);
                    $$ = $1;
                }
            ;

expression_statement:
                        expression_opt SEMI_COLON
                            { 
                                // printf("\nLine %d : STATEMENT Rule : expression_statement -> expression_opt ;\n", yylineno);
                                $$ = $1;
                            }
                        ;

expression_opt:
                expression
                    { 
                        // printf("\nLine %d : STATEMENT Rule : expression_opt -> expression\n", yylineno);
                        $$ = $1;
                    }
                |
                    { 
                        // printf("\nLine %d : STATEMENT Rule : expression_opt -> epsilon\n", yylineno);
                        $$ = new Expression();
                    }
                ;

selection_statement:
                    IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N %prec THEN
                        { 
                            // printf("\nLine %d : STATEMENT Rule : selection_statement -> if ( expression ) statement\n", yylineno);
                            backpatch($4->nextList, nextInstruction());                  
                            int2bool($3);                                  
                            $$ = new Statement();                                   
                            backpatch($3->trueList, $6);                           
                        
                            list<int> temp = merge($3->falseList, $7->nextList);
                            $$->nextList = merge($8->nextList, temp);
                        }
                    | IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N ELSE M statement
                        { 
                            // printf("\nLine %d : STATEMENT Rule : selection_statement -> if ( expression ) statement else statement\n", yylineno);
                            backpatch($4->nextList, nextInstruction());                  
                            int2bool($3);                                  
                            $$ = new Statement();                                  
                            backpatch($3->trueList, $6);                        
                            backpatch($3->falseList, $10);
                            list<int> temp = merge($7->nextList, $8->nextList);
                            $$->nextList = merge($11->nextList, temp);
                        }
                    | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                        { 
                            // printf("\nLine %d : STATEMENT Rule : selection_statement -> switch ( expression ) statement\n", yylineno);
                        }
                    ;

iteration_statement:
                    WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES M loop_statement
                    {   
                        $$ = new Statement();                 
                        int2bool($7);                 
                        backpatch($10->nextList, $6);           
                        backpatch($7->trueList, $9);         
                        $$->nextList = $7->falseList;         
                        emit("goto", int2string($6));  
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    | WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES LEFT_CURLY_BRACKET M block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        $$ = new Statement();                 
                        int2bool($7);                 
                        backpatch($11->nextList, $6);         
                        backpatch($7->trueList, $10);          
                        $$->nextList = $7->falseList;         
                        emit("goto", int2string($6));  
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    | DO D M loop_statement M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                    {
                        
                        $$ = new Statement();                     
                        int2bool($8);                  
                        backpatch($8->trueList, $3);           
                        backpatch($4->nextList, $5);           
                        $$->nextList = $8->falseList;          
                        blockName = "";
                    }
                    | DO D LEFT_CURLY_BRACKET M block_item_list_opt RIGHT_CURLY_BRACKET M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                    {
                        $$ = new Statement();                  
                        int2bool($10);                 
                        backpatch($10->trueList, $4);          
                        backpatch($5->nextList, $7);           
                        $$->nextList = $10->falseList;         
                        blockName = "";
                    }
                    | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
                    {
                        $$ = new Statement();                  
                        int2bool($8);                  
                        backpatch($8->trueList, $13);          
                        backpatch($11->nextList, $7);        
                        backpatch($14->nextList, $9);          
                        emit("goto", int2string($9));   
                        $$->nextList = $8->falseList;          
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
                    {
                        $$ = new Statement();                
                        int2bool($8);                  
                        backpatch($8->trueList, $13);        
                        backpatch($11->nextList, $7);          
                        backpatch($14->nextList, $9);          
                        emit("goto", int2string($9));   
                        $$->nextList = $8->falseList;          
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        $$ = new Statement();                  
                        int2bool($8);                   
                        backpatch($8->trueList, $13);        
                        backpatch($11->nextList, $7);        
                        backpatch($15->nextList, $9);         
                        emit("goto", int2string($9));   
                        $$->nextList = $8->falseList;        
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        $$ = new Statement();                  
                        int2bool($8);                   
                        backpatch($8->trueList, $13);         
                        backpatch($11->nextList, $7);          
                        backpatch($15->nextList, $9);          
                        emit("goto", int2string($9));  
                        $$->nextList = $8->falseList;         
                        blockName = "";
                        changeTable(currentST->parent);
                    }
                    ;

jump_statement:
                GOTO IDENTIFIER SEMI_COLON
                    { 
                        // printf("\nLine %d : STATEMENT Rule : jump_statement -> goto IDENTIFIER ;\n", yylineno);
                    }    
                | CONTINUE SEMI_COLON
                    { 
                        // printf("\nLine %d : STATEMENT Rule : jump_statement -> continue ;\n", yylineno);
                        $$ = new Statement();
                    }
                | BREAK SEMI_COLON
                    { 
                        // printf("\nLine %d : STATEMENT Rule : jump_statement -> break ;\n", yylineno);
                        $$ = new Statement();
                    }
                | RETURN expression SEMI_COLON
                    { 
                        // printf("\nLine %d : STATEMENT Rule : jump_statement -> return expression_opt ;\n", yylineno);
                        $$ = new Statement();
                        emit("return", $2->loc->name); 
                    }
                | RETURN SEMI_COLON
                    { 
                        // printf("\nLine %d : STATEMENT Rule : jump_statement -> return ;\n", yylineno);
                        $$ = new Statement();
                        emit("return", ""); 
                    }
                ;

F:
        {
            blockName = "FOR";
        }
        ;

W:
        {
            blockName = "WHILE";
        }
        ;

D:
        {
            blockName = "DO_WHILE";
        }
        ;

X:
        {   
            string newST = currentST->name + "." + blockName + "$" + to_string(STCount++);  
            Symbol* temp_symbol = currentST->lookup(newST);
            temp_symbol->nestedTable = new SymbolTable(newST); 
            temp_symbol->name = newST;
            temp_symbol->nestedTable->parent = currentST;
            temp_symbol->type = new SymbolType("block");   
            currentSymbol = temp_symbol; 
        }
        ;

translation_unit:
                    external_declaration
                        { 
                            // printf("\nLine %d : EXTERNAL DEFINITION Rule : translation_unit -> external_declaration\n", yylineno);
                        }
                    | translation_unit external_declaration
                        { 
                            // printf("\nLine %d : EXTERNAL DEFINITION Rule : translation_unit -> translation_unit external_declaration\n", yylineno);
                        }
                    ;

external_declaration:
                        function_definition
                            { 
                                // printf("\nLine %d : EXTERNAL DEFINITION Rule : external_declaration -> function_definition\n", yylineno);
                            }
                        | declaration
                            { 
                                // printf("\nLine %d : EXTERNAL DEFINITION Rule : external_declaration -> declaration\n", yylineno);
                            }
                        ;

function_definition: // to prevent block change here which is there in the compound statement grammar rule
                     // this rule is slightly modified by expanding the original compound statement rule over here
                    declaration_specifiers declarator declaration_list_opt change_table LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                        { 
                            // printf("\nLine %d : EXTERNAL DEFINITION Rule : function_definition -> declaration_specifiers declarator declaration_list_opt { block_item_list_opt }\n", yylineno);
                            currentST->parent = globalST;
                            STCount = 0;
                            changeTable(globalST); 
                        }
                    ;

declaration_list_opt:
                        declaration_list
                            { 
                                // printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list_opt -> declaration_list\n", yylineno);
                            }
                        |
                            { 
                                // printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list_opt -> epsilon\n", yylineno);
                            }
                        ;

declaration_list:
                    declaration
                        { 
                            // printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list -> declaration\n", yylineno);
                        }
                    | declaration_list declaration
                        { 
                            // printf("\nLine %d : EXTERNAL DEFINITION Rule : declaration_list -> declaration_list declaration\n", yylineno);
                        }
                    ;

%%

void yyerror(string s) {
    printf("ERROR [Line %d] : %s\n", yylineno, s.c_str());
}
