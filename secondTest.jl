module secondTest

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


    function randomNumber()
            while true
                n = rand(-1000:1000)
                if n>0
                    return n
                    break
                end
            end
        end


    function runTests()
        n = randomNumber()
        println("Is $n a prime?")

        if isPrime(n)
            println("yes")
        else
            println("no")
        end
    end

end