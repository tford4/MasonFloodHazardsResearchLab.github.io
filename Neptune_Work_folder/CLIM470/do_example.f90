program loop_example
implicit none
! Declare the variables
integer :: n, n_factorial,i

! Get the number to calculate its factorial value
write(*,*)'Enter a intger number'
read(*,*)n
! Calculate the factorial value
n_factorial = 1
do i = 1, n
   n_factorial = n_factorial*i
end do

! Write out the result
write(*,*) 'result  ',n_factorial

end program loop_example
