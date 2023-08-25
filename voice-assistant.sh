#!/bin/bash

echo ""
echo ""
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo "|              Welcome to the Voice Assistant!              |"
echo "|===========================================================|"
echo "|                       Please enter                        |"
echo "|                 - 1 for text responses                    |"
echo "|                 - 2 for voice responses:                  |"
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo ""
echo ""

while true; do
  read -p "Your choice: " response
  case $response in
    1) echo "" 
      echo "You chose text responses."
      echo "" 
      break;;
    2) echo "" 
      echo "You chose voice responses."
      echo "" 
      break;;
    *) echo ""
      echo " Invalid response."
      echo "Please enter 1 or 2."
      echo ""
  esac
done

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do

  arecord -f cd -t wav -r 44100 | lame -r - tmp.mp3

  api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@tmp.mp3" \
    -F "model=whisper-1")

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
