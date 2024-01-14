.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
SPACE:.asciiz " "
NL:   .asciiz "\n"


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4	# make room in stack for return adress
	sw $ra, 0($sp)		# put return adress into stack
	li $v0, 4 		# load 4 into v0 for string print
	la $a0, str0 		# load str0 into ao for string print
	syscall 		# string print
	li $v0, 5		# Read the number of scores from user
	syscall			# input it
	move $s0, $v0		# $s0 = numScores
	move $t0, $0		# make a zero adress for shifting 
	la $s1, orig		# $s1 = orig
	la $s2, sorted		# $s2 = sorted
loop_in:
	li $v0, 4 		# ready for print string
	la $a0, str1 		# print str1
	syscall 
	sll $t1, $t0, 2		# shift $t0 by 2
	add $t1, $t1, $s1	# add the shift with the orig[i] element
	li $v0, 5		# Read elements from user
	syscall
	sw $v0, 0($t1)		#store inputed number into array
	addi $t0, $t0, 1	#incremement i in for looop
	bne $t0, $s0, loop_in	#if i = len, continue
	
	move $a0, $s0		#load length into a0
	jal selSort		# Call selSort to perform selection sort in original array
	
	li $v0, 4 		#ready for string print
	la $a0, str2 		#print str2
	syscall
	move $a0, $s1		# store start of orig in a0
	move $a1, $s0		# store len of array in a1
	jal printArray		# Print original scores
	li $v0, 4 		#print string 
	la $a0, str3 		#print str3
	syscall 
	move $a0, $s2		# store start of sorted into a0
	jal printArray		# Print sorted scores
	
	li $v0, 4 		#ready for string print
	la $a0, str4 		#print str4
	syscall 
	li $v0, 5		# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0		# store num of scores to drop into a1
	sub $a1, $s0, $a1	# subtract the number of stores to drop from length of array (len-drop)
	move $a0, $s2		# store sorted array into a0
	jal calcSum		# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	add $t0, $zero, $v0	# set t0 to v0 (the calculated sum)
	beq $a1, $zero, DIVBYZERO
	div $t0, $t0, $a1	# divide sum by length
	j PRINTRESULTS
DIVBYZERO:
	add $t0, $zero, $zero
PRINTRESULTS:
	li $v0, 4		# ready for string print
	la $a0, str5		# print str5
	syscall
	
	li $v0, 1		# ready for int print
	addu $a0, $zero, $t0	# put sum/len into a0 and print
	syscall
	
	lw $ra, 0($sp)		# load return adress from stack
	addi $sp, $sp 4		# reset stack
	li $v0, 10 		# exit program
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	add $t0, $zero, $zero 	# set t0 to i = 0
	addi $t1, $a1, -1	# set t1 to len of array for i < a1
	addi $t2, $zero, 1	# set t2 to 1 for beq check
	add $t4, $zero, $a0	# set t4 to start of array
LOOP:
	slt $t3, $t1, $t0	# check if length is less than i
	beq $t3, $t2, END	# if i is greater than or equal to len, end loop
	
	sll $t5, $t0, 2		# set t5 to shift of i
	add $t5, $t5, $t4	# set t5 to the shift based on i plus the start of array
	lw $t6, 0($t5)		# load the value of array at t5 into t6
	
	li  $v0, 1		# print int
    	add $a0, $t6, $zero	# print t6
    	syscall
    	
    	li $v0, 4 		# print string
	la $a0, SPACE		# print space for formatting
	syscall
	
	add $t0, $t0, $t2	# increase i by 1 (i++)
	beq $zero, $zero, LOOP	# endless loop until broken by line 103
END:
	li $v0, 4 		# print string
	la $a0, NL 		# print newline
	syscall
	jr $ra			# return to printarray call
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	add $t0, $zero, $zero	# t0 = i
	add $t1, $zero, $zero	# t1 =  j
	add $t3, $zero, $a0	# t3 = len
SELLOOP:		
	sll $t5, $t0, 2		# shift i by 2 bits
	add $t5, $t5, $s1	# add shift to start of orig
	lw $t6, 0($t5)		# load orig[i] into t6
	
	sll $t5, $t0, 2		# shift i by 2 bits
	add $t5, $t5, $s2	# add shift to start of sorted
	sw $t6, 0($t5)		# store orig[i] into sorted[i]
	
	addi $t0, $t0, 1	# increase i by 1
	bne $t0, $t3, SELLOOP	# continue loop until i = len
	
	add $t0, $zero, $zero	# reset i to 0
	addi $t3, $t3, -1	# t3 = len-1
SELILOOP:
	add $t4, $t0, $zero	# t4 = maxIndex
	addi $t1, $t0, 1	# set j to i + 1
SELJLOOP:
	bge $t1, $a0, SELEND
	sll $t5, $t1, 2		# shift j
	add $t5, $t5, $s2	# add started of sorted by t5 (sorted[j])
	lw $t2, 0($t5)		# load value of sorted[j] into t2
	
	sll $t5, $t4, 2		# shift maxIndex
	add $t5, $t5, $s2	# add maxIndex to sorted (sorted[maxIndex])
	lw $t7, 0($t5)		# load value of sorted[maxIndex] into t7
	
	ble $t2, $t7, CONT	# if sorted[j] <= sorted[maxIndex] do not enter if statement and continue
	add $t4, $t1, $zero	# if sorted[j] > sorted[maxIndex] set maxIndex to equal j
CONT:
	addi $t1, $t1, 1	# increase j by 1
	bne $t1, $a0, SELJLOOP	# if j != len continue loop. if it is equal, continue i loop

	sll $t5, $t4, 2		# shift maxIndex
	add $t5, $t5, $s2	# set t5 to equal sorted[maxIndex]
	lw $t1, 0($t5)		# load sorted[maxIndex] into temp (t1)
	
	sll $t5, $t0, 2		# shift i
	add $t5, $t5, $s2	# set t5 equal to sorted[i]
	lw $t2, 0($t5)		# load sorted[i] into t2
	
	sll $t5, $t4, 2		# shift maxIndex
	add $t5, $t5, $s2	# set t5 to equal sorted[maxIndex]
	sw $t2, 0($t5)		# store the value of sorted[i] into sorted[maxIndex]
	
	sll $t5, $t0, 2		# shift i
	add $t5, $t5, $s2	# set t5 to equal sorted[i]
	sw $t1, 0($t5)		#store the value of sorted[maxIndex] into sorted[i]
	
	addi $t0, $t0, 1	# increase i by 1
	bne $t0, $t3, SELILOOP	# if i = len - 1, continue. If not, loop again
SELEND:
	jr $ra			# return to main
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	addi $sp, $sp, -8	# increase stack to store 2 more things
	sw $ra, 4($sp)		# store return adress to main
	sw $a1, 8($sp)		# store len in stack
	add $v0, $zero, $zero	# set v0 to zero
	ble $a1, $zero, CALCEND	# if len <= 0, return 0. if not, enter recursion
	addi $a1, $a1, -1	# set len to len-1
	jal calcSum		# recurse
	
	sll $t1, $a1, 2		# shift based on len-1
	add $t1, $t1, $a0	# add shift to start of array to get array[len-1]
	lw $t2, 0($t1)		# load value of array[len-1] into t2
	add $v0, $v0, $t2	# add value from recursion to value of array[len-1]
CALCEND:
	lw $a1, 8($sp)		# reset a1 from stack
	lw $ra, 4($sp)		# reset ra from stack
	addi $sp, $sp, 8	# add 8 back to stack
	jr $ra			# return to ra
	
