declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @main() {
entry:
  %a = alloca i32
  %b = alloca i32
  %t0 = load i32, i32* %a
  store i32 1, i32* %a
  %t1 = load i32, i32* %b
  %t2 = load i32, i32* %a
  %t3 = add i32 %t2, 2
  store i32 %t3, i32* %b
  %t4 = load i32, i32* %b
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.0, i32 0, i32 0), i32 %t4)
  ret i32 0
}
