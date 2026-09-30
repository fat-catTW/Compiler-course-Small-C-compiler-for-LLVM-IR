declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [10 x i8] c"max = %d\0A\00", align 1

define i32 @main() {
entry:
  %a = alloca i32
  %b = alloca i32
  %max = alloca i32
  %t0 = load i32, i32* %a
  store i32 8, i32* %a
  %t1 = load i32, i32* %b
  store i32 12, i32* %b
  %t2 = load i32, i32* %a
  %t3 = load i32, i32* %b
  %t4 = icmp sge i32 %t2, %t3
  br i1 %t4, label %L0, label %L1
L0:
  %t5 = load i32, i32* %a
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %L3, label %L4
L3:
  %t7 = load i32, i32* %max
  %t8 = load i32, i32* %a
  store i32 %t8, i32* %max
  br label %L4
L4:
  br label %L2
L1:
  %t9 = load i32, i32* %b
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %L5, label %L6
L5:
  %t11 = load i32, i32* %max
  %t12 = load i32, i32* %b
  store i32 %t12, i32* %max
  br label %L6
L6:
  br label %L2
L2:
  %t13 = load i32, i32* %max
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %L7, label %L8
L7:
  %t15 = load i32, i32* %max
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.0, i32 0, i32 0), i32 %t15)
  br label %L8
L8:
  ret i32 0
}
