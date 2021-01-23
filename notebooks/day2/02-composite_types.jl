### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ eb0428ac-5d8c-11eb-09a3-2b3cfc77f3f4
using DSJulia

# ╔═╡ 70be3952-5d8c-11eb-1509-b3f7077d57e0
md"""
# Composite and parametric types

In the previous notebook, we have seen that we can easily extend the type system with our own types in the hierarchy. The interesting thing is to have the concrete 'leafs' on this tree contain data that can be used in the functions.

## Paramametric types

Composite types, sometimes call records, structs or object, can store several values in its *fields*.

When defining a new composite type, we can choose them to be mutable or immuatble:
- mutable types are defined using `mutable struct ... end`, they allow the fields to be changed after the object is created;
- immuatble types are defined similarly using `mutable struct ... end`, after creating the object its fields cannot be changed.
Mutable types are a bit more flexible, though might be a somewhat less safe and are more difficult to work with. As the compiler
knows everything in advance, it might better optimize for immutable types. Which one you choose depends on your application, though
generally immuatable types are the better choice!

As an example, let us define an agent type for an ecological individual-based model (IBM). We create the abstract type `Agent` for which we
can then specify several children types.
"""

# ╔═╡ acd7de0c-5d8c-11eb-120a-8b79f2b8eb3b
abstract type Agent end

# ╔═╡ af8c6460-5d8c-11eb-3ba8-c16e8855e992
md"The concrete types in such an IBM might represent an animal type you want to model, for example preys and predators. Making a concrete type of 
a prey animal, we want each to have an unique identifier (represented by an integer) and a position. As we expect the agent to move, hence changing
its position when our simulation runs, we choose a mutable type."

# ╔═╡ b96a33b8-5d8c-11eb-01de-439f53cdc355
mutable struct Prey <: Agent
    id::Int
    pos
end

# ╔═╡ bcacf89e-5d8c-11eb-0077-e5761b8855a3
md"Notice the type annotation for `id`, which we choose to always reprsenent by an integer."

# ╔═╡ c7a077ba-5d8c-11eb-08bb-07c343ea8ab1
md"Defining a composite type immediately a constructor available."

# ╔═╡ cd0d8636-5d8c-11eb-19f9-4da4550d306f
deer = Prey(1, (0.5, 1.9))

# ╔═╡ ce25e25c-5d8c-11eb-2e8e-b5b1e7350d70
md"You can always check which field names are available."

# ╔═╡ d672cc72-5d8c-11eb-2c06-0341181e3a3d
fieldnames(Prey)

# ╔═╡ dac11770-5d8c-11eb-1058-2d043e172931
md"The fields can be accessed easily:"

# ╔═╡ e7b9023a-5d8c-11eb-1387-cfa7c41ab6ca
fyi(md"This is just syntactic sugar for `getfield`, e.g. `getfield(deer, :id)`")

# ╔═╡ fb6e62d4-5d8c-11eb-34f3-bf3df7cd4cb3
md"Similarly, a predator type can be defined. In addition to an id and position, which each agent has, they also have a size, determining its mobility."

# ╔═╡ 01fe6f9a-5d8d-11eb-0519-03aefcd587bb
mutable struct Predator <: Agent
    id::Int
    pos
    size::Float64
end

# ╔═╡ 05ae1a2a-5d8d-11eb-0ed8-496f48194232
wolf = Predator(2, (0.0, 0.0), 40.0)  # 40 kg wolf

# ╔═╡ 18d04a36-5d8d-11eb-1986-693eaad5d5be
md"Using the `.` syntax for accessing the fields is not very tidy! We should define custom getter functions
for the user to access the relevant fields. We could define `id` and `position` methods to get the respective
fields for the two agents. However, since these fields should be defined for every `Agent` type, we can just create
these for the Agent type!"

# ╔═╡ 1df0419c-5d8d-11eb-3444-d5741bf10d32
id(agent::Agent) = agent.id

# ╔═╡ 234dd2e4-5d8d-11eb-366c-c15474da799f
position(agent::Agent) = agent.pos

# ╔═╡ 23f7e8c4-5d8d-11eb-04af-b5e268c13a14
md"Here, we could theoretically have ommited the type annotation in the function. Then the function would accept objects of the non-agent type and likely yield an error because they don't have the `id` or `pos` field. Now, these functions will return a `MethodError` when given a non-`Agent` input."

# ╔═╡ 330d2090-5d8d-11eb-1003-a52a078514b2
md"A slightly more interesting example is by extending `size`."

# ╔═╡ 375bf8d8-5d8d-11eb-1a49-69905d38effe
Base.size(agent::Predator) = agent.size

# ╔═╡ 39d6d5c4-5d8d-11eb-0e07-11d891ff87a3
size(wolf)

# ╔═╡ 3f5740f6-5d8d-11eb-19c3-ddedf6003e53
md"Here, we had to import `size` because we are extending a function from the `Base` library to work with a new type (doing something vastly different than its original function)."

# ╔═╡ 47049bf0-5d8d-11eb-18c2-733287b69420
md"Similarly, we can program behaviour between the agents."

# ╔═╡ 50f17586-5d8d-11eb-0eec-579467b787d0
begin
	interact(agent1::Agent, agent2::Agent) = nothing
	interact(agent1::Predator, agent2::Prey) = "eat"
	interact(agent1::Prey, agent2::Predator) = "run"
end

# ╔═╡ 585995ae-5d8d-11eb-256f-bd8e9eb52063
md"We have chosen the default behaviour that two Agents of unspecified types do not interact at al, this will now be the case when a prey meets other prey, a predator an other predator or a new third type comes into the equation."

# ╔═╡ 62e49c94-5d8d-11eb-39ac-f30febf282ff
fyi(md"Since in these simple examples, the `interact` methods do not use their arguments, merely perform type checking, we could have written this as `interact(::Agent,::Agent) = ...` etc.")

# ╔═╡ 6e8548b4-5d8d-11eb-3fcc-45cb005e5c5e
md"""
## Paramtric types

Sometimes we want more flexiblility in defining types. Think of designing a new type of matrix. Here you would like to work them for all
numeric datatypes, `Int`, `Int8`, `Float6`, `Rational`, in addition to new datatypes that might not even be defined yet! To this end, we use
*parametric types*, types that depend on another type.

For example, consider a 2-dimensional coordinate:
"""

# ╔═╡ cf6dea8c-5d8d-11eb-3f54-4d947305f5e5
begin
	struct Point{T}
		x::T
		y::T
	end
	
# PASTE HERE YOUR CONSTRUCTORS!

end

# ╔═╡ d305007e-5d8d-11eb-2505-3347d7d1a561
md"Here, each coordinate of the type `Point` has two attributes, `x` and `y`, of the same type. The specific type of Point can vary."

# ╔═╡ d84355d4-5d8d-11eb-2c2c-21daf0364c21
p = Point(1.0, 2.0)

# ╔═╡ db651312-5d8d-11eb-09f1-bb693144d8f7
p_int = Point(1, 2)

# ╔═╡ 8b7688ce-5d8e-11eb-0100-dd2712247ff6
p_string = Point("hello", "goodbye")  # might not make sense but currently allowed!

# ╔═╡ 9c0f7916-5d8e-11eb-15cd-11badf9f9c01
Point([1 2; 3 4], [2 3; 9 4])  # maybe relevant to quantum physics?

# ╔═╡ dd5706ec-5d8d-11eb-29df-75170b547cf8
md"Note that"

# ╔═╡ e799c73e-5d8d-11eb-3df4-13dbef13a342
p isa Point

# ╔═╡ eb563ede-5d8d-11eb-1e91-55bd3b36f4eb
p isa Point{Float64}  # more specific

# ╔═╡ fc2d5c92-5d8d-11eb-08c3-29d0478f1884
p isa Point{Int}  # obviously not true

# ╔═╡ 072f2382-5d8e-11eb-377a-d39d0821559e
p isa Point{Real}  # unexpectedly not true!

# ╔═╡ 17022b06-5d8e-11eb-391b-7194962a2c18
md"The above observation is very important! Even though `Float16 <: Real`, this does not hold for the corresponding parametric types."

# ╔═╡ 393e2f9e-5d8e-11eb-11d7-511c32ce6e48
Point(1, 2.0)  # should error initially, but will be fixed later in the notebook!

# ╔═╡ 4b262a72-5d8e-11eb-02bb-5fb2bd07f280
md"Parametric types can be used in dispatch. For example, if we want to compute the norm of a Point, this would only make sense if Point is a number."

# ╔═╡ 605779e6-5d8e-11eb-3e08-c7420ef76aba
norm(p::Point{T} where {T<:Number}) = sqrt(p.x^2 + p.y^2)

# ╔═╡ 6646eb5c-5d8e-11eb-1e01-f3011c4230de
norm(p)

# ╔═╡ 6960f8d2-5d8e-11eb-0215-2de7b54e3081
norm(p_int)  # dispatch creates a method for this type

# ╔═╡ 8321136a-5d8e-11eb-0da2-e750b81d7ce9
md"""
## Constructors

Constructors are functions that create new objects.

### Outer constructors

We have already seen that when creating a new `struc`, this immediately initiates the constructor (e.g., `Point(1.0, 2.0)`). These can also be made explicitly:

```julia
Point(x::T, y::T) where {T<:Real} = Point{T}(x,y)
```

In a normal file, we could run this, but Pluto does not allow us to have constructors at different places. Copy-paste it to the cell where we defined the `Point` type.

"""

# ╔═╡ e246757e-5d8e-11eb-313c-61a63246cf9a
Point(1, 2.0)

# ╔═╡ ecc14f96-5d8f-11eb-2b18-cb23fad26b6e
Point(1.2)

# ╔═╡ 9d4b9eee-5d8f-11eb-07bb-557415e4ac4a
md"""

The line above yield an error, because there is no constructor method when two inputs are of a different type. The following constructors will resolve such cases satisfactory.

```julia
Point(x::Real, y::Real) = Point(promote(x, y)...)
```

Add it to the definition and see the change!

We can write other constructors just like functions. For example, support that when we provide a single `x`, we want to create a point (x, y):

```julia
Point(x) = Point(x, x)
```
"""

# ╔═╡ 142666de-5d90-11eb-3231-efe53ddc9b0d
md"""

### Inner constructors

The above examples show *outer constructors*. These are defined outside the structure. We can also use *inner constructors*, which are declared within the definition of the type. These make use of the keyword `new`. For example, let us define an ordered pair.
"""

# ╔═╡ 27fcaede-5d90-11eb-1cea-91fcc4b6b0fe
struct OrderedPair
  x
  y
  function OrderedPair(x, y)
    if x < y
      new(x, y)
    else
      new(y, x)
    end
  end
end

# ╔═╡ 2a224fde-5d90-11eb-1c46-3fd248350914
OrderedPair(18, 23)

# ╔═╡ 2c937298-5d90-11eb-06e6-ab70b9d3701e
OrderedPair(8, 2)

# ╔═╡ 2efe030e-5d90-11eb-38ae-092222d3a8d4
fyi(md"For parametric types, the `new` keyword should be type annotated. So, for in the `Point` example one would use `new{T}(x,y)`.")

# ╔═╡ 46df4eb0-5d90-11eb-1fdf-f34a7bcb7191
md"""

## Illustration: iterators

We can extend Julia by making use of establised interfaces, such as for iterators like `a:b`. For example, suppose we want to iterate over the first $n$ squares of natural numbers.
"""

# ╔═╡ a4a1cb18-5d90-11eb-08ee-8570368a056b
struct Squares
    count::Int
end

# ╔═╡ aca1c930-5d90-11eb-29d9-954e097bbe3b
md"To make this an iterator, we just have to extend the `iterate` function of `Base`. This is what is needed for Julia to treat this as an iterator because all functions fall back to this."

# ╔═╡ a9502b64-5d90-11eb-144c-3d7ce0949e67
Base.iterate(S::Squares, state=1) = state > S.count ? nothing : (state*state, state+1)

# ╔═╡ da6cc5b8-5d90-11eb-07ff-db8bdb504054
# check REPL
for i in Squares(7)
    println(i)
end

# ╔═╡ e3759d4c-5d90-11eb-0bea-bb4247623ec2
25 ∈ Squares(10)

# ╔═╡ 07998440-5d91-11eb-1a65-8de428eac89c
sum(Squares(18093))

# ╔═╡ 0b8980aa-5d91-11eb-385b-71568ec0e325
md"Let's give the compiler some additional information!"

# ╔═╡ 192d9fd4-5d91-11eb-1cb9-c706aad03480
Base.eltype(::Type{Squares}) = Int

# ╔═╡ 1fa68c72-5d91-11eb-1102-c18460e92ee6
Base.length(S::Squares) = S.count

# ╔═╡ 26a70358-5d91-11eb-0241-699b5dc4783f
md"Now this works:"

# ╔═╡ 2270e790-5d91-11eb-20e5-29905f232734
collect(Squares(4))

# ╔═╡ 2cbe2370-5d91-11eb-130a-5da52d1a62c8
md"I remember there is a fancy formula to compute the sum of squared natural numbers."

# ╔═╡ 49f1d98c-5d91-11eb-1657-f320e9fcdc0e
Base.sum(S::Squares) = (n = S.count; return n*(n+1)*(2n+1)÷6)

# ╔═╡ 4cb68744-5d91-11eb-2b3e-e7df55888c93
sum(Squares(18093))  # much faster now!

# ╔═╡ 579e3828-5d91-11eb-1d33-b94628d61fc0
md"""

## Illustration: custom matrices

Similarly, we can make our very own matrix types. Consider the Strang matrix, a [tridiagonal matrix](https://en.wikipedia.org/wiki/Tridiagonal_matrix) with 2 on the main diagonal, and -1 on the first diagonal below and above the main diagonal. 
"""

# ╔═╡ e9a99a00-5d91-11eb-2c50-8be452cab83f
struct Strang <: AbstractMatrix{Int}
    n::Int
end

# ╔═╡ ec62c35c-5d91-11eb-3773-b9385f312f7f
Base.size(S::Strang) = (S.n, S.n)

# ╔═╡ efb0b460-5d91-11eb-2534-496df689dc60
Base.getindex(S::Strang, i, j) = i==j ? 2 : (abs(i - j) == 1 ?  -1 : 0)

# ╔═╡ f3c3114c-5d91-11eb-1d37-6d97ea6d267f
S = Strang(1000)  # holy cow! Looks like a real matrix!

# ╔═╡ 04dcda58-5d92-11eb-10ba-396947081338
sum(S)  # works, but slow...

# ╔═╡ 0f878dea-5d92-11eb-0000-b7484532ee70
Base.sum(S::Strang) = 2

# ╔═╡ 11630c02-5d92-11eb-1746-4dabf327fbbe
sum(S)

# ╔═╡ 1e65cb9c-5d92-11eb-3526-332169917fd9
v = randn(1000)

# ╔═╡ 201f59ee-5d92-11eb-33ae-51904d249dd4
S * v  # works, but slow

# ╔═╡ 276e9af4-5d92-11eb-1399-993570859698
function Base.:*(S::Strang, v::Vector)
    n = length(v)
    @assert size(S, 2) == n
    x = similar(v)
    for i in 1:n
        x[i] = v[i]
        i > 1 && (x[i] += v[i-1])
        i < n && (x[i] += v[i+1])
    end
    return x
end

# ╔═╡ 300a8428-5d92-11eb-188b-05d00df4f6a7
S * v  # fast (linear time in v)

# ╔═╡ 3fd82400-5d92-11eb-2b2d-67535d4733e6


# ╔═╡ Cell order:
# ╠═eb0428ac-5d8c-11eb-09a3-2b3cfc77f3f4
# ╠═70be3952-5d8c-11eb-1509-b3f7077d57e0
# ╠═acd7de0c-5d8c-11eb-120a-8b79f2b8eb3b
# ╠═af8c6460-5d8c-11eb-3ba8-c16e8855e992
# ╠═b96a33b8-5d8c-11eb-01de-439f53cdc355
# ╠═bcacf89e-5d8c-11eb-0077-e5761b8855a3
# ╠═c7a077ba-5d8c-11eb-08bb-07c343ea8ab1
# ╠═cd0d8636-5d8c-11eb-19f9-4da4550d306f
# ╠═ce25e25c-5d8c-11eb-2e8e-b5b1e7350d70
# ╠═d672cc72-5d8c-11eb-2c06-0341181e3a3d
# ╠═dac11770-5d8c-11eb-1058-2d043e172931
# ╠═e7b9023a-5d8c-11eb-1387-cfa7c41ab6ca
# ╠═fb6e62d4-5d8c-11eb-34f3-bf3df7cd4cb3
# ╠═01fe6f9a-5d8d-11eb-0519-03aefcd587bb
# ╠═05ae1a2a-5d8d-11eb-0ed8-496f48194232
# ╠═18d04a36-5d8d-11eb-1986-693eaad5d5be
# ╠═1df0419c-5d8d-11eb-3444-d5741bf10d32
# ╠═234dd2e4-5d8d-11eb-366c-c15474da799f
# ╠═23f7e8c4-5d8d-11eb-04af-b5e268c13a14
# ╠═330d2090-5d8d-11eb-1003-a52a078514b2
# ╠═375bf8d8-5d8d-11eb-1a49-69905d38effe
# ╠═39d6d5c4-5d8d-11eb-0e07-11d891ff87a3
# ╠═3f5740f6-5d8d-11eb-19c3-ddedf6003e53
# ╠═47049bf0-5d8d-11eb-18c2-733287b69420
# ╠═50f17586-5d8d-11eb-0eec-579467b787d0
# ╠═585995ae-5d8d-11eb-256f-bd8e9eb52063
# ╠═62e49c94-5d8d-11eb-39ac-f30febf282ff
# ╠═6e8548b4-5d8d-11eb-3fcc-45cb005e5c5e
# ╠═cf6dea8c-5d8d-11eb-3f54-4d947305f5e5
# ╠═d305007e-5d8d-11eb-2505-3347d7d1a561
# ╠═d84355d4-5d8d-11eb-2c2c-21daf0364c21
# ╠═db651312-5d8d-11eb-09f1-bb693144d8f7
# ╠═8b7688ce-5d8e-11eb-0100-dd2712247ff6
# ╠═9c0f7916-5d8e-11eb-15cd-11badf9f9c01
# ╠═dd5706ec-5d8d-11eb-29df-75170b547cf8
# ╠═e799c73e-5d8d-11eb-3df4-13dbef13a342
# ╠═eb563ede-5d8d-11eb-1e91-55bd3b36f4eb
# ╠═fc2d5c92-5d8d-11eb-08c3-29d0478f1884
# ╠═072f2382-5d8e-11eb-377a-d39d0821559e
# ╠═17022b06-5d8e-11eb-391b-7194962a2c18
# ╠═393e2f9e-5d8e-11eb-11d7-511c32ce6e48
# ╠═4b262a72-5d8e-11eb-02bb-5fb2bd07f280
# ╠═605779e6-5d8e-11eb-3e08-c7420ef76aba
# ╠═6646eb5c-5d8e-11eb-1e01-f3011c4230de
# ╠═6960f8d2-5d8e-11eb-0215-2de7b54e3081
# ╠═8321136a-5d8e-11eb-0da2-e750b81d7ce9
# ╠═e246757e-5d8e-11eb-313c-61a63246cf9a
# ╠═ecc14f96-5d8f-11eb-2b18-cb23fad26b6e
# ╠═9d4b9eee-5d8f-11eb-07bb-557415e4ac4a
# ╠═142666de-5d90-11eb-3231-efe53ddc9b0d
# ╠═27fcaede-5d90-11eb-1cea-91fcc4b6b0fe
# ╠═2a224fde-5d90-11eb-1c46-3fd248350914
# ╠═2c937298-5d90-11eb-06e6-ab70b9d3701e
# ╠═2efe030e-5d90-11eb-38ae-092222d3a8d4
# ╠═46df4eb0-5d90-11eb-1fdf-f34a7bcb7191
# ╠═a4a1cb18-5d90-11eb-08ee-8570368a056b
# ╠═aca1c930-5d90-11eb-29d9-954e097bbe3b
# ╠═a9502b64-5d90-11eb-144c-3d7ce0949e67
# ╠═da6cc5b8-5d90-11eb-07ff-db8bdb504054
# ╠═e3759d4c-5d90-11eb-0bea-bb4247623ec2
# ╠═07998440-5d91-11eb-1a65-8de428eac89c
# ╠═0b8980aa-5d91-11eb-385b-71568ec0e325
# ╠═192d9fd4-5d91-11eb-1cb9-c706aad03480
# ╠═1fa68c72-5d91-11eb-1102-c18460e92ee6
# ╠═26a70358-5d91-11eb-0241-699b5dc4783f
# ╠═2270e790-5d91-11eb-20e5-29905f232734
# ╠═2cbe2370-5d91-11eb-130a-5da52d1a62c8
# ╠═49f1d98c-5d91-11eb-1657-f320e9fcdc0e
# ╠═4cb68744-5d91-11eb-2b3e-e7df55888c93
# ╠═579e3828-5d91-11eb-1d33-b94628d61fc0
# ╠═e9a99a00-5d91-11eb-2c50-8be452cab83f
# ╠═ec62c35c-5d91-11eb-3773-b9385f312f7f
# ╠═efb0b460-5d91-11eb-2534-496df689dc60
# ╠═f3c3114c-5d91-11eb-1d37-6d97ea6d267f
# ╠═04dcda58-5d92-11eb-10ba-396947081338
# ╠═0f878dea-5d92-11eb-0000-b7484532ee70
# ╠═11630c02-5d92-11eb-1746-4dabf327fbbe
# ╠═1e65cb9c-5d92-11eb-3526-332169917fd9
# ╠═201f59ee-5d92-11eb-33ae-51904d249dd4
# ╠═276e9af4-5d92-11eb-1399-993570859698
# ╠═300a8428-5d92-11eb-188b-05d00df4f6a7
# ╠═3fd82400-5d92-11eb-2b2d-67535d4733e6