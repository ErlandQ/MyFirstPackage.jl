using MyFirstPackage
using Test

@testset "greet" begin
    @test greet("Erland") == "Greetings,Erland!"
end

@testset "private_sum" begin
    @test MyFirstPackage.private_sum([1,2,3]) == 6
    @test MyFirstPackage.private_sum(Int[]) == 0
end