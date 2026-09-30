# Small C Compiler for LLVM IR

A small C subset compiler built with **ANTLR4** and **Java** that translates C subset programs into **LLVM Intermediate Representation (LLVM IR)**.

The compiler implements lexical analysis, syntax analysis, static semantic checking, and LLVM IR code generation. The generated LLVM IR can be compiled and executed using **LLVM/Clang**.

This project was developed as the final project for the Compiler Design course at National Chung Cheng University.

## Features

### Basic Language Features

- Data types
  - `int`
  - `float`
  - `void`
- Arithmetic operators
  - `+`
  - `-`
  - `*`
  - `/`
- Comparison operators
  - `>`
  - `>=`
  - `<`
  - `<=`
  - `==`
  - `!=`
- Conditional statements
  - `if`
  - `if-else`
- Input / Output
  - `printf()` with `%d`, `%f`, and string literals
  - `scanf()` with `%d` and `%f`
- Custom `##` operator

### Extended Language Features

- `while` loops
- Nested `while` loops
- Nested `if` statements
- Combined `while` and `if-else` control flow
- User-defined functions
- Function calls
- One-dimensional arrays
- Array element access

## Static Semantic Analysis

The compiler maintains symbol tables and scopes to perform static semantic checking.

Supported checks include:

- Undeclared identifier detection
- Redeclaration detection
- Type mismatch checking
- Function parameter checking
- Function return type checking
- Array-related checking
- Unused variable warnings

## Custom `##` Operator

The compiler implements a custom floating-point operator:

```c
a ## b
```

The operator is implemented through the runtime library in:

```text
myRuntime.c
```

For example:

```c
float result;

result = 1.5 ## 2.5;
```

The compiler generates an LLVM IR call to the runtime implementation of the operator.

## Project Structure

```text
.
├── example/                     # Test programs and generated LLVM IR
├── antlr-4.13.2-complete.jar    # ANTLR4
├── myCompiler.g4                # ANTLR grammar and compiler implementation
├── myCompiler_test.java         # Compiler driver
├── myRuntime.c                  # Runtime library for custom operations
├── Makefile
├── C_Subset.pdf                 # Definition of the supported C subset
└── README.pdf                   # Course project documentation
```

## Build

### Linux / WSL

Generate the ANTLR lexer/parser and compile the Java source code:

```bash
make
```

### Run the Compiler

```bash
make run FILE=example/test3.c
```

### Generate LLVM IR

```bash
make ll FILE=example/test3.c
```

This generates:

```text
example/test3.ll
```

To generate LLVM IR for all test programs in the `example` directory:

```bash
make examples
```

## Compile and Execute Generated LLVM IR

The generated LLVM IR can be compiled with Clang together with the runtime library:

```bash
clang example/test3.ll myRuntime.c -o test3
```

Run the executable:

```bash
./test3
```

For example:

```text
sum = 17
```

This verifies the complete compilation pipeline:

```text
C Subset Source Code
        ↓
   ANTLR4 Lexer
        ↓
   ANTLR4 Parser
        ↓
 Semantic Analysis
        ↓
LLVM IR Generation
        ↓
      Clang
        ↓
   Executable
```

## Windows

Generate the lexer and parser:

```powershell
java -jar antlr-4.13.2-complete.jar myCompiler.g4
```

Compile the Java source code:

```powershell
javac -cp ".;antlr-4.13.2-complete.jar" myCompiler*.java myCompiler_test.java
```

Run the compiler:

```powershell
java -cp ".;antlr-4.13.2-complete.jar" myCompiler_test example/test3.c
```

Generate LLVM IR:

```powershell
java -cp ".;antlr-4.13.2-complete.jar" myCompiler_test example/test3.c > example/test3.ll
```

## Test Programs

The `example/` directory contains test programs covering different compiler features and semantic checks.

Examples include:

| Test | Purpose |
|---|---|
| `test_array.c` | One-dimensional array operations |
| `test_arrayIndex.c` | Invalid array index checking |
| `test_funcParam.c` | Function parameter type checking |
| `test_funcReturn.c` | Function return type checking |
| `test_function_hashhash.c` | Custom `##` operator |
| `test_if_else_compare.c` | Conditional and comparison operations |
| `test_redeclare.c` | Redeclaration detection |
| `test_scanf_printf.c` | `scanf()` and `printf()` |
| `test_semantic_error.c` | Undeclared identifier detection |
| `test_typeMismatch.c` | Type mismatch detection |
| `test_while_nest_while.c` | Nested `while` loops |
| `test_while_nested_if.c` | `while` loop with nested `if-else` |

## Technologies

- Java
- ANTLR 4.13.2
- LLVM IR
- Clang
- C Runtime Library

## Author

**Vincent Hsiao**  
National Chung Cheng University  
Department of Information Management