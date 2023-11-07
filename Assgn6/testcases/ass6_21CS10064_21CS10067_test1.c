int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
int readFlt (float *eP);
int printFlt (float f);
//Calculates the sum of the first n natural numbers
int main() {
    printStr("Enter a number: ");
    int n, z;
    float x = 1.31312;
    n = readInt(&z);
    printStr("The number entered is: ");
    printInt(n);
    int sum = 0;
    int i, k;
    for (i = 0; i < n; i++) {
        k = i + 1;
        sum = sum + k;
    }
    printStr("\nThe sum of first ");
    printInt(n);
    printStr(" natural numbers is: ");
    printInt(sum);
    printStr("\n");
    return 0;
}
