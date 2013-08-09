# This script outputs the files for file writing to wikipedia
import sys, re, os, csv, pickle
#Lets make a candidate class which has all the properties we need
class Candidate:
	def __init__(self, kwargs={}, **args):
		self.data = {}
		self.data.update(kwargs)
		if args:
			self.data.update(args)
		self.data.setdefault('Candidate','')
		self.data.setdefault('Constituency','')
		self.data.setdefault('Party','')
		self.data.setdefault('State','')
		self.data.setdefault('Education','')
		self.data.setdefault('Photo','')
		self.data.setdefault('Sex','')
		self.data.setdefault('Caste','')
		self.data.setdefault('Religion','')
		self.data.setdefault('CrimeAccusationInstances','')
		self.data.setdefault('PreviousOfficeTitle','')
		self.data.setdefault('DateOfBirth','')
		self.data.setdefault('AlmaMater','')
		self.data.setdefault('Email','')
		self.data.setdefault('Phone','')
		self.data.setdefault('Tag','')
		self.data.setdefault('Profession','')
		self.data.setdefault('Website','')
		self.data.setdefault('Candidature','')
		self.data.setdefault('Networth','')
		self.data.setdefault('PAN','')
		self.data.setdefault('Sections','')
		self.data.setdefault('Criminal cases','')
	def set(**data):
		if not data:
			self.data.update(data)
	
	def write(self):
		return """xxxx
'''%(Candidate)s'''
{{#widget:Google_News|query={{PAGENAME}}}}
{{Politician
|Constituency=%(Constituency)s
|Party=%(Party)s
|State=%(State)s
|Education=%(Education)s
|Photo=%(Photo)s
|Sex=%(Sex)s
|Caste=%(Caste)s
|Religion=%(Religion)s
|CrimeAccusationInstances=%(CrimeAccusationInstances)s
|PreviousOfficeTitle=%(PreviousOfficeTitle)s
|DateOfBirth=%(DateOfBirth)s
|AlmaMater=%(AlmaMater)s
|Profession=%(Profession)s
|Website=%(Website)s
|Email=%(Email)s
|Phone=%(Phone)s
|Tag=%(Tag)s
|Candidature=%(Candidature)s
|Networth=%(Networth)s
|PAN=%(PAN)s
}}
==Early Education==
==Political Career==
==Causes==
Check for the political parties agenda, no causes currently associated with %(Candidate)s. You can list or vote on your cause at [http://www.voiceofthenation.org/ VoiceOfTheNation].
==Controversies==
=== Criminal Cases ===
Based on data from [http://www.nocriminals.org NoCriminals.org]
==== Sections ====
%(Sections)s
==== Details ====
%(Criminal cases)s
==Personal Wealth==
Details of assets owned by %(Candidate)s.
==Track record in Public Office==
Check details on [http://www.govcheck.org Govcheck] for Rajya Sabha and Lok Sabha attendance and work resume. Check details on [http://www.mumbaivotes.org MumbaiVotes] for local or city body attendance and work resume.

{{#widget:Wikipedia|query={{PAGENAME}}}}
yyyy\n""" % self.data
	
	def commit(self):
		f = open(".\\output\\%s.dat" % self.data["Candidate"], "w+")
		f.write(self.write())
		f.close();


	

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

"""{{Politician
|Constituency=%(Constituency)s
|Party=%(Party)s
|State=%(State)s
|Education=%(Education)s
|Photo=%(Photo)s
|Sex=%(Sex)s
|Caste=%(Caste)s
|Religion=%(Religion)s
|CrimeAccusationInstances=%(CrimeAccusationInstances)s
|PreviousOfficeTitle=%(PreviousOfficeTitle)s
|DateOfBirth=%(DateOfBirth)s
|AlmaMater=%(AlmaMater)s
|Profession=%(Profession)s
|Website=%(Website)s
|Email=%(Email)s
|Phone=%(Phone)s
|Tag=%(Tag)s
|Candidature=%(Candidature)s
|Networth=%(Networth)s
|PAN=%(PAN)s
}}
"""
#decision filler
decision = {}
if (os.path.exists(".\\decisions.pkl")):
	f = open(".\\decisions.pkl","rb")
	decision = pickle.load(f)
	f.close()
for i in getlist('currentmps.csv'):
	#|Constituency=Kanker-ST
	#|Party=Bharatiya Janata Party
	#|State=Chhattisgarh
	#|Sex=Male
	#|Email=
	#|Photo=Sohan Potai.jpg
	i['Candidate'] = i['Candidate'].replace("\"","'")
	d = Candidate(i, Candidature="LokSabha2009")
	for k in os.listdir(".\\spiders\\govcheck2\\"):
			if re.match(i['Candidate'], k , re.IGNORECASE):
			print i['Candidate'] + ":" + i['State'] + " found in Govcheck: " + k
			print "Original Candidate"
			print d.write()
			s = open(".\\spiders\\govcheck2\\%s" % k,"rb")
			line = s.readline()
			r = re.compile(r'^\|(\w+)=(.*)')
			attribs = {}
			while line:
				print "Line:" + line
				m = r.match(line)
				if m:
					print m.group(1) + ":" + m.group(2)
					print d.data[m.group(1)]
					attribs[m.group(1)] = m.group(2)
				line = s.readline()
			#depend on pickler
			c = i['Candidate']
			if decision.has_key(c):
				if decision[c].has_key("govcheck"):
					if decision[c]["govcheck"]== "y":
						yes = "y"
				else:
					yes = raw_input("Should we do this?(y/n):")
					decision[c]["govcheck"] = yes
			else:
				yes = raw_input("Should we do this?(y/n):")
				decision[c] = {}
				decision[c]["govcheck"] = yes
			if (yes == "y"):
				#copy all the attribs
				d.data["Photo"] = attribs["Photo"]
				d.data["Email"] = attribs["Email"]
				d.data["PreviousOfficeTitle"] = "MP (Lok Sabha 2004)"

	# Constituency, Candidate, Sex (M/F), Age, Category, Party, TotalAssets, Liabilities, PAN, Cases(Bool), 
	# Sections(Text), Criminal cases(Text)
	for j in getlist('mps.csv'):
		if re.search(i['Candidate'],j['Candidate'],re.IGNORECASE):
			# Cool now we know that this candidate has criminal history
			print i['Candidate'] + ":" + i['State'] + " found criminal: " + j['Candidate'] + ":" + j['State']
			print "Original Candidate: "
			print d.write()
			print "Ciminal Candidate:" 
			print j
			#depend on pickler
			c = i['Candidate']
			if decision.has_key(c):
				if decision[c].has_key("nocriminal"):
					if decision[c]["nocriminal"]== "y":
						yes = "y"
				else:
					yes = raw_input("Should we do this?(y/n):")
					decision[c]["nocriminal"] = yes
			else:
				yes = raw_input("Should we do this?(y/n):")
				decision[c] = {}
				decision[c]["nocriminal"] = yes
			if (yes == "y"):
				#copy all the attribs
				if (j["Age"] != ''):
					dob = 2009 - (int(j["Age"])+4)
					d.data["DateOfBirth"] = ("%d" % dob)
				d.data["Networth"] = j["TotalAssets"]
				d.data["PAN"] = j["PAN"]
				d.data["CrimeAccusationInstances"] = j["Cases"]
				d.data["Sections"] = j["Sections"]
				d.data["Criminal cases"] = j["Criminal cases"]

	# Constituency, Candidate, Sex (M/F), Age, Category, Party, TotalAssets, Liabilities, PAN, Cases(Bool), 
	# Sections(Text), Criminal cases(Text)
	for p in getlist('mpspending.csv'):
		if re.search(i['Candidate'],p['Candidate'],re.IGNORECASE):
			print i['Candidate'] + ":" + i['State'] + " found pending criminal: " + p['Candidate']+":" + p['State']
			print "Original Candidate: "
			print d.write()
			print "Ciminal Candidate:"
			print p
			#depend on pickler
			c = i['Candidate']
			if decision.has_key(c):
				if decision[c].has_key("nocriminalsuspect"):
					if decision[c]["nocriminalsuspect"]== "y":
						yes = "y"
				else:
					yes = raw_input("Should we do this?(y/n):")
					decision[c]["nocriminalsuspect"] = yes
			else:
				yes = raw_input("Should we do this?(y/n):")
				decision[c] = {}
				decision[c]["nocriminalsuspect"] = yes
			if (yes == "y"):
				#copy all the attribs
				if (j["Age"] != ''):
					dob = 2009 - (int(j["Age"])+4)
					d.data["DateOfBirth"] = ("%d" % dob)
				d.data["Networth"] = j["TotalAssets"]
				d.data["PAN"] = j["PAN"]
				d.data["CrimeAccusationInstances"] = j["Cases"]
				d.data["Sections"] = j["Sections"]
				d.data["Criminal cases"] = j["Criminal cases"]
	d.commit()
# save the decisions file
pkl = file.open(".\\decisions.pkl", "w")
pickle.dump(pkl)
pkl.close()


