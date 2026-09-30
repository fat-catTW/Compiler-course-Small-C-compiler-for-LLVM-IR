declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [16 x i8] c"array sum = %d\0A\00", align 1

define i32 @main() {
entry:
  %nums = alloca [5 x i32]
  %i = alloca i32
  %sum = alloca i32
  %t0 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 0
  %t1 = load i32, i32* %t0
  store i32 1, i32* %t0
  %t2 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 1
  %t3 = load i32, i32* %t2
  store i32 2, i32* %t2
  %t4 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 2
  %t5 = load i32, i32* %t4
  store i32 3, i32* %t4
  %t6 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 3
  %t7 = load i32, i32* %t6
  store i32 4, i32* %t6
  %t8 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 4
  %t9 = load i32, i32* %t8
  store i32 5, i32* %t8
  %t10 = load i32, i32* %i
  store i32 0, i32* %i
  %t11 = load i32, i32* %sum
  store i32 0, i32* %sum
  br label %L0
L0:
  %t12 = load i32, i32* %i
  %t13 = icmp slt i32 %t12, 5
  br i1 %t13, label %L1, label %L2
L1:
  %t14 = load i32, i32* %sum
  %t15 = load i32, i32* %sum
  %t16 = load i32, i32* %i
  %t17 = getelementptr inbounds [5 x i32], [5 x i32]* %nums, i32 0, i32 %t16
  %t18 = load i32, i32* %t17
  %t19 = add i32 %t15, %t18
  store i32 %t19, i32* %sum
  %t20 = load i32, i32* %i
  %t21 = load i32, i32* %i
  %t22 = add i32 %t21, 1
  store i32 %t22, i32* %i
  br label %L0
L2:
  %t23 = load i32, i32* %sum
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.0, i32 0, i32 0), i32 %t23)
  ret i32 0
}
