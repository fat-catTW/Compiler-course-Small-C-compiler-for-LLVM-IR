declare dso_local i32 @printf(i8*, ...)
@str = private unnamed_addr constant [13 x i8] c"Hello World\0A\00", align 1

define dso_local i32 @main() {
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @str, i64 0, i64 0))
  ret i32 0
}

