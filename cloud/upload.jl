#!/usr/bin/julia
ddir, bdir = "../data/", "../backup/"
# uploads the json files
for fname∈readdir("../units")
	println("Uploading: ", fname)
	run(`scp -i key.pem -P 27851 ../units/$fname ubuntu@213.21.96.180:servers/gripen2/units/`)
end
for i=1:3600
	sleep(1)
	println("Iteration: ", i, " looking for new files...")
	for fname∈readdir(ddir)
		println("Uploading: ", fname)
		run(`scp -i key.pem -P 27851 $ddir$fname ubuntu@213.21.96.180:servers/gripen2/data/`)
		mv(ddir*fname, bdir*fname, force=true)
	end
end
