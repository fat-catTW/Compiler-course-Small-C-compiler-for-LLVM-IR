declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @main() {
entry:
  %a = alloca i32
  %t0 = load i32, i32* %a
  %t1 = getelementptr inbounds [3 x i32], [3 x i32]* %nums, i32 0, i32 2
  %t2 = load i32, i32* %t1
  store i32 %t2, i32* %a
  ret i32 0
}
