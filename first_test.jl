function maxElement(A::Vector{Int})
    n = length(A)
    if n<=0
        error("Array size should be greater than 0")
    end

    max = A[1]
    for i in 2:n
        if A[i]>max
            max = A[i]
        end
    end
    return max
end

function randomNumber()
    while true
        n = rand(-1000:1000)
        if n>0
            return n
            break
        end
    end
end

print('\n')
println("Julia workflow example: ")
r = randomNumber()
A = [3, 5, 7, 9, r]


max_elem = maxElement(A)
println("The biggest number in the array is: $max_elem")

languages = ["julia", "python", "R"]
for lang=languages
    println(lang)
end