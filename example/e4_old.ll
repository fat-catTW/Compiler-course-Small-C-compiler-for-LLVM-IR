define dso_local i32 @main() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 1, i32* %1
  %3 = load i32, i32* %1
  %4 = add nsw i32 %3, 4
  store i32 %4, i32* %2
  ret i32 0
}

