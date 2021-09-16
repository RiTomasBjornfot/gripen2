#!/usr/bin/julia
using Pipe, JSON, Statistics, Plots

# to be used when implementing binary files!
function saveUInt8(fname, x)
  io = open(fname, "w")
  write(io, x)
  close(io)
end

tonum_acc(y) = @pipe (split(y, " ") 
	|> [_[i+1]*_[i] for i in 1:2:length(_)-1] 
	|> parse.(Int, _, base=16)
	|> _[1:end-9]
)

tonum_pl(y) = @pipe (split(y, " ") |> parse.(Int, _[2]*_[1], base=16)
)

pcalc_acc(y) = @pipe ([mean(y[i:3:length(y)]) for i=1:3]
	|> _ * 4.3/2^12
	|> _ .- s["CalibrationPosition"]
	|> _ * 1/6.5e-3
	|> _ ./ s["CalibrationMagnetud"]
)

pcalc_pl(y) =  y * 4.3/2^12

barplot_acc(arr) = bar([1,2,3], arr, legend = false, ylims = (-1, 1)) |> display
barplot_pl(val) = bar([1], [100*val], legend = false, ylims = (0, 1)) |> display

# MAIN
# ====
unit = ARGS[1]
gr()
println("Using unit: ", unit)

s = JSON.parsefile("units/"*unit*".json")
for ii=1:s["Packages"]
	i, ble_str = 0, []
	while i < s["BlePackageSize"]
		try
			push!(ble_str, readline("fifo/"*unit))
			unit[1] == 'a' && s["Plot"] && tonum_acc(ble_str[end]) |> pcalc_acc |> barplot_acc
			unit[1] == 'p' && s["Plot"] && tonum_pl(ble_str[end]) |> pcalc_pl |> barplot_pl
		catch 
			println("ERROR in Package: ", ii, " Iteration ", i," length: ", length(ble_str[end]))
		end
		i += 1
		sleep(s["WriteSleep"])
	end
	println("Package: ", ii)
	open("data/"*unit*"_"*string(ii), "w") do fp
		[write(fp, x*"\n") for x∈ble_str]
	end
end
