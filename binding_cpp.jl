# using Libdl

println("C++ here!")
result = ccall((:NWD, "libcppLib"), Int32, (Int32, Int32), 12, 56)
println("NWD equals: $result")
print('\n')


