declare dso_local i32 @printf(i8*, ...)
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

define dso_local i32 @main(){
   %a = alloca i32, align 4
   %b = alloca i32, align 4
   store i32 1, i32* %a
   %t1 = load i32, i32* %a
   %t2 = add nsw i32 %t1, 2
   store i32 %t2, i32* %b
   %t3 = load i32, i32* %b
   %t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %t3)
   ret i32 0
}

