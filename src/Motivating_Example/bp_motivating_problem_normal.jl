##### Batch Processing motivating problem ##### GA #####
# - s1 -> Mixing - s2 -> Reaction - s3 -> Purification - s4 [Objective value]

using Printf

include("bp_motivating_structs.jl")
include("bp_motivating_functions.jl")
include("ga_alg_normal.jl")
include("bp_motivating_fitness.jl")


#### CONFIG PARAMETERS ####

#=
config_filename = "config_motivating.txt"
config = read_config(config_filename)
=#

### Create Config parameters ###

no_units = 3
no_storages = 4
no_instructions = 2
product = 4

### Load in Units

Units = []

feeder = 1
receiver = 2
alpha = 3.0
beta = 0.03
push!(Units, Unit("Mixer", 100, feeder, receiver, alpha, beta))

feeder = 2
receiver = 3
alpha = 2.0
beta = 2/75
push!(Units, Unit("Reaction", 75, feeder, receiver, alpha, beta))

feeder = 3
receiver = 4
alpha = 1.0
beta = 0.02
push!(Units, Unit("Purification", 50, feeder, receiver, alpha, beta))

### Load in storages

Storages = []

capacity = Inf
feeder_unit = 0
receiver_unit = 1
push!(Storages, Storage(capacity, feeder_unit, receiver_unit))

capacity = 100.0
feeder_unit = 1
receiver_unit = 2
push!(Storages, Storage(capacity, feeder_unit, receiver_unit))

capacity = 100.0
feeder_unit = 2
receiver_unit = 3
push!(Storages, Storage(capacity, feeder_unit, receiver_unit))

capacity = Inf
feeder_unit = 3
receiver_unit = 4
push!(Storages, Storage(capacity, feeder_unit, receiver_unit))

config = BPS_Config(no_units, no_storages, no_instructions, product, Units, Storages)

#=

#### METAHEURISTIC PARAMETERS ####

parameters_filename = "test_parameters.txt"
params = read_parameters(parameters_filename)

##### TEST SOLUTION FITNESS #####

instructions = [1 1 1 1;0 1 1 1;0 0 1 1]
durations = [4.665, 3.479, 2.427, 1.429]

#Test optimal solution

cand = BPS_Program(instructions, durations)

objective = get_fitness(config, params, cand, true)
@printf "\nMotivating example (Optimal): %.3f\n" objective

parameters_filename = "test_parameters.txt"
params = read_parameters(parameters_filename)


parameters_filename = "36_parameters.txt"
params = read_parameters(parameters_filename)

instructions = [1 1 1 0 1 0 1 0 1 0 1 1;
				0 1 1 1 0 1 1 0 1 0 1 1;
				0 0 1 1 1 1 1 1 1 1 1 1]

durations = [6.0, 6.0, 3.519, 2.431, 1.47, 4.046, 2.179, 1.901, 1.891, 1.928, 2.728, 1.907]

@printf "\nSum: %d" sum(durations)

#Test 36-hour solution
cand = BPS_Program(instructions, durations)
objective = get_fitness(config, params, cand, true)
@printf "\n36-hour example: %.3f\n" objective

print("\n")

=#

#=

### RUN TESTS ###


@printf "TESTS: %d" no_tests
newline(2)

for p in 1:no_params

	logfile = open("log_normal_$(p).txt", "a")

	#### METAHEURISTIC PARAMETERS ####
	parameters_filename = "parameters_$(p).txt"
	params = read_parameters(parameters_filename)
	
	#Temporary instructions / duration arrays
	instr_arr::Array{Int, 2} = zeros(config.no_units, params.no_events)	
	durat_arr::Array{Float64} = zeros(params.no_events)

	@printf "Horizon: %.1f Events: %d Generations: %d Population: %d \t--- " params.horizon params.no_events params.generations params.population

	time_sum = 0.0
	top_fitness = 0.0

	for test in 1:no_tests

		#### Test No. ####
		write(logfile, "Test: $(test)\n")

		##### GENERATE CANDIDATES #####
		cands = generate_pool(config, params)

		##### EVOLVE CHROMOSOMES #####
		seconds = @elapsed best_index, best_fitness = evolve_chromosomes(logfile, config, cands, params, false)
		time_sum += seconds

		if best_fitness > top_fitness
			top_fitness = best_fitness
			instr_arr = copy(cands[best_index].instructions)
			durat_arr = copy(cands[best_index].durations)
			time_recorded = seconds
		end

	end

	@printf "Total Time: %.6f Optimal Fitness: %.6f " time_sum top_fitness
	print(instr_arr)
	print(durat_arr)
	newline()

	close(logfile)

end

=#

no_params = 6
no_tests = 30
top_fitness = 0.0
time_recorded = 0.0

#Grid searches 

thetas = 0.1:0.1:1.0
mutations = 0.1:0.1:1.0
deltas = 0:0.125:1.0
sigmas = 1:1:100

# Metaheuristic parameters 



combinations = size(deltas)[1] * size(mutations)[1] * size(thetas)[1]

logfile = open("default.txt", "a")

for p in 1:no_params

	#### METAHEURISTIC PARAMETERS ####
	parameters_filename = "parameters_$(p).txt"
	params_file = read_parameters(parameters_filename)

	overall_top_fitness = 0
	#Keep track of best combination of metaheuristic parameters
	best_theta = 0.1
	best_mutation = 0.1
	best_delta = 0
	best_sigma = 1

	##### GENERATE CANDIDATES #####
	cands = generate_pool(config, params_file)
	comb = 0

for t in thetas
for m in mutations
for d in deltas

	params = Params(params_file.horizon, params_file.no_events, params_file.population, params_file.generations, t, m, d)
	
	#Temporary instructions / duration arrays
	#instr_arr::Array{Int, 2} = zeros(config.no_units, params.no_events)	
	#durat_arr::Array{Float64} = zeros(params.no_events)

	#@printf "Horizon: %.1f Events: %d Generations: %d Population: %d \t--- " params.horizon params.no_events params.generations params.population

	time_sum = 0.0
	top_fitness = 0.0

	for test in 1:no_tests

		#### Test No. ####
		#write(logfile, "Test: $(test)\n")

		##### EVOLVE CHROMOSOMES #####
		#seconds = @elapsed best_index, best_fitness = evolve_chromosomes(logfile, config, cands, params, false)
		#time_sum += seconds

		best_index, best_fitness = evolve_chromosomes(logfile, config, cands, params, false)

		if best_fitness > top_fitness
			top_fitness = best_fitness
			#instr_arr = copy(cands[best_index].instructions)
			#durat_arr = copy(cands[best_index].durations)
		end

	end

	if top_fitness > overall_top_fitness
		overall_top_fitness = top_fitness
		best_theta = t
		best_mutation = m
		best_delta = d
	end

	#@printf "Total Time: %.6f Optimal Fitness: %.6f " time_sum top_fitness
	#print(instr_arr)
	#print(durat_arr)
	#newline()

	#close(logfile)

	comb += 1 #increment combination counter 
	@printf "For P: %d [%d / %d] Theta: %.2f Mutation: %.2f Delta: %.3f Best_t: %.2f Best_m: %.2f Best_d: %.3f \n" p comb combinations t m d best_theta best_mutation best_delta

end #thetas 
end #mutations
end #Deltas 

end #P for end
