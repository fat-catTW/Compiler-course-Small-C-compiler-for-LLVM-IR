@nums = dso_local global [3 x i32] [i32 1, i32 2, i32 3]

define dso_local i32 @main() {
  %a = alloca i32, align 4
  %t1 = load i32, i32* getelementptr inbounds ([3 x i32], [3 x i32]* @nums, i64 0, i64 2)
  store i32 %t1, i32* %a
  ret i32 0
}

