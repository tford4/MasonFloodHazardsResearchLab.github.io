program weather_conditions
implicit none
real::temp_c
character(len=4)::temp
write(*,*)'Enter the temperature in degree Celsius '
read(*,*)temp_c
temp:slect case (floor(temp_c))
	case(:-1)
		write(*,*)"its below freezing"
	case(0)
		write(*,*)"it's exactly at freezing"
	case(21:33)
		write(*,*)"it's warm today"
	case(34)
		write(*,*)"it's hot today"
	end select temp
stop
end program weather_conditions