ANTLR_JAR=antlr-4.13.2-complete.jar

all:
	java -jar $(ANTLR_JAR) myCompiler.g4
	javac -cp .:$(ANTLR_JAR) myCompiler*.java myCompiler_test.java

run:
	java -cp .:$(ANTLR_JAR) myCompiler_test $(FILE)

# 產生單一 LLVM IR
ll:
	java -cp .:$(ANTLR_JAR) myCompiler_test $(FILE) > $(FILE:.c=.ll)

# 一次產生 example 裡所有測資
examples:
	for f in example/*.c; do \
		echo "Generating $${f%.c}.ll"; \
		java -cp .:$(ANTLR_JAR) myCompiler_test $$f > $${f%.c}.ll; \
	done

clean:
	rm -f \
	myCompilerLexer.java \
	myCompilerParser.java \
	myCompilerListener.java \
	myCompilerBaseListener.java \
	myCompiler*.tokens \
	myCompiler*.interp \
	*.class