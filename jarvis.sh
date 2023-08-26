#!/bin/bash

echo ""
echo ""
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo "|               How may I assist you, Master?               |"
echo "|===========================================================|"
echo "|                       Please enter                        |"
echo "|                 - 1 for text responses                    |"
echo "|                 - 2 for voice responses                   |"
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo ""
echo ""

while true; do
  read -p "Your choice: " response
  case $response in
    1) echo "You chose text responses."
      echo "" 
      break;;
    2) echo "You chose voice responses."
      echo "" 
      break;;
    *) echo ""
      echo "Invalid response."
      echo "Please enter 1 or 2."
      echo ""
  esac
done

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do
  echo "Say something ;)"
  echo "Press (ctrl + c) when you're done."

  ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/human-prompt.mp3 2> /dev/null & arecord -q -f cd -t wav -r 44100 | lame -r - $HOME/projects/jarvis/sound/tmp.mp3
  echo ""

  api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@$HOME/projects/jarvis/sound/tmp.mp3" \
    -F "model=whisper-1")

  rm $HOME/projects/jarvis/sound/tmp.mp3

  if [ "$response" = "1" ]; then
    ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/assistant-prompt.mp3 2> /dev/null
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg
    echo ""
  else
    ai_text_response=$(echo $api_response | jq -r '.text' | sgpt --chat $session_arg)
    gtts-cli "$ai_text_response" -o $HOME/projects/jarvis/sound/output.mp3
    ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/assistant-prompt.mp3 2> /dev/null
    ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/output.mp3 2> /dev/null
    rm $HOME/projects/jarvis/sound/output.mp3
  fi

  sleep 2s

done
