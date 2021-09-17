#!/usr/bin/julia
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents
using JSON, PlotlyBase, Pipe
import JLD

# file handling
# ==============

# converts a line (string) to numbers
function line_to_numbers(y, s)
	line = @pipe (split(y, " ")    
  	|> [_[i+1]*_[i] for i in 1:2:length(_)-1]    
  	|> parse.(Int, _, base=16)    
	)
	if s["SensorType"] == "acc"
		line = line[1:end-9]
	end
	return line
end
# convert numbers to real physical values 
to_real(y, s, i) = @pipe (y    
  |> _ * 4.3/2^12    
	|> _ .- s["CalibrationPosition"][i]    
  |> _ * 1/6.5e-3
) 
# converts the file the real physical values as [x, y, z]
function file_to_numbers(fname, s) 
	data = map(x -> line_to_numbers(x, s), readlines(fname)) |> Iterators.flatten |> collect
end

# looks in directotry (dir) and finds unique prefixes
prefixes(dir) = [split(fname, "_")[1] for fname ∈ readdir(dir)] |> union

# clears the data folder
clear_data() = [rm("data/"*fname) for fname∈readdir("data")]

# Layout 
# ==================
app = dash(external_stylesheets=[dbc_themes.BOOTSTRAP])
app.layout = dbc_container(fluid=true, style = Dict("width" => "80%", "padding" => "3%")) do
	dbc_row([
		dbc_col(	
			dbc_dropdownmenu(
				id = "prefix_dd",
				color="primary",
				label="Sensor",
				children = [dbc_dropdownmenuitem(p) for p∈prefixes("data")]
			),
		width=1),
		dbc_col(
			dbc_button(id = "ub", "Update", color="primary", className="mr-1"),
			width=1),
		dbc_col(
			dbc_button(id = "clr", "Clear", color="primary", className="mr-1"),
			width=10)
	 ]),
	dbc_row(
		dbc_col(
			dcc_graph(id = "p0", figure = [0] |> Plot), 
			width=12
		)
	)
end

# Callbacks
# ===================
# Click on "Clear"
callback!(app, Output("prefix_dd", "children"), Input("clr", "n_clicks")) do x
	println(x)
	if x!=nothing
		clear_data()
	end
	[dbc_dropdownmenuitem(p) for p∈prefixes("data")]
end

# Click on "Sensor" or "Update"
callback!(app, Output("p0", "figure"), [Input("ub", "n_clicks"), Input("prefix_dd", "children")]) do x, y
	t, dd_name, data = [], "None", zeros(1, 3)
	# getting the prefix
	for i=1:3
		try
			append!(t, y[i][:props][:n_clicks_timestamp])
		catch
			append!(t, 0)
		end
	end
	if sum(t) != 0
		dd_name = y[argmax(t)][:props][:children]
		s = JSON.parsefile("units/$dd_name.json")
		t0 = time()
		data = Int64[]
		for i=1:100
			try
				println("iteration: ", i)
				fpath = "data/"*dd_name*"_"*string(i)
				println("try to read file: "*fpath)
				x = file_to_numbers(fpath, s)
				println("typeof: ", typeof(x))
				println("size: ", size(x))
				append!(data, x)
				println("")
			catch
				println("loop exit")
				break
			end
		end
		println("time: ", time() - t0)
		if s["SensorType"] == "acc"
			data = @pipe [data[i:3:end] for i=1:3] |> hcat(_...)
		end
	end
	Plot(data, title="Sensor: "*dd_name)
end

# MAIN
# ===================
run_server(app, "0.0.0.0", 8001, debug=true)
