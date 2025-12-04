using GeometryBasics, LinearAlgebra, GLMakie, FileIO


# Create vertices for a Sphere
r = 0.5f0
n = 30
θ = LinRange(0, pi, n)
φ2 = LinRange(0, 2pi, 2 * n)
x2 = [r * cos(φv) * sin(θv) for θv in θ, φv in φ2]
y2 = [r * sin(φv) * sin(θv) for θv in θ, φv in φ2]
z2 = [r * cos(θv) for θv in θ, φv in 2φ2]
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
uv = gen_uv(0.0)
# We can use a Buffer to update single elements in an array directly on the GPU
# with GLMakie. They work just like normal arrays, but forward any updates written to them directly to the GPU
uv_buff = Buffer(uv)
gb_mesh = GeometryBasics.Mesh(points, _faces; uv = uv_buff, normal = _normals)

# f, ax, pl = mesh(gb_mesh,  color = rand(100, 100), colormap=:blues)
# wireframe!(ax, gb_mesh, color=(:black, 0.2), linewidth=2, transparency=true)
# record(f, "uv_mesh.mp4", LinRange(0, 1, 100)) do shift
#     uv_buff[1:end] = gen_uv(shift)
# end

asset_name = joinpath(@__DIR__, "../assets/moon.jpg")
data = load(asset_name) #Makie.assetpath("earth.png"))
color = Sampler(rotl90(data'), x_repeat=:mirrored_repeat,y_repeat=:repeat)


f = Figure(size=(600,400))
ax = Axis3(f[1,1:2]; aspect=:data, azimuth = deg2rad(265), elevation = deg2rad(5))
#f, ax, pl = 
mesh!(ax, gb_mesh,  color = color)
uv_buff[1:end] = gen_uv(1)

display(f)