#include "ass5_21CS10064_21CS10067_translator.h"

Symbol* currentSymbol;  // Pointer to the current symbol
SymbolTable* currentST; // Pointer to the current symbol table
SymbolTable* globalST;  // Pointer to the global symbol table
QuadArray quadList;    // List of quads
int STCount;        // Count of the symbol tables
string blockName;   // Name of the current block
string varType;    // Type of the current variable


SymbolType::SymbolType(string type1, SymbolType* arrType1, int width1): 
    type(type1), width(width1), arrType(arrType1) {}

// Symbol Constructor
Symbol::Symbol(string name1, string t, SymbolType* arrType, int width): name(name1), value("-"), offset(0), nestedTable(NULL) {
    type = new SymbolType(t, arrType, width);
    size = sizeOfType(type);
}

// Update the symbol type and size
Symbol* Symbol::update(SymbolType* t) {
    type = t;
    size = sizeOfType(t);
    return this;
}

// Symbol Table Constructor
SymbolTable::SymbolTable(string name1): name(name1), tempCount(0) {}

// Lookup for a symbol in the symbol table
Symbol* SymbolTable::lookup(string name) { 
    // Iterate through the symbol table
    for (auto it = table.begin(); it != table.end(); it++) {
        if (it->name == name) {
            return &(*it);
        }
    }

    // If not found in the current symbol table, look in the parent symbol table
    Symbol* s = NULL;
    if (this->parent != NULL) {
        s = this->parent->lookup(name);
    }

    // If the symbol is not found in the parent symbol table, create a new symbol
    if (currentST == this && s == NULL) {
        Symbol* newSymbol = new Symbol(name, "int");
        table.push_back(*newSymbol);
        return &(table.back());
    } else if (s != NULL) {
        return s;
    }

    return NULL;
}

// Generate a new temporary variable
Symbol* SymbolTable::genTemp(SymbolType* t, string initValue) {
    // Generate a new temporary variable name
    string name = "t" + int2string(currentST->tempCount++);
    // Create a new symbol
    Symbol* newSymbol = new Symbol(name, "int");
    newSymbol->type = t;
    newSymbol->value = initValue;
    newSymbol->size = sizeOfType(t);

    // Add the symbol to the symbol table
    currentST->table.push_back(*newSymbol);
    // Return the pointer to the symbol
    return &(currentST->table.back());
}

// Print the symbol table
void SymbolTable::print() {
    
    for(int i = 0; i < 160; i++) {
        cout << '-';
    }
    cout << endl;
    // Print the name of the symbol table
    cout << "Symbol Table: " << setfill(' ') << left << setw(50) << this->name;
    cout << setfill(' ') << left << setw(40) << "|";
    // Print the name of the parent symbol table
    cout << "Parent Table: " << setfill(' ') << left << setw(50) << ((this->parent != NULL) ? this->parent->name : "NULL") << endl;
    for(int i = 0; i < 160; i++) {
        cout << '-';
    }
    cout << endl;
    // Print the column headers
    cout << setfill(' ') << setw(15) <<  "Name";
    cout << setw(10) << "|";
    cout << setw(25) << "Type";
    cout << setw(10) << "|";
    cout << setw(20) << "Initial Value";
    cout << setw(10) << "|";
    cout << setw(15) << "Size";
    cout << setw(10) << "|";
    cout << setw(15) << "Offset";
    cout << setw(10) << "|";
    cout << "Nested" << endl;


    for(int i = 0; i < 160; i++) {
        cout << '-';
    }
    cout << endl;

    list<SymbolTable*> tableList;

    // Print the symbols in the symbol table
    for(auto it = this->table.begin(); it != this->table.end(); it++) {
        cout << setw(15) << it->name;
        cout << setw(10) << "|";
        cout << setw(25) << checkType(it->type);
        cout << setw(10) << "|";
        cout << setw(20) << (it->value != "" ? it->value : "-");
        cout << setw(10) << "|";
        cout << setw(15) << it->size;
        cout << setw(10) << "|";
        cout << setw(15) << it->offset;
        cout << setw(10) << "|";

        // Print the name of the nested symbol table
        if(it->nestedTable != NULL) {
            cout << it->nestedTable->name << endl;
            tableList.push_back(it->nestedTable);
        }
        else {
            cout << "NULL" << endl;
        }
    }

    for(int i = 0; i < 160; i++) {
        cout << '-';
    }
    cout << endl << endl;

    // Print the nested symbol tables
    for(list<SymbolTable*>::iterator it = tableList.begin(); it != tableList.end(); it++) {
        (*it)->print();
    }
}

void SymbolTable::update() {
    list<SymbolTable*> tableList;
    int total_offset;

    // Update the offsets of the symbols based on their sizes
    for (auto it = table.begin(); it != table.end(); it++) {
        if (it == table.begin()) {
            it->offset = 0;
            total_offset = it->size;
        } else {
            it->offset = total_offset;
            total_offset += it->size;
        }

        if (it->nestedTable != NULL) {
            tableList.push_back(it->nestedTable);
        }
    }

    // Update the nested symbol tables
    for (auto it = tableList.begin(); it != tableList.end(); it++) {
        (*it)->update();
    }
}

Quad::Quad(string res, string arg1_, string operation, string arg2_): result(res), arg1(arg1_), op(operation), arg2(arg2_) {}

Quad::Quad(string res, int arg1_, string operation, string arg2_): result(res), op(operation), arg2(arg2_) {
    arg1 = int2string(arg1_);
}

Quad::Quad(string res, float arg1_, string operation, string arg2_): result(res), op(operation), arg2(arg2_) {
    arg1 = float2string(arg1_);
}

// Print the quad
void Quad::print() {
    if (op == "=") 
        cout << result << " = " << arg1;
    else if (op == "*=")
        cout << "*" << result << " = " << arg1;
    else if (op == "[]=")
        cout << result << "[" << arg1 << "]" << " = " << arg2;
    else if (op == "=[]")
        cout << result << " = " << arg1 << "[" << arg2 << "]";
    else if (op == "goto" || op == "param" || op == "return")
        cout << op << " " << result;
    else if (op == "call")
        cout << result << " = " << "call " << arg1 << ", " << arg2;
    else if (op == "label")
        cout << result << ": ";
    else if (op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^" || op == "|" || op == "&" || op == "<<" || op == ">>")
        cout << result << " = " << arg1 << " " << op << " " << arg2;
    else if (op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=")
        cout << "if " << arg1 << " " << op << " " << arg2 << " goto " << result;
    else if (op == "= &" || op == "= *" || op == "= -" || op == "= ~" || op == "= !")
        cout << result << " " << op << arg1;
    else
        cout << "Unknown Operator";
}

// Print the quad list
void QuadArray::print() {
    cout << "THREE ADDRESS CODE (TAC):" << endl;

    int cnt = 0;
    // Print each of the quads one by one
    for(auto it = this->quads.begin(); it != this->quads.end(); it++, cnt++) {
        if(it->op == "label") {
            cout << endl;
        }
        cout << left << setw(4) << cnt << ": ";
        it->print();
        cout << endl;
    }
}

// Creates a new quad and adds it to the quad list
void emit(string op, string result, string arg1, string arg2) {
    Quad* newQuad = new Quad(result, arg1, op, arg2);
    quadList.quads.push_back(*newQuad);
}

// Creates a new quad and adds it to the quad list
void emit(string op, string result, int arg1, string arg2) {
    Quad* newQuad = new Quad(result, arg1, op, arg2);
    quadList.quads.push_back(*newQuad);
}

// Creates a new quad and adds it to the quad list
void emit(string op, string result, float arg1, string arg2) {
    Quad* newQuad = new Quad(result, arg1, op, arg2);
    quadList.quads.push_back(*newQuad);
}

// Makes a new list with the given integer
list<int> makeList(int i) {
    list<int> l(1, i);
    return l;
}

// Merges the two lists and returns the merged list
list<int> merge(list<int> &p1, list<int> &p2) {
    p1.merge(p2);
    return p1;
}

// Backpatches the list with the given integer
void backpatch(list<int> p, int i) {
    // Convert the integer to a string
    string str = int2string(i);

    // Iterate through the list and update the result of the quad
    // Here result is the label of the quad
    for(auto it = p.begin(); it != p.end(); it++) {
        quadList.quads[*it].result = str;
    }
}

// Checks if the given symbols are of the same type
bool typecheck(Symbol* &s1, Symbol* &s2) {
    // Gets the type of the symbols
    SymbolType* t1 = s1->type;
    SymbolType* t2 = s2->type;

    // If the types are the same, return true
    if (typecheck(t1, t2))
        return true;
    // If the types are not the same, try to convert the types
    else if (s1 = convertType(s1, t2->type))
        return true;
    else if (s2 = convertType(s2, t1->type))
        return true;
    // If the types cannot be converted, return false
    else
        return false;
}

// Checks if the given symbol types are the same
bool typecheck(SymbolType* t1, SymbolType* t2) {
    // If both the types are NULL, return true
    if (t1 == NULL && t2 == NULL)
        return true;
    // If one of the types is NULL, return false
    else if (t1 == NULL || t2 == NULL)
        return false;
    // If the types are different, return false
    else if (t1->type != t2->type)
        return false;

    // If the types are the same, check for the array types
    return typecheck(t1->arrType, t2->arrType);
}

// Converts the type of the symbol to the given type
Symbol* convertType(Symbol* s, string t) {
    // Creates a new temporary variable
    Symbol* temp = SymbolTable::genTemp(new SymbolType(t));

    // If the symbol is a float, convert it to the given type
    if (s->type->type == "float") {
        // If the type is int, convert the float to int
        if (t == "int") {
            emit("=", temp->name, "float2int(" + s->name + ")");
            return temp;
        }
        // If the type is char, convert the float to char
        else if (t == "char") {
            emit("=", temp->name, "float2char(" + s->name + ")");
            return temp;
        }
        return s;
    }
    else if (s->type->type == "int") {
        if (t == "float") {
            emit("=", temp->name, "int2float(" + s->name + ")");
            return temp;
        }
        else if (t == "char") {
            emit("=", temp->name, "int2char(" + s->name + ")");
            return temp;
        }
        return s;
    }
    else if (s->type->type == "char") {
        if (t == "float") {
            emit("=", temp->name, "char2float(" + s->name + ")");
            return temp;
        }
        else if (t == "int") {
            emit("=", temp->name, "char2int(" + s->name + ")");
            return temp;
        }
        return s;
    }
    return s;
}

// Converts the integer to a string
string int2string(int i) {
    return to_string(i);
}

// Converts the float to a string
string float2string(float f) {
    return to_string(f);
}

// converts the integer type expression to a boolean type expression
Expression* int2bool(Expression* expr) {
    if(expr->type != "bool") {
        // Create the true and false lists
        expr->falseList = makeList(nextInstruction());
        emit("==", expr->loc->name, "0");
        expr->trueList = makeList(nextInstruction());
        emit("goto", "");
    }
    return expr;
}

// converts the boolean type expression to an integer type expression
Expression* bool2int(Expression* expr) {
    if(expr->type == "bool") {
        // Generate a new temporary variable
        expr->loc = SymbolTable::genTemp(new SymbolType("int"));
        // Backpatch the true and false lists
        backpatch(expr->trueList, nextInstruction());
        emit("=", expr->loc->name, "true");
        emit("goto", int2string(nextInstruction() + 1));
        backpatch(expr->falseList, nextInstruction());
        emit("=", expr->loc->name, "false");
    }
    return expr;
}

// Changes the current symbol table
void changeTable(SymbolTable* newTable) {
    currentST = newTable;
}

// Returns the next instruction number
int nextInstruction() {
    return quadList.quads.size();
}

// Returns the size of the given type
int sizeOfType(SymbolType* t) {
    if(t->type == "void")
        return 0;
    else if(t->type == "char")
        return 1;
    else if(t->type == "int")
        return 4;
    else if(t->type == "ptr")
        return 4;
    else if(t->type == "float")
        return 8;
    else if(t->type == "arr")
        return t->width * sizeOfType(t->arrType);
    else if(t->type == "func")
        return 0;
    else
        return -1;
}

// Checks the type of the SymbolType
string checkType(SymbolType* t) {
    if(t == NULL)
        return "null";
    else if(t->type == "void" || t->type == "char" || t->type == "int" || t->type == "float" || t->type == "block" || t->type == "func")
        return t->type;
    else if(t->type == "ptr")
        return "ptr(" + checkType(t->arrType) + ")";
    else if(t->type == "arr")
        return "arr(" + int2string(t->width) + ", " + checkType(t->arrType) + ")";
    else
        return "Unkown Type";
}

int main() {
    // Initialize the global symbol table
    STCount = 0;                            
    globalST = new SymbolTable("Global");   
    // Set the current symbol table to the global symbol table
    currentST = globalST;                 
    blockName = "";

    yyparse();
    // Print the quad list and the symbol table
    globalST->update();
    quadList.print();      
    cout << endl;
    globalST->print();

    return 0;
}
