"""Run tests for PrettyTrajectory.jl"""

using Test

@testset "planet" begin
    include("test_planets.jl")
end
