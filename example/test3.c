int main(void)
{
    int x;
    int sum;

    x = 0;
    sum = 0;

    while (x < 5) {
        if (x != 3) {
            sum = sum + x;
        } else {
            sum = sum + 10;
        }
        x = x + 1;
    }

    printf("sum = %d\n", sum);
    return 0;
}
