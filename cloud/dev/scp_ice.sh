#!/usr/bin/bash
scp -i key.pem -P 27851 testfile.txt ubuntu@213.21.96.180:~/tmp/
