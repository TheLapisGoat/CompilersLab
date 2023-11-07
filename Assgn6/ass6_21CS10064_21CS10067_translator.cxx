#include "ass6_21CS10064_21CS10067_translator.h"
#include <iomanip>
using namespace std;

// Initialize the global variables
int nextinstr = 0;

int nextInstruction() {
    return nextinstr;
}

// Initialize the static variables
int symbolTable::tempCount = 0;

quadArray quadList;
symbolTable globalST;
symbolTable* currentST;


// Implementations of constructors and functions for the symbol class
symbol::symbol(): nestedTable(NULL) {}


// Implementations of constructors and functions for the symbolTable class
symbolTable::symbolTable(): offset(0) {}

symbol* symbolTable::lookup(string name, DataType t, int pc) {
    if(table.count(name) == 0) {
        symbol* sym = new symbol();
        sym->name = name;
        sym->type.type = t;
        sym->offset = offset;
        sym->initVal = NULL;

        if(pc == 0) {
            sym->size = sizeOfType(t);
            offset += sym->size;
        }
        else {
            sym->size = 8;
            sym->type.innerType = t;
            sym->type.pointers = pc;
            sym->type.type = ARRAY;
        }
        symbols.push_back(sym);
        table[name] = sym;
    }
    return table[name];
}

symbol* symbolTable::searchGlobal(string name) {
    return (table.count(name) ? table[name] : NULL);
}

string symbolTable::gentemp(DataType t) {
    // Create the name for the temporary
    string tempName = "t" + to_string(symbolTable::tempCount++);
    
    // Initialize the required attributes
    symbol* sym = new symbol();
    sym->name = tempName;
    sym->size = sizeOfType(t);
    sym->offset = offset;
    sym->type.type = t;
    sym->initVal = NULL;

    offset += sym->size;
    symbols.push_back(sym);
    table[tempName] = sym;  // Add the temporary to the symbol table

    return tempName;
}

void symbolTable::print(string tableName) {
    for(int i = 0; i < 160; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "Symbol Table: " << setfill(' ') << left << setw(145) << tableName;
    cout << setfill(' ') << left << setw(40) << "|" << endl;

    for(int i = 0; i < 160; i++)
        cout << '-';
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

    for(int i = 0; i < 160; i++)
        cout << '-';
    cout << endl;

    // For storing nested symbol tables
    vector<pair<string, symbolTable*>> tableList;

    // Print the symbols in the symbol table
    for(int i = 0; i < (int) symbols.size(); i++) {
        symbol* sym = symbols[i];
        cout << left << setw(15) << sym->name;
        cout << setw(10) << "|";
        cout << left << setw(25) << checkType(sym->type);
        cout << setw(10) << "|";
        cout << left << setw(20) << getInitVal(sym);
        cout << setw(10) << "|";
        cout << left << setw(15) << sym->size;
        cout << setw(10) << "|";
        cout << left << setw(15) << sym->offset;
        cout << setw(10) << "|";
        cout << left;

        if(sym->nestedTable != NULL) {
            string nestedTableName = tableName + "." + sym->name;
            cout << nestedTableName << endl;
            tableList.push_back({nestedTableName, sym->nestedTable});
        }
        else
            cout << "NULL" << endl;
    }

    for(int i = 0; i < 160; i++)
        cout << '-';
    cout << endl << endl;

    // Recursively call the print function for the nested symbol tables
    for(auto it = tableList.begin(); it != tableList.end(); it++) {
        pair<string, symbolTable*> p = (*it);
        p.second->print(p.first);
    }

}


// Implementations of constructors and functions for the quad class
quad::quad(string res_, string arg1_, string arg2_, opcode op_): op(op_), arg1(arg1_), arg2(arg2_), result(res_) {}

string quad::print() {
    string out = "";
    if(op >= ADD && op <= BW_XOR) {                 // Binary operators
        out += (result + " = " + arg1 + " ");
        switch(op) {
            case ADD: out += "+"; break;
            case SUB: out += "-"; break;
            case MULT: out += "*"; break;
            case DIV: out += "/"; break;
            case MOD: out += "%"; break;
            case SL: out += "<<"; break;
            case SR: out += ">>"; break;
            case BW_AND: out += "&"; break;
            case BW_OR: out += "|"; break;
            case BW_XOR: out += "^"; break;
        }
        out += (" " + arg2);
    }
    else if(op >= BW_U_NOT && op <= U_NEG) {        // Unary operators
        out += (result + " = ");
        switch(op) {
            case BW_U_NOT: out += "~"; break;
            case U_PLUS: out += "+"; break;
            case U_MINUS: out += "-"; break;
            case REFERENCE: out += "&"; break;
            case DEREFERENCE: out += "*"; break;
            case U_NEG: out += "!"; break;
        }
        out += arg1;
    }
    else if(op >= GOTO_EQ && op <= IF_FALSE_GOTO) { // Conditional operators
        out += ("if " + arg1 + " ");
        switch(op) {
            case GOTO_EQ: out += "=="; break;
            case GOTO_NEQ: out += "!="; break;
            case GOTO_GT: out += ">"; break;
            case GOTO_GTE: out += ">="; break;
            case GOTO_LT: out += "<"; break;
            case GOTO_LTE: out += "<="; break;
            case IF_GOTO: out += "!= 0"; break;
            case IF_FALSE_GOTO: out += "== 0"; break;
        }
        out += (" " + arg2 + " goto " + result);
    }
    else if(op >= CtoI && op <= CtoF) {             // Type Conversion functions
        out += (result + " = ");
        switch(op) {
            case CtoI: out += "Char2Int"; break;
            case ItoC: out += "Int2Char"; break;
            case FtoI: out += "Float2Int"; break;
            case ItoF: out += "Int2Float"; break;
            case FtoC: out += "Float2Char"; break;
            case CtoF: out += "Char2Float"; break;
        }
        out += ("(" + arg1 + ")");
    }

    else if(op == ASSIGNMENT)                       // Assignment operator
        out += (result + " = " + arg1);
    else if(op == GOTO)                         // Goto
        out += ("goto " + result);
    else if(op == RETURN)                       // Return from a function
        out += ("return " + result);
    else if(op == PARAM)                        // Parameters for a function
        out += ("param " + result);
    else if(op == CALL) {                       // Call a function
        if(arg2.size() > 0)
            out += (arg2 + " = ");
        out += ("call " + result + ", " + arg1);
    }
    else if(op == ARR_INDEXING)                  // Array indexing
        out += (result + " = " + arg1 + "[" + arg2 + "]");
    else if(op == ARR_ASSIGNMENT)                  // Array indexing
        out += (result + "[" + arg2 + "] = " + arg1);
    else if(op == FUNC_BEG)                     // Function begin
        out += (result + ": ");
    else if(op == FUNC_END) {                   // Function end
        out += ("function " + result + " ends");
    }
    else if(op == L_DEREF)                      // Dereference
        out += ("*" + result + " = " + arg1);

    return out;
}


// Implementations of constructors and functions for the quadArray class
void quadArray::print() {
    for(int i = 0; i < 160; i++)
        cout << '-';
    cout << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 160; i++)
        cout << '-';
    cout << endl;

    // Print each of the quads one by one
    for(int i = 0; i < (int)quads.size(); i++) {
        if(quads[i].op != FUNC_BEG && quads[i].op != FUNC_END)
            cout << left << setw(4) << i << ":    ";
        else if(quads[i].op == FUNC_BEG)
            cout << endl << left << setw(4) << i << ": ";
        else if(quads[i].op == FUNC_END)
            cout << left << setw(4) << i << ": ";
        cout << quads[i].print() << endl;
    }
    cout << endl;
}


// Implementations of constructors and functions for the expression class
expression::expression(): dereferenced(0), innerIndex(NULL) {}

opcode get_opcode(string operation) {
    if (operation == "+") {
        return ADD;
    }
    if (operation == "-") {
        return SUB;
    }
    if (operation == "*") {
        return MULT;
    }
    if (operation == "/") {
        return DIV;
    }
    if (operation == "%") {
        return MOD;
    }
    if (operation == "<<") {
        return SL;
    }
    if (operation == ">>") {
        return SR;
    }
    if (operation == "&") {
        return BW_AND;
    }
    if (operation == "|") {
        return BW_OR;
    }
    if (operation == "^") {
        return BW_XOR;
    }
    if (operation == "~") {
        return BW_U_NOT;
    }
    if (operation == "U+") {
        return U_PLUS;
    }
    if (operation == "U-") {
        return U_MINUS;
    }
    if (operation == "&x") {
        return REFERENCE;
    }
    if (operation == "*x") {
        return DEREFERENCE;
    }
    if (operation == "!") {
        return U_NEG;
    }
    if (operation == "goto==") {
        return GOTO_EQ;
    }
    if (operation == "goto!=") {
        return GOTO_NEQ;
    }
    if (operation == "goto>") {
        return GOTO_GT;
    }
    if (operation == "goto>=") {
        return GOTO_GTE;
    }
    if (operation == "goto<") {
        return GOTO_LT;
    }
    if (operation == "goto<=") {
        return GOTO_LTE;
    }
    if (operation == "ifgoto") {
        return IF_GOTO;
    }
    if (operation == "ifFalsegoto") {
        return IF_FALSE_GOTO;
    }
    if (operation == "c2i") {
        return CtoI;
    }
    if (operation == "i2c") {
        return ItoC;
    }
    if (operation == "f2i") {
        return FtoI;
    }
    if (operation == "i2f") {
        return ItoF;
    }
    if (operation == "c2f") {
        return CtoF;
    }
    if (operation == "=") {
        return ASSIGNMENT;
    }
    if (operation == "goto") {
        return GOTO;
    }
    if (operation == "return") {
        return RETURN;
    }
    if (operation == "param") {
        return PARAM;
    }
    if (operation == "call") {
        return CALL;
    }
    if (operation == "=[]") {
        return ARR_INDEXING;
    }
    if (operation == "[]=") {
        return ARR_ASSIGNMENT;
    }
    if (operation == "fstart") {
        return FUNC_BEG;
    }
    if (operation == "fend") {
        return FUNC_END;
    }
    if (operation == "*x=") {
        return L_DEREF;
    }
    return ASSIGNMENT;
}

// Overloaded emit functions
void emit(string result, string arg1, string arg2, string operation) {
    opcode op = get_opcode(operation);
    quad q(result, arg1, arg2, op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, int constant, string operation) {
    opcode op = get_opcode(operation);
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, char constant, string operation) {
    opcode op = get_opcode(operation);
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}

void emit(string result, float constant, string operation) {
    opcode op = get_opcode(operation);
    quad q(result, to_string(constant), "", op);
    quadList.quads.push_back(q);
    nextinstr++;
}


// Implementation of the makelist function
vector<int> makelist(int i) {
    vector<int> l(1, i);
    return l;
}

// Implementation of the merge function
vector<int> merge(vector<int> list1, vector<int> list2) {
    for (auto x : list2) {
        list1.push_back(x);
    }
    return list1;
}

// Implementation of the backpatch function
void backpatch(vector<int> l, int address) {
    string str = to_string(address);
    for(auto it = l.begin(); it != l.end(); it++) {
        quadList.quads[*it].result = str;
    }
}

// Implementation of the int2bool function
void int2bool(expression* expr) {
    if(expr->type != BOOL) {
        expr->type = BOOL;
        expr->falselist = makelist(nextinstr);    // Add falselist for boolean expressions
        emit("", expr->loc, "", "ifFalsegoto");
        expr->truelist = makelist(nextinstr);     // Add truelist for boolean expressions
        emit("", "", "", "goto");
    }
}

// Implementation of the sizeOfType function
int sizeOfType(DataType t) {
// VOID_SIZE 0
// FUNCTION_SIZE 0
// CHARACTER_SIZE 1
// INTEGER_SIZE 4
// POINTER_SIZE 8
// FLOAT_SIZE 8
    if(t == VOID)
        return 0;
    else if(t == CHAR)
        return 1;
    else if(t == INT)
        return 4;
    else if(t == POINTER)
        return 8;
    else if(t == FLOAT)
        return 8;
    else if(t == FUNCTION)
        return 0;
    else
        return 0;
}

// Implementation of the checkType function
string checkType(symbolType t) {
    if(t.type == VOID)
        return "void";
    else if(t.type == CHAR)
        return "char";
    else if(t.type == INT)
        return "int";
    else if(t.type == FLOAT)
        return "float";
    else if(t.type == FUNCTION)
        return "function";

    else if(t.type == POINTER) {        // Depending on type of pointer
        string tp = "";
        if(t.innerType == CHAR)
            tp += "char";
        else if(t.innerType == INT)
            tp += "int";
        else if(t.innerType == FLOAT)
            tp += "float";
        tp += string(t.pointers, '*');
        return tp;
    }

    else if(t.type == ARRAY) {          // Depending on type of array
        string tp = "";
        if(t.innerType == CHAR)
            tp += "char";
        else if(t.innerType == INT)
            tp += "int";
        else if(t.innerType == FLOAT)
            tp += "float";
        vector<int> dim = t.dims;
        for(int i = 0; i < (int)dim.size(); i++) {
            if(dim[i])
                tp += "[" + to_string(dim[i]) + "]";
            else
                tp += "[]";
        }
        if((int)dim.size() == 0)
            tp += "[]";
        return tp;
    }

    else
        return "unknown";
}

// Implementation of the getInitVal function
string getInitVal(symbol* sym) {
    if(sym->initVal != NULL) {
        if(sym->type.type == INT)
            return to_string(sym->initVal->i);
        else if(sym->type.type == CHAR)
            return to_string(sym->initVal->c);
        else if(sym->type.type == FLOAT)
            return to_string(sym->initVal->f);
        else
            return "-";
    }
    else
        return "-";
}
