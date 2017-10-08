program weather_conditions                                                                                       
implicit none

! Declare variables used in this program
real :: temp_c	! Temperature in degrees C
character(len=4) :: temp

! Get the temperature in degrees Celsius
write(*,*)’Enter the temperature in degrees Celsius’
read(*,*)temp_c
temp: select case (floor(temp_c))     ! floor(x) returns the greates integer 			less or equal to  x 
case(:-1)
   write(*,*)”It’s below freezing today!”
case(0)
   write(*,*)”It’s exactly at the freezing point.”
case(1:20)
   write(*,*)”It’s cool today.”
case(21:33)
   write(*,*)”It’s warm today.”
case(34:)”It’s hot today.”
end select temp

! Finish up
stop
end program weather_conditions
