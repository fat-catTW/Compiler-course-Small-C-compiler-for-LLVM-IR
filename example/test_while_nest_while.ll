declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [12 x i8] c"count = %d\0A\00", align 1

define i32 @main() {
entry:
  %i = alloca i32
  %j = alloca i32
  %count = alloca i32
  %t0 = load i32, i32* %i
  store i32 0, i32* %i
  %t1 = load i32, i32* %count
  store i32 0, i32* %count
  br label %L0
L0:
  %t2 = load i32, i32* %i
  %t3 = icmp slt i32 %t2, 3
  br i1 %t3, label %L1, label %L2
L1:
  %t4 = load i32, i32* %j
  store i32 0, i32* %j
  br label %L3
L3:
  %t5 = load i32, i32* %j
  %t6 = icmp slt i32 %t5, 2
  br i1 %t6, label %L4, label %L5
L4:
  %t7 = load i32, i32* %count
  %t8 = load i32, i32* %count
  %t9 = add i32 %t8, 1
  store i32 %t9, i32* %count
  %t10 = load i32, i32* %j
  %t11 = load i32, i32* %j
  %t12 = add i32 %t11, 1
  store i32 %t12, i32* %j
  br label %L3
L5:
  %t13 = load i32, i32* %i
  %t14 = load i32, i32* %i
  %t15 = add i32 %t14, 1
  store i32 %t15, i32* %i
  br label %L0
L2:
  %t16 = load i32, i32* %count
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.0, i32 0, i32 0), i32 %t16)
  ret i32 0
}
