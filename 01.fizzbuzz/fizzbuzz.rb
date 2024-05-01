num = 1

while num <= 20
    if num % 3 == 0 && num % 5 == 0
        puts "FizzBuzz"
    elsif num % 3 == 0
        puts "Fizz"
    elsif num % 5 == 0
        puts "Buzz"
    else
        puts num
    end
    num += 1
end
