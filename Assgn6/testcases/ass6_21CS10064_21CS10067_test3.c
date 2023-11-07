int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
int readFlt (float *eP);
int printFlt (float f);
//A program to take 2 inputs and calculate the exponent of one wrt to other using fast exponentiation
int fast_expo(int a, int e) {
    int ans = 1;
    while(e > 0) {
        if(e % 2 == 1) {
            ans = ans * a;
        }
        a = a * a;
        e = e / 2;
    }
    return ans;
}
int main() {
    printStr("This program calculates the exponent of the base wrt the exponent (Ensure the expected answer is within 2147483647)\n");
    printStr("Enter an integer the base: ");
    int a = readInt(&a);
    printStr("Enter an integer the exponent: ");
    int e = readInt(&e);
    int ans = fast_expo(a, e);
    printStr("The answer is: ");
    printInt(ans);
    printStr("\n");
}
