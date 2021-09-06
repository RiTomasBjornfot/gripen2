#!/usr/bin/julia
ddir, bdir = "../data/", "../backup/"
for i=1:120
	sleep(1)
	println("Iteration: ", i, " looking for new files...")
	for fname∈readdir(ddir)
		run(`scp -i key.pem -P 27851 $ddir$fname ubuntu@213.21.96.180:servers/gripen2/data/`)
		mv(ddir*fname, bdir*fname, force=true)
	end
end
