declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [8 x i8] c"c = %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"y = %f\0A\00", align 1

define i32 @main() {
entry:
  %a = alloca i32
  %b = alloca i32
  %c = alloca i32
  %x = alloca float
  %y = alloca float
  %t0 = load i32, i32* %a
  store i32 10, i32* %a
  %t1 = load i32, i32* %b
  store i32 3, i32* %b
  %t2 = load i32, i32* %c
  %t3 = load i32, i32* %a
  %t4 = load i32, i32* %b
  %t5 = mul i32 %t4, 2
  %t6 = add i32 %t3, %t5
  %t7 = sdiv i32 4, 2
  %t8 = sub i32 %t6, %t7
  store i32 %t8, i32* %c
  %t9 = load float, float* %x
  store float 1.5, float* %x
  %t10 = load float, float* %y
  %t11 = load float, float* %x
  %t12 = fmul float %t11, 2.0
  %t13 = fadd float %t12, 3.0
  store float %t13, float* %y
  %t14 = load i32, i32* %c
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.0, i32 0, i32 0), i32 %t14)
  %t15 = load float, float* %y
  %t16 = fpext float %t15 to double
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i32 0, i32 0), double %t16)
  ret i32 0
}
