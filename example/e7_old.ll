define dso_local i32 @func(i32 %0) {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2
  %3 = load i32, i32* %2
  %4 = add nsw i32 %3, 1
  ret i32 %4
}


define dso_local i32 @main() {
  %1 = alloca i32, align 4
  %2 = call i32 @func(i32 2)
  store i32 %2, i32* %1
  ret i32 0
}

