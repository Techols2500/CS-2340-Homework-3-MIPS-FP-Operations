
                        
 ################################### stdDev.asm ######################################
.data
inputfile : .asciiz "input.txt"
prompt: .asciiz "Enter input text filename: "
msg1: .asciiz "The array before:\t"
msg2: .asciiz "The array after: \t"
msg3: .asciiz "the mean is: "
msg4: .asciiz "The median is: "
msg5: .asciiz "The standard deviation is: "
newline : .asciiz "\n"
space : .asciiz " "
buffer: .space 80
intarray: .word 20

.text
main:
   # Pass file name and address of the buffer to the procedure readFile
   la $a0,inputfile
   la $a1, buffer                # address of buffer where dat is to be stored
   jal readFile                  # Call the procedure readFile
   beq $v0,$0,exit                  # Exit, if error occured in opening file
   # Extract integers from ASCII string to integer array  
   la $a0, intarray                # address of integer array
   li $a1, 20                  # maximum number of integers can be stored
   la $a2, buffer                # address input buffer
   jal extractInts                  # Call the procedure extractInts
   move $t7,$v0                  # $t7= number of integers extracted or
                    # $t7= size of the array
   li $v0,4               # print label "The array before:"
   la $a0,msg1
   syscall
   # print the original integer array
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal print                      # Call the procedure print
   # sort the integer array using selection sort
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal selectionSort              # Call the procedure sort
   # pritn the sorted integer array
   li $v0,4               # print label "The array after:"
   la $a0,msg2
   syscall
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal print                      # Call the procedure print
# Calculate and print mean
   la $a0,msg3               # print label "The mean is:"
   li $v0,4
   syscall
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal calMean
   li $v0,2               # print mean
   syscall
   la $a0,newline
   li $v0,4
   syscall
   la $a0,msg4               # print label "The median is:"
   li $v0,4
   syscall
# Calculate and print median
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal calMedian    
   bltz $v1, printFloat           # if $v1 is negative mean median is a float
                    # value (average of middle two numbers)
   # if $v1 is positive means, median is a an integer( middle integer)
   move $a0,$v0
   li $v0,1                 # print median(integer value)
   syscall
   j stdDev               # go to calcualte standard deviation
printFloat:
   li $v0,2
   syscall               # print median(float value)
# Calculate and print standard deviation
stdDev:
   li $v0,4
   la $a0,newline
   syscall
   li $v0,4              
   la $a0,msg5  
   syscall               # print label "The standard deviation is:"
   la $a0,intarray                # address of integer array
   move $a1,$t7                  # $a1= length of the array
   jal calStdDev
   li $v0,2
   syscall                   # print standared deviation
exit:   li $v0, 10                  # Exit the program
   syscall
################################   readFile #####################################
# reads data into a buffer of maximum length 80                              #
#################################################################################
readFile:
   move $t1,$a1               # tempararily store address of buffer in $t1
   # Open file for reading
   li   $v0, 13                     # system call for open file
   li   $a1, 0                      # flag for reading(0-read only)
   syscall                          # open a file

   blt $v0,$0 returnReadFile          # If failed to open input file, return to main
   move $s0, $v0                    # save the file descriptor in $s0
   # Reading from file just opened
   li   $v0, 14                     # system call for reading from file
   move $a0, $s0                    # file descriptor
   move $a1,$t1                  # address of buffer
   li   $a2, 80                    # hardcoded buffer length
   syscall                          # read from file
   # Close input file
   li   $v0, 16                     # system call for reading from file
   move $a0,$s0               # #a0 file descripter
   syscall
   move $v0,$s0                  # return number of character read
returnReadFile:
   jr $ra                      # Return to main program
################################## extractInts ##################################
# Traverses the buffer byte by byte and convertes into a decimal             #
# number and stores the converted numbers into an array of integers             #
#################################################################################
extractInts :
   # read buffer(ASCII string) byte by byte
   li,$s1,-1                      # To store the integer decimal
   li $t0,0
loop1:   lb $t1,($a2)              # Load the address of first byte into $t2
   beq $t1,10,storeintoarray         # if byte is new line(new line means one complete
                    # decimal integer is formed) save the integer into
                              # array
   beq $t1,$zero,returnextractInts      # If $t1 is 0, end of file is reached
                              # thus return to main
   # if byte is not a digit(0-9), ignore it
   blt $t1,48,ignoreNnext          # ignore the byte if $t1<48
   bgt $t1,57,ignoreNnext          # ignore the byte if $t1>57
   # other wise consider it for convertion
   addi $t1,$t1,-48              # Convert charcter digit to decimal digit
                              # by subtracting 48 from ASCII integer.
   bne $s1,-1,multiply10      
   li $s1,0               # if $s1=-1, current byte is the starting digit
                    # thus set $s0 to 0
multiply10:
   li $t3,10        
   mul $s1,$s1,$t3                  # Multiply $s1 with 10
   add $s1,$s1,$t1                  # Add converted decimal digit to $s1
ignoreNnext:            
   add $a2,$a2,1                  # go to next byte
   j loop1               # go to next iteration
# if complete decimal integer is formed, save it into integer array
storeintoarray:                    
   beq $s1,-1,skipStoring         # -1 means , no integer is formed
   sll $t2,$t0,2                  # multiply index with 4
   add $t2,$t2,$a0                  # #t2=address to store integer
   sw $s1,0($t2)                  # Store decimal integer into array
   li $s1,-1                      # Re set $s1 to -1(for fresh integer)
skipStoring:
   addiu $t0,$t0,1                   # increment the index of integer array
   add $a2,$a2,1                  # go to next byte
   beq $t0,20,returnextractInts         # only allow maximum 20 integer
   j loop1
returnextractInts:
   move $v0,$t0                  # return number of integers read(converted)
   jr $ra                      # Return to main program
####################################### print ###################################
# Prints the integer array                                           #
#################################################################################
print:
   move $s0,$a0
   li $t0,0
loop2:
   beq $t0,$a1,returnPrint         # if $t0 = size of the array, return
   li $v0,1
   sll $t1,$t0,2
   add $t1,$t1,$s0
   lw $a0,0($t1)           # load the integer
   syscall               # print integer
   li $v0, 4                        # 4 for printing a string
   la $a0, space                   # Print space
   syscall
   add $t0,$t0,1                  # Move to next integer
   j loop2
returnPrint:
   li $v0, 4                        # 4 for printing a string
   la $a0, newline                   # Print new line
   syscall
   jr $ra                      # Return to main program
################################## selectionSort ################################
# Sorts the integer array using selection sort                              #
#################################################################################
selectionSort:
   li $t0,0                      # $t0= the starting index(j) of intarray
   sub $s0,$a1,1                  # $s1=n-1
outerloop:
   beq $t0,$s0,returnSSort
   move $s1,$t0                  # iMin=j
   add $t1,$t0,1                  # i=j+1
innerloop:
   beq $t1,$a1,check4swap
   sll $t2,$t1,2
   sll $t3,$s1,2
   add $t2,$t2,$a0
   add $t3,$t3,$a0
   lw $t4,0($t3)                  # $t4= intarray[i]
   lw $t5,0($t3)                  # $t5= intarray[iMin]
   blt $t4,$t5,udateI              # Swap $t0 and $t1, if $t0<$t1
   j nextinner

udateI:   move $s1,$t1              # iMin=i
nextinner:
   add $t1,$t1,1
   j innerloop               # go to next iteration of inner loop
check4swap:
   bne $s1,$t0,swap              # swap intarray[j] and intarray[iMin],
                              # if intarray[i]<intarray[iMin]
   j nextouter
# swap intarray[j] and intarray[iMin]
swap:
   sll $t2,$t0,2
   sll $t3,$s1,2
   add $t2,$t2,$a0        
   add $t3,$t3,$a0
   lw $t4,0($t2)        
   lw $t5,0($t3)        
   sw $t4,0($t3)
   sw $t5,0($t2)
nextouter:
   add $t0,$t0,1
   j outerloop               # go to next iteration of outer loop
returnSSort:     
   jr $ra
####################################### calMean #################################
# returns calMean of the given array of integers                           #
#################################################################################
calMean:
   li $t0,0
   mtc1 $t0,$f12                  # sum=0 (keep track sum int $f12)
   mtc1 $t0,$f0
# sum all the integers in the array
calMeanloop:
   beq $t0,$a1,returnCalMean       # if $t0 = size of the array, return to main
   sll $t1,$t0,2
   add $t1,$t1,$a0
   lwc1 $f0,0($t1)           # load integer as float value into $f0
   add.s $f12,$f12,$f0           # add it to $f12
   add $t0,$t0,1           # advance $t0 by 1
   j calMeanloop           # go to next iteration
returnCalMean:
   mtc1 $a1,$f0                  # $f0= n
   div.s $f12,$f12,$f0         # mean=$f12=sum/n
   jr $ra                      # return mean in $f12
#################################### calMedian ##################################
# returns median of the given array of integers                             #
#################################################################################
calMedian:
   div $t0,$a1,2           # $t0=index of middle integer
   mfhi $t1
   beqz $t1,calaverage           # if $t1=0 means, number of integers is even
                    # then calculate average of middle two integers
   sll $t2,$t0,2
   add $t2,$t2,$a0
   lw $v0,0($t2)           # other wise, number of integers is odd
                    # and thus return the middle integer as median
   li $v1,0               # return 0 in $v1, means result is integer
   j returnCalMedian
calaverage:
   sub $t1,$t0,1
   sll $t2,$t0,2
   sll $t3,$t1,2
   add $t2,$t2,$a0        
   add $t3,$t3,$a0
   lw $t4,0($t2)               # load middle two integers    
   lw $t5,0($t3)
   add $t4,$t4,$t5           # sum of middle two integers
   mtc1 $t4,$f12           # $f12= sum of middle two integers
   li $t5,2
   mtc1 $t5,$f0               # $f0= 2
   div.s $f12,$f12,$f0           # $f12= $f12/2
   li $v1,-1                  # return negative value $v1
                    # negative value indicates that result is a float
returnCalMedian:      
   jr $ra               # return to main
#################################### calStdDev ##################################
# returns standard deviation of the given array of integers                   #
#################################################################################
calStdDev:
   add $sp,$sp,-4
   sw $ra,4($sp)                  # save return address
   jal calMean               # $f12= mean
   mov.s $f0,$f12           # copy mean into $f0
   li $t0,0
   mtc1 $t0,$f12                  # sun=0 ( keep track sum in $f12)
loopStdDev:
   beq $t0,$a1,returnStdDev        # if $t0 = size of the array, return to main
   sll $t1,$t0,2
   add $t1,$t1,$a0
   lw $t2,0($t1)           # load integer
   mtc1 $t2,$f1              
   cvt.s.w $f1,$f1           # convert it into single precission value
   sub.s $f2,$f1,$f0             # $f2=ri-ravg
   mul.s $f3,$f2,$f2             # $f3=(ri-ravg)^2
   add.s $f12,$f12,$f3         # $f12=Sum of (ri-ravg)^2
   add $t0,$t0,1
   j loopStdDev               # go to next iteration
returnStdDev:
   sub $t2,$a1,1                  # $t3=n-1
   mtc1 $t2,$f4                  # $f4=n-1
   cvt.s.w $f4,$f4             # CONVERT $t2 into single precission value
   div.s $f12,$f12,$f4         # $f12=sum/n-1
   sqrt.s $f12,$f12               # sqrt($f12)
   lw $ra,4($sp)
   add $sp,$sp,4                  # re store the return address
   jr $ra               # return to main
#################################################################################
