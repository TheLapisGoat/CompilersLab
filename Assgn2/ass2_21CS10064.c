#include "myl.h"                        // Header file for the library
#define BUFF 100                        // Buffer size for reading and writing

int printStr(char * str) {              // Prints the string str
    int len = 0;                        // Length of the string

    while(str[len] != '\0') {           // Calculate the length of the string
        len++;
    }

    __asm__ __volatile__ (              // System call to print the string
        "movl $1, %%eax \n\t"           // System call number 1
        "movq $1, %%rdi \n\t"           // File descriptor 1 (stdout)
        "syscall \n\t"                  // System call
        :                           
        :"S"(str), "d"(len)             // Pass the string and the length of the string
    );

    return len;                         // Return the length of the string
}

int readInt(int * n) {                  // Reads an integer from the standard input
    char buff[BUFF] = "";               // Buffer to store the input
    int i = 0, sign = 1;                // i is the index of the buffer, sign is the sign of the number
    int len = 0;                        // Length of the input

    __asm__ __volatile__ (              // System call to read the input
        "movl $0, %%eax \n\t"           // System call number 0
        "movq $0, %%rdi \n\t"           // File descriptor 0 (stdin)
        "syscall \n\t"                  // System call
        :"=a"(len)                      // Store the length of the input in len
        :"S"(buff), "d"(BUFF)           // Pass the buffer and the buffer size
    );

    if (len <= 0 || (buff[0] != '-' && (buff[0] < '0' || buff[0] > '9'))) {     // If the input is invalid
        return ERR;                                                             // Return error
    }

    if (buff[0] == '-') {               // If the number is negative
        sign = -1;                      // Set the sign to -1
        i = 1;                          // Set the index to 1
    }

    int number = 0;                     // The number read from the input

    while (i < len - 1) {               // While the index is less than the length of the input
        if (buff[i] < '0' || buff[i] > '9') {   // If the character is not a digit (except the last character, which is '\n')
            return ERR;                 // Return error
        }

        int digit = buff[i] - '0';      // Convert the character to an integer                      
        if (1L * number * 10 + digit > 2147483647 || 1L * number * 10 + digit < -2147483648) {      // If the number is out of range
            return ERR;                                                                             // Return error
        }

        number = number * 10 + digit;   // Add the digit to the number
        i++;                            // Increment the index
    }

    *n = number * sign;                 // Set the value of n to the number read from the input

    return OK;                          // Return OK
}

int printInt(int n) {                   // Prints the integer n
    char buff[BUFF] = "";               // Buffer to store the output
    int i = 0, j = 0, len = 0;          // i and j are buffer indices, len is the length of the output
    int sign = 1;                       // sign is the sign of the number

    if (n < 0) {                        // If the number is negative
        sign = -1;                      // Set the sign to -1
        n = -n;                         // Make the number positive
    }

    if (n == 0) {                       // If the number is 0
        buff[i++] = '0';                // Add '0' to the buffer
    }

    while (n > 0) {                     // While the number is greater than 0
        buff[i++] = n % 10 + '0';       // Add the last digit to the buffer
        n /= 10;                        // Remove the last digit from the number
    }

    if (sign == -1) {                   // If the number is negative
        buff[i++] = '-';                // Add '-' to the buffer
    }                                   

    len = i;                            // Set the length of the output to i
    i--;

    while (j < i) {                     // Reverse the buffer
        char temp = buff[j];            // Swap the characters at indices j and i
        buff[j] = buff[i];              
        buff[i] = temp;                     
        j++;
        i--;
    }

    __asm__ __volatile__ (              // System call to print the output
        "movl $1, %%eax \n\t"           // System call number 1
        "movq $1, %%rdi \n\t"           // File descriptor 1 (stdout)
        "syscall \n\t"                  // System call
        :
        :"S"(buff), "d"(len)            // Pass the buffer and the length of the output
    );

    return len;                         // Return the length of the output
}

int readFlt(float * f) {                // Reads a float from the standard input
    char buff[BUFF] = "";               // Buffer to store the input
    int i = 0, sign = 1;                // i is the index of the buffer, sign is the sign of the number
    int len = 0;                        // Length of the input

    __asm__ __volatile__ (              // System call to read the input
        "movl $0, %%eax \n\t"           // System call number 0
        "movq $0, %%rdi \n\t"           // File descriptor 0 (stdin)
        "syscall \n\t"                  // System call
        :"=a"(len)                      // Store the length of the input in len
        :"S"(buff), "d"(BUFF)           // Pass the buffer and the buffer size
    );

    if (len <= 0 || (buff[0] != '-' && buff[0] != '.' && (buff[0] < '0' || buff[0] > '9'))) {       // If the input is invalid
        return ERR;                                                                                 // Return error
    }

    if (buff[0] == '-') {               // If the number is negative
        sign = -1;                      // Set the sign to -1
        i = 1;                          // Set the index to 1
    }

    int number = 0;                     // The integer part of the number read from the input
    float decimal = 0;                  // The decimal part of the number
    int decimalFlag = 0;                // Flag to check if the decimal part has started
    int decimalcount = 0;               // Number of digits in the decimal part
    int decimaldiv = 1;                 // Divisor for the decimal part

    while (i < len) {                   // While the index is less than the length of the input
        if (buff[i] == '.') {           // If the character is a decimal point
            if (decimalFlag == 1) {     // If the decimal part has already started
                return ERR;             // Return error
            }
            decimalFlag = 1;            // Set the decimal flag to 1
            i++;                        // Increment the index
            continue;                   // Continue to the next iteration
        }

        if (buff[i] == '\n') {          // If the character is a newline
            break;                      // Break out of the loop
        }

        if (buff[i] < '0' || buff[i] > '9') {           // If the character is not a digit
            return ERR;                                 // Return error
        }

        int digit = buff[i] - '0';      // Convert the character to an integer
        if (decimalFlag == 0) {                                                                             // If the decimal part has not started
            if (1L * number * 10 + digit > 2147483647 || 1L * number * 10 + digit < -2147483648) {          // If the number is out of range
                return ERR;                                                                                 // Return error
            }
            number = number * 10 + digit;                                                                   // Add the digit to the number
        } else {                                                                                            // If the decimal part has started
            if (decimalcount < 6) {                                                                         // If the number of digits in the decimal part is less than 6
                decimaldiv *= 10;                                                                           // Multiply the divisor by 10
                decimal = decimal + (float) digit / decimaldiv;                                             // Add the digit to the decimal part
                decimalcount++;                                                                             // Increment the number of digits in the decimal part
            }
        }

        i++;                                                                                                // Increment the index
    }

    *f = number + decimal;                                                            // Set the value of f to the number read from the input
    *f *= sign;                                                                       // Multiply the value of f by the sign                        

    return OK;                                                                        // Return OK
}

int printFlt(float f) {                             // Prints the float f
    char buff[BUFF] = "";                           // Buffer to store the output
    int i = 0, j = 0, len = 0;                      // i and j are buffer indices, len is the length of the output
    int sign = 1;                                   // sign is the sign of the number

    if (f < 0) {                                    // If the number is negative
        sign = -1;                                  // Set the sign to -1
        f = -f;                                     // Make the number positive
    }

    if (f == 0) {                                   // If the number is 0
        buff[i++] = '0';                            // Add '0' to the buffer
    }

    int number = (int) f;                           // The integer part of the number
    int decimal = (int) ((f - number) * 1000000);   // The decimal part of the number (upto 6 decimal places)

    while (number > 0) {                            // While the number is greater than 0
        buff[i++] = number % 10 + '0';              // Add the last digit to the buffer
        number /= 10;                               // Remove the last digit from the number
    }

    if (sign == -1) {                               // If the number is negative
        buff[i++] = '-';                            // Add '-' to the buffer
    }

    len = i;                                        // Set the length of the output to i
    i--;                                            // Set i to the last index of the buffer

    while (j < i) {                                 // Reverse the buffer
        char temp = buff[j];                        // Swap the characters at indices j and i
        buff[j] = buff[i];
        buff[i] = temp;
        j++;
        i--;
    }

    if (decimal > 0) {                              // If the decimal part is greater than 0
        buff[len++] = '.';                          // Add '.' to the buffer
        for (int k = 0; k < 6; k++) {                       // Add the digits of the decimal part to the buffer
            buff[len + 5 - k] =  (decimal % 10) + '0';      // Add the last digit to the buffer
            decimal /= 10;                                  // Remove the last digit from the number
        }
        len += 6;                                   // Increment the length of the output by 6    
        while (buff[len - 1] == '0') {              // Remove trailing zeroes
            len--;                                  // Decrement the length of the output
        }
    }

    __asm__ __volatile__ (                      // System call to print the output
        "movl $1, %%eax \n\t"                   // System call number 1
        "movq $1, %%rdi \n\t"                   // File descriptor 1 (stdout)
        "syscall \n\t"                          // System call
        :
        :"S"(buff), "d"(len)                    // Pass the buffer and the length of the output
    );

    return len;                                 // Return the length of the output
}