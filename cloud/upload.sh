for fname in $(ls ../units)
do
	scp -i key.pem -P 27851 ../units/$fname ubuntu@213.21.96.180:servers/gripen2/units/
done
for fname in $(ls ../data)
do
	scp -i key.pem -P 27851 ../data/$fname ubuntu@213.21.96.180:servers/gripen2/data/
	mv ../data/$fname ../backup/$fname
done
