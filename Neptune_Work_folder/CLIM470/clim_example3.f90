program example
implicit none
integer::i,j,k
write(*,*)'write numbers to multiple: '
read (*,*)i,j
if(i==0.or.j==0) then
	write(*,*)'Numbers must be different from zero'
	write(*,*)'enter numbers to multiply'
	read(*,*)i,j
end if
k=i*j
write(*,*)'result= ',k
stop
end program example