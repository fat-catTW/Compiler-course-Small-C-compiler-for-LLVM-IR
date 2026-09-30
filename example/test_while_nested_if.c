int main(void)
{
    int i;
    int sum;

    i = 0;
    sum = 0;

    while (i < 6) {
        if (i == 3) {
            sum = sum + 10;
        } else {
            sum = sum + i;
        }
        i = i + 1;
    }

    printf("sum = %d\n", sum);
    return 0;
}
