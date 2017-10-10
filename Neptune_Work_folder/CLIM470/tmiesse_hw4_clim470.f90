program hw4
real::Ai,F,Af,delta_t				!Ai(initial temp), delta_t (change in time), F (forcing that will be changing), Af (final temp)
integer::choice2,x
character(len=6)::choice
delta_t=10.0
F=0.05
write(*,*)'input the initial temperature= '
read(*,*)Ai
write(*,*)'choose which case you would like to run (1 or 2)= '
read(*,*)choice2
choice:select case(choice2)
case(1)							!case 1 is linear meaning the forecast will steadily increase	
do x=0,21600,10
	Af=Ai+F*delta_t				! a simple numerical model used to forecast
	F=F+(0.05/2160.0)			! used this to interval F by the timestep
	! if (x==3600) then
		! print*,'Af(1h)=',Af 	
	! end if
	! if (x==7200) then
		! print*,'Af(2h)=',Af 
	! end if
	! if (x==10800) then
		! print*,'Af(3h)=',Af 
	! end if
	! if (x==14400) then
		! print*,'Af(4h)=',Af 
	! end if
	! if (x==18000) then
		! print*,'Af(5h)=',Af 
	! end if
	if (x==21600) then
		print*,'Af(6h)=',Af 
	end if
	if (F>.11) then
		exit
	end if
end do
case(2)							!Case 2 the forecast will increase the first 3 hours than it will decrease					
do x=0,21600,10					!the next 3 hours
	Af=Ai+F*delta_t
	if (x<=10800) then
		if (x==10800) then
			print*,'Af(3)=',Af
		end if
		F=F+(0.05/1080.0)		! this F was intervalled at every 10s within 3 hours (steadliy increasing)
	end if
	if (x>10800) then
		if (F==.025) then
		exit
		end if
		if (x==21600) then
			print*,'Af(6)=',Af
		end if
		F=F-(0.05/1080.0)		! F was intervalled at every 10s for 3 hours (steadily decreasing)
	end if
end do		
end select choice
end program hw4