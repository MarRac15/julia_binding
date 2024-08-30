
const lib = "./libCookie"

#interact with our C-interface by using ccall:
function new_cookie(taste::String, calories::Int64)
    ccall((:Cookie_new, lib), Ptr{Nothing}, (Cstring, Int64), taste, calories)
end

function getTaste(obj::Ptr{Nothing})
    ccall((:Cookie_getTaste, lib), Cstring, (Ptr{Nothing},), obj)
end

function getCalories(obj::Ptr{Nothing})
    ccall((:Cookie_getCalories, lib), Int64, (Ptr{Nothing},), obj)
end

function delete_cookie(obj::Ptr{Nothing})
    ccall((:Cookie_delete, lib), Nothing, (Ptr{Nothing},), obj)
end

#tests:

cookie = new_cookie("chocolate", 120)
println(getTaste(cookie))
println(getCalories(cookie))
delete_cookie(cookie)