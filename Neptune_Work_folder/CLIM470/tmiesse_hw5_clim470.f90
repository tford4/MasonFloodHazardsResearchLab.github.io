program homework5
implicit none
character*8::filename
write(*,*)'specify the file to read: '
read(*,*)filename

integer::ierr,i
real :: n
real dimension(:), allocatable :: x
!real :: avg, oldavg, std1, std2
!avg = 0.0
!oldavg = 0.0
!std1 = 0.0



open(10,file=filename,status='old',action='read',iostat=ierr)
if (ierr==0)then
	write(*,*)'file successfully open ',ierr
		read(10,*)n
		allocate( x(n))
else
write(*,*)'file will not open. error code=',ierr
end if
do i=1,n
read(10,*) x(i)
!oldavg = avg
!avg = avg + (x(i) - oldavg)/float(i)
!std1 = std1 + (x(i) - oldavg)*(x(i)-avg)
end do

!std2 = sqrt(std1/float(n))

write (*,*) ' No of elements n=', n
!write (*,*) ' Avg of the number is', avg
!write (*,*) ' Standard Deviation of the file is ', std2
deallocate(x)

close(10)

end program homework5