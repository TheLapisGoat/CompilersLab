#include "ass6_21CS10064_21CS10067_translator.h"
#include <fstream>
#include <sstream>
#include <stack>
using namespace std;

// External variables
extern symbolTable globalST;
extern symbolTable* currentST;
extern quadArray quadList;

// Declare global variables
vector<string> string_constants;
map<int, string> labels;
stack<pair<string, int>> parameters;
int labelCount = 0;
string funcRunning = "";
string asmFileName;


// Prints the global information to the assembly file
void printGlobal(ofstream& assembly_file) {
    for(auto it = globalST.symbols.begin(); it != globalST.symbols.end(); it++) {
        symbol* sym = *it;
        if(sym->type.type == CHAR && sym->name[0] != 't') {
            if(sym->initVal != NULL) {
                assembly_file << "\t.globl\t" << sym->name << endl;
                assembly_file << "\t.data" << endl;
                assembly_file << "\t.type\t" << sym->name << ", @object" << endl;
                assembly_file << "\t.size\t" << sym->name << ", 1" << endl;
                assembly_file << sym->name << ":" << endl;
                assembly_file << "\t.byte\t" << sym->initVal->c << endl;
            }
            else
                assembly_file << "\t.comm\t" << sym->name << ",1,1" << endl;
        }
        else if(sym->type.type == INT && sym->name[0] != 't') {
            if(sym->initVal != NULL) {
                assembly_file << "\t.globl\t" << sym->name << endl;
                assembly_file << "\t.data" << endl;
                assembly_file << "\t.align\t4" << endl;
                assembly_file << "\t.type\t" << sym->name << ", @object" << endl;
                assembly_file << "\t.size\t" << sym->name << ", 4" << endl;
                assembly_file << sym->name << ":" << endl;
                assembly_file << "\t.long\t" << sym->initVal->i << endl;
            }
            else
                assembly_file << "\t.comm\t" << sym->name << ",4,4" << endl;
        }
    }
}

// Prints all the strings used in the program to the assembly file
void printStrings(ofstream& assembly_file) {
    assembly_file << ".section\t.rodata" << endl;
    int i = 0;
    for(auto it = string_constants.begin(); it != string_constants.end(); it++) {
        assembly_file << ".LC" << i++ << ":" << endl;
        assembly_file << "\t.string " << *it << endl;
    }
}

// Generates labels for different targets of goto statements
void setLabels() {
    int i = 0;
    for(auto it = quadList.quads.begin(); it != quadList.quads.end(); it++) {
        if(it->op == GOTO || (it->op >= GOTO_EQ && it->op <= IF_FALSE_GOTO)) {
            int target = atoi((it->result.c_str()));
            if(!labels.count(target)) {
                string labelName = ".L" + to_string(labelCount++);
                labels[target] = labelName;
            }
            it->result = labels[target];
        }
    }
}

// Generates the function prologue to be printed before each function
void generatePrologue(int memBind, ofstream& assembly_file) {
    int width = 16;
    assembly_file << endl << "\t.text" << endl;
    assembly_file << "\t.globl\t" << funcRunning << endl;
    assembly_file << "\t.type\t" << funcRunning << ", @function" << endl;
    assembly_file << funcRunning << ":" << endl;
    assembly_file << "\tpushq\t" << "%rbp" << endl;
    assembly_file << "\tmovq\t" << "%rsp, %rbp" << endl;
    assembly_file << "\tsubq\t$" << (memBind / width + 1) * width << ", %rsp" << endl;
}

// Generates assembly code for a given three address quad
void quadCode(quad q, ofstream& assembly_file) {
    string strLabel = q.result;
    bool hasStrLabel = (q.result[0] == '.' && q.result[1] == 'L' && q.result[2] == 'C');
    string toPrint1 = "", toPrint2 = "", toPrintRes = "";
    int off1 = 0, off2 = 0, offRes = 0;

    symbol* loc1 = currentST->lookup(q.arg1);
    symbol* loc2 = currentST->lookup(q.arg2);
    symbol* loc3 = currentST->lookup(q.result);
    symbol* glb1 = globalST.searchGlobal(q.arg1);
    symbol* glb2 = globalST.searchGlobal(q.arg2);
    symbol* glb3 = globalST.searchGlobal(q.result);

    if(currentST != &globalST) {
        if(glb1 == NULL)
            off1 = loc1->offset;
        if(glb2 == NULL)
            off2 = loc2->offset;
        if(glb3 == NULL)
            offRes = loc3->offset;

        if(q.arg1[0] < '0' || q.arg1[0] > '9') {
            if(glb1 != NULL)
                toPrint1 = q.arg1 + "(%rip)";
            else
                toPrint1 = to_string(off1) + "(%rbp)";
        }
        if(q.arg2[0] < '0' || q.arg2[0] > '9') {
            if(glb2 != NULL)
                toPrint2 = q.arg2 + "(%rip)";
            else
                toPrint2 = to_string(off2) + "(%rbp)";
        }
        if(q.result[0] < '0' || q.result[0] > '9') {
            if(glb3 != NULL)
                toPrintRes = q.result + "(%rip)";
            else
                toPrintRes = to_string(offRes) + "(%rbp)";
        }
    }
    else {
        toPrint1 = q.arg1;
        toPrint2 = q.arg2;
        toPrintRes = q.result;
    }

    if(hasStrLabel)
        toPrintRes = strLabel;

    if(q.op == ASSIGNMENT) {
        if(q.result[0] != 't' || loc3->type.type == INT || loc3->type.type == POINTER) {
            if(loc3->type.type != POINTER) {
                if(q.arg1[0] < '0' || q.arg1[0] > '9')
                {
                    assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
                    assembly_file << "\tmovl\t%eax, " << toPrintRes << endl; 
                }
                else
                    assembly_file << "\tmovl\t$" << q.arg1 << ", " << toPrintRes << endl;
            }
            else {
                assembly_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
                assembly_file << "\tmovq\t%rax, " << toPrintRes << endl; 
            }
        }
        else {
            int temp = q.arg1[0];
            assembly_file << "\tmovb\t$" << temp << ", " << toPrintRes << endl;
        }
    }
    else if(q.op == U_MINUS) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tnegl\t%eax" << endl;
        assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == ADD) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            assembly_file << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            assembly_file << "\tmovl\t$" << q.arg2 << ", %edx" << endl;
        else
            assembly_file << "\tmovl\t" << toPrint2 << ", %edx" << endl; 
        assembly_file << "\taddl\t%edx, %eax" << endl;
        assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == SUB) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            assembly_file << "\tmovl\t$" << q.arg1 << ", %edx" << endl;
        else
            assembly_file << "\tmovl\t" << toPrint1 << ", %edx" << endl; 
        if(q.arg2[0]>'0' && q.arg2[0]<='9')
            assembly_file << "\tmovl\t$" << q.arg2 << ", %eax" << endl;
        else
            assembly_file << "\tmovl\t" << toPrint2 << ", %eax" << endl; 
        assembly_file << "\tsubl\t%eax, %edx" << endl;
        assembly_file << "\tmovl\t%edx, %eax" << endl;
        assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == MULT) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            assembly_file << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        assembly_file << "\timull\t";
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            assembly_file << "$" << q.arg2 << ", %eax" << endl;
        else
            assembly_file << toPrint2 << ", %eax" << endl;
        assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == DIV) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    else if(q.op == MOD) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        assembly_file << "\tmovl\t%edx, " << toPrintRes << endl;
    }
    else if(q.op == GOTO)
        assembly_file << "\tjmp\t" << q.result << endl;
    else if(q.op == GOTO_LT) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjge\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_GT) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjle\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjl\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_LTE) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjg\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjl\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_EQ) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        if(q.arg2[0] >= '0' && q.arg2[0] <= '9')
            assembly_file << "\tcmpl\t$" << q.arg2 << ", %eax" << endl;
        else
            assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tjne\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == GOTO_NEQ) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        assembly_file << "\tje\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == IF_GOTO) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t$0" << ", %eax" << endl;
        assembly_file << "\tje\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == IF_FALSE_GOTO) {
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tcmpl\t$0" << ", %eax" << endl;
        assembly_file << "\tjne\t.L" << labelCount << endl;
        assembly_file << "\tjmp\t" << q.result << endl;
        assembly_file << ".L" << labelCount++ << ":" << endl;
    }
    else if(q.op == ARR_INDEXING) {
        assembly_file << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        assembly_file << "cltq" << endl;
        if(off1 < 0) {
            assembly_file << "\tmovl\t" << off1 << "(%rbp,%rdx,1), %eax" << endl;
            assembly_file << "\tmovl\t%eax, " << toPrintRes << endl;
        }
        else {
            assembly_file << "\tmovq\t" << off1 << "(%rbp), %rdi" << endl;
            assembly_file << "\taddq\t%rdi, %rdx" << endl;
            assembly_file << "\tmovq\t(%rdx) ,%rax" << endl;
            assembly_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == ARR_ASSIGNMENT) {
        assembly_file << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "cltq" << endl;
        if(offRes > 0) {
            assembly_file << "\tmovq\t" << offRes << "(%rbp), %rdi" << endl;
            assembly_file << "\taddq\t%rdi, %rdx" << endl;
            assembly_file << "\tmovl\t%eax, (%rdx)" << endl;
        }
        else
            assembly_file << "\tmovl\t%eax, " << offRes << "(%rbp,%rdx,1)" << endl;
    }
    else if(q.op == REFERENCE) {
        if(off1 < 0) {
            assembly_file << "\tleaq\t" << toPrint1 << ", %rax" << endl;
            assembly_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
        else {
            assembly_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
            assembly_file << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == DEREFERENCE) {
        assembly_file << "\tmovq\t" << toPrint1 << ", %rax" << endl;
        assembly_file << "\tmovq\t(%rax), %rdx" << endl;
        assembly_file << "\tmovq\t%rdx, " << toPrintRes << endl;
    }
    else if(q.op == L_DEREF) {
        assembly_file << "\tmovq\t" << toPrintRes << ", %rdx" << endl;
        assembly_file << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        assembly_file << "\tmovl\t%eax, (%rdx)" << endl;
    }
    else if(q.op == PARAM) {
        int paramSize;
        DataType t;
        if(glb3 != NULL)
            t = glb3->type.type;
        else
            t = loc3->type.type;
        if(t == INT)                                
            paramSize = 4;                  //INT Size = 4
        else if(t == CHAR)
            paramSize = 1;                  //CHAR Size = 1
        else
            paramSize = 8;                  //POINTER Size = 8
        stringstream ss;
        if(q.result[0] == '.')
            ss << "\tmovq\t$" << toPrintRes << ", %rax" <<endl;
        else if(q.result[0] >= '0' && q.result[0] <= '9')
            ss << "\tmovq\t$" << q.result << ", %rax" <<endl;
        else {
            if(loc3->type.type != ARRAY) {
                if(loc3->type.type != POINTER)
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
                else if(loc3 == NULL)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
            }
            else {
                if(offRes < 0)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else {
                    ss << "\tmovq\t" << offRes << "(%rbp), %rdi" <<endl;
                    ss << "\tmovq\t%rdi, %rax" <<endl;
                }
            }
        }
        parameters.push(make_pair(ss.str(), paramSize));
    }
    else if(q.op == CALL) {
        int numParams = atoi(q.arg1.c_str());
        int totalSize = 0, k = 0;

        // We need different registers based on the parameters
        if(numParams > 6) {
            for(int i = 0; i < numParams - 6; i++) {
                string s = parameters.top().first;
                assembly_file << s << "\tpushq\t%rax" << endl;
                totalSize += parameters.top().second;
                parameters.pop();
            }
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
            totalSize += parameters.top().second;				
            parameters.pop();
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
            assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
            totalSize += parameters.top().second;
            parameters.pop();
        }
        else {
            while(!parameters.empty()) {
                if(parameters.size() == 6) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 5) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 4) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 3) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 2) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
                else if(parameters.size() == 1) {
                    assembly_file << parameters.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
                    totalSize += parameters.top().second;
                    parameters.pop();
                }
            }
        }
        assembly_file << "\tcall\t" << q.result << endl;
        if(q.arg2 != "")
            assembly_file << "\tmovq\t%rax, " << toPrint2 << endl;
        assembly_file << "\taddq\t$" << totalSize << ", %rsp" << endl;
    }
    else if(q.op == RETURN) {
        if(q.result != "")
            assembly_file << "\tmovq\t" << toPrintRes << ", %rax" << endl;
        assembly_file << "\tleave" << endl;
        assembly_file << "\tret" << endl;
    }

}

// Main function which calls all other relevant functions for generating the target assembly code
void generateTargetCode(ofstream& assembly_file) {
    printGlobal(assembly_file);
    printStrings(assembly_file);
    symbolTable* currFuncTable = NULL;
    symbol* currFunc = NULL;
    setLabels();

    for(int i = 0; i < (int)quadList.quads.size(); i++) {
        // Print the quad as a comment in the assembly file
        assembly_file << "# " << quadList.quads[i].print() << endl;
        if(labels.count(i))
            assembly_file << labels[i] << ":" << endl;

        // Necessary tasks for a function
        if(quadList.quads[i].op == FUNC_BEG) {
            i++;
            if(quadList.quads[i].op != FUNC_END)
                i--;
            else
                continue;
            currFunc = globalST.searchGlobal(quadList.quads[i].result);
            currFuncTable = currFunc->nestedTable;
            int takingParam = 1, memBind = 16;
            currentST = currFuncTable;
            for(int j = 0; j < (int)currFuncTable->symbols.size(); j++) {
                if(currFuncTable->symbols[j]->name == "RETVAL") {
                    takingParam = 0;
                    memBind = 0;
                    if(currFuncTable->symbols.size() > j + 1)
                        memBind = -currFuncTable->symbols[j + 1]->size;
                }
                else {
                    if(!takingParam) {
                        currFuncTable->symbols[j]->offset = memBind;
                        if(currFuncTable->symbols.size() > j + 1)
                            memBind -= currFuncTable->symbols[j + 1]->size;
                    }
                    else {
                        currFuncTable->symbols[j]->offset = memBind;
                        memBind += 8;
                    }
                }
            }
            if(memBind >= 0)
                memBind = 0;
            else
                memBind *= -1;
            funcRunning = quadList.quads[i].result;
            generatePrologue(memBind, assembly_file);
        }

        // Function epilogue (while leaving a function)
        else if(quadList.quads[i].op == FUNC_END) {
            currentST = &globalST;
            funcRunning = "";
            assembly_file << "\tleave" << endl;
            assembly_file << "\tret" << endl;
            assembly_file << "\t.size\t" << quadList.quads[i].result << ", .-" << quadList.quads[i].result << endl;
        }

        if(funcRunning != "")
            quadCode(quadList.quads[i], assembly_file);
    }
}

int main(int argc, char* argv[]) {
    currentST = &globalST;
    yyparse();

    asmFileName = "assembly_files/ass6_21CS10064_21CS10067_" + string(argv[argc - 1]) + ".s";
    ofstream assembly_file;
    assembly_file.open(asmFileName);

    quadList.print();               // Print the three address quads

    currentST->print("ST.global");         // Print the symbol tables

    currentST = &globalST;

    generateTargetCode(assembly_file);      // Generate the target assembly code

    assembly_file.close();

    return 0;
}
