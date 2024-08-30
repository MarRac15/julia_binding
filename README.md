# Binding Julia with C++, Fortran and Java
>This project explores the possible use cases for Julia in the Euro Fusion Project. It aims to show how well Julia integrates with native code (e.g. C++, Fortran) and how well Julia integrates with Java.

This is the result of my research - I will show you everything you need to know in order to run my test programs, tell you about some reocurring errors and show how to avoid them.

# 1) First, let's take a look at my Dockerfile where the whole setup takes place:
## Dockerfile analysis
* [Packages and compilers](#package-installation)
* [Work directory](#work-directory)
* [C++ compilation](#c++-compilation)
* [Fortran compilation](#fortran-compilation)
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

## C++ compilation:
- First, we copy the .cpp file into the work directory ('./' is the relative path to the current working directory)
- Compilation is done by the g++ compiler:
```
COPY ./gppTest.cpp ./
RUN g++ -shared -o libcppLib.so -fPIC gppTest.cpp
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-o"** and **"-fPIC"** flags!


## Fortran compilation:

- First, we copy the .f90 file into the work directory ('./' is the relative path to the current working directory)
- Compilation is handled by the gfortran compiler:
```
COPY ./fortranTest.f90 ./
RUN gfortran -shared -o libFortran.so -fPIC fortranTest.f90
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-shared"** and **"-fPIC"** flags!

## Java compilation:

- First, we copy the .java files into the work directory ('./' is the relative path to the current working directory)
- Compilation is handled by the OpenJDK compiler:
```
COPY ./javaTest.java ./Animal.java ./Zoo.java ./
RUN javac Animal.java Zoo.java javaTest.java
```
- **Note:** we compile it as a shared library file in order to use it later on in the Julia script, be sure to add **"-shared"** and **"-fPIC"** flags!


## Enviromental variables:

- Make sure that JVM (Java Virtual Machine) knows where to find the compiled classes when running the Julia script:
```
ENV CLASSPATH /app
```
- Add the following to my Dockerfile so Julia knows where to look for the libraries (/app is my work directory set by WORKDIR):
```
ENV LD_LIBRARY_PATH="/app:${LD_LIBRARY_PATH}"
```
- In order to avoid warning or error messages, be sure to set:
```
ENV JULIA_COPY_STACKS=1
```

# 2) Binding with Julia
