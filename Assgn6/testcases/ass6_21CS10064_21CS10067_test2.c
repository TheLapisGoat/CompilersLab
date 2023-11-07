int printStr (char *ch);
int printInt (int n);
int readInt (int *eP);
int readFlt (float *eP);
int printFlt (float f);
//Sorts 8 numbers inputted by the user using bubble sort
int main() {
    int a[8];
    int i, j, temp;
    int n = 8;
    int eP;
    printStr("Enter 8 numbers to be sorted (using bubble sort): \n");
    for (i = 0; i < n; i++) {
        a[i] = readInt(&eP);
    }
    for (i = 0; i < n; i++) {
        for (j = 0; j < n - 1 - i; j++) {
            if (a[j] > a[j + 1]) {
                temp = a[j + 1];
                a[j + 1] = a[j];
                a[j] = temp;
            }
        }
    }
    printStr("The sorted array is: \n");
    for (i = 0; i < n; i++) {
        printInt(a[i]);
        printStr(" ");
    }
    printStr("\n");
    return 0;
}
