#include <stdio.h>

// This is a comment
int main() {
    int num = 42;
    float pi = 3.14159;
    char initial = 'C';
    char str[] = "Hello, world!";
    
    int octalNum = 0123;
    int hexNum = 0xABCD;
    
    if (num == 42 && pi < 4.0) {
        printf("Conditions met!\n");
    }
    
    switch (initial) {
        case 'A':
            printf("Initial is A\n");
            break;
        case 'B':
            printf("Initial is B\n");
            break;
        default:
            printf("Initial is neither A nor B\n");
    }
    
    do {
        num++;
    } while (num < 42);
    
    int *ptr = NULL;
    if (!ptr) {
        printf("Pointer is NULL\n");
    }

    int array[5] = {1, 2, 3, 4, 5};
    int sum = -1;
    
    printf("Sum of array: %d\n", sum);

    int x = 5, y = 0;
    int z = x / y;                      //Div by Zero

    printf("Sum: %d\n", add(5, 7));     //Calling function that isn't defined
    
    return 0;
}
/* 
    This 
        is 
            also 
                a 
                    comment
                            */