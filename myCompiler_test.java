import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.IOException;

public class myCompiler_test {
    public static class VerboseErrorListener extends BaseErrorListener {
        private int syntaxErrorCount = 0;

        @Override
        public void syntaxError(
                Recognizer<?, ?> recognizer,
                Object offendingSymbol,
                int line,
                int charPositionInLine,
                String msg,
                RecognitionException e) {
            syntaxErrorCount++;
            System.err.println("\u001B[31m" + "==Syntax Error== " + line + ":" + charPositionInLine + " " + msg + "\u001B[0m");
        }

        public int getSyntaxErrorCount() {
            return syntaxErrorCount;
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("Usage: java -cp .:antlr-4.13.2-complete.jar myCompiler_test <input-file>");
            System.err.println("Example: java -cp .:antlr-4.13.2-complete.jar myCompiler_test test1.c");
            return;
        }

        String inputFile = args[0];

        CharStream input = CharStreams.fromFileName(inputFile);
        myCompilerLexer lexer = new myCompilerLexer(input);

        VerboseErrorListener lexerErrorListener = new VerboseErrorListener();
        lexer.removeErrorListeners();
        lexer.addErrorListener(lexerErrorListener);

        CommonTokenStream tokens = new CommonTokenStream(lexer);
        myCompilerParser parser = new myCompilerParser(tokens);

        VerboseErrorListener parserErrorListener = new VerboseErrorListener();
        parser.removeErrorListeners();
        parser.addErrorListener(parserErrorListener);

        System.err.println("===== Small C Compiler for LLVM IR =====");
        System.err.println("Input file: " + inputFile);
        System.err.println();

        parser.program();

        int totalSyntaxErrors = lexerErrorListener.getSyntaxErrorCount() + parserErrorListener.getSyntaxErrorCount();
        if (totalSyntaxErrors > 0) {
            System.out.println("\n===== Syntax Checking Summary =====");
            System.out.println("Syntax errors: " + totalSyntaxErrors);
        }
    }
}
