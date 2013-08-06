import sys, re, os, csv, pickle

def getlist(file):
	ifile  = open(file, "rb")
	reader = csv.reader(ifile)
	rownum = 0
	mps = []
	for row in reader:
	    # Save header row.
	    if rownum == 0:
        	header = row
		#print header
	    else:
        	colnum = 0
		gclist = {}
	        for col in row:
		    gclist[header[colnum]] = col
	            colnum += 1            	
		mps.append(gclist);
	    rownum += 1
	ifile.close()
	return mps

for i in getlist('currentmps.csv'):
	print i['Constituency'] + " : " + i["State"]
