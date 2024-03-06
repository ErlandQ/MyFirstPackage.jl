module MyFirstPackage
using OMEinsum

export greet

 """
 greet (name::String)

 Return a greeting message to input 'name'
 """

function greet(name::String)

return "Greetings,$(name)!"
end
function private_sum(v::AbstractVector{<:Real})
    return ein"i->"(v)[]
    
end
end