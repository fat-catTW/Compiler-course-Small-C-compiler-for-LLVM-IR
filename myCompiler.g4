grammar myCompiler;

options { language = Java; }

@header {
import java.util.*;
}

@members {
    boolean TRACEON = false;
    boolean PRINT_SYMBOL_TABLE = false;

    enum Type { INT, FLOAT, VOID, BOOL, ERROR }

    static class Symbol {
        String name;
        Type type;
        boolean isArray;
        boolean isFunction;
        boolean used;
        int declaredLine;
        ArrayList<Type> params = new ArrayList<Type>();
        String ptrName;
        int arraySize = 0;

        Symbol(String name, Type type, boolean isArray, boolean isFunction, int declaredLine) {
            this.name = name;
            this.type = type;
            this.isArray = isArray;
            this.isFunction = isFunction;
            this.used = false;
            this.declaredLine = declaredLine;
        }
    }

    ArrayList<HashMap<String, Symbol>> scopes = new ArrayList<HashMap<String, Symbol>>();
    ArrayList<HashMap<String, Symbol>> allScopes = new ArrayList<HashMap<String, Symbol>>();

    Type currentFunctionReturnType = Type.VOID;
    String currentFunctionName = "";
    boolean currentFunctionHasReturn = false;

    int errorCount = 0;
    int warningCount = 0;
    int tempCount = 0;
    int labelCount = 0;
    int strCount = 0;

    ArrayList<String> globalIR = new ArrayList<String>();
    ArrayList<String> ir = new ArrayList<String>();
    ArrayList<String> outputIR = new ArrayList<String>();

    final String RED = "\u001B[31m";
    final String YELLOW = "\u001B[33m";
    final String GREEN = "\u001B[32m";
    final String BLUE = "\u001B[34m";
    final String RESET = "\u001B[0m";

    void enterScope() {
        HashMap<String, Symbol> scope = new HashMap<String, Symbol>();
        scopes.add(scope);
        allScopes.add(scope);
    }

    void exitScope() {
        if (scopes.size() > 0) {
            checkUnusedVariables(scopes.get(scopes.size() - 1));
            scopes.remove(scopes.size() - 1);
        }
    }

    HashMap<String, Symbol> currentScope() {
        if (scopes.size() == 0) enterScope();
        return scopes.get(scopes.size() - 1);
    }

    Symbol lookupCurrentScope(String name) { return currentScope().get(name); }

    Symbol lookup(String name) {
        for (int i = scopes.size() - 1; i >= 0; i--) {
            Symbol s = scopes.get(i).get(name);
            if (s != null) return s;
        }
        return null;
    }

    String typeName(Type t) {
        if (t == Type.INT) return "int";
        if (t == Type.FLOAT) return "float";
        if (t == Type.VOID) return "void";
        if (t == Type.BOOL) return "boolean";
        return "error";
    }

    String llvmType(Type t) {
        if (t == Type.INT) return "i32";
        if (t == Type.FLOAT) return "float";
        if (t == Type.BOOL) return "i1";
        if (t == Type.VOID) return "void";
        return "i32";
    }

    String newTemp() { return "%t" + (tempCount++); }
    String newLabel() { return "L" + (labelCount++); }

    void emit(String s) { ir.add("  " + s); }
    void emitLabel(String label) { ir.add(label + ":"); }

    String escapeLLVMString(String raw) {
        String s = raw.substring(1, raw.length() - 1);
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                char n = s.charAt(++i);
                if (n == 'n') out.append("\\0A");
                else if (n == 't') out.append("\\09");
                else if (n == '"') out.append("\\22");
                else if (n == '\\') out.append("\\5C");
                else out.append(n);
            } else if (c == '"') out.append("\\22");
            else if (c == '\\') out.append("\\5C");
            else out.append(c);
        }
        out.append("\\00");
        return out.toString();
    }

    int llvmStringLength(String raw) {
        String s = raw.substring(1, raw.length() - 1);
        int len = 1; // null terminator
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) { i++; len++; }
            else len++;
        }
        return len;
    }

    String addStringConstant(String raw) {
        String name = "@.str." + (strCount++);
        String escaped = escapeLLVMString(raw);
        int len = llvmStringLength(raw);
        globalIR.add(name + " = private unnamed_addr constant [" + len + " x i8] c\"" + escaped + "\", align 1");
        return "getelementptr inbounds ([" + len + " x i8], [" + len + " x i8]* " + name + ", i32 0, i32 0)";
    }

    void reportError(int line, String category, String msg) {
        errorCount++;
        System.err.println(RED + "==Error== " + line + ": [" + category + "] " + msg + RESET);
    }

    void reportWarning(int line, String msg) {
        warningCount++;
        System.err.println(YELLOW + "==Warning== " + line + ": " + msg + RESET);
    }

    void declareVariable(String name, Type type, boolean isArray, int arraySize, int line) {
        if (type == Type.VOID) {
            reportError(line, "Declaration Error", "variable '" + name + "' cannot have type void.");
            return;
        }
        if (lookupCurrentScope(name) != null) {
            reportError(line, "Redeclared Identifier", "identifier '" + name + "' is already declared in this scope.");
            return;
        }
        Symbol s = new Symbol(name, type, isArray, false, line);
        s.arraySize = arraySize;
        s.ptrName = "%" + name;
        currentScope().put(name, s);

        if (!isArray) emit(s.ptrName + " = alloca " + llvmType(type));
        else emit(s.ptrName + " = alloca [" + arraySize + " x " + llvmType(type) + "]");
    }

    void declareFunction(String name, Type returnType, ArrayList<Type> params, int line) {
        if (scopes.size() == 0) enterScope();
        HashMap<String, Symbol> global = scopes.get(0);
        if (global.containsKey(name)) {
            reportError(line, "Redeclared Identifier", "function '" + name + "' is already declared.");
            return;
        }
        Symbol s = new Symbol(name, returnType, false, true, line);
        s.params = params;
        global.put(name, s);
    }

    void installParameter(Symbol paramSym) {
        if (lookupCurrentScope(paramSym.name) != null) {
            reportError(paramSym.declaredLine, "Redeclared Identifier", "parameter '" + paramSym.name + "' is already declared in this function.");
            return;
        }
        paramSym.ptrName = "%" + paramSym.name + ".addr";
        currentScope().put(paramSym.name, paramSym);
        emit(paramSym.ptrName + " = alloca " + llvmType(paramSym.type));
        emit("store " + llvmType(paramSym.type) + " %" + paramSym.name + ", " + llvmType(paramSym.type) + "* " + paramSym.ptrName);
    }

    Type useVariable(String name, int line) {
        Symbol s = lookup(name);
        if (s == null) {
            reportError(line, "Undeclared Identifier", "variable '" + name + "' has not been declared.");
            return Type.ERROR;
        }
        if (s.isFunction) {
            reportError(line, "Type Error", "function '" + name + "' cannot be used as a variable.");
            return Type.ERROR;
        }
        s.used = true;
        return s.type;
    }

    Symbol getVariableSymbol(String name, int line) {
        Symbol s = lookup(name);
        if (s == null) reportError(line, "Undeclared Identifier", "variable '" + name + "' has not been declared.");
        return s;
    }

    Type useArrayVariable(String name, Type indexType, int line) {
        Symbol s = lookup(name);
        if (s == null) {
            reportError(line, "Undeclared Identifier", "array '" + name + "' has not been declared.");
            return Type.ERROR;
        }
        if (!s.isArray) {
            reportError(line, "Type Error", "identifier '" + name + "' is not an array.");
            return Type.ERROR;
        }
        if (indexType != Type.INT && indexType != Type.ERROR) {
            reportError(line, "Type Error", "array index of '" + name + "' must be int, but got " + typeName(indexType) + ".");
        }
        s.used = true;
        return s.type;
    }

    Type checkBinary(Type left, Type right, String op, int line) {
        if (op.equals("##")) return checkHashHash(left, right, line);
        if (left == Type.ERROR || right == Type.ERROR) return Type.ERROR;
        if (left != right) {
            reportError(line, "Type Mismatch", "type mismatch for operator '" + op + "': " + typeName(left) + " and " + typeName(right) + ".");
            return Type.ERROR;
        }
        if (left == Type.BOOL || left == Type.VOID) {
            reportError(line, "Type Error", "operator '" + op + "' cannot be applied to " + typeName(left) + ".");
            return Type.ERROR;
        }
        return left;
    }

    Type checkHashHash(Type left, Type right, int line) {
        if (left == Type.ERROR || right == Type.ERROR) return Type.ERROR;
        if (left != Type.FLOAT || right != Type.FLOAT) {
            reportError(line, "Type Error", "operator '##' requires two float operands.");
            return Type.ERROR;
        }
        return Type.FLOAT;
    }

    Type checkRelop(Type left, Type right, String op, int line) {
        if (left == Type.ERROR || right == Type.ERROR) return Type.ERROR;
        if (left != right) {
            reportError(line, "Type Mismatch", "type mismatch for relational operator '" + op + "': " + typeName(left) + " and " + typeName(right) + ".");
            return Type.ERROR;
        }
        if (left == Type.BOOL || left == Type.VOID) {
            reportError(line, "Type Error", "relational operator '" + op + "' cannot be applied to " + typeName(left) + ".");
            return Type.ERROR;
        }
        return Type.BOOL;
    }

    void checkAssignment(Type left, Type right, int line) {
        if (left == Type.ERROR) return;
        if (right == Type.ERROR) {
            reportError(line, "Type Mismatch", "type mismatch for the two sides of an assignment.");
            return;
        }
        if (left != right) {
            reportError(line, "Type Mismatch", "type mismatch for the two sides of an assignment: " + typeName(left) + " = " + typeName(right) + ".");
        }
    }

    Type checkFunctionCall(String name, ArrayList<Type> args, int line) {
        Symbol s = lookup(name);
        if (s == null) {
            reportError(line, "Undeclared Identifier", "function '" + name + "' has not been declared.");
            return Type.ERROR;
        }
        if (!s.isFunction) {
            reportError(line, "Type Error", "identifier '" + name + "' is not a function.");
            return Type.ERROR;
        }
        s.used = true;
        if (s.params.size() != args.size()) {
            reportError(line, "Function Call Error", "function '" + name + "' expects " + s.params.size() + " argument(s), but got " + args.size() + ".");
            return s.type;
        }
        for (int i = 0; i < args.size(); i++) {
            Type expected = s.params.get(i);
            Type actual = args.get(i);
            if (actual != Type.ERROR && expected != actual) {
                reportError(line, "Function Call Error", "argument " + (i + 1) + " of function '" + name + "' expects " + typeName(expected) + ", but got " + typeName(actual) + ".");
            }
        }
        return s.type;
    }

    void checkCondition(Type cond, int line, String constructName) {
        if (cond == Type.ERROR) {
            reportError(line, "Type Mismatch", "type mismatch for condition.");
            return;
        }
        if (cond != Type.BOOL) reportError(line, "Type Mismatch", "type mismatch for condition.");
    }

    void checkReturn(Type exprType, int line) {
        currentFunctionHasReturn = true;
        if (currentFunctionReturnType == Type.VOID) {
            if (exprType != Type.VOID && exprType != Type.ERROR) {
                reportError(line, "Return Error", "void function '" + currentFunctionName + "' should not return a value.");
            }
        } else {
            if (exprType == Type.VOID) {
                reportError(line, "Return Error", "non-void function '" + currentFunctionName + "' must return a value of type " + typeName(currentFunctionReturnType) + ".");
            } else if (exprType != Type.ERROR && exprType != currentFunctionReturnType) {
                reportError(line, "Return Error", "function '" + currentFunctionName + "' should return " + typeName(currentFunctionReturnType) + ", but got " + typeName(exprType) + ".");
            }
        }
    }

    void checkUnusedVariables(HashMap<String, Symbol> scope) {
        for (Symbol s : scope.values()) {
            if (!s.isFunction && !s.used) reportWarning(s.declaredLine, "variable '" + s.name + "' declared but never used.");
        }
    }

    String defaultValue(Type t) {
        if (t == Type.FLOAT) return "0.0";
        if (t == Type.VOID) return "";
        return "0";
    }

    String arithmeticInst(Type t, String op) {
        if (t == Type.FLOAT) {
            if (op.equals("+")) return "fadd";
            if (op.equals("-")) return "fsub";
            if (op.equals("*")) return "fmul";
            if (op.equals("/")) return "fdiv";
        } else {
            if (op.equals("+")) return "add";
            if (op.equals("-")) return "sub";
            if (op.equals("*")) return "mul";
            if (op.equals("/")) return "sdiv";
            if (op.equals("%")) return "srem";
        }
        return "add";
    }

    String relInst(Type t, String op) {
        if (t == Type.FLOAT) {
            if (op.equals("<")) return "fcmp olt";
            if (op.equals("<=")) return "fcmp ole";
            if (op.equals(">")) return "fcmp ogt";
            if (op.equals(">=")) return "fcmp oge";
            if (op.equals("==")) return "fcmp oeq";
            if (op.equals("!=")) return "fcmp one";
        } else {
            if (op.equals("<")) return "icmp slt";
            if (op.equals("<=")) return "icmp sle";
            if (op.equals(">")) return "icmp sgt";
            if (op.equals(">=")) return "icmp sge";
            if (op.equals("==")) return "icmp eq";
            if (op.equals("!=")) return "icmp ne";
        }
        return "icmp eq";
    }

    String buildArgString(ArrayList<Type> types, ArrayList<String> places) {
        ArrayList<String> parts = new ArrayList<String>();
        for (int i = 0; i < types.size(); i++) parts.add(llvmType(types.get(i)) + " " + places.get(i));
        return String.join(", ", parts);
    }

    String functionParamString(ArrayList<Symbol> params) {
        ArrayList<String> parts = new ArrayList<String>();
        for (Symbol p : params) parts.add(llvmType(p.type) + " %" + p.name);
        return String.join(", ", parts);
    }

    void finishFunction() {
        if (!currentFunctionHasReturn) {
            if (currentFunctionReturnType == Type.VOID) emit("ret void");
            else emit("ret " + llvmType(currentFunctionReturnType) + " " + defaultValue(currentFunctionReturnType));
        }
        ir.add("}");
        outputIR.addAll(ir);
        ir.clear();
    }

    void printSymbolTable() {
        if (!PRINT_SYMBOL_TABLE) return;
        System.err.println(BLUE + "\n===== Symbol Table =====" + RESET);
        for (int i = 0; i < allScopes.size(); i++) {
            System.err.println("Scope " + i + ":");
            for (Symbol s : allScopes.get(i).values()) {
                if (s.isFunction) System.err.println("  " + s.name + " : function " + typeName(s.type));
                else System.err.println("  " + s.name + " : " + typeName(s.type) + (s.isArray ? "[]" : ""));
            }
        }
    }

    void printSummary() {
        System.err.println(GREEN + "\n===== Checking Summary =====" + RESET);
        System.err.println("Errors: " + errorCount);
        System.err.println("Warnings: " + warningCount);
        if (errorCount == 0) System.err.println(GREEN + "Type checking passed." + RESET);
        else System.err.println(RED + "Type checking failed." + RESET);
    }

    void printLLVMIR() {
        if (errorCount != 0) return;
        System.err.println("\n===== LLVM IR =====");
        System.out.println("declare i32 @printf(i8*, ...)");
        System.out.println("declare i32 @__isoc99_scanf(i8*, ...)");
        System.out.println("declare float @hashhash(float, float)");
        for (String g : globalIR) System.out.println(g);
        System.out.println();
        for (String s : outputIR) System.out.println(s);
    }
}

program
    : { enterScope(); }
      declarationList EOF
      {
          checkUnusedVariables(scopes.get(0));
          printSymbolTable();
          printSummary();
          printLLVMIR();
      }
    ;

declarationList
    : declaration+
    ;

declaration
    : varDeclaration
    | funDeclaration
    ;

varDeclaration
    : t=typeSpecifier varDeclItem[$t.attr_type] (COMMA varDeclItem[$t.attr_type])* SEMI
    ;

varDeclItem[Type declType]
    locals [String idName, int arrSize]
    : id=ID
      {
          $idName = $id.text;
          declareVariable($id.text, $declType, false, 0, $id.getLine());
      }
      ( assignTok=ASSIGN e=expression
        {
            checkAssignment($declType, $e.attr_type, $assignTok.getLine());
            Symbol sym = getVariableSymbol($idName, $id.getLine());
            if (sym != null) emit("store " + llvmType($declType) + " " + $e.place + ", " + llvmType($declType) + "* " + sym.ptrName);
        }
      )?
    | id=ID LBRACK size=INT_LITERAL RBRACK
      {
          $idName = $id.text;
          $arrSize = Integer.parseInt($size.text);
          declareVariable($id.text, $declType, true, $arrSize, $id.getLine());
      }
      ( assignTok=ASSIGN LBRACE values=initList RBRACE
        {
            Symbol sym = getVariableSymbol($idName, $id.getLine());
            if (sym != null) {
                for (int i = 0; i < $values.types.size() && i < $arrSize; i++) {
                    checkAssignment($declType, $values.types.get(i), $assignTok.getLine());
                    String elemAddr = newTemp();
                    emit(elemAddr + " = getelementptr inbounds [" + $arrSize + " x " + llvmType($declType) + "], [" + $arrSize + " x " + llvmType($declType) + "]* " + sym.ptrName + ", i32 0, i32 " + i);
                    emit("store " + llvmType($declType) + " " + $values.places.get(i) + ", " + llvmType($declType) + "* " + elemAddr);
                }
            }
        }
      )?
    ;

initList returns [ArrayList<Type> types, ArrayList<String> places]
    @init { $types = new ArrayList<Type>(); $places = new ArrayList<String>(); }
    : e=expression
      { $types.add($e.attr_type); $places.add($e.place); }
      (COMMA e2=expression { $types.add($e2.attr_type); $places.add($e2.place); })*
    | /* empty */
    ;

typeSpecifier returns [Type attr_type]
    : INT   { $attr_type = Type.INT; }
    | VOID  { $attr_type = Type.VOID; }
    | FLOAT { $attr_type = Type.FLOAT; }
    ;

funDeclaration
    : t=typeSpecifier id=ID LPAREN p=params RPAREN
      {
          declareFunction($id.text, $t.attr_type, $p.paramTypes, $id.getLine());
          currentFunctionReturnType = $t.attr_type;
          currentFunctionName = $id.text;
          currentFunctionHasReturn = false;
          tempCount = 0;
          labelCount = 0;
          ir.clear();
          ir.add("define " + llvmType($t.attr_type) + " @" + $id.text + "(" + functionParamString($p.paramSymbols) + ") {");
          emitLabel("entry");
          enterScope();
          for (Symbol paramSym : $p.paramSymbols) installParameter(paramSym);
      }
      compoundStmtNoNewScope
      {
          exitScope();
          finishFunction();
          currentFunctionReturnType = Type.VOID;
          currentFunctionName = "";
      }
    ;

params returns [ArrayList<Type> paramTypes, ArrayList<Symbol> paramSymbols]
    : p=paramList
      { $paramTypes = $p.paramTypes; $paramSymbols = $p.paramSymbols; }
    | VOID
      { $paramTypes = new ArrayList<Type>(); $paramSymbols = new ArrayList<Symbol>(); }
    | /* empty */
      { $paramTypes = new ArrayList<Type>(); $paramSymbols = new ArrayList<Symbol>(); }
    ;

paramList returns [ArrayList<Type> paramTypes, ArrayList<Symbol> paramSymbols]
    @init { $paramTypes = new ArrayList<Type>(); $paramSymbols = new ArrayList<Symbol>(); }
    : p=param
      { $paramTypes.add($p.paramType); $paramSymbols.add($p.paramSymbol); }
      (COMMA p2=param { $paramTypes.add($p2.paramType); $paramSymbols.add($p2.paramSymbol); })*
    ;

param returns [Type paramType, Symbol paramSymbol]
    : t=typeSpecifier id=ID
      {
          $paramType = $t.attr_type;
          $paramSymbol = new Symbol($id.text, $t.attr_type, false, false, $id.getLine());
          if ($t.attr_type == Type.VOID) reportError($id.getLine(), "Declaration Error", "parameter '" + $id.text + "' cannot have type void.");
      }
    | t=typeSpecifier id=ID LBRACK RBRACK
      {
          $paramType = $t.attr_type;
          $paramSymbol = new Symbol($id.text, $t.attr_type, true, false, $id.getLine());
          if ($t.attr_type == Type.VOID) reportError($id.getLine(), "Declaration Error", "parameter '" + $id.text + "' cannot have type void.");
      }
    ;

compoundStmt
    : LBRACE { enterScope(); } localDeclarations statementList RBRACE { exitScope(); }
    ;

compoundStmtNoNewScope
    : LBRACE localDeclarations statementList RBRACE
    ;

localDeclarations
    : varDeclaration*
    ;

statementList
    : statement*
    ;

statement
    : expressionStmt
    | compoundStmt
    | selectionStmt
    | iterationStmt
    | returnStmt
    ;

expressionStmt
    : expression SEMI
    | printfStmt
    | scanfStmt
    | SEMI
    ;

printfStmt
    : PRINTF LPAREN s=STRING_LITERAL RPAREN SEMI
      {
          String fmt = addStringConstant($s.text);
          emit("call i32 (i8*, ...) @printf(i8* " + fmt + ")");
      }
    | PRINTF LPAREN s=STRING_LITERAL COMMA e=expression RPAREN SEMI
      {
          String fmt = addStringConstant($s.text);
          if ($e.attr_type == Type.FLOAT) {
              String d = newTemp();
              emit(d + " = fpext float " + $e.place + " to double");
              emit("call i32 (i8*, ...) @printf(i8* " + fmt + ", double " + d + ")");
          } else {
              emit("call i32 (i8*, ...) @printf(i8* " + fmt + ", " + llvmType($e.attr_type) + " " + $e.place + ")");
          }
      }
    ;

scanfStmt
    : SCANF LPAREN s=STRING_LITERAL COMMA AMP v=var RPAREN SEMI
      {
          String fmt = addStringConstant($s.text);
          emit("call i32 (i8*, ...) @__isoc99_scanf(i8* " + fmt + ", " + llvmType($v.attr_type) + "* " + $v.addr + ")");
      }
    ;

selectionStmt
    locals [String thenL, String elseL, String endL]
    : IF LPAREN cond=expression RPAREN
      {
          checkCondition($cond.attr_type, $IF.getLine(), "if");
          String thenLabel = newLabel();
          String elseLabel = newLabel();
          String endLabel = newLabel();
          $thenL = thenLabel;
          $elseL = elseLabel;
          $endL = endLabel;
          emit("br i1 " + $cond.place + ", label %" + thenLabel + ", label %" + elseLabel);
          emitLabel(thenLabel);
      }
      statement
      {
          emit("br label %" + $endL);
          emitLabel($elseL);
      }
      ELSE statement
      {
          emit("br label %" + $endL);
          emitLabel($endL);
      }
    | IF LPAREN cond=expression RPAREN
      {
          checkCondition($cond.attr_type, $IF.getLine(), "if");
          String thenLabel = newLabel();
          String endLabel = newLabel();
          $thenL = thenLabel;
          $endL = endLabel;
          emit("br i1 " + $cond.place + ", label %" + thenLabel + ", label %" + endLabel);
          emitLabel(thenLabel);
      }
      statement
      {
          emit("br label %" + $endL);
          emitLabel($endL);
      }
    ;

iterationStmt
    locals [String condL, String bodyL, String endL]
    : WHILE
      {
          String condLabel = newLabel();
          String bodyLabel = newLabel();
          String endLabel = newLabel();
          $condL = condLabel;
          $bodyL = bodyLabel;
          $endL = endLabel;
          emit("br label %" + condLabel);
          emitLabel(condLabel);
      }
      LPAREN cond=expression RPAREN
      {
          checkCondition($cond.attr_type, $WHILE.getLine(), "while");
          emit("br i1 " + $cond.place + ", label %" + $bodyL + ", label %" + $endL);
          emitLabel($bodyL);
      }
      statement
      {
          emit("br label %" + $condL);
          emitLabel($endL);
      }
    ;

returnStmt
    : RETURN SEMI
      {
          checkReturn(Type.VOID, $RETURN.getLine());
          emit("ret void");
      }
    | RETURN e=expression SEMI
      {
          checkReturn($e.attr_type, $RETURN.getLine());
          emit("ret " + llvmType($e.attr_type) + " " + $e.place);
      }
    ;

expression returns [Type attr_type, String place]
    : v=var ASSIGN e=expression
      {
          checkAssignment($v.attr_type, $e.attr_type, $ASSIGN.getLine());
          emit("store " + llvmType($v.attr_type) + " " + $e.place + ", " + llvmType($v.attr_type) + "* " + $v.addr);
          $attr_type = $v.attr_type;
          $place = $e.place;
      }
    | s=simpleExpression
      { $attr_type = $s.attr_type; $place = $s.place; }
    ;

var returns [Type attr_type, String place, String addr]
    : id=ID
      {
          $attr_type = useVariable($id.text, $id.getLine());
          Symbol sym = getVariableSymbol($id.text, $id.getLine());
          if (sym != null) {
              $addr = sym.ptrName;
              $place = newTemp();
              emit($place + " = load " + llvmType(sym.type) + ", " + llvmType(sym.type) + "* " + sym.ptrName);
          } else { $addr = "%error"; $place = "0"; }
      }
    | id=ID LBRACK e=expression RBRACK
      {
          $attr_type = useArrayVariable($id.text, $e.attr_type, $id.getLine());
          Symbol sym = getVariableSymbol($id.text, $id.getLine());
          if (sym != null) {
              $addr = newTemp();
              emit($addr + " = getelementptr inbounds [" + sym.arraySize + " x " + llvmType(sym.type) + "], [" + sym.arraySize + " x " + llvmType(sym.type) + "]* " + sym.ptrName + ", i32 0, i32 " + $e.place);
              $place = newTemp();
              emit($place + " = load " + llvmType(sym.type) + ", " + llvmType(sym.type) + "* " + $addr);
          } else { $addr = "%error"; $place = "0"; }
      }
    ;

simpleExpression returns [Type attr_type, String place]
    : left=additiveExpression op=relop right=additiveExpression
      {
          $attr_type = checkRelop($left.attr_type, $right.attr_type, $op.opText, $op.startTok.getLine());
          $place = newTemp();
          emit($place + " = " + relInst($left.attr_type, $op.opText) + " " + llvmType($left.attr_type) + " " + $left.place + ", " + $right.place);
      }
    | a=additiveExpression
      { $attr_type = $a.attr_type; $place = $a.place; }
    ;

relop returns [String opText, Token startTok]
    : x=LE  { $opText = $x.text; $startTok = $x; }
    | x=LT  { $opText = $x.text; $startTok = $x; }
    | x=GT  { $opText = $x.text; $startTok = $x; }
    | x=GE  { $opText = $x.text; $startTok = $x; }
    | x=EQ  { $opText = $x.text; $startTok = $x; }
    | x=NEQ { $opText = $x.text; $startTok = $x; }
    ;

additiveExpression returns [Type attr_type, String place]
    : left=additiveExpression op=addop right=term
      {
          $attr_type = checkBinary($left.attr_type, $right.attr_type, $op.opText, $op.startTok.getLine());
          $place = newTemp();
          emit($place + " = " + arithmeticInst($attr_type, $op.opText) + " " + llvmType($attr_type) + " " + $left.place + ", " + $right.place);
      }
    | t=term
      { $attr_type = $t.attr_type; $place = $t.place; }
    ;

addop returns [String opText, Token startTok]
    : x=PLUS  { $opText = $x.text; $startTok = $x; }
    | x=MINUS { $opText = $x.text; $startTok = $x; }
    ;

term returns [Type attr_type, String place]
    : left=term op=mulop right=factor
      {
          $attr_type = checkBinary($left.attr_type, $right.attr_type, $op.opText, $op.startTok.getLine());
          $place = newTemp();
          if ($op.opText.equals("##")) emit($place + " = call float @hashhash(float " + $left.place + ", float " + $right.place + ")");
          else emit($place + " = " + arithmeticInst($attr_type, $op.opText) + " " + llvmType($attr_type) + " " + $left.place + ", " + $right.place);
      }
    | f=factor
      { $attr_type = $f.attr_type; $place = $f.place; }
    ;

mulop returns [String opText, Token startTok]
    : x=STAR     { $opText = $x.text; $startTok = $x; }
    | x=SLASH    { $opText = $x.text; $startTok = $x; }
    | x=PERCENT  { $opText = $x.text; $startTok = $x; }
    | x=HASHHASH { $opText = $x.text; $startTok = $x; }
    ;

factor returns [Type attr_type, String place]
    : LPAREN e=expression RPAREN
      { $attr_type = $e.attr_type; $place = $e.place; }
    | v=var
      { $attr_type = $v.attr_type; $place = $v.place; }
    | c=call
      { $attr_type = $c.attr_type; $place = $c.place; }
    | i=INT_LITERAL
      { $attr_type = Type.INT; $place = $i.text; }
    | f=FLOAT_LITERAL
      { $attr_type = Type.FLOAT; $place = $f.text; }
    ;

call returns [Type attr_type, String place]
    : id=ID LPAREN a=args RPAREN
      {
          $attr_type = checkFunctionCall($id.text, $a.argTypes, $id.getLine());
          String argStr = buildArgString($a.argTypes, $a.argPlaces);
          if ($attr_type == Type.VOID) {
              emit("call void @" + $id.text + "(" + argStr + ")");
              $place = "";
          } else {
              $place = newTemp();
              emit($place + " = call " + llvmType($attr_type) + " @" + $id.text + "(" + argStr + ")");
          }
      }
    ;

args returns [ArrayList<Type> argTypes, ArrayList<String> argPlaces]
    : a=argList
      { $argTypes = $a.argTypes; $argPlaces = $a.argPlaces; }
    | /* empty */
      { $argTypes = new ArrayList<Type>(); $argPlaces = new ArrayList<String>(); }
    ;

argList returns [ArrayList<Type> argTypes, ArrayList<String> argPlaces]
    @init { $argTypes = new ArrayList<Type>(); $argPlaces = new ArrayList<String>(); }
    : e=expression
      { $argTypes.add($e.attr_type); $argPlaces.add($e.place); }
      (COMMA e2=expression { $argTypes.add($e2.attr_type); $argPlaces.add($e2.place); })*
    ;

// Keywords
INT     : 'int';
FLOAT   : 'float';
VOID    : 'void';
IF      : 'if';
ELSE    : 'else';
WHILE   : 'while';
RETURN  : 'return';
PRINTF  : 'printf';
SCANF   : 'scanf';

// Operators
HASHHASH: '##';
LE      : '<=';
GE      : '>=';
EQ      : '==';
NEQ     : '!=';
ASSIGN  : '=';
LT      : '<';
GT      : '>';
PLUS    : '+';
MINUS   : '-';
STAR    : '*';
SLASH   : '/';
PERCENT : '%';
AMP     : '&';

// Delimiters
LPAREN  : '(';
RPAREN  : ')';
LBRACE  : '{';
RBRACE  : '}';
LBRACK  : '[';
RBRACK  : ']';
SEMI    : ';';
COMMA   : ',';

INCLUDE
    : '#include' ~[\r\n]* -> skip
    ;

// Literals
STRING_LITERAL
    : '"' ( '\\' . | ~["\\\r\n] )* '"'
    ;

FLOAT_LITERAL
    : [0-9]+ '.' [0-9]*
    | '.' [0-9]+
    ;

INT_LITERAL
    : [0-9]+
    ;

ID
    : [a-zA-Z_][a-zA-Z0-9_]*
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

BLOCK_COMMENT
    : '/*' .*? '*/' -> skip
    ;

WS
    : [ \t\r\n]+ -> skip
    ;
