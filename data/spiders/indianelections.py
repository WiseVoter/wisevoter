import urllib2
from BeautifulSoup import BeautifulSoup

ifile = open('congress.csv', 'w')
page = urllib2.urlopen("http://www.indian-elections.com/partyprofiles/congress.html")
soup = BeautifulSoup(page)
count = 0
for incident in soup.findAll("td",{"class" : "sthome"}):
	if count < 3:
		ifile.write('%s,' % (incident.string))
		count += 1
	if count == 3:
		ifile.write('%s\n' % (incident.string))
		count = 0;
ifile.close()

