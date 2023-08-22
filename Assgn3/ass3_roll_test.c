#include <stdio.h>

int main() {
    int x = 42;
    float pi = 3.14159;
    char ch = 'A';
    char *str = "Hello, world!";
    
    // This is a single-line comment
    
    /* This is a multi-line
       comment that spans
       multiple lines */
    
    int sum = x + 5;
    printf("Sum: %d\n", sum);
    
    if (x > 0) {
        printf("x is positive.\n");
    } else {
        printf("x is non-positive.\n");
    }
    
    for (int i = 0; i < 5; i++) {
        printf("Iteration %d\n", i);
    }
    
    return 0;
}
