"""Run tests for PrettyTrajectory.jl"""

using Test

@testset "geometry" begin
    include("test_geometry.jl")
end

@testset "planet" begin
    include("test_planets.jl")
end

@testset "animate orbit" begin
    include("test_animate_orbit.jl")
end
