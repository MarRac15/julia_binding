using JavaCall
classpath="/app"

print("Java here!")

#JVM init:
JavaCall.init(["-Djava.class.path=$classpath"])

#import classes:
Animal = @jimport Animal
Zoo = @jimport Zoo 


#using constructors:
my_animal = Animal((JString, jint, jboolean), "tiger", 7, true)
my_animal_2 = Animal((JString, jint, jboolean), "crocodile", 2, false)
smallZoo = Zoo()


jcall(smallZoo, "addToZoo", jvoid, (Animal,), my_animal)
jcall(smallZoo, "addToZoo", jvoid, (Animal,), my_animal_2)

precious_animal = jcall(my_animal, "getSpecies", JString)
println()
println("Our most precious animal is: $precious_animal")

is_in_cage = jcall(my_animal, "isInCage", jboolean)
is_in_cage_jul = is_in_cage != 0
println("Is $precious_animal in cage? $is_in_cage_jul")

num_of_animals = jcall(smallZoo, "getNumberOfAnimals", jint)
println("The numer of animals in the zoo equals: $num_of_animals")

#---------WIP-----------------:

#this works:
# animals_age = jfield(my_animal, "age", jint)
# println(animals_age)

#this works:
# size = jcall(animals_array, "size", jint)
# println(size) 

animals_array = jcall(smallZoo, "getAnimals", JavaObject{Symbol("java.util.ArrayList")})

firstAnimal = jcall(smallZoo, "getFirstAnimal", JavaObject{:Animal})
firstAnimal_specie = jcall(firstAnimal, "getSpecies", JString)
println("The first animal specie is: $firstAnimal_specie")


#--------------this doesnt work:--------------------------

# for i in 0:num_of_animals-1
#     #error:
#     animal = jcall(animals_array, "get", JavaArray{Animal}, jint, i)
#     ##
#     species = jcall(animal, "getSpecies", JString)
#     print("Animal at index $i is $species")
# end


