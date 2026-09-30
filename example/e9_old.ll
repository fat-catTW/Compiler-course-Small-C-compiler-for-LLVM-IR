define dso_local i32 @func() {
  %1 = alloca i32, align 4
  store i32 10, i32* %1
  %2 = load i32, i32* %1
  ret i32 %2
}

define dso_local i32 @main() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %1
  %3 = call i32 @func()
  store i32 %3, i32* %2
  ret i32 0
}
