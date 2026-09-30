# C Subset Definition

This document describes the C language subset supported by the compiler.

## Data Types

The following data types are supported:

- `int`
- `float`
- `void`

## Variable Declaration

Variable declarations are supported:

```c
int a;
float b;
```

## Arrays

One-dimensional arrays are supported:

```c
int nums[5];
nums[0] = 10;
```

## Arithmetic Expressions

The following arithmetic operators are supported:

- `+`
- `-`
- `*`
- `/`

Example:

```c
a = b + c * 2 - d / 4;
```

## Comparison Expressions

The following comparison operators are supported:

- `>`
- `<`
- `>=`
- `<=`
- `==`
- `!=`

Example:

```c
if (a > b)
```

## Assignment Statements

Assignment statements are supported:

```c
a = 10;
sum = sum + i;
```

## Conditional Statements

`if` statements are supported:

```c
if (...)
{
    ...
}
```

`if-else` statements are also supported:

```c
if (...)
{
    ...
}
else
{
    ...
}
```

Multiple levels of nested `if` statements are supported.

## Iteration Statements

`while` loops are supported:

```c
while (...)
{
    ...
}
```

Nested `while` loops are also supported.

## Functions

The following function-related features are supported:

- Function declarations
- Function parameters
- Function calls
- `return` statements

Example:

```c
int add(int a, int b)
{
    return a + b;
}
```

## Input / Output

The compiler supports `printf()` with integer, floating-point, and string output:

```c
printf("Hello\n");
printf("x = %d\n", x);
printf("y = %f\n", y);
```

The compiler also supports `scanf()` with `%d` and `%f`:

```c
scanf("%d", &x);
scanf("%f", &y);
```

## Custom Operator

The compiler supports the custom `##` operator specified by the course:

```c
a ## b
```

The implementation of this operator is provided by the runtime library:

```text
myRuntime.c
```

## Semantic Checking

The compiler supports the following static semantic checks:

- Undeclared Identifier Checking
- Redeclaration Checking
- Type Mismatch Checking
- Function Parameter Checking
- Return Type Checking
- Array Checking