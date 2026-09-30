float combine(float a, float b)
{
    float result;
    result = a ## b;
    return result;
}

int main(void)
{
    float x;
    float y;
    float z;

    x = 1.5;
    y = 2.5;
    z = combine(x, y);

    return 0;
}
