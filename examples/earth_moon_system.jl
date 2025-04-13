"""Plot of Earth-Moon system"""

using GLMakie

include(joinpath(@__DIR__, "..", "src", "PrettyTrajectory.jl"))

fig = Figure(size=(1000,400))
ax = Axis3(fig[1,1], aspect=:data)
PrettyTrajectory.plot_planet!(ax, 6378.0, (0.0, 0.0, 0.0))
PrettyTrajectory.plot_planet!(ax, 1737.4, (384400.0, 0.0, 0.0))
display(fig)