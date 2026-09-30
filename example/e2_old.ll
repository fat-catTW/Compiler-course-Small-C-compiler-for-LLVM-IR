@a = dso_local global i32 0, align 4

define dso_local i32 @main()
{
  store i32 1, i32* @a
  ret i32 0
}

