subroutine even_odd(j) bind(C, name="even_odd")
    integer:: i
    integer:: j
    do i=1, j
        if (mod(i,2)==0) then
            print *, 'Even number: ', i
        else
            print *, 'Odd number: ', i
        end if
    end do
end subroutine


program fortranTest
    call even_odd(5)
    
end program