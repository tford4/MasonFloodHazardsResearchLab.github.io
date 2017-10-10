program Assign_3_final

      ! Name - Selina Jahan Sumi
      ! Course No - CSI 501
      ! Assignment No - 3
      ! Due Date - September 21, 2016

       implicit none
     
      ! Declaring variables and allocating space
       	   
       real*4, dimension(:), allocatable :: x
       real*4 :: avg,oldavg,std1,std2
       integer :: n,i
       avg = 0.0
       oldavg = 0.0
       std1= 0.0
       
      ! Open file
      	  
       open (unit=99, file='dat1.dat', status='old', action='read')  
       read(99, *) n
       allocate(x(n))
  
       
       ! Computing average and standard deviation of the numbers
        	
       do i=1,n
           read(99,*) x(i)
           oldavg = avg
           avg = avg + (x(i) - oldavg)/float(i)
           std1 = std1 + (x(i)-oldavg)*(x(i)-avg)
       end do
       
       std2 = sqrt(std1/float(n)) 
      
      ! Printing answers to screen
      	  
   
       write (*,*) ' No of elements n = ', n
       write (*,*) ' Average of the numbers is', avg
       write (*,*) ' Standard Deviation of the numbers is', std2
       write (*,*) ' Done!'
       
       
       deallocate(x)
       
end program Assign_3_final