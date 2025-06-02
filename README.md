# Weather-script


This Bash script fetches the current weather and a 5-day forecast for a specified city using the OpenWeatherMap API. Optionally, it can send the weather report by email.

## Features

- Fetches current weather and 5-day forecast for a given city (in Czech).
- Outputs results to a timestamped log file.
- Optionally sends the report by email.
- Basic error handling for API responses and email sending.

## Requirements

- **curl**
- **jq**
- **msmtp** (for email sending)
- OpenWeatherMap API key

## Installation

1. **Clone or download this script**.
2. **Install required dependencies** (on Debian/Ubuntu):
    ```bash
    sudo apt-get update
    sudo apt-get install curl jq msmtp
    ```
3. **Obtain an API key** from [OpenWeatherMap](https://openweathermap.org/api).

4. **Configure msmtp**  
   Create or edit your `~/.msmtprc` with your SMTP credentials (see [msmtp docs](https://marlam.de/msmtp/) for help).
