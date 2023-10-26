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
/* struct Point
{
    int x;
    int y;
}; */

// Define a function
int add(int *restrict p1, const int p2, volatile int p3, ...)
{
    auto int a;
    register int b;
    extern int c;
    static int d = 4;
    return 12;
}

void hehe(int b[const static 8], int c[static 9], int d[], int e[const *]);

int main()
{
    int num = 42;
    float pi = 3.14159;
    char initial = 'C';
    char final = 'ABC';
    char str[] = "Hello, world!\n";


    int t1, t2, t3, t4, t5;
    t2 = t2 >> 2;
    //int octalNum = 0123;
    //int hexNum = 0xABCD;

    if (num == 42 && pi < 4.0)
    {
        printf("Conditions Met!\n");
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
    float n3 = -3.53;

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

    a += (n1 -= n1);
    // Using the structure
    /*struct Point p;
    p.x = 10;
    p.y = 20;
    printf("Point: x = %d, y = %d\n", p.x, p.y);*/

    // Using the enum
    enum Day today = FRIDAY;
    printf("Today is day number %d\n", today);

    char *c2 = &c1;
    *c2 = 'a';
    char **d = (char) { "a", b, "abc" };

    unsigned long n1 = +123456789;
    short n2 = ~16;
    double n4 = 2.99e-2;
    _Bool n5 = !1;
    double _Imaginary n7;

    h1 = (int) c;
    hehe = sizeof(int);
    h2 = sizeof n1;

    c &= n1 |= n1 ^= n1;
    c = ( (n1==0 || n1==1) && n1!=n2 ) ? n1 = 0 : n2;

    a[n2] = n1;

    TEMP:
        if (n1 < n2) {

            switch (n2) {
                case 0:
                    n2++;
                    break;
                default:
                    n2--;
            }

        } else if (n1 > n2) {
            if(n2 >= n1)
                n1++;
        } else {
            if(n2 <= n1)
                n2++;
        }

    while(n2--)
        goto TEMP;

    b <<= (n1 >>= n1);

    t1 = t2 & t3 | t4 ^ t5;

    return 0;
}

/*
    This
        is
            also
                a
                    comment
                            */