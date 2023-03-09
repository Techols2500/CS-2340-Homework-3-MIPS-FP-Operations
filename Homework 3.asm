# Tyler Echols
# Assignment 3 
# CS 2340.004 - Computer Architecture - F20
# Karen Mazidi
########################################################################################
# - read the input file “input.txt” into a buffer in memory
# - extract the string “numbers”, convert them to integers and store in an array
# - print the integers to console
# - sort the integers in place using selection sort
# - print the sorted integers to console
# - calculate the mean, median, and standard deviation, printing results to the console
######################################################################################## 
.data 
arr:	.space	80 	# address of the beginning of the array
arrLen:	.word	0
mean:	.float	0.0 	# address of mean
median:	.word	0	# address of median  
sd:	.float	0.0	# address of standard deviation
fname:	.asciiz		"input.txt" # address of file name 
	.align	2
space:	.asciiz 	" "
	.align	2
newLine:.asciiz     	"\n"
	.align	2
buff:	.space	80	# buff = Buffer, address of buffer
msg_1: 	.asciiz 	"\n Array BEFORE: " 
msg_2: 	.asciiz		"\n Array AFTER: " 
msg_3:	.asciiz		"\n The MEAN of the Array is: " 
msg_4:	.asciiz		"\n The MEDIAN of the Array is: " 
msg_5: 	.asciiz		"\n The STANDARD DEVIATION of the Array is: "
msg_6:	.asciiz		"\n ERROR IN FILE READING. CLOSING PROGRAM." 

.text 

main: 
##################### Instruction 1 #################################
	la   	$a0, fname     	# input file name, set file name as $a0
	la   	$a1, buff     	# address of buffer to read into
	jal	read		# reads from file 
	ble  	$v0, $0, msg_6  
		
	
############################################################################################################################################
  # print out string just read
 	#li   	$v0, 4		# system call for print string   
  	#la	$a0, buff 	# address of buffer to print string 
  	#syscall
 
 
 
 	la 	$a0, arr	# load address put in
	li	$a1, 20 	# 20 is the number of bytes the array can hold 
	la	$a2, buff 	# load buffer into $a2
 
 	jal	extractintegers
 	sw	$v0, arrLen
 
 	li	$a0, 10
 	li	$v0, 11
 	syscall 
 	
 	# Displaying message
	la	$a0, msg_1
	li	$v0, 4
	syscall 
 	
 	la 	$a0, arr	
	li	$a1, 20	        
 	jal	printintarray
 	
 	li	$a0, 10
 	li	$v0, 11
 	syscall 
 	
 	# Displaying message
	la	$a0, msg_2
	li	$v0, 4
	syscall 
 	
 	
 	la      $a0, arr
        li	$a1, 20
 	jal 	sortbyselection
 	
 	
 	
 	la         $a0,arr
        li        $a1, 20
       jal     printintarray
       
        li	$a0, 10
 	li	$v0, 11
 	syscall 
 	
 	
 	# Displaying message
	la	$a0, msg_3
	li	$v0, 4
	syscall 
 	
 	la 	$a0, arr 
 	li 	$v0, 20 
 	jal 	WhatsTheMean
 	
 	swc1 $f12, mean
 	
 	li 	$v0, 2
 	syscall 
 
 	
 	# Displaying message
	la	$a0, msg_4
	li	$v0, 4
	syscall 
 	
 	la 	$a0, arr 
 	li 	$v0, 20 
 	jal  WhatsTheMedian
 	
 	
 	li 	$v0, 2
 	syscall
 	
 	
 	# Displaying message
	la	$a0, msg_5
	li	$v0, 4
	syscall 
	
	
 	lwc1 $f0,mean 		# this store the mean for standard devation to calculate  
 	 
 	la	$a0, arr
 	li	$v0, 20
 	jal	StandardDev 

 	
 	li 	$v0, 2
 	syscall
 	
 exit:
 	li	$v0, 10 
 	syscall 
 	
 	
 

read: 
	# read in a file and saves in a buffer 
	# $a0= faile bing read 
	# $a1, buffer in use 
	
	move	$t1, $a1	# move the buffer in $a1 into $t1 
	li   	$v0, 13      	# system call for open file
  
  	
  	li   	$a1, 0        	# Open for reading (flags are 0: read, 1: write)
	li   	$a2, 0       	# mode is ignored
  	syscall            	# open a file (file descriptor returned in $v0)
 	move 	$s6, $v0      	# save the file descriptor 
 	
############################################################################################################################################
  # read from file just opened
 	 li   	$v0, 14       	# system call for file read
 	 la 	$a0, ($s6)      # file descriptor 
 	 move	$a1,$t1		# move whatever is in $t1 into $a1  
 	 li   	$a2, 80       	# hardcoded buffer length
 	 syscall            	# read from file
	 jr	$ra		# jump return, and return address
	 

############################################################################################################################################
	 	 	 	 	 	 	 	 
##################### Instruction 2 #################################

extractintegers: 
	li 	$t2, 0		# Our counter to count the numbers being loaded into the array  
	li	$t8, 0	  
LoopExtInt: 
		# $a0= Array Address 
		# $a1 = Array Length    
		# $a2 = is the buffer read from
		# $t1 = is the byte 
		# $t2 = the new value converted from ASCII to int (DECEMIAL) Make sure $t2 is cleared out for next value to add into, it is also the accumulator (the counting up)  

	lb 	$t1, ($a2) 		        # loading byte from address at a2 
	
	beqz 	$t1, LoopExtIntExit		# If t1 equals 0 go to LoopExtIntExit
	addi	$a2, $a2, 1			# Increase Addresse by 1, so it loads new letter instead or repeating the same letter  
	
	beq  	$t1, 32, CheckingWhiteSpace  	# Checks for Space
	beq 	$t1, 10, CheckingWhiteSpace 	# Checks for new line   
	beq	$t1, 9,	 CheckingWhiteSpace 	# Checks Horizontal Tab 
	blt 	$t1, 48, Skip			# skip reading what ever is in $t1 because it's something that ASCII dosen't regonize as a number because it something LESS that's not in our number range
	bgt 	$t1, 57, Skip			# skip reading what ever is in $t1 because it's something that ASCII dosen't regonize as a number because it something MORE that's not in our number range
	add	$t8, $t8, 1
	addi 	$t1, $t1, -48 			# $t1 + -48 = new $t1 
	mul	$t2, $t2, 10    		# 10 * $t2 = new $t2
	add   	$t2, $t1, $t2 			# $t2 + $t1 = new $t2
	
	Skip:	 
	
	j 	LoopExtInt 			# jump back into loop 
 
	CheckingWhiteSpace:
	sw 	$t2, ($a0) 			# whatever is in $a0 were also gonna save it in $t2, and even though sw means save word were able to make it weard the word as a number 
	move 	$t2, $0 			# 
	add 	$a0, $a0, 4 			# ADD 4 to $a0 to make a new $a0 
	
	 j	LoopExtInt  			# Goes Back to the top of Loop1WC 
 
	 LoopExtIntExit: 
	 move	$v0, $t8
 	jr 	$ra 				# return to the return address  

	
############################################################################################################################################

##################### Instruction 3 #################################
printintarray: 
 # $a0 = Array Address 
 # $a1 = Array Length 
 # $t1 = What $a0 is being loaded into 
 # $t2 = the word counter from the array 
 
     li     $t2, 0        # 0 (from the Array) is assigned into $t2
     move     $t3, $a0    # move the address of the array into $t3

     LoopPrintIntArray:
     bge     $t2, $a1, LoopExtIntExit # Loop out of the print Pri
      lw     $t1, ($t3)     # Whatever is being held in $t3 because the () means to hold the value in there no matter what, and load it into $t1 as well
      addi    $t3, $t3, 4     # add 4 to whatever is in $t3 and combine those and make them the new $t3
      addi    $t2, $t2, 1    # add 1 into $t2 which is the word counter from the array and combine them to make a new $t2 

      PrintArray:
       move     $a0, $t1     # whatever is the being loaded into $t1 we are putting it into the array address
       li     $v0, 1      # then we tell it to print the array 
       syscall

      li $v0, 4
      la $a0, space
      syscall

      j    LoopPrintIntArray

     LoopPrintIntExit: 
     jr     $ra
                   
                   
############################################################################################################################################

##################### Instruction 4 #################################
sortbyselection:
# A c++ version of this function 
	# $a1 = Array Length
	# Word *a0 = array;
	# Word *a2 = a0 + a1 (* 4);
	# for (Word *t1 = a0; t1 < a2; t1 += 1 (4)) {
	#   for (Word *t2 = t1 + 1 (4); t2 < a2; t2 += 1 (4)) {
	#     if (*t2 < *t1) {
	#       Word t1 = *t2;
	#       *t2 = *t1;
	#       *t1 = tmp;
	#     }
	#   }
	# }
		# $a0 = Array Address
	# $a1 = Array Length
	# Word *a0 = array;
# $a0 = Array Address	
# a1 = size of array/ number of elements in array 
# outter loop looks at beginnig and the end
# inner loop looks at evrything in the middle, in the inner most part of the loop they start comparing 
# t1 and t2 are comparing what each is pointing to, if the outer and the inner are comparing who's bigger and they swap or stay depend on who's the biggest, NOT COMPARING POINTSER JUST WHAT THER AER POINTING TO
	
	# Word *a2 = a0 + a1 (* 4);
	sll $t1, $a1, 2 # $t1 is getting $a1 and 2 to get new array length in bytes 
	add $t1, $t1, $a0 # take the array address and $t1 and save them in a new value to be passed at the end of array
   
	# for (Word *t1 = a0; t1 < a2; t1 += 1 (4)) {
	move $t2, $a0        # move Array Address into $t2
  
	Loop1:
 	bge $t2, $t1, ExitLoop1
 
	#   for (Word *t2 = t1 + 1 (4); t2 < a2; t2 += 1 (4)) {
	addi $t3, $t2, 4 
	Loop2:  
	bge $t3, $t1, ExitLoop2 

	#     if (*t2 < *t1) {
	lw $t4, ($t2)
           lw $t5, ($t3) 

	blt $t4, $t5, ifend 

	#       Word t1 = *t2;
	#       *t2 = *t1;
	#       *t1 = tmp;
	sw $t4, ($t3)
	sw $t5, ($t2) 

	#     }
	ifend:
	addi $t3, $t3, 4
	j  Loop2 

	#   }
	ExitLoop2:
	addi $t2, $t2, 4
	j Loop1  
	# } 
	ExitLoop1: 

	jr $ra 
    
############################################################################################################################################    
            
##################### Instruction 5 #################################
# $a0 = Array Address 
# $a1 = Array Length  
# $t1 = What $a0 is being loaded into 
# $t2 = the word counter from the array
# $f12 = stores the float 
  
WhatsTheMean:
	li 	$t2, 0		# $t2 has 0 bytes stored 
	mtc1 	$t2, $f12	# Assigning $f12 to $t2 to convert into float values   
	mtc1	$t2, $f0	# Assigning $f0 into $t2 to convert to float values 
	
	LoopMean: 
	beq	$t2, $a1,ReturnToMean 	# If it's read the whole array exit out with return to mean 
	mul	$t1, $t2, 4		# 4 * $t2 are $t1 new value 
	add	$t1, $t1, $a0		 # the array address and it's lentgh are being stored in 
	lwc1 	$f0, 0($t1) 		# holds value of $t1 to be converted for $f0 
	add.s	$f12, $f12, $f0		# adds the converted $f0 int $f12 
	add	$t2, $t2, 1		 # $t2 + 1 = new $t2 

	j	LoopMean 
	
	ReturnToMean: 
	mtc1	$a1, $f2	# turns the value of $f2 into a number for $a1 to hold
	div.s	$f12, $f12, $f2	 # divides the floating points of $f2, and $f12 and stores it into $f12 to be calculated ;;ater 
	jr	$ra		 

############################################################################################################################################

##################### Instruction 6 #################################
# a C++ interpetration of this function 
# Word *a0 = array;
# Word *a2 = a0 + a1 (* 4);
# for (Word *t1 = a0; t1 < a2; t1 += 1 (4)) {
#   for (Word *t2 = t1 + 1 (4); t2 < a2; t2 += 1 (4)) {
#     if (*t2 < *t1) {
#       Word t1 = *t2;
#       *t2 = *t1;
#       *t1 = tmp;
#     }
#   }
# }


WhatsTheMedian:
# $a0 = Array Address 
# $a1 = Array Length  

# $a0 - address of array,
# $a1 - number of elements
  
# Form the address of the middle of the array:
  #$t1 = $a1 >> 1
  sll 	$t1, $a1, 1 
  #$t1 = $t1 + $a0
  add 	$t1, $t1, $a0 
# Is the number of elements in the array even or odd?

  # if (($a1 & 1) == 0) {
  andi $t2, $a1, 1 
  bne $t2, $t2, OddMed 
  
      #median = (-4($t1) + 0($t1)) >> 1
      lw $t3, -4($t1)
      lw $t4, 0($t1) 
      
       add $t1, $t3, $t4 
       mtc1 $t1, $f12
      li $t1, 2
      mtc1 $t1, $f2 
       div.s $f12, $f12, $f2 
       j   ExitMed  
  #} 
  
  
  # else {
  OddMed: 
   lw $t1, ($t1) 
   
   ExitMed: 
   jr $ra 
     # median = 0($t1)
  # }
  

	
  
    
############################################################################################################################################
##################### Instruction 7 #################################
StandardDev: 
# $f0 = needs to set to mean value of array (Set as argument before function is called)   
# $a1 = array size 
# $a0 = Array Address
# $t3 = New Array Size 
# $f12 = holds the float value to return to main  		
	
		li	$t3,0 		# $t3 assigned 0
		
		mtc1	$t3,$f12	# $t3 is the new $f12 
		
	STDLoop: 
		beq	$t3,$a1,SDFinished	# if $t3 is at the end of the array looking at the numbers it will go straitght toward the SDFinished  
		sll	$t4,$t3,2		# shift $t4 and $t3 
		add	$t4,$t4,$a0 		# $t4 + $a0 = $t4
		
		 lw	$t4,0($t4)		# load the word that's in $t4 and keep it in the paratheses
		 
		mtc1		$t4,$f1 	# move float value into $t4
		cvt.s.w 	$f1,$f1 	# convert the save value in $f1 into a float  
		
		
		sub.s 	$f6,$f1,$f0 		# subtract the value of $f0, and $f1 into $f6
		mul.s 	$f3,$f6,$f6		# multiply $f6's value and stores in $f3 
		
		add.s 	$f12,$f12,$f3 		# $f3 then gets added to $f12 to make a new $f12
		
		 add	$t3,$t3,1		# $t3 is added by 1 
		j	STDLoop  		# starts over if more valuse to count 
	SDFinished: 
		sub 		$t2,$a1,1 	# $a1 and 1 subtracted and stored into $t2
		mtc1		$t2,$f8 	# $f8 gets moved to a compressor 	
		cvt.s.w		$f8,$f8 	# $f8 value is turened from a letter to a word 
		
		div.s	 	$f12,$f12,$f8	# divide $f8, and $f12 to get new $f12 
		
		sqrt.s 		$f12,$f12 		# $f12 valve is squared rooted and held in #f12 to be given to main 
		
		
		jr	$ra 		



############################################################################################################################################
  
  
 
 

  
 
 
