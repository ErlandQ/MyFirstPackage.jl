"""
    AbstractLBConfig{D, N}

An abstract type for lattice Boltzmann configurations.
"""
abstract type AbstractLBConfig{D, N} end     

"""
    D2Q9 <: AbstractLBConfig{2, 9}

A lattice Boltzmann configuration for 2D, 9-velocity model.
"""
struct D2Q9 <: AbstractLBConfig{2, 9} end
directions(::D2Q9) = (
        Point(1, 1), Point(-1, 1),
        Point(1, 0), Point(0, -1),
        Point(0, 0), Point(0, 1),
        Point(-1, 0), Point(1, -1),
        Point(-1, -1),
    )

  # directions[k] is the opposite of directions[flip_direction_index(k)
function flip_direction_index(::D2Q9, i::Int)
    return 10 - i
end 

# the density of the fluid, each component is the density of a velocity
struct Cell{N, T <: Real}
    density::NTuple{N, T}
end
# the total density of the fluid
density(cell::Cell) = sum(cell.density)
# the density of the fluid in a specific direction,
# where the direction is an integer
density(cell::Cell, direction::Int) = cell.density[direction]

"""
    momentum(lb::AbstractLBConfig, rho::Cell)

Compute the momentum of the fluid from the density of the fluid.
"""
function momentum(lb::AbstractLBConfig, rho::Cell)
    return mapreduce((r, d) -> r * d, +, rho.density, directions(lb)) / density(rho)
end

Base.:+(x::Cell, y::Cell) = Cell(x.density .+ y.density)
Base.:*(x::Real, y::Cell) = Cell(x .* y.density)

# streaming step
function stream!(
    lb::AbstractLBConfig{2, N},  # lattice configuration
    newgrid::AbstractMatrix{D}, # the updated grid
    grid::AbstractMatrix{D}, # the original grid
    barrier::AbstractMatrix{Bool} # the barrier configuration
) where {N, T, D<:Cell{N, T}}
ds = directions(lb)
@inbounds for ci in CartesianIndices(newgrid)
    i, j = ci.I
    newgrid[ci] = Cell(ntuple(N) do k # collect the densities
        ei = ds[k]
        m, n = size(grid)
        i2, j2 = mod1(i - ei[1], m), mod1(j - ei[2], n)
        if barrier[i2, j2]
            # if the cell is a barrier, the fluid flows back
            density(grid[i, j], flip_direction_index(lb, k))
        else
            # otherwise, the fluid flows to the neighboring cell
            density(grid[i2, j2], k)
        end
    end)
end
end