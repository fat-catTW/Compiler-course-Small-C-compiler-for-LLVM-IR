declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [8 x i8] c"c = %d\0A\00", align 1

define i32 @main() {
entry:
  %a = alloca i32
  %b = alloca i32
  %c = alloca i32
  %t0 = load i32, i32* %a
  store i32 3, i32* %a
  %t1 = load i32, i32* %b
  store i32 5, i32* %b
  %t2 = load i32, i32* %c
  %t3 = load i32, i32* %a
  %t4 = load i32, i32* %b
  %t5 = mul i32 %t4, 2
  %t6 = add i32 %t3, %t5
  store i32 %t6, i32* %c
  %t7 = load i32, i32* %c
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.0, i32 0, i32 0), i32 %t7)
  ret i32 0
}
