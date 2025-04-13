"""Plot of Earth-Moon system"""

using GLMakie

if !@isdefined PrettyTrajectory
    include(joinpath(@__DIR__, "..", "src", "PrettyTrajectory.jl"))
end

function test_planets()
    # plot of Earth and Moon
    fig = Figure(size=(1000,700))
    ax = Axis3(fig[1,1:2]; aspect=:data, azimuth = deg2rad(265), elevation = deg2rad(5))
    PrettyTrajectory.plot_planet!(ax, 6378.0, (0.0, 0.0, 0.0))  # default is Earth.png
    PrettyTrajectory.plot_planet!(ax, 1737.4, (384400.0, 0.0, 0.0), asset_name=joinpath(@__DIR__, "../assets/moon.jpg"))

    ax_Earth = Axis3(fig[2:3,1], aspect=:data)
    PrettyTrajectory.plot_planet!(ax_Earth, 6378.0, (0.0, 0.0, 0.0)) # default is Earth.png
    ax_Moon = Axis3(fig[2:3,2], aspect=:data)
    PrettyTrajectory.plot_planet!(ax_Moon, 1737.4, (384400.0, 0.0, 0.0), asset_name=joinpath(@__DIR__, "../assets/moon.jpg"))
    save(joinpath(@__DIR__, "plots/test_earth_moon.png"), fig; px_per_unit=2)
    @test true          # just check that the function runs

    # plot with rotated Earth
    fig = Figure(size=(800,800))
    rotations = [
        (0.0, 0.0, 0.0),
        (deg2rad(90), 0.0, 0.0),
        (0.0, deg2rad(90.0), 0.0),
        (0.0, 0.0, deg2rad(90.0)),
    ]
    axes_locations = [(1,1),(1,2),(2,1),(2,2)]
    titles = ["(0,0,0)", "(90,0,0)", "(0,90,0)", "(0,0,90)"]
    for (i,(rotation,axloc)) in enumerate(zip(rotations, axes_locations))
        ax = Axis3(fig[axloc...]; aspect=:data, title="Rotation $(titles[i])")
        PrettyTrajectory.plot_planet!(ax, 1.0, (1.0, 2.0, 3.0), rotation=rotation)
    end
    save(joinpath(@__DIR__, "plots/test_planet_rotations.png"), fig; px_per_unit=2)
    @test true
end

test_planets()