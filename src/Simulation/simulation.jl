##### Batch Processing literature example #####

using Printf

include("bp_primary_structs.jl")
include("bp_primary_functions.jl")
include("bp_primary_fitness_improved.jl")
include("ga_alg.jl")

#=

Storages:

1: Feed A
2: Feed B
3: Feed C
4: Hot A
5: Int AB
6: Int BC
7: Impure E
8: Product 1
9: Product 2

=#

#Seed
Random.seed!(Dates.value(convert(Dates.Millisecond, Dates.now())))

function newline() @printf "\n" end
function newline(n::Int) for i in 1:n @printf "\n" end end

function main_func()
	#=

	instructions = [1 1 1 0 0 1 1 0 0 1 0 0 1 1 1 0 1 0 1 0 1; 2 2 0 3 0 2 3 2 0 4 2 0 0 3 0 4 0 0 3 4 0; 2 3 0 3 0 3 4 0 4 3 0 4 4 3 0 4 0 0 3 0 4; 0 0 0 5 0 0 5 0 0 5 0 5 5 5 5 5 0 5 5 0 5]
	durations = [2.70124, 0.98126, 1.68606, 1.20393, 1.47519, 2.6835, 0.124424, 1.24122, 1.42906, 1.66661, 1.01, 1.56972, 0.0876, 2.32005, 0.363589, 0.116204, 0.894455, 0.298675, 1.48692, 0.657943, 0.00235711]

	=#

	##### TESTS #####

	#### CONFIG PARAMETERS ####

	no_units = 4
	no_storages = 9
	no_instructions = 5
	products = [8, 9]
	prices = [10.0, 10.0]

	#### Setup tasks ####

	tasks = []

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[1] = 1.0
	receivers[4] = 1.0
	push!(tasks, RTask("Heating", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[2] = 0.5
	feeders[3] = 0.5
	receivers[6] = 1.0
	push!(tasks, RTask("reaction 1", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[4] = 0.4
	feeders[6] = 0.6
	receivers[8] = 0.4
	receivers[5] = 0.6
	push!(tasks, RTask("reaction 2", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[3] = 0.2
	feeders[5] = 0.8
	receivers[7] = 1.0
	push!(tasks, RTask("reaction 3", feeders, receivers))

	feeders = Dict{Int, Float64}()
	receivers = Dict{Int, Float64}()
	feeders[7] = 1.0
	receivers[5] = 0.1
	receivers[9] = 0.9
	push!(tasks, RTask("still", feeders, receivers))

	#### Setup storages ####	
	
	storages = []
	
	feeders = []
	receivers = [1]
	feed_A = BPS_Storage("Feed_A", Inf, feeders, receivers)
	push!(storages, feed_A)

	feeders = []
	receivers = [2]
	feed_B = BPS_Storage("Feed_B", Inf, feeders, receivers)
	push!(storages, feed_B)

	feeders = []
	receivers = [2, 4]
	feed_C = BPS_Storage("Feed_C", Inf, feeders, receivers)
	push!(storages, feed_C)

	feeders = [1]
	receivers = [3]
	hot_A = BPS_Storage("Hot A", 100, feeders, receivers)
	push!(storages, hot_A)

	feeders = [4]
	receivers = [3, 5]
	int_AB = BPS_Storage("Int AB", 200, feeders, receivers)
	push!(storages, int_AB)

	feeders = [3]
	receivers = [2]
	int_BC = BPS_Storage("Int BC", 150, feeders, receivers)
	push!(storages, int_BC)

	feeders = [4]
	receivers = [5]
	impure_E = BPS_Storage("Impure E", 200, feeders, receivers)
	push!(storages, impure_E)

	feeders = [3]
	receivers = []
	product_1 = BPS_Storage("Product 1", Inf, feeders, receivers)
	push!(storages, product_1)

	feeders = [5]
	receivers = []
	product_2 = BPS_Storage("Product 2", Inf, feeders, receivers)
	push!(storages, product_2)

	##### Reactions #####
	#=

	Mixing		: 1
	Reaction 1	: 2
	Reaction 2	: 3
	Reaction 3	: 4
	Seperation	: 5
	
	=#
	#####################

	#Setup units
	units = []

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[1] = Coefs(2/3, 1/150)

	unit_1 = Unit("Heater", 100.0, unit_tasks)
	push!(units, unit_1)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[2] = Coefs(4/3, 2/75)
	unit_tasks[3] = Coefs(4/3, 2/75)
	unit_tasks[4] = Coefs(2/3, 1/75)

	unit_2 = Unit("Reactor 1", 50.0, unit_tasks)
	push!(units, unit_2)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[2] = Coefs(4/3, 1/60)
	unit_tasks[3] = Coefs(4/3, 1/60)
	unit_tasks[4] = Coefs(2/3, 1/120)

	unit_3 = Unit("Reactor 2", 80.0, unit_tasks)
	push!(units, unit_3)

	unit_tasks = Dict{Int, Coefs}()
	unit_tasks[5] = Coefs(4/3, 1/150)

	unit_4 = Unit("Still", 200.0, unit_tasks)
	push!(units, unit_4)

	#Initial volumes
	initial_volumes = [Inf, Inf, Inf, 0, 0, 0, 0, 0, 0]

	config = BPS_Config(no_units, no_storages, no_instructions, products, prices, units, tasks, storages, initial_volumes)

	params = read_parameters("tmp_params.txt")
	no_runs = 100
	cmd = `reset`

	for runs in 1:no_runs
		cands = generate_pool(config, params)
		run(cmd)
		evolve_chromosomes(config, params, cands)
	end

end

main_func()
