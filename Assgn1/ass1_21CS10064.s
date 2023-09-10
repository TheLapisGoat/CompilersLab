	.file	"code.c"							# Name of source file
	.text										# Start of the executable code section 
	.globl	calculateFrequency					# Makes the function visible to the linker (Meant for non-static functions)
	.type	calculateFrequency, @function		# Assembler directive stating it is a function, useful for debugger
calculateFrequency:								# Function label
.LFB0:											# Function label
	.cfi_startproc								# CFI directive for debugger
	endbr64										
	pushq	%rbp								# Pushes the base pointer onto the stack
	.cfi_def_cfa_offset 16						
	.cfi_offset 6, -16
	movq	%rsp, %rbp							# Moves the stack pointer to the base pointer
												# As this is a leaf function, memory is not allocated for the stack frame
	.cfi_def_cfa_register 6						
	movq	%rdi, -24(%rbp)						# Moves the first argument (address of start of arr1) to memory 
	movl	%esi, -28(%rbp)						# Moves the second argument (int n) to memory
	movq	%rdx, -40(%rbp)						# Moves the third argument (address of start of fr1) to memory
	movl	$0, -12(%rbp)						# Sets i to 0
	jmp	.L2
.L7:
	movl	$1, -4(%rbp)						# Sets ctr to 1
	movl	-12(%rbp), %eax						# Moves i to eax
	addl	$1, %eax							# Increments eax (increments i)
	movl	%eax, -8(%rbp)						# Moves eax (i) to j
	jmp	.L3										# Jumps to L3
.L5:
	movl	-12(%rbp), %eax						# Moves i to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * i
	movq	-24(%rbp), %rax						# Moves address of start of arr1 to rax
	addq	%rdx, %rax							# Adds rdx to rax === rax = start address of arr1 + 4 * i
	movl	(%rax), %edx						# Moves the value at address rax to edx === edx = arr1[i]
	movl	-8(%rbp), %eax						# Moves j to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rcx					# rcx = 4 * rax === rcx = 4 * j
	movq	-24(%rbp), %rax						# Moves address of start of arr1 to rax
	addq	%rcx, %rax							# Adds rcx to rax === rax = start address of arr1 + 4 * j
	movl	(%rax), %eax						# Moves the value at address rax to eax === eax = arr1[j]
	cmpl	%eax, %edx							# Compares eax (arr1[j]) to edx (arr1[i])
	jne	.L4										# If arr1[i] != arr1[j] jumps to L4
	addl	$1, -4(%rbp)						# Increments ctr
	movl	-8(%rbp), %eax						# Moves j to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * j
	movq	-40(%rbp), %rax						# Moves address of start of fr1 to rax
	addq	%rdx, %rax							# Adds rdx to rax === rax = start address of fr1 + 4 * j
	movl	$0, (%rax)							# Moves 0 to value at address rax === fr1[j] = 0
.L4:
	addl	$1, -8(%rbp)						# Increments j
.L3:
	movl	-8(%rbp), %eax						# Moves j to eax
	cmpl	-28(%rbp), %eax						# Compares n to eax (j)
	jl	.L5										# If j < n jumps to L5
	movl	-12(%rbp), %eax						# Moves i to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * i
	movq	-40(%rbp), %rax						# Moves address of start of fr1 to rax
	addq	%rdx, %rax							# Adds rdx to rax === rax = start address of fr1 + 4 * i
	movl	(%rax), %eax						# Moves the value at address rax to eax === eax = fr1[i]
	testl	%eax, %eax							# Takes the AND of eax and eax.
	je	.L6										# If the AND of eax and eax is 0, jump to L6 === if eax (fr1[i]) == 0, jump to L6
	movl	-12(%rbp), %eax						# Moves i to eax
	cltq										# Converts eac to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * i
	movq	-40(%rbp), %rax						# Moves address of start of fr1 to rax
	addq	%rax, %rdx							# Adds rdx to rax === rax = start address of fr1 + 4 * i
	movl	-4(%rbp), %eax						# Moves ctr to eax
	movl	%eax, (%rdx)						# Moves eax (ctr) to value at address rdx === fr1[i] = ctr
.L6:		
	addl	$1, -12(%rbp)						# Increments i
.L2:		
	movl	-12(%rbp), %eax						# Moves i to eax
	cmpl	-28(%rbp), %eax						# Compares n to i
	jl	.L7										# If i < n then jumps to L7
	nop											# No operation
	nop											# No operation
	popq	%rbp								# Pops rbp
	.cfi_def_cfa 7, 8							
	ret											# Returns
	.cfi_endproc
.LFE0:											# Label referenced for exception related reasons
	.size	calculateFrequency, .-calculateFrequency		# States that the size of the function is the difference between the current location and the label calculateFrequency
	.section	.rodata
.LC0:
	.string	"Element\tFrequency"				# String data for printf
.LC1:
	.string	"%d\t%d\n"							# String data for printf
	.text										# Start of the executable code section
	.globl	printArrayWithFrequency				# Makes the function visible to the linker (Meant for non-static functions)
	.type	printArrayWithFrequency, @function	# Assembler directive stating it is a function, useful for debugger
printArrayWithFrequency:
.LFB1:
	.cfi_startproc								# CFI directive for debugger
	endbr64										
	pushq	%rbp								# Pushes the base pointer onto the stack
	.cfi_def_cfa_offset 16		
	.cfi_offset 6, -16
	movq	%rsp, %rbp							# Moves the stack pointer to the base pointer
	.cfi_def_cfa_register 6	
	subq	$48, %rsp							# Allocates 48 bytes of memory for the stack frame
	movq	%rdi, -24(%rbp)						# Moves the first argument (address of start of arr1) to memory
	movq	%rsi, -32(%rbp)						# Moves the second argument (address of start of fr1) to memory
	movl	%edx, -36(%rbp)						# Moves the third argument (int n) to memory
	leaq	.LC0(%rip), %rax					# Moves the address of the string data for printf to rax
	movq	%rax, %rdi							# Moves the address of the string data for printf to rdi
	call	puts@PLT							# Calls the puts@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
												# The compiler realized that printf has only one argment (the format argument), so instead of using printf, it uses puts.
	movl	$0, -4(%rbp)						# Sets i to 0
	jmp	.L9										# Jumps to L9
.L11:
	movl	-4(%rbp), %eax						# Moves i to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * i
	movq	-32(%rbp), %rax						# Moves address of start of fr1 to rax
	addq	%rdx, %rax							# Adds rdx to rax === rax = start address of fr1 + 4 * i
	movl	(%rax), %eax						# Moves the value at address rax to eax === eax = fr1[i]
	testl	%eax, %eax							# Takes the AND of eax and eax.
	je	.L10									# If the AND of eax and eax is 0, jump to L10 === if eax (fr1[i]) == 0, jump to L10
	movl	-4(%rbp), %eax						# Moves i to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rdx					# rdx = 4 * rax === rdx = 4 * i
	movq	-32(%rbp), %rax						# Moves address of start of fr1 to rax
	addq	%rdx, %rax							# Adds rdx to rax === rax = start address of fr1 + 4 * i
	movl	(%rax), %edx						# Moves the value at address rax to edx === edx = fr1[i]
	movl	-4(%rbp), %eax						# Moves i to eax
	cltq										# Converts eax to rax (long to quadword)
	leaq	0(,%rax,4), %rcx					# rcx = 4 * rax === rcx = 4 * i
	movq	-24(%rbp), %rax						# Moves address of start of arr1 to rax
	addq	%rcx, %rax							# Adds rcx to rax === rax = start address of arr1 + 4 * i
	movl	(%rax), %eax						# Moves the value at address rax to eax === eax = arr1[i]
	movl	%eax, %esi							# Moves eax (arr1[i]) to esi
	leaq	.LC1(%rip), %rax					# Moves the address of the string data for printf to rax
	movq	%rax, %rdi							# Moves rax to rdi
	movl	$0, %eax							# Moves 0 to eax
	call	printf@PLT							# Calls the printf@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
.L10:
	addl	$1, -4(%rbp)						# Increments i
.L9:
	movl	-4(%rbp), %eax						# Moves i to eax
	cmpl	-36(%rbp), %eax						# Compares n to i
	jl	.L11									# If i < n jumps to L11
	nop											# No operation
	nop											# No operation
	leave										# Restores stack and frame pointers
	.cfi_def_cfa 7, 8
	ret											# Returns
	.cfi_endproc
.LFE1:
	.size	printArrayWithFrequency, .-printArrayWithFrequency					# States that the size of the function is the difference between the current location and the label printArrayWithFrequency
	.section	.rodata															# Read only data section
	.align 8																	# Aligns the data to 8 bytes
.LC2:
	.string	"\n\nCount frequency of each integer element of an array:"			# String data for printf
	.align 8
.LC3:
	.string	"------------------------------------------------"					# String data for printf
	.align 8																	# Aligns the data to 8 bytes
.LC4:
	.string	"Input the number of elements to be stored in the array :"			# String data for printf
.LC5:
	.string	"%d"																# String data for scanf
	.align 8
.LC6:
	.string	"Enter each elements separated by space: "							# String data for printf
	.text																		# Start of the executable code section
	.globl	main																# Makes the function visible to the linker (Meant for non-static functions)
	.type	main, @function														# Assembler directive stating it is a function, useful for debugger
main:																			# Function label
.LFB2:	
	.cfi_startproc																# CFI directive for debugger
	endbr64																		
	pushq	%rbp																# Pushes the base pointer onto the stack
	.cfi_def_cfa_offset 16														
	.cfi_offset 6, -16
	movq	%rsp, %rbp															# Moves the stack pointer to the base pointer
	.cfi_def_cfa_register 6
	subq	$832, %rsp															# Allocates 832 bytes of memory for the stack frame
	movq	%fs:40, %rax														
	movq	%rax, -8(%rbp)														# Moves the address of the stack frame to memory
	xorl	%eax, %eax															# Clears eax
	leaq	.LC2(%rip), %rax													# Moves the address of the string data for printf to rax
	movq	%rax, %rdi															# Moves the address of the string data for printf to rdi
	call	puts@PLT															# Calls the puts@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
																				# Prints "\n\nCount frequency of each integer element of an array:\n"
	leaq	.LC3(%rip), %rax													# Moves the address of the string data for printf to rax
	movq	%rax, %rdi															# Moves the address of the string data for printf to rdi
	call	puts@PLT															# Calls the puts@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
																				# Prints "------------------------------------------------\n"
	leaq	.LC4(%rip), %rax													# Moves the address of the string data for printf to rax
	movq	%rax, %rdi															# Moves the address of the string data for printf to rdi
	movl	$0, %eax															# Moves 0 to eax
	call	printf@PLT															# Calls the printf@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
																				# Prints "Input the number of elements to be stored in the array :"
	leaq	-828(%rbp), %rax													# Moves the address of the variable n to rax
	movq	%rax, %rsi															# Moves the address of the variable n to rsi
	leaq	.LC5(%rip), %rax													# Moves the address of the string data for scanf to rax
	movq	%rax, %rdi															# Moves the address of the string data for scanf to rdi
	movl	$0, %eax															# Moves 0 to eax
	call	__isoc99_scanf@PLT													# Calls the __isoc99_scanf@PLT function
	leaq	.LC6(%rip), %rax													# Moves the address of the string data for printf to rax
	movq	%rax, %rdi															# Moves the address of the string data for printf to rdi
	movl	$0, %eax															# Moves 0 to eax
	call	printf@PLT															# Calls the printf@PLT function. PLT stands for Procedure Linkage Table, and is linked by the linker
																				# Prints "Enter each elements separated by space: "
	movl	$0, -824(%rbp)														# Sets i to 0
	jmp	.L13																	# Jumps to L13
.L14:																			
	leaq	-816(%rbp), %rdx													# Moves the address of the start of arr1 to rdx
	movl	-824(%rbp), %eax													# Moves i to eax
	cltq																		# Converts eax to rax (long to quadword)
	salq	$2, %rax															# Shifts rax left by 2 bits === rax = 4 * i
	addq	%rdx, %rax															# Adds rdx to rax === rax = start address of arr1 + 4 * i
	movq	%rax, %rsi															# Moves the address of arr1[i] to rsi
	leaq	.LC5(%rip), %rax													# Moves the address of the string format data for scanf to rax
	movq	%rax, %rdi															# Moves the address of the string format data for scanf to rdi
	movl	$0, %eax															# Moves 0 to eax
	call	__isoc99_scanf@PLT													# Calls the __isoc99_scanf@PLT function
	addl	$1, -824(%rbp)														# Increments i
.L13:
	movl	-828(%rbp), %eax													# Moves n to eax
	cmpl	%eax, -824(%rbp)													# Compares n to i
	jl	.L14																	# If i < n jumps to L14
	movl	$0, -820(%rbp)														# Sets i to 0
	jmp	.L15																	# Jumps to L15
.L16:
	movl	-820(%rbp), %eax
	cltq
	movl	$-1, -416(%rbp,%rax,4)
	addl	$1, -820(%rbp)
.L15:
	movl	-828(%rbp), %eax													# Moves n to eax
	cmpl	%eax, -820(%rbp)													# Compares n to i
	jl	.L16																	# If i < n jumps to L16
	movl	-828(%rbp), %ecx													# Moves n to ecx
	leaq	-416(%rbp), %rdx													# Moves the address of the start of fr1 to rdx
	leaq	-816(%rbp), %rax													# Moves the address of the start of arr1 to rax
	movl	%ecx, %esi															# Moves n to esi
	movq	%rax, %rdi															# Moves the address of the start of fr1 to rdi
	call	calculateFrequency													# Calls the calculateFrequency function
	movl	-828(%rbp), %edx													# Moves n to edx
	leaq	-416(%rbp), %rcx													# Moves the address of the start of arr1 to rcx
	leaq	-816(%rbp), %rax													# Moves the address of the start of fr1 to rax
	movq	%rcx, %rsi															# Moves the address of the start of arr1 to rsi
	movq	%rax, %rdi															# Moves the address of the start of fr1 to rdi
	call	printArrayWithFrequency												# Calls the printArrayWithFrequency function
	movl	$0, %eax															# Moves 0 to eax
	movq	-8(%rbp), %rdx														# Moves the address of the stack frame to rdx
	subq	%fs:40, %rdx														# Subtracts the address of the stack frame from the address of the stack frame
	je	.L18																	# If the address of the stack frame is 0, jump to L18
	call	__stack_chk_fail@PLT												# Terminates the function in case of stack overflow
.L18:
	leave																		# Restores stack and frame pointers
	.cfi_def_cfa 7, 8															# CFI directive for debugger
	ret																			# Returns
	.cfi_endproc																
.LFE2:
	.size	main, .-main														# States that the size of the function is the difference between the current location and the label main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"						# Compiler version
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4: