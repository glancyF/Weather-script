#!/bin/bash

API_KEY=your_api_token
CITY="$1"
EMAIL="$2"
LOG_FILE="pocasi_${CITY}_$(date +%Y%m%d_%H%M%S).log"
EMAIL_FILE="/tmp/pocasi_email_$$.txt"

if [ -z "$CITY" ]; then
  echo "Pouziti: $0 <mesto> [email]"
  exit 1
fi

echo "Ziskavam data pro: $CITY..."

CURRENT=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=metric&lang=cz")
FORECAST=$(curl -s "https://api.openweathermap.org/data/2.5/forecast?q=${CITY}&appid=${API_KEY}&units=metric&lang=cz")

{
  echo "Aktuální počasí v $CITY:"
echo "-----------------------------"
if echo "$CURRENT" | jq -e '.main' >/dev/null; then
  WEATHER_DATE=$(date -d @"$(echo "$CURRENT" | jq '.dt')" "+%Y-%m-%d %H:%M:%S")
  TEMP=$(echo "$CURRENT" | jq '.main.temp')
  DESC=$(echo "$CURRENT" | jq -r '.weather[0].description')
  WIND=$(echo "$CURRENT" | jq '.wind.speed')
  HUMIDITY=$(echo "$CURRENT" | jq '.main.humidity')

  echo -e "Datum: $WEATHER_DATE\nTeplota: $TEMP °C\nPočasí: $DESC\nVítr: $WIND m/s\nVlhkost: $HUMIDITY%"
else
  echo "Chyba: Nelze načíst aktuální data."
  exit 2
fi

  echo -e "\nPředpověď na 5 dní:"
  echo "-----------------------------"
  if echo "$FORECAST" | jq -e '.list' >/dev/null; then
    echo "$FORECAST" | jq -r '
      .list[] | select(.dt_txt | contains("12:00:00")) |
      "Datum: \(.dt_txt)\nTeplota: \(.main.temp) °C\nPočasí: \(.weather[0].description)\n"
    '
  else
    echo "Chyba: Nelze načíst předpověď."
    exit 3
  fi
} > "$LOG_FILE"

cp "$LOG_FILE" "$EMAIL_FILE"

echo "Log byl uložen v $LOG_FILE"

if [ -n "$EMAIL" ]; then
  echo "Odesílám e-mail na $EMAIL..."

  {
    echo "Subject: Počasí v $CITY"
    echo "From: your@email.com"
    echo "To: $EMAIL"
    echo "Content-Type: text/plain; charset=UTF-8"
    echo
    cat "$EMAIL_FILE"
  } | msmtp --debug --from=default -t

  if [ $? -eq 0 ]; then
    echo "Email byl úspěšně odeslán."
  else
    echo "Chyba: Email se nepodařilo odeslat."
  fi

  rm -f "$EMAIL_FILE"
else
  echo "Email nezadán – výstup pouze uložen."
fi
