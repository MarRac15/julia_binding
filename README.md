# Binding Julia with C++, Fortran and Java
>This project explores the possible use cases for Julia in the Euro Fusion Project. It aims to show how well Julia integrates with native code (e.g. C++, Fortran) and how well Julia integrates with Java. At the same time, it works as a really simple example of running workflows - codes from various languages are executed one after another

>This is the result of my research - I will show you everything you need to know in order to run my test programs, tell you about some reocurring errors and show how to avoid them.


<br></br>
# 1) First, let's take a look at my Dockerfile where the whole setup takes place:
## Dockerfile analysis
* [Packages and compilers](#package-installation)
* [Work directory](#work-directory)
* <a href="#c++-compilation">C++ compilation</a>
* <a href="#fortran-compilation">Fortran compilation</a>
* [Java compilation](#java-compilation)
* [Enviromental variables](#enviromental-variables)

<br></br>

## Package installation:

- As you can see, I started by pulling the official julia image in the first line:
  ```dockerfile
  FROM julia:latest
  ```
  
- Then, I run commands to install all the compilers:
  ```dockerfile
  RUN apt-get update && \
      apt-get install -y --no-install-recommends \
      g++ \
      gcc \
      gfortran \
      build-essential \
      openjdk-17-jdk 
  ```

- Julia packages are installed here:
  ```dockerfile
  RUN julia -e 'using Pkg; Pkg.add("JavaCall")'
  ```


## Work directory:
- I create the new "/app" directory during the docker image building process, where all my programs are stored:
  ```dockerfile
  WORKDIR /app
  ```

## <a id="c++-compilation"></a> C++ compilation:
- First, we copy the .cpp file into the work directory ('./' is the relative path to the current working directory).
- Compilation is done by the g++ compiler:
  
```dockerfile
COPY ./gppTest.cpp ./
RUN g++ -shared -o libcppLib.so -fPIC gppTest.cpp
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-o"** and **"-fPIC"** flags!


## Fortran compilation:

- First, we copy the .f90 file into the work directory ('./' is the relative path to the current working directory).
- Compilation is handled by the gfortran compiler:
  
```dockerfile
COPY ./fortranTest.f90 ./
RUN gfortran -shared -o libFortran.so -fPIC fortranTest.f90
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-shared"** and **"-fPIC"** flags!

## Java compilation:

- First, we copy the .java files into the work directory ('./' is the relative path to the current working directory).
- Compilation is handled by the OpenJDK compiler:
  
```dockerfile
COPY ./javaTest.java ./Animal.java ./Zoo.java ./
RUN javac Animal.java Zoo.java javaTest.java
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-shared"** and **"-fPIC"** flags!


## Enviromental variables:

- Make sure that JVM (Java Virtual Machine) knows where to find the compiled classes when running the Julia script:
  
```dockerfile
ENV CLASSPATH /app
```
- I added the following to my Dockerfile so Julia knows where to look for the libraries (/app is my work directory set by WORKDIR):
  
```dockerfile
ENV LD_LIBRARY_PATH="/app:${LD_LIBRARY_PATH}"
```
- In order to avoid warning or error messages, be sure to set:
  
```dockerfile
ENV JULIA_COPY_STACKS=1
```


<br></br>
# 2) Binding with Julia

* <a href="#binding-c++">Binding C++</a>
* [Binding Fortran](#binding-fortran)
* [Binding Java](#binding-java)


<br></br>
## <a id="binding-c++"></a>Binding C++

> There are a few ways of running C++ code within Julia. I only used the simplest one as it suits best our needs. Nevertheless, I'll decribe the other ones in short.

  
### 1) The way I did it - the built in **ccall()** function (recommended):

  
  #### Step by step instructions:

  - In the _gppTest.cpp_ file is my test C++ funtion that will be imported into Julia later on.
    The important part here is to wrap your C++ function with the C interface like this:
  
  ```c++
    extern "C"{ your C++ code ........ }
  ```
  - Remember that your C++ code has to be compiled as a **shared library** (.so file) in order to be loaded - I did this in my Dockerfile (<a href="#c++-compilation">see here</a>).
  - Next, head on to my _binding_cpp.jl_ julia file where the import takes place.
  - The only I had to do was to call the **ccall()** function:
    ```julia
    result = ccall((:NWD, "libcppLib"), Int32, (Int32, Int32), 12, 56)
    ```
  - <a id="ccall-syntax"></a>The syntax for ccall():
    ```
    ccall((:function_name, "path_to_library"), return_type, (argument_types, ), arguments)
    ```
  
  - <a id="library-name"></a>**Note:** _(:function_name, "library name")_ and _(argument_types, )_ are tuples!
  - **Note:** I only use the library name in the _"path_to_library"_ as I have it in my work directory. I also set up the *LD_LIBRARY_PATH* in the Dockerfile.
    
    Normally, library path must be expressed in term of full path, unless the library is in the search path of the OS. If you encounter any problems, try specyfing it like this:
    ```
    const myclib = joinpath(@__DIR__, "libmyclib.so")
    a = ccall((:function_name, myclib), return_type, (arg_types, ), args)
    ```


### Important info: 

- This approach doesnt support object oriented elements of C++ and is definitely limited!
- **Mapping C-types** with Julia is critical for the whole import to work. Some conversion is handled automatically by ccall() but you still need to know the corresponding types.
  
  More on this here: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/#mapping-c-types-to-julia


<br></br>
### 2) Alternative methods:

#### CxxWrap package: 

> This way you can manipulate C++ objects and gain much more control. This is the most powerful, yet the hardest to set up tool. It would be rather unnecessary in simple scenarios.

- **Overview:** you write a wrapper completely in C++ and expose your classes and their methods to Julia. It is then compiled into a shared library file. After you import the library, it will allow you to use imported C++ classes and play with objects in Julia syntax.
- Sources:  
  https://github.com/JuliaInterop/CxxWrap.jl  
  https://tianjun.me/essays/A_Guide_to_Wrap_a_C++_Library_with_CXXWrap.jl_and_BinaryBuilder.jl_in_Julia/


<br></br>  
#### Cxx package:

> This package allows you to write C++ code inside Julia by embedding it.  
For more details, check this: https://juliapackages.com/p/cxx


<br></br>
## Binding Fortran:

> Just like the C language, Fortran can be simply called from Julia by using the built-in ccall() function.


### Explanation and instructions:

- In the _fortranTest.f90_ file is my fortran subroutine that will be called from Julia later on.

  
- **Tip:** it is strongly recommended to add **_bind(C, name="your_func_name")_** next to your function.
  It eliminates errors casued by name mangling (some fortran compilers change names during the compilation process).  
  Here's an example:

  ```fortran
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
  ```


- Remember that your Fortran code has to be compiled as a **shared library** (.so file) in order to be loaded - I did this in my Dockerfile: <a href="#fortran-compilation">here</a>).
- Next, head on to my _binding_fortr.jl_ julia file where the import takes place.
- Now, let's take a look at the **ccall()** function:
```fortran
ccall((:even_odd, "libFortran"), Cvoid, (Ref{Int32},), 7)
```
  
- **Reminder:** see <a href="#ccall-syntax">ccall() syntax</a> 
- **Reminder:** explanation on libraries names <a href="#library-name">here</a>  

- **Important note:** when calling a Fortran function, all inputs must be passed as pointers to allocated values on the heap or stack. In order to avoid segmentaition fault, please add an additional Ptr{..} or Ref{..} wrapper around their type specification.


<br></br>
## Binding Java:

> It's the most advanced operation here, but provides the best functionality! I use JavaCall package that was inspired by the ccall() function, but allows you to work with Java classes.  
> You can import classes from .java files and .jar files as well.



### Explanation and instructions:


#### Preperations and first steps:

- Make sure that you have installed the JavaCall package (like I did in my Dockerfile):
```dockerfile
RUN julia -e 'using Pkg; Pkg.add("JavaCall")'
```
- I created 2 java classes for the purpose of this demo: in the _Animal.java_ and _Zoo.java_ files.
  These are basic classes with some really simple functions.


- Go to the _binding_java.jl_ where the import takes place.
- Be sure to inlcude `using JavaCall` at the start of your file.

- It's best to define the _classpath_ which can then be used in the JVM (Java Virtual Machine) initialization.
- I initialised JVM (Java Virtual Machine) by adding:
  ```
  JavaCall.init([-Djava.class.apth=$classpath])
  ```
  where classpath is your path in a string
  - **Note:** only one JVM can be initialised within a process.
  - **Note:** if you're using a JAR file, then remember to include it in the classpath.

<br></br>  
#### Importing classes:

- Importing classes is done by the @jimport keyword:
  ```julia
  Animal = @jimport Animal
  Zoo = @jimport Zoo
  ```
  - **Note:** it's best to assign the imported class to a variable just like I did it above.


<br></br>
#### Calling constructors:

- Object initialisation via constructor is fairly simple and very intuitive:
  
  ```julia
  my_animal = Animal((jstring, jint, jboolean), "tiger", 7, true)
  my_animal_2 = Animal((jstring, jint, jboolean), "crocodile", 2, false)
  smallZoo = Zoo()
  ```

  - **Note:** it works just like in every object-oriented language, but you provide **types of your parameters** first (as a tuple!) in order to avoid conflicts with java types


<br></br>
#### Calling java methods:

- **jcall()** function allows you to run methods on your objects and much more. You'd use it a lot, because JavaCall provides only a low interface.
  
- I use jcall() here to call "addToZoo" method on a smallZoo object:
  ```julia
  jcall(smallZoo, "addToZoo", jvoid, (Animal,), my_animal)
  ```
- **Syntax for jcall()** looks like this:
  ```julia
  jcall(java_object_receiver, "function_name", return_type, (argument_type1, ), argument1)
  ```

- Of course, you can also assign it to the variable if there is a return value from your method:
  ```julia
  precious_animal = jcall(my_animal, "getSpecies", jstring)
  ```


<br></br>
#### Accessing fields:

- Accessing object's fields is done by calling the **jfield()** function. Example:

  ```julia
  animals_age = jfield(my_animal, "age", jint)
  ```
  
- **Syntax for jfield()** looks like this:

```julia
jfield(java_object, "field_name", field's type)
```

> If you have getters in your class, then you can just use jcall() to access fields.


<br></br>
#### Java types:
> The Java primitive types are aliased to their corresponding types in Julia. That's why it's best to use these aliases.

- The aliases to use:

| Java Type        | Julia Alias|       
| ------------- |:-------------:|
| boolean      | jboolean |
| char      | jchar      |
| int | jint      |
| long      | jlong |
| float      | jfloat      |
| double | jdouble      |

- **Note:** A Java String is represented as a **JString** type.

- If your type is an object, then **JavaObject** can represent it:
```
JavaObject{:T}
```
where T is referring to a Java class name.  
Example in my code:
```julia
firstAnimal = jcall(smallZoo, "getFirstAnimal", JavaObject{:Animal})
```
> You can use `JavaObject{Symbol("java_class_name")}` to indicate the specific Java class. Try it if the first approach doesn't work.


<br></br>
#### The rest of my code:

> I call the jcall() function many times in my code in order to test all my methods. Let me explain all the actions here:  
1. I add the two previously created animals to the smallZoo (to the animals array) - "addToZoo" method.
2. I read the first animal's species (tiger) and print it - "getSpecies" method.
3. I chceck if the animal is in cage (true/false) - method "isInCage" checks the given specie.
4. Results are printed.
5. I read the number of animals in the smallZoo - "getNumberOfAnimals" method (how many objects are in the animals array).
6. I get access to animals array - "getAnimals" method (simple getter).
7. I get the first animal from the given array and then print the result - "getFirstAnimal" method.


<br></br>
### Known issues:

There is one major issue that I encountered and wasn't able to fix:
It occurs while calling jcall() on an array/array lists of objects when you need to specify the "return type".  
It causes JNI not to recognize the method, probably beacuse it cannot match the types.


- Example - I have the following array list:
```julia
animals_array = jcall(smallZoo, "getAnimals", JavaObject{Symbol("java.util.ArrayList")})
```
code in _Zoo.java_ for reference:
```java
    public ArrayList<Animal> animals;

    public ArrayList<Animal> getAnimals()
    {
        return animals;
    }
```

- The error occurs here:
```julia
animal = jcall(animals_array, "get", JavaArray{:Animal}, jint, i)
```
The same error is called here:
```julia
animals_array2 = jfield(smallZoo, "animals", JavaObject{Symbol("LAnimal;")})
```
I tried experimenting with the JavaObject syntax but nothing seems to work properly (LAnimal indicates that it is an array of the Animal type).
It is clearly the problem with the return type, so the JNI doesn't recognize the correct method.

- On the contrary - returning a single object (e.g.: the first object in an array) works like a charm.  
  This works because jcall() is not called on an array:
  ```julia
  firstAnimal = jcall(smallZoo, "getFirstAnimal", JavaObject{:Animal})
  ```


<br></br>
# 3) Binding all these languages in a single file:

> Finally , I created a small test presenting the exchange of information between the imported functions from different languages.

  Take a look at my _binding_all.jl_ file and follow my explanation. I also added a few helpful comments next to the code.

Quick explanation on what it does:

- First, I import the JavaCall package and define the libraries.
- Next, I import the Java classes and create 2 animals via constructor.
- Then, I get access to animals' age values by using the getters and the jcall() function.
- Next, I use the said age values in the C++ function and compute their NWD.
- Then, I import the function "isPrime" from another **julia file** (called _secondTest.jl_) and module:
  ```julia
  include("secondTest.jl")
  using .binding
  ```
  The other file (_secondTest.jl_) looks like this:
  ```julia
  module binding

    export isPrime

    function isPrime(n)
        if n<=1
            return false    
        end

        if n==2
            return true
        else
            for i in 2:n-1

                if n%i == 0
                    return false
                end

                return true
            end
        end
    end
  ```
  Remember to add the `export your_function_name` at the start of the module!
  
- I check if the NWD is a prime number by using the imported julia function.
- Finally, I import the Fortran function and based on the result of the "isPrime" function, I provide either 10 or 20 as the argument.
- At the end of the file, I use `JavaCall.destroy()` to end the JVM session.


<br></br>
# 4) Pure Julia code:

> This is the pure Julia code to test along with the other files that together make up the sample workflow. Take a look at the **_first_test.jl_** file.
In my Dockerfile, it is executed as the last one.


<br></br>
# 5) Starting my demo:

> Everything will work inside the Docker container and is already configured so it should take only 2 commands to run my test programs from this repo.

1. In your terminal, make sure that you're inside the directory where you cloned this repository
2. Run `docker build -t your_name .`
3. Run `docker run --rm your_name`
4. The printed results of my programs should now be visible in the terminal:
   - first: C++ function (NWD function)
   - then: Fortran subroutine (subroutine for printing odd and even numbers)
   - then: Java methods
   - next: results of all these languages working together (from _binding_all.jl_ file)
   - at last: test of the julia code (from _first_test.jl_ file)
