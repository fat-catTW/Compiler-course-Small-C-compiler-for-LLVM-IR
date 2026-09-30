define dso_local i32 @main() {
   %t1 = alloca i32, align 4    ; allocate a in stack frame
   %t2 = alloca i32, align 4    ; allocate b in stack frame
   store i32 1, i32* %t1, align 4    ; a = 1
   %t3 = load i32, i32* %t1, align 4 ; load a to %t3
   %cond = icmp sgt i32 %t3, 0       ; a > 0?
   br i1 %cond, label %Ltrue, label %Lfalse

   Ltrue:                             ; If-then part
   store i32 0, i32* %t2, align 4    ; b = 0
   br label %Lend

   Lfalse:                            ; If-else part
   %t5 = load i32, i32* %t1, align 4  ; load a to %t5
   %t6 = add nsw i32 %t5, 2           ; %t6 = a + 2
   store i32 %t6, i32* %t2, align 4   ; store %t6 to b
   br label %Lend

   Lend:
   ret i32 0
}

