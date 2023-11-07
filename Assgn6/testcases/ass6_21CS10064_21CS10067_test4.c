int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
int readFlt (float *eP);
int printFlt (float f);
//A program to calculate the nth catalan number using recursion
int catalan(int n) {
    if(n <= 1) {
        return 1;
    }
    int ans = 0;
    int i;
    for(i = 0; i < n; i = i + 1) {
        ans = ans + catalan(i) * catalan(n - i - 1);
    }
    return ans;
}
int main() {
    printStr("This program calculates the nth catalan number using recursion (Ensure the expected answer is within 2147483647)\n");
    printStr("Enter an integer: ");
    int n = readInt(&n);
    int ans = catalan(n);
    printStr("The answer is: ");
    printInt(ans);
    printStr("\n");
}
