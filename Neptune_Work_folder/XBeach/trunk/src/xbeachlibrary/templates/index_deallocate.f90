!  DO NOT EDIT THIS FILE
!  But edit variable.f90 and scripts/generate.py
!  Compiling and running is taken care of by the Makefile

## helper functions
<%
def rank(var):
    """the number of dimensions"""
    return len(var["shape"])
%>
    
%for i, var in enumerate(variables):
%if rank(var) > 0:
 case(  ${i+1})
   deallocate(s%${var["name"]})
%endif
%endfor

!directions for vi vim: filetype=fortran : syntax=fortran

