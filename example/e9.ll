declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @func() {
entry:
  %a = alloca i32
  %t0 = load i32, i32* %a
  store i32 10, i32* %a
  %t1 = load i32, i32* %a
  ret i32 %t1
}
define i32 @main() {
entry:
  %b = alloca i32
  %t0 = load i32, i32* %b
  %t1 = call i32 @func()
  store i32 %t1, i32* %b
  ret i32 0
}
