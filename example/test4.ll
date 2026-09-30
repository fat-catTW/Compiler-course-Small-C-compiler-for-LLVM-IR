declare i32 @printf(i8*, ...)
declare i32 @__isoc99_scanf(i8*, ...)
declare float @hashhash(float, float)

define float @combine(float %a, float %b) {
entry:
  %a.addr = alloca float
  store float %a, float* %a.addr
  %b.addr = alloca float
  store float %b, float* %b.addr
  %result = alloca float
  %t0 = load float, float* %result
  %t1 = load float, float* %a.addr
  %t2 = load float, float* %b.addr
  %t3 = call float @hashhash(float %t1, float %t2)
  store float %t3, float* %result
  %t4 = load float, float* %result
  ret float %t4
}
define i32 @main() {
entry:
  %x = alloca float
  %y = alloca float
  %z = alloca float
  %t0 = load float, float* %x
  store float 1.5, float* %x
  %t1 = load float, float* %y
  store float 2.5, float* %y
  %t2 = load float, float* %z
  %t3 = load float, float* %x
  %t4 = load float, float* %y
  %t5 = call float @combine(float %t3, float %t4)
  store float %t5, float* %z
  ret i32 0
}
