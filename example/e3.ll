declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @main() {
entry:
  %t0 = load i32, i32* %a
  store i32 1, i32* %a
  %t1 = load i32, i32* %b
  %t2 = load i32, i32* %a
  %t3 = add i32 %t2, 4
  store i32 %t3, i32* %b
  ret i32 0
}
