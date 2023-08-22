#include "myl.h"                                                    // Header file for my library

int main() {                                                        
    printStr("1. Testing printStr function\n");                     // Testing printStr function
    char * newline = "\n";
    char * sample_strings[4] = {                                    // Sample strings to test
        "Sourodeep Datta",
        "",
        "abcdefghijklmnopqrstuvwxyz",
        "123 Hello World 456 Goodbye World 789 @@@@ #### %%%% ^^^^ \t \t \t &&&& ** (()) )))) (((( "
    };

    for (int i = 0; i < 4; i++) {                                       // Printing the strings
        int len = printStr(sample_strings[i]);
        printStr(newline);
        printStr("Number of characters printed: ");
        printInt(len);
        printStr(newline);
        printStr(newline);
    }

    printStr("2. Testing printInt function\n");                         // Testing printInt function
    int sample_ints[4] = {                                              // Sample integers to test
        0,
        1,
        -1,
        2147483647
    };

    for (int i = 0; i < 4; i++) {                                    // Printing the integers
        int len = printInt(sample_ints[i]);     
        printStr(newline);  
        printStr("Number of characters printed: ");
        printInt(len);
        printStr(newline);
        printStr(newline);
    }

    printStr("3. Testing printFlt function\n");                         // Testing printFlt function
    float sample_floats[4] = {                                          // Sample floats to test
        0.0,
        1.0158,
        -1.0218,
        3.141592653589793238462643383279502884197169399375105820974944592307816406286
    };

    for (int i = 0; i < 4; i++) {                                       // Printing the floats
        int len = printFlt(sample_floats[i]);
        printStr(newline);
        printStr("Number of characters printed: ");
        printInt(len);
        printStr(newline);
        printStr(newline);
    }

    printStr("4. Testing readInt function\n");                          // Testing readInt function

    int cont = 1;                                                       // Variable to continue or stop the loop
    
    while (cont) {
        printStr("Enter an integer: ");                                 // Taking input from user
        int n;
        int status = readInt(&n);
        if (status == ERR) {                                            // If input is invalid
            printStr("Invalid input. Please try again.\n");             // Print error message
        } else {                                                        // If input is valid
            printStr("You entered: ");                                  
            printInt(n);                                                // Print the integer
            printStr(newline);
        }
        printStr("Do you want to continue? (1 to continue / 0 to stop): ");     // Asking user if they want to continue 
        readInt(&cont);
        printStr(newline);
    }

    printStr("5. Testing readFlt function\n");                          // Testing readFlt function

    cont = 1;                                                           // Variable to continue or stop the loop

    while (cont) {                                                      
        printStr("Enter a float: ");                                    // Taking input from user
        float f;
        int status = readFlt(&f);
        if (status == ERR) {                                            // If input is invalid
            printStr("Invalid input. Please try again.\n");             // Print error message
        } else {                                                        // If input is valid
            printStr("You entered: ");                                  // Print the float
            printFlt(f);
            printStr(newline);
        }
        printStr("Do you want to continue? (1 to continue / 0 to stop): ");     // Asking user if they want to continue
        readInt(&cont);
        printStr(newline);
    }

}