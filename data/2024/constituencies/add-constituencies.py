import sqlite3

constituencies_sql = '''
DROP TABLE IF EXISTS loksabhaconstituencies;
CREATE TABLE IF NOT EXISTS loksabhaconstituencies  (
    Constituency TEXT,
    State TEXT
);

INSERT INTO loksabhaconstituencies (Constituency, State) VALUES 
('AHMEDNAGAR', 'MAHARASHTRA'),
('AKOLA', 'MAHARASHTRA'),
('AMRAVATI', 'MAHARASHTRA'),
('AURANGABAD', 'MAHARASHTRA'),
('BARAMATI', 'MAHARASHTRA'),
('BEED', 'MAHARASHTRA'),
('BHANDARA-GONDIYA', 'MAHARASHTRA'),
('BHIWANDI', 'MAHARASHTRA'),
('BULDHANA', 'MAHARASHTRA'),
('CHANDRAPUR', 'MAHARASHTRA'),
('DHULE', 'MAHARASHTRA'),
('DINDORI', 'MAHARASHTRA'),
('GADCHIROLI-CHIMUR', 'MAHARASHTRA'),
('HATKANANGLE', 'MAHARASHTRA'),
('HINGOLI', 'MAHARASHTRA'),
('JALGAON', 'MAHARASHTRA'),
('JALNA', 'MAHARASHTRA'),
('KALYAN', 'MAHARASHTRA'),
('KOLHAPUR', 'MAHARASHTRA'),
('LATUR', 'MAHARASHTRA'),
('MADHA', 'MAHARASHTRA'),
('MAVAL', 'MAHARASHTRA'),
('MUMBAI NORTH', 'MAHARASHTRA'),
('MUMBAI NORTH CENTRAL', 'MAHARASHTRA'),
('MUMBAI NORTH EAST', 'MAHARASHTRA'),
('MUMBAI NORTH WEST', 'MAHARASHTRA'),
('MUMBAI SOUTH', 'MAHARASHTRA'),
('MUMBAI SOUTH CENTRAL', 'MAHARASHTRA'),
('NAGPUR', 'MAHARASHTRA'),
('NANDED', 'MAHARASHTRA'),
('NANDURBAR', 'MAHARASHTRA'),
('NASHIK', 'MAHARASHTRA'),
('OSMANABAD', 'MAHARASHTRA'),
('PALGHAR', 'MAHARASHTRA'),
('PARBHANI', 'MAHARASHTRA'),
('PUNE', 'MAHARASHTRA'),
('RAIGAD', 'MAHARASHTRA'),
('RAMTEK', 'MAHARASHTRA'),
('RATNAGIRI-SINDHUDURG', 'MAHARASHTRA'),
('RAVER', 'MAHARASHTRA'),
('SANGLI', 'MAHARASHTRA'),
('SATARA', 'MAHARASHTRA'),
('SHIRDI', 'MAHARASHTRA'),
('SHIRUR', 'MAHARASHTRA'),
('SOLAPUR', 'MAHARASHTRA'),
('THANE', 'MAHARASHTRA'),
('WARDHA', 'MAHARASHTRA'),
('YAVATMAL-WASHIM', 'MAHARASHTRA');

INSERT INTO loksabhaconstituencies (Constituency, State) VALUES 
('CHANDNI CHOWK', 'DELHI'),
('NORTH EAST DELHI', 'DELHI'),
('EAST DELHI', 'DELHI'),
('NEW DELHI', 'DELHI'),
('NORTH WEST DELHI', 'DELHI'),
('WEST DELHI', 'DELHI'),
('SOUTH DELHI', 'DELHI');
'''

# Create a connection to the SQLite database
conn = sqlite3.connect('./candidates.db')
cursor = conn.cursor()

# Execute the SQL statements
cursor.executescript(constituencies_sql)

# Commit the changes and close the connection
conn.commit()
conn.close()

print("Data inserted successfully into candidate.db")