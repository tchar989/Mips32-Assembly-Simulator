		#MIPS32 program that simulates the running of machine code. It has machine code stored in
		#the word array m. It prints useful information such as register values and alu output
		#currently only works with the instructions add, sub, and, or, nor, slt, sll, srl
		#Tim Chartier
		#MP4 stage 1
		#due 4/14
		#ECE 201

		.data
#m:		.word 0x1284820, 0x1495020, 0x22A9020, 0x1284820, 0x1495020, 0x24A9820, 0x1284820, 0x1495020, 0x26AA020, 0x1284820, 0x1495020, 0x28AA820, 0x1000FFFF
#MAXMEM:	.word 0xD
m: 		.word 0x8c040030, 0x8c050034, 0x8c0b0038, 0x00044820, 0x00005020, 0x0125602a, 0x118b0003, 0x01254822, 0x014b5020, 0x08000005, 0x01401020, 0x08000010, 0x0000000e, 0x00000007, 0x00000001, 0x00000000, 0xac0a003c, 0x8c11003c, 0x1000FFFF 
MAXMEM: .word 0x13
mdr:	.word 0x0
r:		.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
ir:		.word 0x0
pc:		.word 0x0
a:		.word 0x0
ib:		.word 0x0
funct:	.word 0x0
shamt:	.word 0x0
aluout:	.word 0x0
rd:		.word 0x0
opcode:	.word 0x0
here:	.asciiz "here!\n"
error1:	.asciiz "unimplemented instruction"
error2: .asciiz "internal programming error: unable to find hex conversion.\n"
error3: .asciiz "memory out of bounds.\n"
error4: .asciiz "Can't write to 0 reg\n"
pir:	.asciiz " ir= "
ppc:	.asciiz "pc= "	
pa:		.asciiz " a = "
pib:	.asciiz " ib= "
paluout:.asciiz " aluout= "
pv0:	.asciiz "v0= "
pa0:	.asciiz " a0= "
pa1:	.asciiz " a1= "
pt1:	.asciiz " t1= "
pt2:	.asciiz " t2= "
pt3:	.asciiz " t3= "
pt4:	.asciiz "t4= "
ps1:	.asciiz " s1= "
ps2:	.asciiz " s2= "
ps3:	.asciiz " s3= "
ps4:	.asciiz " s4= "
ps5:	.asciiz " s5= "
hexin:	.asciiz "0x"
line:	.asciiz "-----------------------------------------------------------------------------"
		.text
		.globl main
		
			#NOTE! the babbage program requires $t0-$t2 & $s0-$s5. As such, they should be pushed and popped within methods or not used at all.
main:
			#load babbage dependencies 	
			#la $t3, r
			#li $t4, 6
			#addi $t3, $t3, 32
			#sw $t4, 0($t3)
			#li $t4, 0
			#sw $t4, 4($t3)
			#li $t4, 1
			#sw $t4, 8($t3)
			#sw $t4, 36($t3)
			la $t3, m							# $t3 = p = address of beginning of m (pointer to m)
			addi $t3, $t3, -4
			la $t9, pc
			sw $zero, 0($t9)						# pc = address of beginning of m -4 (initial increm)
			la $t5, MAXMEM
			lw $t5, 0($t5)
			add $t5, $t5, $t5
			add $t5, $t5, $t5
			add $t5, $t5, $t3
			lw $t5, 0($t5)						# $t5 = MAXMEM
	while:
			lw $t8, 0($t9)
			addi $t8, $t8, 4	
			sw $t8, 0($t9)
			add $t8, $t8, $t3			
			lw $t4, 0($t8)						# $t4 = ir
			sub $t8, $t8, $t3
			move $a0, $t8
			jal address_check					# call address_check
			la $t7, ir
			sw $t4, 0($t7)						# store ir
			move $a0, $t4
			li $a1, 31
			li $a2, 26
			jal extract
			move $t7, $v0					
			li $a1, 25
			li $a2, 21
			jal extract							# extract a
			la $t6, a
			sw $v0, 0($t6)						# store extracted a in a label (source register 1)
			li $a1, 20
			li $a2, 16
			jal extract							# extract b
			la $t6, ib
			sw $v0, 0($t6)						# store extracted b in ib (source register 2)
			li $a1, 15
			li $a2, 0
			jal extract  						# $v0 = last 16 bits (immed)			
			#sll $v0, $v0, 2						# $v0 << 2
			move $a0, $v0
			jal signex							# $v0 = signex(extract(ir, 15, 0) << 2)
			la $t6, aluout						
			add $s1, $t8, $v0					# $s1 = pc + signex(extract(ir, 15, 0) << 2)
			sw $s1, 0($t6)						# $s1 -> aluout
			li $s2, 2
			beq $t7, $s2, jType					# if opcode == 2, its j type
			li $s2, 4
			beq $t7, $s2, beqType
			li $s2, 35
			beq $t7, $s2, loadstore
			li $s2, 43
			beq $t7, $s2, loadstore
			li $s2, 0
			bne $t7, $zero, unimplemented
			#else it must be rtype
			li $a1, 6
			li $a2, 0
			jal extract							#extract funct #
			la $t6, funct
			sw $v0, 0($t6)						#store extracted funct in funct field
			li $a1, 10
			li $a2, 7
			jal extract							#extract shamt #
			la $t6, shamt
			sw $v0, 0($t6)						#store extracted shamt in shamt field
			li $a1, 15
			li $a2, 11
			jal extract
			beq $v0, $zero, zeroError			#if rd is 0, invalid instruction. protect $0
			la $t6, rd		
			sw $v0, 0($t6)						#store in rd
												#since must be rtype, will go directly into rtype SR

rtype:		
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			addi $sp, $sp, -4
			sw $t6, 0($sp)
			addi $sp, $sp, -4
			sw $t7, 0($sp)
			jal alufunct
			la $t6, aluout
			sw $v0, 0($t6)
			la $t6, r						#t6 has address of r
			la $t7, rd						#t7 has address for reg # for rd
			lw $t7, 0($t7)					#t7 has reg # for rd
			add $t7, $t7, $t7
			add $t7, $t7, $t7				#since r has 4 byte elements, need to multiply index by 4
			add $t6, $t6, $t7				#t6 has exact address of register given by rd
			sw $v0, 0($t6)	
			lw $t7, 0($sp)
			addi $sp, $sp, 4
			lw $t6, 0($sp)
			addi $sp, $sp, 4	
			lw $v0, 0($sp)
			addi $sp, $sp, 4	
			jal traceout
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit
			j while							# reiterate loop

finish:
			li $v0, 10
			syscall							#exits program
			
		
alufunct:
# needs the numbers of source registers (stored in fields a and ib) and the funct (stored in funct)
# performs operation on a and ib based on funct
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $sp, $sp, -4			#7 pushes
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $t2, 0($sp)
			addi $sp, $sp, -4
			sw $t3, 0($sp)				# make sure no registers get clobbered by pushing
			addi $sp, $sp, -4
			sw $t4, 0($sp)
			addi $sp, $sp, -4
			sw $t5, 0($sp)
			la $t4, r					# load r address into t4
			la $t0, a					# load address of source reg # into t0
			lw $t0, 0($t0)				# load source reg # into t0			
			add $t0, $t0, $t0			# multiply source reg # by 4 since r array holds 4 byte elements
			add $t0, $t0, $t0			
			add $t4, $t4, $t0			# add address of r with byte index of a reg
			lw $t0, 0($t4)				# $t0 now holds the value stored in the source register whose # is given by a
			la $t1, ib
			lw $t1, 0($t1)
			la $t4, r
			add $t1, $t1, $t1
			add $t1, $t1, $t1
			add $t4, $t4, $t1
			lw $t1, 0($t4)				# $t1 now holds the value stored in the source register whose # is given by ib
			la $t2, funct
			lw $t2, 0($t2)				# a->$t0, ib->$t1, funct->$t2
			la $t5, shamt
			lw $t5, 0($t5)				#shamt->$t5
			jal switch					# check which function to performs
			la $t0, aluout
			sw $v0, 0($t0)
			lw $t5, 0($sp)
			addi $sp, $sp, 4
			lw $t4, 0($sp)
			addi $sp, $sp, 4
			lw $t3, 0($sp)
			addi $sp, $sp, 4			#7 pops
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
	
	#check which function to perform, perform it, and put result in $v0 then return to spot in alufunc
	#in funct is not once of the 5, put 0 in $v0 and return
switch:	
			addi $sp, $sp, -4				#1 push
			sw $ra, 0($sp)
			li $t3, 32
			beq $t2, $t3, addop
			li $t3, 34
			beq $t2, $t3, subop
			li $t3, 36
			beq $t2, $t3, andop
			li $t3, 37
			beq $t2, $t3, orop
			li $t3, 39
			beq $t2, $t3, norop
			li $t3, 42
			beq $t2, $t3, sltop
			li $t3, 0
			beq $t2, $t3, sllop
			li $t3, 2
			beq $t2, $t3, srlop
			li $v0, 0
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
addop:
			add $v0, $t0, $t1				#1 pop (switch)
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
subop:	
			sub $v0, $t0, $t1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
andop:
			and $v0, $t0, $t1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
orop:
			or $v0, $t0, $t1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra 
norop:	
			nor $v0, $t0, $t1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
sltop:
			slt $v0, $t0, $t1
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
sllop:		
			sll $v0, $t0, $t5
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
srlop:
			srl $v0, $t0, $t5
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

			#set pc = extract(pc,31,28) | (extract(ir,25,0)) << 2)
jType:			
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			addi $sp, $sp, -4
			sw $a2, 0($sp)
			addi $sp, $sp, -4
			sw $s1, 0($sp)
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			move $a0, $t8				# t8 holds pc value
			li $a1, 31
			li $a2, 28
			jal extract
			move $s1, $v0				# $s1 holds pc[31,28]
			sll $s1, $s1, 28			
			move $a0, $t4				# $a0 = ir 
			li $a1, 25
			li $a2, 0
			jal extract
			sll $v0, $v0, 2				
			move $s2, $v0				# $s2 holds ir[25,0] << 2
			or $v0, $s1, $s2			# $v0 concatenates pc[31,28] and ir[25,0] << 2
			jal traceout
			la $t1, pc
			sw $v0, 0($t1)				# $v0 -> new pc
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit
			j while

beqType:
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $s1, 0($sp)
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			addi $sp, $sp, -4
			sw $a2, 0($sp)
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			addi $sp, $sp, -4
			sw $t2, 0($sp)
			la $s1, r
			la $t0, a 					
			lw $t0, 0($t0)				
			sll $t0, $t0, 2
			add $t0, $t0, $s1			# $t0 = address of a reg
			la $t1, ib
			lw $t1, 0($t1)
			sll $t1, $t1, 2
			add $t1, $t1, $s1			# $t1 = index of b reg
			lw $t0, 0($t0)				# $t0 = a reg
			lw $t1, 0($t1)				# $t1 = b reg
			beq $t0, $t1, beqTypeTrue
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			jal traceout
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit
			j while
beqTypeTrue:
			move $a0, $t4
			li $a1, 15
			li $a2, 0
			jal extract
			sll $v0, $v0, 2
			move $a0, $v0
			jal signex
			la $s1, pc
			lw $t2, 0($s1)
			add $t2, $t2, $v0				# $t2 = pc + signex(extract(ir, 15, 0))
			sw $t2, 0($s1)					# pc = $t2
			la $s1, aluout
			sw $t2, 0($s1)
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			addi $sp, $sp, -4
			lw $t0, 0($sp)
			addi $sp, $sp, -4
			lw $t1, 0($sp)
			la $t0, pc
			lw $t1, 0($t0)
			addi $t1, $t1, 4
			sw $t1, 0($t0)
			jal traceout
			addi $t1, $t1, -4
			sw $t1, 0($t0)
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4	
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit
			j while

loadstore:
			#aluout = a + signex(extract(ir,15,0))
			addi $sp, $sp, -4
			sw $s1, 0($sp)
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			addi $sp, $sp, -4
			sw $a2, 0($sp)
			addi $sp, $sp, -4
			sw $s2, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			addi $sp, $sp, -4
			sw $t3, 0($sp)
			addi $sp, $sp, -4
			sw $s4, 0($sp)
			la $s1, r
			la $t0, a
			lw $t0, 0($t0)
			sll $t0, $t0, 2
			add $t0, $t0, $s1			# $t0 = index of a reg
			lw $t0, 0($t0)				# $t0 = a reg
			move $a0, $t4
			li $a1, 15
			li $a2, 0
			jal extract
			move $a0, $v0
			jal signex
			add $t1, $t0, $v0			# $t1 = a+signex(extract(ir,15,0))
			la $s2, aluout
			sw $t1, 0($s2)				# $t1 -> aluout
			move $a0, $t1
			jal address_check
			move $a0, $t4
			li $a1, 29
			li $a2, 29
			jal extract
			li $t2, 1
			beq $v0, $t2, storeOp
			beq $v0, $zero, loadOp
			lw $s4, 0($sp)
			addi $sp, $sp, 4
			lw $t3, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $s2, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			j unimplemented

storeOp:
			add $t1, $t1, $s1			# $t1 = address of data location
			la $t3, ib
			lw $t3, 0($t3)
			sll $t3, $t3, 2
			add $t3, $t3, $s1			# $t1 = index of b reg
			lw $t3, 0($t3)				# $t1 = b reg
			sw $t3, 0($t1)				# b reg -> m[aluout]
			lw $s4, 0($sp)
			addi $sp, $sp, 4
			lw $t3, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $s2, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			jal traceout
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit			
			j while

loadOp:
			# m[aluout] -> mdr
			la $s2, m
			add $t1, $t1, $s2
			lw $t1, 0($t1)				#$t1 = m[aluout]
			la $t3, mdr					
			sw $t1, 0($t3)				# m[aluout] -> mdr
			move $a0, $t4
			li $a1, 20
			li $a2, 16
			jal extract
			beq $v0, $zero, zeroError
			# mdr -> r[extract(ir,20,16)]
			la $s4, r
			sll $v0, $v0, 2
			add $s4, $s4, $v0			# $s4 holds address for register to write to 
			sw $t1, 0($s4)
			lw $s4, 0($sp)
			addi $sp, $sp, 4
			lw $t3, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $s2, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $s1, 0($sp)
			addi $sp, $sp, 4
			jal traceout
			beq $t4, $t5, finish				# if ir == 0x1000FFFF, quit			
			j while


extract:						#needs to be passed the instruction number in a0(index of m to retrieve), left in a1, right in a2
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $sp, $sp, -4			#pushing a0, a1, a2 to stack
			sw $t0,0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4			#6 push
			sw $t2, 0($sp)
			addi $sp, $sp, -4			#preserve $t0-$t3 
			sw $t3, 0($sp)		
			addi $sp, $sp, -4
			sw $a0, 0($sp)		
			li $t0, 31	
			sub $t1, $t0, $a1
			sub $t2, $a1, $a2
			sub $t2, $t0, $t2
			li $v0, 0					
			sll	$v0, $a0, $t1			#shifting based on num location and size
			srl $v0, $v0, $t2			#v0 holds our value
			lw $a0, 0($sp)
			addi $sp, $sp, 4	
			lw $t3, 0($sp)
			addi $sp, $sp, 4
			lw $t2, 0($sp)				
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4			#6 pop
			lw $t0, 0($sp)
			addi $sp, $sp, 4	
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra	


hexdig:
#assumes the digit is in $a0. 
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $sp, $sp, -4			#5 push
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4	
			sw $a0, 0($sp)
			addi $sp, $sp, -4			#pushes registers to prevent clobbering
			sw $v0, 0($sp)
			li $t0, 9
			slt $t1, $t0, $a0
			bne $t1, $zero, findhex		#if 9 >= our input val, no need to convert
			addi $a0, $a0, 0x30			#print $a0
			li $v0, 11
			syscall
			j after						#jump to after to pop regs and go back
findhex:
			addi $a0, $a0, -10			#compare $a0 to possible hex values
			beq $a0, $zero, hexA
			addi $a0, $a0, -1
			beq $a0, $zero, hexB
			addi $a0, $a0, -1
			beq $a0, $zero, hexC
			addi $a0, $a0, -1
			beq $a0, $zero, hexD
			addi $a0, $a0, -1
			beq $a0, $zero, hexE
			addi $a0, $a0, -1
			beq $a0, $zero, hexF
			li $v0, 4					#if none were found, error
			la $a0, error2
			syscall
after:
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4			#5 pop
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
hexA:
			li $a0, 0x41
			li $v0, 11
			syscall
			j after
		
hexB:
			li $a0, 0x42
			li $v0, 11
			syscall
			j after
hexC:
			li $a0, 0x43
			li $v0, 11
			syscall
			j after
hexD:
			li $a0, 0x44
			li $v0, 11
			syscall
			j after
hexE:
			li $a0, 0x45
			li $v0, 11
			syscall
			j after
hexF:
			li $a0, 0x46
			li $v0, 11
			syscall
			j after


hexprint:
#prints the word in hexadecimal
#word goes in a0
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $sp, $sp, -4			#8 push
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $t0, 0($sp)			
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			addi $sp, $sp, -4
			sw $a2, 0($sp)
			addi $sp, $sp, -4
			sw $t1, 0($sp)
			addi $sp, $sp, -4
			sw $t2, 0($sp)
			addi $sp, $sp, -4
			sw $t3, 0($sp)
			move $t0, $a0
			la $a0, hexin
			li $v0, 4
			syscall						
			li $t1, 31					#first left
			li $t2, 28					#first right
			li $t3, 4					#for subtracting after each iteration
hexloop:	
#extracting every consecutive 4 bits from word
			move $a0, $t0
			move $a1, $t1
			move $a2, $t2
			jal extract
			move $a0, $v0
			jal hexdig
			move $a0, $t0
			sub $t1, $t1, $t3
			sub $t2, $t2, $t3			#decrement left and right by 4
			blt $t1, $zero, hexfin		#if left is less than 1, we're done
			j hexloop
hexfin:
			lw $t3, 0($sp)
			addi $sp, $sp, 4
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $t1, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)				#8 pop
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra


traceout:
			addi $sp, $sp, -4			#6 push
			sw $ra, 0($sp)
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			addi $sp, $sp, -4
			sw $a2, 0($sp)
			addi $sp, $sp, -4
			sw $t0, 0($sp)
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			li $a1, 0
			la $t0, r
			la $a0, ppc
			la $a2, pc
			lw $v0, 0($a2)
			addi $v0, $v0, -4
			sw $v0, 0($a2) 
			jal printAd
			la $a2, pc
			lw $v0, 0($a2)
			addi $v0, $v0, 4
			sw $v0, 0($a2) 
			la $a0, pir
			la $a2, ir
			jal printAd
			la $a0, pa
			la $a2, a
			jal printAd
			la $a0, pib
			la $a2, ib
			jal printAd
			la $a0, paluout
			la $a2, aluout
			jal printAd
			li $v0, 11
			li $a0, 0xd
			syscall
			move $a2, $t0
			la $a0, pv0
			li $a1, 2
			jal printAd
			la $a0, pa0
			li $a1, 4
			jal printAd
			la $a0, pa1
			li $a1, 5
			jal printAd
			la $a0, pt1
			li $a1, 9
			jal printAd
			la $a0, pt2
			li $a1, 10
			jal printAd
			la $a0, pt3
			li $a1, 11
			jal printAd
			li $v0, 11
			li $a0, 0xd
			syscall
			la $a0, pt4
			li $a1, 12
			jal printAd
			la $a0, ps1
			li $a1, 17
			jal printAd
			la $a0, ps2
			li $a1, 18
			jal printAd
			la $a0, ps3
			li $a1, 19
			jal printAd
			la $a0, ps4
			li $a1, 20
			jal printAd
			la $a0, ps5
			li $a1, 21
			jal printAd
			li $v0, 11
			li $a0, 0xd
			syscall
			la $a0, line
			li $v0, 4
			syscall
			li $v0, 11
			li $a0, 0xd
			syscall
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $t0, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 0($sp)
			addi $sp, $sp, 4
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			lw $ra, 0($sp)
			addi $sp, $sp, 4			#6 pop
			jr $ra

printAd:
#prints integer of register within r array
#$a0 assumed to contain the address of string, $a1 holds index, $a2 holds r address
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			addi $sp, $sp, -4
			sw $a1, 0($sp)
			li $v0, 4
			syscall
			sll $a1, $a1, 2
			add $a1, $a1, $a2
			lw $a0, 0($a1)
			jal hexprint
			lw $a1, 0($sp)
			addi $sp, $sp, 4
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

			#takes argument in $a0, which is the address to be addressed within m array.
			#if its out of bounds, exit with an error
			#if its not out of bounds, do nothing
address_check:
			addi $sp, $sp, -4			#3 push
			sw $ra,  0($sp)
			addi $sp, $sp, -4
			sw $t1,  0($sp)
			addi $sp, $sp, -4
			sw $a0,  0($sp)
			addi $sp, $sp, -4
			sw $t2, 0($sp)
			la $t1, MAXMEM
			lw $t1, 0($t1)				#t1 holds value of MAXMEM 
			sll $t1, $t1, 2				#MAXMEM*4, since each index of MAXMEM is 4 bytes
			la $t2, m
			add $t1, $t1, $t2
			bge $a0, $t1, oops			#if addr >= MAXMEM, jump to oops
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			lw $a0,  0($sp)				#else, pop regs and return
			addi $sp, $sp, 4
			lw $t1,  0($sp)
			addi $sp, $sp, 4
			lw $ra,  0($sp)	
			addi $sp, $sp, 4			#3 pop
			jr $ra
oops:	
			la $a0, error3
			li $v0, 4
			syscall
			j finish

		#signex takes an argument in register $a0 and sign extends it to 32 bit.
		#returns sign extended word in $v0

		#signex takes an argument in register $a0 and sign extends it to 32 bit.
		#returns sign extended word in $v0
	signex:		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		addi $sp, $sp, -4
		sw $a0, 0($sp)
		addi $sp, $sp, -4
		sw $s1, 0($sp)
		addi $sp, $sp, -4
		sw $s2, 0($sp)
		move $s1, $a0
		li $s2, 0x0000FFFF
		and $s1, $s1, $s2			#forcibly makes number 16 bits by setting all other bits to 0
		srl $s1, $s1, 15			#isolate sign bit
		li $s2, 1
		beq $s1, $s2, ofill			#if sign bit == 1, go to ofill. Else, go to zfill.
		j zfill

	zfill:	
		li $s2, 0x0000FFFF
		and $v0, $a0, $s2
		lw $s2, 0($sp)
		addi $sp, $sp, 4
		lw $s1, 0($sp)
		addi $sp, $sp, 4
		lw $a0, 0($sp)
		addi $sp, $sp, 4
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	ofill:
		li $s2, 0xFFFF0000
		or $v0, $a0, $s2
		lw $s2, 0($sp)
		addi $sp, $sp, 4
		lw $s1, 0($sp)
		addi $sp, $sp, 4
		lw $a0, 0($sp)
		addi $sp, $sp, 4
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

unimplemented:
			la $a0, error1
			li $v0, 4
			syscall
			la $a0, ir
			lw $a0, 0($a0)
			jal hexprint
			jal printnewl
			j finish

#prints a newline
printnewl:
			addi $sp, $sp, -4
			sw $a0, 0($sp)
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			addi $sp, $sp, -4
			sw $t9, 0($sp)
			li $v0, 11
			li $a0, 13
			syscall
			lw $t9, 0($sp)
			addi $sp, $sp, 4
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $a0, 0($sp)
			addi $sp, $sp, 4
			jr $ra

zeroError:
			la $a0, error4
			li $v0, 4
			syscall
			j finish



