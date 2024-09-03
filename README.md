# Binding Julia with C++, Fortran and Java
>This project explores the possible use cases for Julia in the Euro Fusion Project. It aims to show how well Julia integrates with native code (e.g. C++, Fortran) and how well Julia integrates with Java.

This is the result of my research - I will show you everything you need to know in order to run my test programs, tell you about some reocurring errors and show how to avoid them.

# 1) First, let's take a look at my Dockerfile where the whole setup takes place:
## Dockerfile analysis
* [Packages and compilers](#package-installation)
* [Work directory](#work-directory)
* <a href="#c++-compilation">C++ compilation</a>
* <a href="#fortran-compilation">Fortran compilation</a>
* [Java compilation](#java-compilation)
* [Enviromental variables](#enviromental-variables)

## Package installation:
- As you can see, I started by pulling the official julia image in the first line.
- Then, I run commands to install all the compilers:
![obraz](https://github.com/user-attachments/assets/637e1741-4ac1-4fb5-9be9-ac1872cd8a45)
- Julia packages are installed here:
![obraz](https://github.com/user-attachments/assets/118cbd2f-5dd4-4f44-a541-5f8d0e4ae073)


## Work directory:
- I create the new "/app" directory during the docker image building process, where all my programs are stored:
![obraz](https://github.com/user-attachments/assets/8a82ff51-03f1-45fe-97de-995c970315c3)

## <a id="c++-compilation"></a> C++ compilation:
- First, we copy the .cpp file into the work directory ('./' is the relative path to the current working directory)
- Compilation is done by the g++ compiler:
  
```dockerfile
COPY ./gppTest.cpp ./
RUN g++ -shared -o libcppLib.so -fPIC gppTest.cpp
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-o"** and **"-fPIC"** flags!


## Fortran compilation:

- First, we copy the .f90 file into the work directory ('./' is the relative path to the current working directory)
- Compilation is handled by the gfortran compiler:
  
```dockerfile
COPY ./fortranTest.f90 ./
RUN gfortran -shared -o libFortran.so -fPIC fortranTest.f90
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-shared"** and **"-fPIC"** flags!

## Java compilation:

- First, we copy the .java files into the work directory ('./' is the relative path to the current working directory)
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
- Add the following to my Dockerfile so Julia knows where to look for the libraries (/app is my work directory set by WORKDIR):
  
```dockerfile
ENV LD_LIBRARY_PATH="/app:${LD_LIBRARY_PATH}"
```
- In order to avoid warning or error messages, be sure to set:
  
```dockerfile
ENV JULIA_COPY_STACKS=1
```

# 2) Binding with Julia

* [Binding C++](#binding-c++)
* [Binding Fortran](#binding-fortran)
* [Binding Java](#binding-java)


## Binding C++

> There are a few ways of running C++ code within Julia. I only used the simplest one as it suits best our needs. Nevertheless, I'll decribe the other ones in short:


### 1) The way I did it - the built in **ccall()** function (recommended):

  #### Step by step instructions:

  - In the _gppTest.cpp_ file is my test C++ funtion that will be imported into Julia later on.
    The important part here is to wrap your C++ function with the C interface like this:
  
  ```c++
    extern "C"{ your C++ code ........ }
  ```
  - Remember that your C++ code has to be compiled as a **shared library** (.so file) in order to be loaded - I did this in my Dockerfile (<a href="#c++-compilation">see here</a>)
  - Next, head on to my _binding_cpp.jl_ julia file where the import takes place 
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


### 2) Alternative methods:

#### CxxWrap package: (WIP !!!!!)

> This way you can manipulate C++ objects and gain much more control. This is the most powerful, yet the hardest to set up tool. It would be rather unnecessary in simple scenarios.

- **Overview:** you write a wrapper completely in C++ and then compile it into a shared library file. It allows you to use imported C++ classes and play with objects in Julia syntax.
- Sources:
  https://github.com/JuliaInterop/CxxWrap.jl  
  https://tianjun.me/essays/A_Guide_to_Wrap_a_C++_Library_with_CXXWrap.jl_and_BinaryBuilder.jl_in_Julia/

  
#### Basic instructions:
- First, you need to install the package. In Dockerfile it looks like this:
  
```dockerfile
RUN julia -e 'using Pkg; Pkg.add("CxxWrap")'
```
-Your C++ code should include the necessary headers and expose your classes and functions to Julia. Example:
```

```
- Compile your C++ program as a shared library file (just like we did <a href="#c++-compilation">here</a>)

#### Cxx package:

> This package allows you to write C++ code inside Julia by embedding it. For more details, check this: https://juliapackages.com/p/cxx


## Binding Fortran:

> Just like the C language, Fortran can be simply called from Julia by using the built-in ccall() function


### Explanation and instructions:

- In the _fortranTest.f90_ file is my fortran subroutine that will be called from Julia later on

  
- **Tip:** It is strongly recommended to add **_bind(C, name="your_func_name")_** next to your function.
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


- Remember that your Fortran code has to be compiled as a **shared library** (.so file) in order to be loaded - I did this in my Dockerfile: <a href="#fortran-compilation">here</a>)
- Next, head on to my _binding_fortr.jl_ julia file where the import takes place 
- Now, let's take a look at the **ccall()** function:
```fortran
ccall((:even_odd, "libFortran"), Cvoid, (Ref{Int32},), 7)
```
  
- **Reminder:** see <a href="#ccall-syntax">ccall() syntax</a> 
- **Reminder:** explanation on libraries names <a href="#library-name">here</a>  

- **Important note:** when calling a Fortran function, all inputs must be passed as pointers to allocated values on the heap or stack. In order to avoid segmentaition fault, please add an additional Ptr{..} or Ref{..} wrapper around their type specification


## Binding Java:

> It's the most advanced operation here, but provides the best functionality! I use JavaCall package that was inspired by the ccall() function, but allows you to work with Java classes.  
> You can import classes from .java files and .jar files as well.


### Explanation and instructions:


- Make sure that you have installed the JavaCall package (like I did in my Dockerfile):
```dockerfile
RUN julia -e 'using Pkg; Pkg.add("JavaCall")'
```
- I created 2 java classes for the purpose of this demo: in the _Animal.java_ and _Zoo.java_ files.
  These are basic classes with some really simple functions.


- Go to the _binding_java.jl_ file
