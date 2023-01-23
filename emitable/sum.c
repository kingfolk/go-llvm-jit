typedef long long int64_t;
typedef double float64_t;

int64_t sum_int64(int64_t a[], int count) {
    int64_t res = 0;
    for (int i = 0; i < count; i ++) {
        res += a[i];
    }
    return res;
}

float64_t sum_float64(float64_t a[], int count) {
    float64_t res = 0;
    for (int i = 0; i < count; i ++) {
        res += a[i];
    }
    return res;
}
