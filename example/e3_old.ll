@a = dso_local global i32 0, align 4
@b = dso_local global i32 0, align 4

define dso_local i32 @main()
{
  store i32 1, i32* @a
  %1 = load i32, i32* @a
  %2 = add nsw i32 %1, 4
  store i32 %2, i32* @b
  ret i32 0
}
