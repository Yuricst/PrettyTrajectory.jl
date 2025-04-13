"""For plotting planets"""


"""
Plot sphere with UV-sphere texture based on an image file

See: https://docs.makie.org/v0.22/reference/plots/mesh#example-bb52943
"""
function plot_planet!(
    ax::Axis3,
    r::Real,
    center::Tuple{Float64, Float64, Float64} = (0.0, 0.0, 0.0);
    x_rotation::Real = 0.0,
    y_rotation::Real = 0.0,
    z_rotation::Real = 0.0,
    n::Int = 30,
    show_wireframe::Bool = false,
    asset_name::String = Makie.assetpath("earth.png")
)
    # Create vertices for a Sphere
    θ = LinRange(0, pi, n)
    φ2 = LinRange(0, 2pi, 2 * n)
    x2 = [center[1] + r * cos(φv) * sin(θv) for θv in θ, φv in φ2]
    y2 = [center[2] + r * sin(φv) * sin(θv) for θv in θ, φv in φ2]
    z2 = [center[3] + r * cos(θv) for θv in θ, φv in φ2]
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

    # Apply rotations
    Rx = [1 0 0; 0 cos(x_rotation) -sin(x_rotation); 0 sin(x_rotation) cos(x_rotation)]
    Ry = [cos(y_rotation) 0 sin(y_rotation); 0 1 0; -sin(y_rotation) 0 cos(y_rotation)]
    Rz = [cos(z_rotation) -sin(z_rotation) 0; sin(z_rotation) cos(z_rotation) 0; 0 0 1]
    R = Rz * Ry * Rx
    
    rotated_points = [Point3f(R * [p[1], p[2], p[3]]) for p in points]
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