declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @func(i32 %a) {
entry:
  %a.addr = alloca i32
  store i32 %a, i32* %a.addr
  %t0 = load i32, i32* %a.addr
  %t1 = add i32 %t0, 1
  ret i32 %t1
}
define i32 @main() {
entry:
  %b = alloca i32
  %t0 = load i32, i32* %b
  %t1 = call i32 @func(i32 2)
  store i32 %t1, i32* %b
  ret i32 0
}
