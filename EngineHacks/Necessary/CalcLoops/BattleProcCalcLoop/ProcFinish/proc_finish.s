.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ proc_truehit, 0x802A558
.equ d100Result, 0x802a52c
@ r0 is attacker, r1 is defender, r2 is current buffer, r3 is battle data
push {r4-r7,lr}
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data

mov r1, #4
ldrsh r0, [r7,r1] @damage
cmp r0, #0x7f
ble UnderDMGCap
mov r0, #0x7f
strh r0, [r7,r1] @damage is capped at 127
UnderDMGCap:
cmp r0, #0
bge OverDMGFloor
mov r0, #0
strh r0, [r7,r1] @damage is floored at 0
strb r0, [r6, #5] @set hp change to 0 too
ldr r1, [r6]
mov r0, #0x80 @and unset the hp drain flag
lsl r0, #1
mvn r0, r0
and r1, r0
str r1, [r6]
OverDMGFloor:
mov r0, r4
add r0, #0x48
ldrb r0, [r0]
cmp r0, #0xb5 @stone
bne NotStone
mov r0, #0
strh r0, [r7, #4]
NotStone:
mov r0, #4
ldrsh r0, [r7, r0]
cmp r0, #0
beq CapHealing @tink = no exp for you
ldr r0, [r6]
mov r1, #2 @miss flag
tst r1, r0
bne CapHealing @missed = no exp for you
mov r1, r4
add r1, #0x7c
mov r0, #1
strb r0, [r1] @set hit flag 

CapHealing:
mov r1,#5
ldsb r0, [r6, r1] @r0 = hp change for attacker
cmp r0,#0
ble End @if not healing, skip this
ldrb r1,[r4,#0x12] @attacker max HP
ldrb r2,[r4,#0x13] @attacker cur HP
sub r1,r2 @damage taken
cmp r1,r0
bge NoCap
mov r0,r1 @set amount healed to damage taken if would cap

NoCap:
strb r0,[r6,#5]
ldrb r1,[r4,#0x13] @cur HP
add r0,r1
strb r0,[r4,#0x13]

End:
pop {r4-r7}
pop {r15}
