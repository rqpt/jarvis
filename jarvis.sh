#!/bin/bash

echo ""
echo ""
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo "|               How may I assist you, Master?               |"
echo "|===========================================================|"
echo "|     Press Enter to stop recording, or type your prompt    |"
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo ""
echo ""

# Baby blue color code for prompts
BLUE='\033[1;34m'
# Baby red color code for responses
RED='\033[1;91m'
# Reset color code
RESET='\033[0m'

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do
  # User prompt
  ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/human-prompt.mp3 2> /dev/null

  arecord -d 600 -q -f cd -t wav -r 44100 > $HOME/projects/jarvis/sound/tmp.wav &

  echo -e "${BLUE}"
  read -p "Press Enter to stop recording, or type your prompt:" input
  echo -e "${RESET}"
  kill $!

  if [[ -z $input ]]; then
    lame -r $HOME/projects/jarvis/sound/tmp.wav $HOME/projects/jarvis/sound/tmp.mp3 2> /dev/null
    api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@$HOME/projects/jarvis/sound/tmp.mp3" \
      -F "model=whisper-1")

    rm $HOME/projects/jarvis/sound/tmp.mp3
  fi

  # Jarvis response
  ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/assistant-prompt.mp3 2> /dev/null

  echo -e "${RED}"
  if [[ -z $input ]]; then
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  else
    echo $input | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  fi
  echo -e "${RESET}"

  cat $HOME/projects/jarvis/ai-text-response | festival --tts

  rm $HOME/projects/jarvis/ai-text-response
  rm $HOME/projects/jarvis/sound/tmp.wav

  sleep 3s
done
