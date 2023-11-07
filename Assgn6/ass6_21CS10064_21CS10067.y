%{
    #include "ass6_21CS10064_21CS10067_translator.h"
    extern int yylex();                     
    void yyerror(string s);                 // Report errors
    extern char* yytext;                    // lexeme value
    extern int yylineno;                    // current line number

    extern quadArray quadList;              // List of all quads
    extern symbolTable globalST;            // Global symbol table
    extern symbolTable* currentST;                 // Pointer to the current symbol table
    extern vector<string> string_constants;     // List of all string constants

    int strCount = 0;                       // Counter for string constants
%}

%union {
    int intVal;                     // For an integer value
    char charVal;                   // For a char value
    float floatVal;                 // For a float value
    void* ptr;                      // For a pointer
    string* strVal;                    // For a string
    symbolType* symType;            // For the type of a symbol
    symbol* symp;                   // For a symbol
    DataType types;                 // For the type of an expression
    opcode opc;                     // For an opcode
    expression* expr;               // For an expression
    declaration* dec;               // For a declaration
    vector<declaration*> *decList;  // For a list of declarations
    param* prm;                     // For a parameter
    vector<param*> *prmList;        // For a list of parameters
}

/*
    All tokens
*/
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
%token _GOTO
%token IF
%token INLINE
%token INTTYPE
%token LONG
%token REGISTER
%token RESTRICT
%token _RETURN
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

%token LEFT_SQUARE_BRACKET
%token INCREMENT
%token SLASH
%token QUESTION_MARK
%token _ASSIGNMENT
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

// Identifiers are treated with type str
%token <strVal> IDENTIFIER

// Integer constants have a type intval
%token <intVal> INTEGER_CONSTANT

// Floating constants have a type floatval
%token <floatVal> FLOATING_CONSTANT

// Character constants have a type charval
%token <charVal> CHARACTER_CONSTANT

// String literals have a type str
%token <strVal> STRING_LITERAL

// Non-terminals of type expr (deEXCLAMATIONing expressions)
%type <expr> 
        expression
        primary_expression 
        multiplicative_expression
        additive_expression
        shift_expression
        relational_expression
        equality_expression
        and_expression
        exclusive_or_expression
        inclusive_or_expression
        logical_and_expression
        logical_or_expression
        conditional_expression
        assignment_expression
        postfix_expression
        unary_expression
        cast_expression
        expression_statement
        statement
        compound_statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        block_item
        block_item_list
        initializer
        M
        N
        constants

// Non-terminals of type charval (unary operator)
%type <charVal> unary_operator

// The pointer non-terminal is treated with type intval
%type <intVal> pointer

// Non-terminals of type DataType (deEXCLAMATIONing types)
%type <types> type_specifier declaration_specifiers

// Non-terminals of type declaration
%type <dec> direct_declarator initializer_list init_declarator declarator function_prototype

// Non-terminals of type decList
%type <decList> init_declarator_list

// Non-terminals of type param
%type <prm> parameter_declaration

// Non-terminals of type prmList
%type <prmList> parameter_list parameter_type_list parameter_type_list_opt argument_expression_list

// Helps in removing the dangling else problem
%expect 1
%nonassoc ELSE

// The start symbol is translation_unit
%start translation_unit

%%

primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();  // Create new expression
            string s = *($1);
            currentST->lookup(s);          // Store entry in the symbol table
            $$->loc = s;            // Store pointer to string identifier name
        }
        | LEFT_PARENTHESES expression RIGHT_PARENTHESES
        {
            $$ = $2;                                // Simple assignment
        }
        | constants
        {
            $$ = $1;
        }
        ;

constants:
        INTEGER_CONSTANT
        {
            $$ = new expression();                  // Create new expression
            $$->loc = currentST->gentemp(INT);             // Generate a new temporary variable
            emit($$->loc, $1, "=");
            symbolValue* val = new symbolValue();
            val->i = val->c = val->f = $1;                   // Set the initial value
            val->p = NULL;
            currentST->lookup($$->loc)->initVal = val;     // Store in symbol table
        }
        | FLOATING_CONSTANT
        {
            $$ = new expression();                  // Create new expression
            $$->loc = currentST->gentemp(FLOAT);           // Generate a new temporary variable
            emit($$->loc, $1, "=");
            symbolValue* val = new symbolValue();
            val->i = val->c = val->f = $1;                  // Set the initial value
            val->p = NULL;
            currentST->lookup($$->loc)->initVal = val;     // Store in symbol table
        }
        | CHARACTER_CONSTANT
        {
            $$ = new expression();                  // Create new expression
            $$->loc = currentST->gentemp(CHAR);            // Generate a new temporary variable
            emit($$->loc, $1, "=");
            symbolValue* val = new symbolValue();
            val->i = val->c = val->f = $1;                   // Set the initial value
            val->p = NULL;
            currentST->lookup($$->loc)->initVal = val;     // Store in symbol table
        }
        | STRING_LITERAL
        {
            $$ = new expression();                  // Create new expression
            $$->loc = ".LC" + to_string(strCount++);
            string_constants.push_back(*($1));          // Add to the list of string constants
        }
        ;

postfix_expression: 
        primary_expression
        {}
        | postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
        {
            string f = "";
            if(!($1->dereferenced)) {
                f = currentST->gentemp(INT);                       // Generate a new temporary variable
                emit(f, 0, "=");
                $1->innerIndex = new string(f);
            }
            string temp = currentST->gentemp(INT);

            emit(temp, $3->loc, "", "=");
            emit(temp, temp, "4", "*");
            emit(f, temp, "", "=");
            $$ = $1;
        }
        | postfix_expression LEFT_PARENTHESES RIGHT_PARENTHESES
        {   
            // Corresponds to calling a function with the function name but without any arguments
            symbolTable* funcTable = globalST.lookup($1->loc)->nestedTable;
            emit($1->loc, "0", "", "call");
        }
        | postfix_expression LEFT_PARENTHESES argument_expression_list RIGHT_PARENTHESES
        {   
            // Corresponds to calling a function with the function name and the appropriate number of arguments
            symbolTable* funcTable = globalST.lookup($1->loc)->nestedTable;
            vector<param*> parameters = *($3);                          // Get the list of parameters
            vector<symbol*> paramsList = funcTable->symbols;

            for (auto p : parameters) {
                emit(p->name, "", "", "param");       // List parameters as param x, where x is a parameter
            }

            DataType retType = funcTable->lookup("RETVAL")->type.type;  // Add an entry in the symbol table for the return value
            if(retType == VOID)                                         // If the function returns void
                emit($1->loc, (int)parameters.size(), "call");
            else {                                                      // If the function returns a value
                string retVal = currentST->gentemp(retType);
                emit($1->loc, to_string(parameters.size()), retVal, "call");
                $$ = new expression();
                $$->loc = retVal;
            }
        }
        | postfix_expression DOT IDENTIFIER
        {}
        | postfix_expression ARROW IDENTIFIER
        {}
        | postfix_expression INCREMENT
        {   
            $$ = new expression();                                          // Create new expression
            symbolType t = currentST->lookup($1->loc)->type;                       // Get the type of the expression and generate a temporary variable
            if(t.type == ARRAY) {
                $$->loc = currentST->gentemp(currentST->lookup($1->loc)->type.innerType);
                emit($$->loc, $1->loc, *($1->innerIndex), "=[]");
                string temp = currentST->gentemp(t.innerType);
                emit(temp, $1->loc, *($1->innerIndex), "=[]");
                emit(temp, temp, "1", "+");
                emit($1->loc, temp, *($1->innerIndex), "[]=");
            }
            else {
                $$->loc = currentST->gentemp(currentST->lookup($1->loc)->type.type);
                emit($$->loc, $1->loc, "", "=");                         // Assign the old value 
                emit($1->loc, $1->loc, "1", "+");                           // Increment the value
            }
        }
        | postfix_expression DECREMENT
        {
            $$ = new expression();                                          // Create new expression
            $$->loc = currentST->gentemp(currentST->lookup($1->loc)->type.type);          // Generate a new temporary variable
            symbolType t = currentST->lookup($1->loc)->type;
            if(t.type == ARRAY) {
                $$->loc = currentST->gentemp(currentST->lookup($1->loc)->type.innerType);
                string temp = currentST->gentemp(t.innerType);
                emit(temp, $1->loc, *($1->innerIndex), "=[]");
                emit($$->loc, temp, "", "=");
                emit(temp, temp, "1", "-");
                emit($1->loc, temp, *($1->innerIndex), "[]=");
            }
            else {
                $$->loc = currentST->gentemp(currentST->lookup($1->loc)->type.type);
                emit($$->loc, $1->loc, "", "=");                         // Assign the old value
                emit($1->loc, $1->loc, "1", "-");                           // Decrement the value
            }
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
        {}
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
        {}
        ;

argument_expression_list: 
        assignment_expression
        {
            param* first = new param();                 // Create a new parameter
            first->name = $1->loc;
            first->type = currentST->lookup($1->loc)->type;
            $$ = new vector<param*>;
            $$->push_back(first);                       // Add the parameter to the list
        }
        | argument_expression_list COMMA assignment_expression
        {
            param* next = new param();                  // Create a new parameter
            next->name = $3->loc;
            next->type = currentST->lookup(next->name)->type;
            $$ = $1;
            $$->push_back(next);                        // Add the parameter to the list
        }
        ;

unary_expression: 
        postfix_expression
        {}
        | INCREMENT unary_expression
        {
            $$ = new expression();
            symbolType type = currentST->lookup($2->loc)->type;
            if(type.type == ARRAY) {
                string t = currentST->gentemp(type.innerType);
                emit(t, $2->loc, *($2->innerIndex), "=[]");
                emit(t, t, "1", "+");
                emit($2->loc, t, *($2->innerIndex), "[]=");
                $$->loc = currentST->gentemp(currentST->lookup($2->loc)->type.innerType);
            }
            else {
                emit($2->loc, $2->loc, "1", "+");                       // Increment the value
                $$->loc = currentST->gentemp(currentST->lookup($2->loc)->type.type);
            }
            $$->loc = currentST->gentemp(currentST->lookup($2->loc)->type.type);
            emit($$->loc, $2->loc, "", "=");                         // Assign the value
        }
        | DECREMENT unary_expression
        {
            $$ = new expression();
            symbolType type = currentST->lookup($2->loc)->type;
            if(type.type == ARRAY) {
                string t = currentST->gentemp(type.innerType);
                emit(t, $2->loc, *($2->innerIndex), "=[]");
                emit(t, t, "1", "-");
                emit($2->loc, t, *($2->innerIndex), "[]=");
                $$->loc = currentST->gentemp(currentST->lookup($2->loc)->type.innerType);
            }
            else {
                emit($2->loc, $2->loc, "1", "-");                       // Decrement the value
                $$->loc = currentST->gentemp(currentST->lookup($2->loc)->type.type);
            }
            emit($$->loc, $2->loc, "", "=");                         // Assign the value
        }
        | unary_operator cast_expression
        {
            // Case of unary operator
            switch ($1) {
                case '&':   // Address
                    $$ = new expression();
                    $$->loc = currentST->gentemp(POINTER);                 // Generate temporary of the same base type
                    emit($$->loc, $2->loc, "", "&x");          // Emit the quad
                    break;
                case '*':   // De-referencing
                    $$ = new expression();
                    $$->loc = currentST->gentemp(INT);                     // Generate temporary of the same base type
                    $$->dereferenced = 1;
                    $$->innerIndex = new string($2->loc);
                    emit($$->loc, $2->loc, "", "*x");        // Emit the quad
                    break;
                case '-':   // Unary minus
                    $$ = new expression();
                    $$->loc = currentST->gentemp();                        // Generate temporary of the same base type
                    emit($$->loc, $2->loc, "", "U-");            // Emit the quad
                    break;
                case '!':   // Logical EXCLAMATION 
                    $$ = new expression();
                    $$->loc = currentST->gentemp(INT);                     // Generate temporary of the same base type
                    int temp = nextInstruction() + 2;
                    emit(to_string(temp), $2->loc, "0", "goto==");   // Emit the quads
                    temp = nextInstruction() + 3;
                    emit(to_string(temp), "", "", "goto");
                    emit($$->loc, "1", "", "=");
                    temp = nextInstruction() + 2;
                    emit(to_string(temp), "", "", "goto");
                    emit($$->loc, "0", "", "=");
                    break;
            }
        }
        | SIZEOF unary_expression
        {}
        | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
        {}
        ;

unary_operator:
        BITWISE_AND
        {
            $$ = '&';
        }
        | ASTERISK
        {
            $$ = '*';
        }
        | PLUS
        {
            $$ = '+';
        }
        | MINUS
        {
            $$ = '-';
        }
        | TILDE
        {
            $$ = '~';
        }
        | EXCLAMATION
        {
            $$ = '!';
        }
        ;

cast_expression: 
        unary_expression
        {}
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
        {}
        ;

multiplicative_expression: 
        cast_expression
        {
            $$ = new expression();                                  // Generate new expression
            symbolType tp = currentST->lookup($1->loc)->type;
            if(tp.type == ARRAY) {                                  // If the type is an array
                string t = currentST->gentemp(tp.innerType);                // Generate a temporary
                if($1->innerIndex != NULL) {
                    emit(t, $1->loc, *($1->innerIndex), "=[]");   // Emit the necessary quad
                    $1->loc = t;
                    $1->type = tp.innerType;
                    $$ = $1;
                }
                else
                    $$ = $1;        // Simple assignment
            }
            else
                $$ = $1;            // Simple assignment
        }
        | multiplicative_expression ASTERISK cast_expression
        {   
            // Indicates multiplication
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }

            // Assign the result of the multiplication to the higher data type
            DataType final = ((s1->type.type > s2->type.type) ? (s1->type.type) : (s2->type.type));
            $$->loc = currentST->gentemp(final);                       // Store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, "*");
        }
        | multiplicative_expression SLASH cast_expression
        {
            // Indicates division
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }

            // Assign the result of the division to the higher data type
            DataType final = ((s1->type.type > s2->type.type) ? (s1->type.type) : (s2->type.type));
            $$->loc = currentST->gentemp(final);                       // Store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, "/");
        }
        | multiplicative_expression MODULO cast_expression
        {
            // Indicates modulo
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }

            // Assign the result of the modulo to the higher data type
            DataType final = ((s1->type.type > s2->type.type) ? (s1->type.type) : (s2->type.type));
            $$->loc = currentST->gentemp(final);                       // Store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, "%");
        }
        ;

additive_expression: 
        multiplicative_expression
        {}
        | additive_expression PLUS multiplicative_expression
        {   
            // Indicates addition
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }

            // Assign the result of the addition to the higher data type
            DataType final = ((s1->type.type > s2->type.type) ? (s1->type.type) : (s2->type.type));
            $$->loc = currentST->gentemp(final);                       // Store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, "+");
        }
        | additive_expression MINUS multiplicative_expression
        {
            // Indicates MINUSion
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }

            // Assign the result of the MINUSion to the higher data type
            DataType final = ((s1->type.type > s2->type.type) ? (s1->type.type) : (s2->type.type));
            $$->loc = currentST->gentemp(final);                       // Store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, "-");
        }
        ;

shift_expression: 
        additive_expression
        {}
        | shift_expression LEFT_SHIFT additive_expression
        {
            // Indicates left shift
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$->loc = currentST->gentemp(s1->type.type);              // Assign the result of the left shift to the data type of the left operand
            emit($$->loc, $1->loc, $3->loc, "<<");
        }
        | shift_expression RIGHT_SHIFT additive_expression
        {
            // Indicates right shift
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$->loc = currentST->gentemp(s1->type.type);              // Assign the result of the right shift to the data type of the left operand
            emit($$->loc, $1->loc, $3->loc, ">>");
        }
        ;

relational_expression: 
        shift_expression
        {}
        | relational_expression LESS_THAN shift_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto<");                // Emit "if x < y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        | relational_expression GREATER_THAN shift_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto>");                // Emit "if x > y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        | relational_expression LESS_EQUAL_THAN shift_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto<=");               // Emit "if x <= y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        | relational_expression GREATER_EQUAL_THAN shift_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto>=");               // Emit "if x >= y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = new expression();
            $$ = $1;                // Simple assignment
        }
        | equality_expression EQUALS relational_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto==");                // Emit "if x == y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        | equality_expression NOT_EQUALS relational_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", "=");
            $$->truelist = makelist(nextInstruction());                 // Set the truelist to the next instruction
            emit("", $1->loc, $3->loc, "goto!=");               // Emit "if x != y goto ..."
            emit($$->loc, "0", "", "=");
            $$->falselist = makelist(nextInstruction());                // Set the falselist to the next instruction
            emit("", "", "", "goto");                             // Emit "goto ..."
        }
        ;

and_expression: 
        equality_expression
        {}
        | and_expression BITWISE_AND equality_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();                            // Create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, "&");            // Emit the quad
        }
        ;

exclusive_or_expression: 
        and_expression
        {
            $$ = $1;    // Simple assignment
        }
        | exclusive_or_expression BITWISE_XOR and_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();                            // Create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, "^");            // Emit the quad
        }
        ;

inclusive_or_expression: 
        exclusive_or_expression
        {
            $$ = new expression();
            $$ = $1;                // Simple assignment
        }
        | inclusive_or_expression BITWISE_OR exclusive_or_expression
        {
            $$ = new expression();
            symbol* s1 = currentST->lookup($1->loc);                  // Get the first operand from the symbol table
            symbol* s2 = currentST->lookup($3->loc);                  // Get the second operand from the symbol table
            if(s2->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                string t = currentST->gentemp(s2->type.innerType);
                emit(t, $3->loc, *($3->innerIndex), "=[]");
                $3->loc = t;
                $3->type = s2->type.innerType;
            }
            if(s1->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                string t = currentST->gentemp(s1->type.innerType);
                emit(t, $1->loc, *($1->innerIndex), "=[]");
                $1->loc = t;
                $1->type = s1->type.innerType;
            }
            $$ = new expression();
            $$->loc = currentST->gentemp();                            // Create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, "|");             // Emit the quad
        }
        ;

logical_and_expression: 
        inclusive_or_expression
        {}
        | logical_and_expression LOGICAL_AND M inclusive_or_expression
        {
            /*
                Here, we have augmented the grammar with the non-terminal M to facilitate backpatching
            */
            backpatch($1->truelist, $3->instr);                     // Backpatching
            $$->falselist = merge($1->falselist, $4->falselist);    // Generate falselist by merging the falselists of $1 and $4
            $$->truelist = $4->truelist;                            // Generate truelist from truelist of $4
            $$->type = BOOL;                                        // Set the type of the expression to boolean
        }
        ;

logical_or_expression: 
        logical_and_expression
        {}
        | logical_or_expression LOGICAL_OR M logical_and_expression
        {
            backpatch($1->falselist, $3->instr);                    // Backpatching
            $$->truelist = merge($1->truelist, $4->truelist);       // Generate falselist by merging the falselists of $1 and $4
            $$->falselist = $4->falselist;                          // Generate truelist from truelist of $4
            $$->type = BOOL;                                        // Set the type of the expression to boolean
        }
        ;

conditional_expression: 
        logical_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            /*
                EXCLAMATIONe the augmented grammar with the non-terminals M and N
            */
            symbol* s1 = currentST->lookup($5->loc);
            $$->loc = currentST->gentemp(s1->type.type);      // Create a temporary for the expression
            $$->type = s1->type.type;
            emit($$->loc, $9->loc, "", "=");         // Assign the conditional expression
            vector<int> temp = makelist(nextInstruction());
            emit("", "", "", "goto");                     // Prevent fall-through
            backpatch($6->nextlist, nextInstruction());         // Backpatch with nextInstruction()
            emit($$->loc, $5->loc, "", "=");
            temp = merge(temp, makelist(nextInstruction()));
            emit("", "", "", "goto");                     // Prevent fall-through
            backpatch($2->nextlist, nextInstruction());         // Backpatch with nextInstruction()
            int2bool($1);                       // Convert the expression to boolean
            backpatch($1->truelist, $4->instr);         // When $1 is true, control goes to $4 (expression)
            backpatch($1->falselist, $8->instr);        // When $1 is false, control goes to $8 (conditional_expression)
            backpatch($2->nextlist, nextInstruction());         // Backpatch with nextInstruction()
        }
        ;

M: %empty
        {   
            // Stores the next instruction value, and helps in backpatching
            $$ = new expression();
            $$->instr = nextInstruction();
        }
        ;

N: %empty
        {
            // Helps in control flow
            $$ = new expression();
            $$->nextlist = makelist(nextInstruction());
            emit("", "", "", "goto");
        }
        ;

assignment_expression: 
        conditional_expression
        {}
        | unary_expression assignment_operator assignment_expression
        {
            symbol* sym1 = currentST->lookup($1->loc);         // Get the first operand from the symbol table
            symbol* sym2 = currentST->lookup($3->loc);         // Get the second operand from the symbol table
            if(!($1->dereferenced)) {
                if(sym1->type.type != ARRAY)
                    emit($1->loc, $3->loc, "", "=");
                else
                    emit($1->loc, $3->loc, *($1->innerIndex), "[]=");
            }
            else
                emit(*($1->innerIndex), $3->loc, "", "*x=");
            $$ = $1;        // Assignment 
        }
        ;

assignment_operator: 
        _ASSIGNMENT
        {}
        | ASTERISK_ASSIGNMENT
        {}
        | SLASH_ASSIGNMENT
        {}
        | MODULO_ASSIGNMENT
        {}
        | PLUS_ASSIGNMENT
        {}
        | MINUS_ASSIGNMENT
        {}
        | LEFT_SHIFT_ASSIGNMENT
        {}
        | RIGHT_SHIFT_ASSIGNMENT
        {}
        | BITWISE_AND_ASSIGNMENT
        {}
        | BITWISE_XOR_ASSIGNMENT
        {}
        | BITWISE_OR_ASSIGNMENT
        {}
        ;

expression: 
        assignment_expression
        {}
        | expression COMMA assignment_expression
        {}
        ;

constant_expression: 
        conditional_expression
        {}
        ;

declaration: 
        declaration_specifiers init_declarator_list SEMI_COLON
        {
            DataType currType = $1;
            int currSize = -1;
            switch (currType) {
                case INT:
                    currSize = 4;
                    break;
                case CHAR:
                    currSize = 1;
                    break;
                case FLOAT:
                    currSize = 8;
                    break;
                case VOID:
                    currSize = 0;
                    break;
                default:
                    break;
            }
            vector<declaration*> decs = *($2);
            for(auto it = decs.begin(); it != decs.end(); it++) {
                declaration* currDec = *it;
                if(currDec->type == FUNCTION) {
                    currentST = &globalST;
                    emit(currDec->name, "", "", "fend");
                    symbol* s1 = currentST->lookup(currDec->name);        // Create an entry for the function
                    symbol* s2 = s1->nestedTable->lookup("RETVAL", currType, currDec->pointers);
                    s1->size = 0;
                    s1->initVal = NULL;
                    continue;
                }

                symbol* three = currentST->lookup(currDec->name, currType);        // Create an entry for the variable in the symbol table
                three->nestedTable = NULL;
                if(currDec->li == vector<int>() && currDec->pointers == 0) {
                    three->type.type = currType;
                    three->size = currSize;
                    if(currDec->initVal != NULL) {
                        string rval = currDec->initVal->loc;
                        emit(three->name, rval, "", "=");
                        three->initVal = currentST->lookup(rval)->initVal;
                    }
                    else
                        three->initVal = NULL;
                }
                else if(currDec->li != vector<int>()) {         // Handle array types
                    three->type.type = ARRAY;
                    three->type.innerType = currType;
                    three->type.dims = currDec->li;
                    vector<int> temp = three->type.dims;
                    int sz = currSize;
                    for(auto i = 0; i < (int) temp.size(); i++)
                        sz *= temp[i];
                    currentST->offset += sz;
                    three->size = sz;
                    currentST->offset -= 4;
                }
                else if(currDec->pointers != 0) {               // Handle pointer types
                    three->type.type = POINTER;
                    three->type.innerType = currType;
                    three->type.pointers = currDec->pointers;
                    currentST->offset += (8 - currSize);
                    three->size = 8;
                }
            }
        }
        | declaration_specifiers SEMI_COLON
        {}
        ;

declaration_specifiers: 
        storage_class_specifier declaration_specifiers
        {}
        |storage_class_specifier
        {}
        | type_specifier declaration_specifiers
        {}
        | type_specifier
        {}
        | type_qualifier declaration_specifiers
        {}
        | type_qualifier
        {}
        | function_specifier declaration_specifiers
        {}
        | function_specifier
        {}
        ;

init_declarator_list: 
        init_declarator
        {
            $$ = new vector<declaration*>;      // Create a vector of declarations and add $1 to it
            $$->push_back($1);
        }
        | init_declarator_list COMMA init_declarator
        {
            $1->push_back($3);                  // Add $3 to the vector of declarations
            $$ = $1;
        }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
            $$->initVal = NULL;         // Initialize the initVal to NULL as no initialization is done
        }
        | declarator _ASSIGNMENT initializer
        {   
            $$ = $1;
            $$->initVal = $3;           // Initialize the initVal to the value provided
        }
        ;

storage_class_specifier: 
        EXTERN
        {}
        | STATIC
        {}
        | AUTO
        {}
        | REGISTER
        {}
        ;

type_specifier: 
        VOIDTYPE
        {
            $$ = VOID;
        }
        | CHARTYPE
        {
            $$ = CHAR;
        }
        | SHORT
        {}
        | INTTYPE
        {
            $$ = INT; 
        }
        | LONG
        {}
        | FLOATTYPE
        {
            $$ = FLOAT;
        }
        | DOUBLE
        {}
        | SIGNED
        {}
        | UNSIGNED
        {}
        | _BOOL
        {}
        | _COMPLEX
        {}
        | _IMAGINARY
        {}
        | enum_specifier
        {}
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_list_opt
        {}
        | type_qualifier specifier_qualifier_list_opt
        {}
        ;

specifier_qualifier_list_opt: 
        specifier_qualifier_list
        {}
        | %empty
        {}
        ;

enum_specifier: 
        ENUM LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET
        {}
        | ENUM IDENTIFIER LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET
        {}
        | ENUM IDENTIFIER LEFT_CURLY_BRACKET enumerator_list COMMA RIGHT_CURLY_BRACKET
        {}
        | ENUM IDENTIFIER
        {}
        ;

enumerator_list: 
        enumerator
        {}
        | enumerator_list COMMA enumerator
        {}
        ;

enumerator: 
        IDENTIFIER
        {}
        | IDENTIFIER _ASSIGNMENT constant_expression
        {}
        ;

type_qualifier: 
        CONST
        {}
        | RESTRICT
        {}
        | VOLATILE
        {}
        ;

function_specifier: 
        INLINE
        {}
        ;

declarator: 
        pointer direct_declarator
        {
            $$ = $2;
            $$->pointers = $1;
        }
        | direct_declarator
        {
            $$ = $1;
            $$->pointers = 0;
        }
        ;

direct_declarator: 
        IDENTIFIER
        {
            $$ = new declaration();
            $$->name = *($1);
        }
        | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
        {}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt RIGHT_SQUARE_BRACKET
        {
            $1->type = ARRAY;       // Array type
            $1->innerType = INT;     // Array of ints
            $$ = $1;
            $$->li.push_back(0);
        }
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt assignment_expression RIGHT_SQUARE_BRACKET
        {
            $1->type = ARRAY;       // Array type
            $1->innerType = INT;     // Array of ints
            $$ = $1;
            int index = currentST->lookup($4->loc)->initVal->i;
            $$->li.push_back(index);
        }
        | direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
        {}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
        {}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt ASTERISK RIGHT_SQUARE_BRACKET
        {
            $1->type = POINTER;     // Pointer type
            $1->innerType = INT;
            $$ = $1;
        }
        | direct_declarator LEFT_PARENTHESES parameter_type_list_opt RIGHT_PARENTHESES
        {
            $$ = $1;
            $$->type = FUNCTION;    // Function type
            symbol* funcData = currentST->lookup($$->name, $$->type);
            symbolTable* funcTable = new symbolTable();
            funcData->nestedTable = funcTable;
            vector<param*> paramList = *($3);   // Get the parameter list
            for(auto i = 0; i < (int)paramList.size(); i++) {
                param* curParam = paramList[i];
                if(curParam->type.type == ARRAY) {          // If the parameter is an array
                    funcTable->lookup(curParam->name, curParam->type.type);
                    funcTable->lookup(curParam->name)->type.innerType = INT;
                    funcTable->lookup(curParam->name)->type.dims.push_back(0);
                }
                else if(curParam->type.type == POINTER) {   // If the parameter is a pointer
                    funcTable->lookup(curParam->name, curParam->type.type);
                    funcTable->lookup(curParam->name)->type.innerType = INT;
                    funcTable->lookup(curParam->name)->type.dims.push_back(0);
                }
                else                                        // If the parameter is a anything other than an array or a pointer
                    funcTable->lookup(curParam->name, curParam->type.type);
            }
            currentST = funcTable;         // Set the pointer to the symbol table to the function's symbol table
            emit($$->name, "", "", "fstart");
        }
        | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
        {}
        ;

parameter_type_list_opt:
        parameter_type_list
        {}
        | %empty
        {
            $$ = new vector<param*>;
        }
        ;

type_qualifier_list_opt: 
        type_qualifier_list
        {}
        | %empty
        {}
        ;

pointer: 
        ASTERISK type_qualifier_list
        {}
        | ASTERISK
        {
            $$ = 1;
        }
        | ASTERISK type_qualifier_list pointer
        {}
        | ASTERISK pointer
        {
            $$ = 1 + $2;
        }
        ;

type_qualifier_list: 
        type_qualifier
        {}
        | type_qualifier_list type_qualifier
        {}
        ;

parameter_type_list: 
        parameter_list
        | parameter_list COMMA ELLIPSIS
        ;

parameter_list: 
        parameter_declaration
        {
            $$ = new vector<param*>;         // Create a new vector of parameters
            $$->push_back($1);              // Add the parameter to the vector
        }
        | parameter_list COMMA parameter_declaration
        {
            $1->push_back($3);              // Add the parameter to the vector
            $$ = $1;
        }
        ;

parameter_declaration: 
        declaration_specifiers declarator
        {
            $$ = new param();
            $$->name = $2->name;
            if($2->type == ARRAY) {
                $$->type.type = ARRAY;
                $$->type.innerType = $1;
            }
            else if($2->pc != 0) {
                $$->type.type = POINTER;
                $$->type.innerType = $1;
            }
            else
                $$->type.type = $1;
        }
        | declaration_specifiers
        {}
        ;

identifier_list: 
        IDENTIFIER
        {}
        | identifier_list COMMA IDENTIFIER
        {}
        ;

type_name: 
        specifier_qualifier_list
        {}
        ;

initializer: 
        assignment_expression
        {
            $$ = $1;   // Simple assignment
        }
        | LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
        {}
        | LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
        {}
        ;

initializer_list: 
        designation_opt initializer
        {}
        | initializer_list COMMA designation_opt initializer
        {}
        ;

designation_opt: 
        designation
        {}
        | %empty
        {}
        ;

designation: 
        designator_list _ASSIGNMENT
        {}
        ;

designator_list: 
        designator
        {}
        | designator_list designator
        {}
        ;

designator: 
        LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
        {}
        | DOT IDENTIFIER
        {}
        ;

statement: 
        labeled_statement
        {}
        | compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement: 
        IDENTIFIER COLON statement
        {}
        | CASE constant_expression COLON statement
        {}
        | DEFAULT COLON statement
        {}
        ;

compound_statement: 
        LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET
        {}
        | LEFT_CURLY_BRACKET block_item_list RIGHT_CURLY_BRACKET
        {
            $$ = $2;
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;    // Simple assignment
            backpatch($1->nextlist, nextInstruction());
        }
        | block_item_list M block_item
        {   
            /*
                This production rule has been augmented with the non-terminal M
            */
            $$ = new expression();
            backpatch($1->nextlist, $2->instr);    // After $1, move to block_item via $2
            $$->nextlist = $3->nextlist;
        }
        ;

block_item: 
        declaration
        {
            $$ = new expression();   // Create new expression
        }
        | statement
        ;

expression_statement: 
        expression SEMI_COLON
        {}
        | SEMI_COLON
        {
            $$ = new expression();  // Create new expression
        }
        ;

selection_statement: 
        IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, nextInstruction());         // nextlist of N now has nextInstruction()
            int2bool($3);                       // Convert expression to bool
            backpatch($3->truelist, $6->instr);         // Backpatching - if expression is true, go to M
            $$ = new expression();                      // Create new expression
            // Merge falselist of expression, nextlist of statement and nextlist of the last N
            $7->nextlist = merge($8->nextlist, $7->nextlist);
            $$->nextlist = merge($3->falselist, $7->nextlist);
        }
        | IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N ELSE M statement N
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, nextInstruction());         // nextlist of N now has nextInstruction()
            int2bool($3);                       // Convert expression to bool
            backpatch($3->truelist, $6->instr);         // Backpatching - if expression is true, go to first M, else go to second M
            backpatch($3->falselist, $10->instr);
            $$ = new expression();                      // Create new expression
            // Merge nextlist of statement, nextlist of N and nextlist of the last statement
            $$->nextlist = merge($7->nextlist, $8->nextlist);
            $$->nextlist = merge($$->nextlist, $11->nextlist);
            $$->nextlist = merge($$->nextlist, $12->nextlist);
        }
        | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
        {}
        ;

iteration_statement: 
        WHILE M LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement
        {   
            /*
                This production rule has been augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                   // Create a new expression
            emit("", "", "", "goto");
            backpatch(makelist(nextInstruction() - 1), $2->instr);
            backpatch($5->nextlist, nextInstruction());
            int2bool($4);                   // Convert expression to bool
            $$->nextlist = $4->falselist;           // Exit loop if expression is false
            backpatch($4->truelist, $7->instr);     // Backpatching - if expression is true, go to M
            backpatch($8->nextlist, $2->instr);     // Backpatching - go to the beginning of the loop
        }
        | DO M statement M WHILE LEFT_PARENTHESES expression N RIGHT_PARENTHESES SEMI_COLON
        {
            /*
                This production rule has been augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                  // Create a new expression  
            backpatch($8->nextlist, nextInstruction());     // Backpatching 
            int2bool($7);                   // Convert expression to bool
            backpatch($7->truelist, $2->instr);     // Backpatching - if expression is true, go to M
            backpatch($3->nextlist, $4->instr);     // Backpatching - go to the beginning of the loop
            $$->nextlist = $7->falselist;
        }
        | FOR LEFT_PARENTHESES expression_statement M expression_statement N M expression N RIGHT_PARENTHESES M statement
        {
            /*
                This production rule has been augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                   // Create a new expression
            emit("", "", "", "goto");
            $12->nextlist = merge($12->nextlist, makelist(nextInstruction() - 1));
            backpatch($12->nextlist, $7->instr);    // Backpatching - go to the beginning of the loop
            backpatch($9->nextlist, $4->instr);     
            backpatch($6->nextlist, nextInstruction());     
            int2bool($5);                   // Convert expression to bool
            backpatch($5->truelist, $11->instr);    // Backpatching - if expression is true, go to M
            $$->nextlist = $5->falselist;           // Exit loop if expression is false
        }
        ;

jump_statement: 
        _GOTO IDENTIFIER SEMI_COLON
        {}
        | CONTINUE SEMI_COLON
        {}
        | BREAK SEMI_COLON
        {}
        | _RETURN SEMI_COLON
        {
            if(currentST->lookup("RETVAL")->type.type == VOID) {
                emit("", "", "", "return");           // Emit the quad when return type is void
            }
            $$ = new expression();
        }
        | _RETURN expression SEMI_COLON
        {
            if(currentST->lookup("RETVAL")->type.type == currentST->lookup($2->loc)->type.type) {
                emit($2->loc, "", "", "return");      // Emit the quad when return type is EXCLAMATION void
            }
            $$ = new expression();
        }
        ;

translation_unit: 
        external_declaration
        {}
        | translation_unit external_declaration
        {}
        ;

external_declaration: 
        function_definition
        {}
        | declaration
        {}
        ;

function_definition: 
        declaration_specifiers declarator declaration_list compound_statement
        {}
        | function_prototype compound_statement
        {
            currentST = &globalST;                     // Reset the symbol table to global symbol table
            emit($1->name, "", "", "fend");
        }
        ;

function_prototype:
        declaration_specifiers declarator
        {
            DataType currType = $1;
            int currSize = -1;
            switch (currType) {
                case INT:
                    currSize = 4;
                    break;
                case CHAR:
                    currSize = 1;
                    break;
                case FLOAT:
                    currSize = 8;
                    break;
                case VOID:
                    currSize = 0;
                    break;
                default:
                    break;
            }
            declaration* currDec = $2;
            symbol* sym = globalST.lookup(currDec->name);
            if(currDec->type == FUNCTION) {
                symbol* retval = sym->nestedTable->lookup("RETVAL", currType, currDec->pointers);   // Create entry for return value
                sym->size = 0;
                sym->initVal = NULL;
            }
            $$ = $2;
        }
        ;

declaration_list: 
        declaration
        {}
        | declaration_list declaration
        {}
        ;

%%
//Prints Error Messages
void yyerror(string s) {
    printf("ERROR [Line %d] : %s\n", yylineno, s.c_str());
}
