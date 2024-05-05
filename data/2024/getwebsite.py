from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import time

def get_url_execute_js_and_save(url,path):
    # Setup Chrome options
    options = Options()
    options.headless = True  # Enable headless mode for automation

    # Initialize the WebDriver
    driver = webdriver.Chrome(options=options)
    # Load the page
    driver.get(url)

    # Wait for JavaScript to execute, adjust time as needed
    time.sleep(5)  # Sleeps for 5 seconds; adjust depending on the page

    # Save the page source to a file
    html_content = driver.page_source
    with open(path, "w", encoding="utf-8") as file:
        file.write(html_content)

    # Close the browser
    driver.quit()
