#ifndef _TRANSLATOR_H
#define _TRANSLATOR_H

#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <list>
#include <functional>
#include <iomanip>
#include <string.h>
using namespace std;

class Symbol;
class SymbolType;
class SymbolTable;
class Quad;
class QuadArray;


class SymbolType {
    public:
        string type;
        int width;
        SymbolType* arrType;

        SymbolType(string type1, SymbolType* arrType1 = NULL, int width1 = 1);
};

class Symbol {
    public:
        string name;
        SymbolType* type;
        string value;
        int size;
        int offset;
        SymbolTable* nestedTable;
    
        Symbol(string name1, string t, SymbolType* arrType = NULL, int width = 0);
        Symbol* update(SymbolType* t);
};

class SymbolTable {
    public:
        string name;
        int tempCount;
        list<Symbol> table;
        SymbolTable* parent;
    
        SymbolTable(string name1 = "NULL");
    
        Symbol* lookup(string name);
        static Symbol* genTemp(SymbolType* t, string initValue = "");
    
        void print();
        void update();
};

class Quad {
    public:
        string op;
        string arg1;
        string arg2;
        string result;

        Quad(string res, string arg1_, string operation = "=", string arg2_ = "");
        Quad(string res, int arg1_, string operation = "=", string arg2_ = "");
        Quad(string res, float arg1_, string operation = "=", string arg2_ = "");

        void print();
};

class QuadArray {
    public:
        vector<Quad> quads;

        void print();
};

class Array {
    public:
        string atype;
        Symbol* loc;
        Symbol* Array;
        SymbolType* type;
};

class Statement {
    public:
        list<int> nextList;
};

class Expression {
    public:
        string type;
        Symbol* loc;
        list<int> trueList;
        list<int> falseList;
        list<int> nextList;
};

void emit(string op, string result, string arg1 = "", string arg2 = "");
void emit(string op, string result, int arg1, string arg2 = "");
void emit(string op, string result, float arg1, string arg2 = "");

list<int> makeList(int i);
list<int> merge(list<int> &p1, list<int> &p2);

void backpatch(list<int> l, int address);

bool typecheck(Symbol* &s1, Symbol* &s2);
bool typecheck(SymbolType* t1, SymbolType* t2);

Symbol* convertType(Symbol* s, string t);

string int2string(int i);
string float2string(float f);
Expression* int2bool(Expression* expr);
Expression* bool2int(Expression* expr);

void changeTable(SymbolTable* newTable);
int nextInstruction();
int sizeOfType(SymbolType* t);
string checkType(SymbolType* t);

// Global variables

extern Symbol* currentSymbol;
extern SymbolTable* currentST;
extern SymbolTable* globalST;
extern QuadArray quadList;
extern int STCount;
extern string blockName;
extern string varType;

extern char* yytext;
extern int yyparse();

#endif