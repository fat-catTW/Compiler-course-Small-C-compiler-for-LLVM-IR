declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [10 x i8] c"sum = %d\0A\00", align 1

define i32 @main() {
entry:
  %i = alloca i32
  %sum = alloca i32
  %t0 = load i32, i32* %i
  store i32 0, i32* %i
  %t1 = load i32, i32* %sum
  store i32 0, i32* %sum
  br label %L0
L0:
  %t2 = load i32, i32* %i
  %t3 = icmp slt i32 %t2, 6
  br i1 %t3, label %L1, label %L2
L1:
  %t4 = load i32, i32* %i
  %t5 = icmp eq i32 %t4, 3
  br i1 %t5, label %L3, label %L4
L3:
  %t6 = load i32, i32* %sum
  %t7 = load i32, i32* %sum
  %t8 = add i32 %t7, 10
  store i32 %t8, i32* %sum
  br label %L5
L4:
  %t9 = load i32, i32* %sum
  %t10 = load i32, i32* %sum
  %t11 = load i32, i32* %i
  %t12 = add i32 %t10, %t11
  store i32 %t12, i32* %sum
  br label %L5
L5:
  %t13 = load i32, i32* %i
  %t14 = load i32, i32* %i
  %t15 = add i32 %t14, 1
  store i32 %t15, i32* %i
  br label %L0
L2:
  %t16 = load i32, i32* %sum
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.0, i32 0, i32 0), i32 %t16)
  ret i32 0
}
