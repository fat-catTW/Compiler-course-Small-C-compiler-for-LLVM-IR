declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [13 x i8] c"Hello World\0A\00", align 1

define i32 @main() {
entry:
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.0, i32 0, i32 0))
  ret i32 0
}
