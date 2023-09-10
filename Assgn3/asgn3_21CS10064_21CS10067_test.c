#include <stdio.h>
// This is a comment
// Define an enum
enum Day
{
    SUNDAY,
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY
};

// Define a structure
struct Point
{
    int x;
    int y;
};

// Define a function
int add(int a, int b)
{
    return a + b;
}

int main()
{
    int num = 42;
    float pi = 3.14159;
    char initial = 'C';
    char str[] = "Hello, world!";

    int octalNum = 0123;
    int hexNum = 0xABCD;

    if (num == 42 && pi < 4.0)
    {
        printf("Conditions met!\n");
    }

    switch (initial)
    {
    case 'A':
        printf("Initial is A\n");
        break;
    case 'B':
        printf("Initial is B\n");
        break;
    default:
        printf("Initial is neither A nor B\n");
    }

    do
    {
        num++;
    } while (num < 42);

    int *ptr = NULL;
    if (!ptr)
    {
        printf("Pointer is NULL\n");
    }

    int array[5] = {1, 2, 3, 4, 5};
    int sum = 0; // Initialize sum

    // Calculate the sum of array elements
    for (int i = 0; i < 5; i++)
    {
        sum += array[i];
    }

    printf("Sum of array: %d\n", sum);

    int x = 5, y = 0;
    // int z = x / y; // This line will cause a division by zero error

    printf("Sum: %d\n", add(5, 7)); // Calling the defined function

    // Using the auto keyword
    auto autoPi = 3.14159;
    printf("Auto Pi: %f\n", autoPi);

    // Using the structure
    struct Point p;
    p.x = 10;
    p.y = 20;
    printf("Point: x = %d, y = %d\n", p.x, p.y);

    // Using the enum
    enum Day today = FRIDAY;
    printf("Today is day number %d\n", today);

    return 0;
}

/*
    This
        is
            also
                a
                    comment
                            */