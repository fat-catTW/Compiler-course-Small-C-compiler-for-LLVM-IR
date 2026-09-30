declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define i32 @main() {
entry:
  %a = alloca i32
  %b = alloca i32
  %t0 = load i32, i32* %a
  store i32 1, i32* %a
  %t1 = load i32, i32* %a
  %t2 = icmp sgt i32 %t1, 0
  br i1 %t2, label %L0, label %L1
L0:
  %t3 = load i32, i32* %b
  store i32 0, i32* %b
  br label %L2
L1:
  %t4 = load i32, i32* %b
  %t5 = load i32, i32* %a
  %t6 = add i32 %t5, 2
  store i32 %t6, i32* %b
  br label %L2
L2:
  ret i32 0
}
