#!/usr/bin/julia
using Pipe, JSON, Statistics, Plots

tonum(y) = @pipe (split(y, " ") 
	|> [_[i+1]*_[i] for i in 1:2:length(_)-1] 
	|> parse.(Int, _, base=16)
)

pcalc(y) = @pipe ([mean(y[i:3:length(y)]) for i=1:3]
	|> _ * 4.3/2^12
	|> _ .- s["CalibrationPosition"]
	|> _ * 1/6.5e-3
	|> _ ./ s["CalibrationMagnetud"]
)

barplot(arr) = bar([1,2,3], arr, legend = false, ylims = (-1, 1)) |> display

# MAIN
# ====
unit = "a3"
gr()
println("Using unit: ", unit)
ble_str = []
s = @pipe "units/"*unit*".json" |> open |> read |> String |> JSON.parse
for ii=1:s["Packages"]
	i = 0
	while i < s["BlePackageSize"]
		try
			push!(ble_str, readline("fifo/"*unit))
			(i % s["PlotRes"] == 0) && s["Plot"] && tonum(ble_str[end]) |> pcalc |> barplot
			i += 1
		catch
			println("ERROR in Package: ", ii, " Iteration ", i," length: ", length(ble_str[end]))
		end
		sleep(s["WriteSleep"])
	end
	println("Package: ", ii)
	open("data/"*unit*"_"*string(ii), "w") do fp
		[write(fp, x*"\n") for x∈ble_str]
	end
end
