FROM julia:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    gfortran \
    build-essential \
    openjdk-17-jdk 

WORKDIR /app

#installing packages:
RUN julia -e 'using Pkg; Pkg.add("JavaCall")'

#C++:
#create c++ shared library - will be useful for embedding purposes
COPY ./gppTest.cpp ./
RUN g++ -shared -o libcppLib.so -fPIC gppTest.cpp

#fortran:
COPY ./fortranTest.f90 ./
RUN gfortran -shared -o libFortran.so -fPIC fortranTest.f90

#java:
COPY ./Animal.java ./Zoo.java ./
RUN javac Animal.java Zoo.java
ENV CLASSPATH /app

#set this if you get a warning or an error message:
ENV JULIA_COPY_STACKS=1
#set this so julia knows where to look for the libraries
ENV LD_LIBRARY_PATH="/app:${LD_LIBRARY_PATH}"
 
COPY ./secondTest.jl ./binding_cpp.jl ./binding_java.jl ./binding_fort.jl ./binding_all.jl ./

CMD bash -c "julia -e 'include(\"binding_cpp.jl\"); include(\"binding_fort.jl\"); include(\"binding_java.jl\"); include(\"binding_all.jl\");'"