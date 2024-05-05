import os
import time
import requests
import hashlib
import pandas as pd
from bs4 import BeautifulSoup
import re
from getwebsite import get_url_execute_js_and_save

if not os.path.exists('.cache'):
    os.makedirs('.cache')

# If file is older than 15 days, download it again
OLD = time.time() - 15 * 24 * 60 * 60

yearkey = {
    2024: 'LokSabha2024',
    2014: 'ls2014',
    2009: 'ls2009',
    2004: 'loksabha2004',
}

def get(url):
    path = os.path.join('.cache', hashlib.sha1(url.encode('utf-8')).hexdigest()) + '.html'
    if not os.path.exists(path) or os.stat(path).st_mtime < OLD:
        print(f"Downloading: {url}")
        get_url_execute_js_and_save(url, path)
    return BeautifulSoup(open(path, 'r', encoding='utf-8'), 'html.parser')

def clean_number(text):
    # Remove Rs symbol, commas, Lacs+ text, and take the first numeric part if it contains a range
    number = re.sub(r'[^0-9]', '', text.split('~')[0])
    return int(number) if number else 0

def candidates(year):
    results = []
    for page in range(1, 60):  # Iterate through each page
        url = f'https://www.myneta.info/{yearkey[year]}/index.php?action=summary&subAction=candidates_analyzed&sort=candidate&page={page}'
        soup = get(url)
        
        table = soup.find('table', class_='w3-table w3-bordered')
        if not table:
            continue  # Skip if no table found
        rows = table.find_all('tr')
        print(rows)
        for row in rows[1:]:  # Skip header row
            print(row)
            cols = row.find_all('td')
            print(row)
            if len(cols) > 7:  # Ensure there are enough columns
                results.append({
                    'Year': year,
                    'Page': page,
                    'Sno': cols[0].text.strip(),
                    'ID': int(cols[1].find('a')['href'].split('=')[-1]),
                    'Candidate': cols[1].find('a').text.strip(),
                    'Constituency': cols[2].text.strip(),
                    'Party': cols[3].text.strip(),
                    'Criminal Cases': int(cols[4].text.strip()),
                    'Education': cols[5].text.strip(),
                    'Total Assets': clean_number(cols[6].text.strip()),
                    'Total Liabilities': clean_number(cols[7].text.strip())
                })
                print(f"Row added: {row}")
            else:
                print(f"Row skipped: {row}")
            print(f"Total results: {len(rows[1:])}")
    print(f"Total results {len(results)}")
    return pd.DataFrame(results)

# Example usage
ls2024 = candidates(2024)
#print(ls2024)
