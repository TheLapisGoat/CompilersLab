int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
int readFlt (float *eP);
int printFlt (float f);
//A program to calculate the number of steps to reach 1 in the Collatz conjecture
int collatz(int n) {
    int ans = 0;
    while(n != 1) {
        if(n % 2 == 0) {
            n = n / 2;
        }
        else {
            n = 3 * n + 1;
        }
        ans = ans + 1;
    }
    return ans;
}
int main() {
    printStr("This program calculates the number of steps to reach 1 in the Collatz conjecture (Ensure the expected answer is within 2147483647)\n");
    printStr("Enter a positive integer: ");
    int n = readInt(&n);
    int ans = collatz(n);
    printStr("The number of steps is: ");
    printInt(ans);
    printStr("\n");
}
