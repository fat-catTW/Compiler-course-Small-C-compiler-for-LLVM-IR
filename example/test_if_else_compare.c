int main(void)
{
    int a;
    int b;
    int max;

    a = 8;
    b = 12;

    if (a >= b)
    {
        if (a != 0)
        {
            max = a;
        }
    }
    else
    {
        if (b != 0)
        {
            max = b;
        }
    }

    if (max != 0)
    {
        printf("max = %d\n", max);
    }

    return 0;
}