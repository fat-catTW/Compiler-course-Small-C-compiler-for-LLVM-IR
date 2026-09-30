declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [10 x i8] c"sum = %d\0A\00", align 1

define i32 @main() {
entry:
  %x = alloca i32
  %sum = alloca i32
  %t0 = load i32, i32* %x
  store i32 0, i32* %x
  %t1 = load i32, i32* %sum
  store i32 0, i32* %sum
  br label %L0
L0:
  %t2 = load i32, i32* %x
  %t3 = icmp slt i32 %t2, 5
  br i1 %t3, label %L1, label %L2
L1:
  %t4 = load i32, i32* %x
  %t5 = icmp ne i32 %t4, 3
  br i1 %t5, label %L3, label %L4
L3:
  %t6 = load i32, i32* %sum
  %t7 = load i32, i32* %sum
  %t8 = load i32, i32* %x
  %t9 = add i32 %t7, %t8
  store i32 %t9, i32* %sum
  br label %L5
L4:
  %t10 = load i32, i32* %sum
  %t11 = load i32, i32* %sum
  %t12 = add i32 %t11, 10
  store i32 %t12, i32* %sum
  br label %L5
L5:
  %t13 = load i32, i32* %x
  %t14 = load i32, i32* %x
  %t15 = add i32 %t14, 1
  store i32 %t15, i32* %x
  br label %L0
L2:
  %t16 = load i32, i32* %sum
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.0, i32 0, i32 0), i32 %t16)
  ret i32 0
}
