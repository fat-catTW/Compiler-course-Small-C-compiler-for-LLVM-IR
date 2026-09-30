declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)
@.str.0 = private unnamed_addr constant [12 x i8] c"Enter age: \00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"Enter score: \00", align 1
@.str.3 = private unnamed_addr constant [3 x i8] c"%f\00", align 1
@.str.4 = private unnamed_addr constant [10 x i8] c"age = %d\0A\00", align 1
@.str.5 = private unnamed_addr constant [12 x i8] c"score = %f\0A\00", align 1

define i32 @main() {
entry:
  %age = alloca i32
  %score = alloca float
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.0, i32 0, i32 0))
  %t0 = load i32, i32* %age
  call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i32 0, i32 0), i32* %age)
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i32 0, i32 0))
  %t1 = load float, float* %score
  call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.3, i32 0, i32 0), float* %score)
  %t2 = load i32, i32* %age
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.4, i32 0, i32 0), i32 %t2)
  %t3 = load float, float* %score
  %t4 = fpext float %t3 to double
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.5, i32 0, i32 0), double %t4)
  ret i32 0
}
