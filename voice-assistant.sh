#!/bin/bash

echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo "|            Welcome to the Voice Assistant!                |"
echo "|===========================================================|"
echo "|         Please enter 1 for text responses or              |"
echo "|               2 for voice responses:                      |"
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"

while true; do
  read response
  case $response in
    1) echo "You chose text responses."
      break;;
    2) echo "You chose voice responses."
      break;;
    *) echo "Invalid response. Please enter 1 or 2."
  esac
done

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do

  # Start audio recording and save as tmp.mp3
  arecord -f cd -t wav -r 44100 | lame -r - tmp.mp3

  # Send audio file for transcription and extract text using jq
  api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@tmp.mp3" \
    -F "model=whisper-1")

  # Remove tmp.mp3 file
  rm tmp.mp3

  if [ "$response" = "1" ]; then
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg
  else
    ai_text_response=$(echo $api_response | jq -r '.text' | sgpt --chat $session_arg)
    gtts-cli "$ai_text_response" -o output.mp3
    ffplay -nodisp -hide_banner -autoexit output.mp3
    rm output.mp3
  fi

done
