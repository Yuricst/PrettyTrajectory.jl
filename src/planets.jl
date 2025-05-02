"""For plotting planets"""


"""
Plot wireframe of a sphere

# Arguments
- `ax::Union{Axis3,LScene}`: Axis3 or LScene object
- `radius::Real`: radius of the sphere
- `center::Vector`: center of the sphere
- `nsph::Int=20`: number of points along latitude and longitude
- `color=:black`: color of the wireframe
- `linewidth=1.0`: linewidth of the wireframe
"""
function plot_sphere_wireframe!(ax::Union{Axis3,LScene}, radius::Real, center::Vector, nsph::Int=30;
    color=:black, linewidth=1.0, label=nothing)
    # Generate spherical coordinates
    θ = range(0, stop=2π, length=nsph)
    ϕ = range(0, stop=π, length=Int(ceil(nsph/2)))

    # Generate points on the sphere
    xsphere = [center[1] + radius * cos(θ[i]) * sin(ϕ[j]) for j in 1:Int(ceil(nsph/2)), i in 1:nsph]
    ysphere = [center[2] + radius * sin(θ[i]) * sin(ϕ[j]) for j in 1:Int(ceil(nsph/2)), i in 1:nsph]
    zsphere = [center[3] + radius * cos(ϕ[j]) for j in 1:Int(ceil(nsph/2)), i in 1:nsph]
    wireframe!(ax, xsphere, ysphere, zsphere, 
               label=label, color=color, linewidth=linewidth)
    return
end


"""
    plot_planet!(
        ax::Axis3,
        r::Real,
        center::Tuple{Float64, Float64, Float64} = (0.0, 0.0, 0.0);
        rotation::Tuple{Float64, Float64, Float64} = (0.0, 0.0, 0.0),
        n::Int = 30,
        show_wireframe::Bool = false,
        asset_name::String = Makie.assetpath("earth.png")
    )
    
Plot sphere with UV-sphere texture based on an image file.

# Arguments
- `ax::Axis3`: Axis3 to plot on
- `r::Real`: radius of the sphere
- `center::Tuple{Float64, Float64, Float64}`: center of the sphere
- `rotation::Tuple{Float64, Float64, Float64}`: rotation of the sphere, in radians
- `n::Int`: number of points on the sphere
- `show_wireframe::Bool`: whether to show the wireframe of the sphere
- `asset_name::String`: path to the image file

See: https://docs.makie.org/v0.22/reference/plots/mesh#example-bb52943
"""
function plot_planet!(
    ax::Axis3,
    r::Real,
    center::Tuple{Float64, Float64, Float64} = (0.0, 0.0, 0.0);
    rotation = (0.0, 0.0, 0.0),
    #rotation::Tuple{Float64, Float64, Float64} = (0.0, 0.0, 0.0),
    n::Int = 30,
    show_wireframe::Bool = false,
    asset_name::String = Makie.assetpath("earth.png")
)
    # Create vertices for a Sphere
    θ = LinRange(0, pi, n)
    φ2 = LinRange(0, 2pi, 2 * n)
    x2 = [r * cos(φv) * sin(θv) for θv in θ, φv in φ2]
    y2 = [r * sin(φv) * sin(θv) for θv in θ, φv in φ2]
    z2 = [r * cos(θv) for θv in θ, φv in φ2]
    points = vec([Point3f(xv, yv, zv) for (xv, yv, zv) in zip(x2, y2, z2)])

    # The coordinates form a matrix, so to connect neighboring vertices with a face
    # we can just use the faces of a rectangle with the same dimension as the matrix:
    _faces = decompose(QuadFace{GLIndex}, Tessellation(Rect(0, 0, 1, 1), size(z2)))
    # Normals of a centered sphere are easy, they're just the vertices normalized.
    _normals = normalize.(points)

    # Now we generate UV coordinates, which map the image (texture) to the vertices.
    # (0, 0) means lower left edge of the image, while (1, 1) means upper right corner.
    function gen_uv(shift)
        return vec(map(CartesianIndices(size(z2))) do ci
            tup = ((ci[1], ci[2]) .- 1) ./ ((size(z2) .* shift) .- 1)
            return Vec2f(reverse(tup))
        end)
    end

    # We add some shift to demonstrate how UVs work:
    uv = gen_uv(1.0)
    # We can use a Buffer to update single elements in an array directly on the GPU
    # with GLMakie. They work just like normal arrays, but forward any updates written to them directly to the GPU
    uv_buff = Buffer(uv)
    #gb_mesh = GeometryBasics.Mesh(points, _faces; uv = uv_buff, normal = _normals)

    # Apply rotations & shift center
    rotated_points, R = rotate_shift_points(points, rotation, center)
    rotated_normals = [R * n for n in _normals]
    gb_mesh = GeometryBasics.Mesh(rotated_points, _faces; uv = uv_buff, normal = rotated_normals)

    data = load(asset_name)
    color = Sampler(rotl90(data'), x_repeat=:mirrored_repeat,y_repeat=:repeat)
    mesh!(ax, gb_mesh, color = color)
    if show_wireframe
        wireframe!(ax, gb_mesh, color=(:black, 0.2), linewidth=2, transparency=true)
    end
    return 
end