using Makie: RGBA # for visualization
using Makie, CairoMakie
using MyFirstPackage # our package

# Set up the visualization with Makie:
lb = example_d2q9()
vorticity = Observable(curl(momentum.(Ref(lb.config), lb.grid))')
fig, ax, plot = image(vorticity, colormap = :jet, colorrange = (-0.1, 0.1))

# Show barrier
barrier_img = map(x -> x ? RGBA(0, 0, 0, 1) : RGBA(0, 0, 0, 0), lb.barrier)
image!(ax, barrier_img')

# Recording the simulation
record(fig, joinpath(@__DIR__, "barrier.mp4"), 1:100; framerate = 10) do i
    for i=1:20
        step!(lb)
    end
    vorticity[] = curl(momentum.(Ref(lb.config), lb.grid))'
    
    using BenchmarkTools
    @benchmark step!($(deepcopy(lb)))

    record(fig,joinpath(@__DIR__,"barrier.jl"),1:100;framerate = 10) do i
        vorticity[] = curls[i+1]'
    end
end


