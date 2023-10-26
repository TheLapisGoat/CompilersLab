int max (int x, int y) {
    int ans;
    if (x > y)                      
        ans = x;
    else
        ans = y;

    if(ans < 0)
        ans = -ans;
    return ans;
}


int min (int x, int y) {
    int ans;
    ans = x > y ? y:x;           
    return ans;
}

int main() {
    float *f1, **f2;
    f2 = &f1;
    f1 = *f2;
    *f1 = **f2;
    **f2 = *f1;
    return 0;
}