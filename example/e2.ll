declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @main() {
entry:
  %t0 = load i32, i32* %a
  store i32 1, i32* %a
  ret i32 0
}
