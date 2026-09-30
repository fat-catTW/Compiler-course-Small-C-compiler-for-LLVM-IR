int main(void)
{
    int nums[5];
    int i;
    int sum;

    nums[0] = 1;
    nums[1] = 2;
    nums[2] = 3;
    nums[3] = 4;
    nums[4] = 5;

    i = 0;
    sum = 0;

    while (i < 5) {
        sum = sum + nums[i];
        i = i + 1;
    }

    printf("array sum = %d\n", sum);
    return 0;
}
