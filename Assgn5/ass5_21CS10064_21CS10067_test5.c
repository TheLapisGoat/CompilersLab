int main() {
    int i, j, k;

    // for loop
    for(i = 0; i < j; i++) {
        j = i;
    }

    // while loop
    while(i < j) {
        j = i;
    }

    // do while loop
    do {
        i = k++;
        // nested while
        while(i < j)
            j--;
    }while(k <= 10);

    // if else
    if (i > j) {
        k = j;
    }

    return 0;
}