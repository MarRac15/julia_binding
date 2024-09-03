using JavaCall
classpath="/app"

lib_cpp = "libcppLib"
lib_fort = "libFortran"

#JVM init:
#JavaCall.init(["-Djava.class.path=$classpath"])

#import java classes:
Animal = @jimport Animal
Zoo = @jimport Zoo 
jstring = @jimport java.lang.String

my_animal_1 = Animal((jstring, jint, jboolean), "elephant", 9, true)
my_animal_2 = Animal((jstring, jint, jboolean), "turtle", 78, false)

#call java methods:
animal_1_age = jcall(my_animal_1, "getAge", jint)
animal_2_age = jcall(my_animal_2, "getAge", jint)
print('\n')
println("elephant's age is: $animal_1_age")
println("turtle's age is: $animal_2_age")

#calling c++ function
nwd = ccall((:NWD, lib_cpp), Int32, (Int32, Int32), animal_1_age, animal_2_age)
println("Nwd of $animal_1_age and $animal_2_age equals: $nwd")


#import the exported function from another Julia module:
include("secondTest.jl")
using .secondTest

prime = isPrime(nwd)
println("Is $nwd prime?")


#calling a fortran subroutine:
if prime==true
    println("yessss")
    ccall((:even_odd, lib_fort), Cvoid, (Ref{Int32},), 20)    
else    
    println("nooo")
    ccall((:even_odd, lib_fort), Cvoid, (Ref{Int32},), 10)
end

print('\n')

JavaCall.destroy()