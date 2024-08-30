# using Libdl

println("Fortran here!")


# lib = Libdl.dlopen("./libFortran.so")

# if lib == C_NULL
#     error("Failed to load the library")
# else
#     println("Library loading succesful")
# end


ccall((:even_odd, "libFortran"), Cvoid, (Ref{Int32},), 7)
print('\n')