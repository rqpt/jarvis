#!/bin/bash

echo ""
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo "|               How may I assist you, Master?               |"
echo "|===========================================================|"
echo "|                                                           |"
echo "|               Press Enter to stop recording,              |"
echo "|             or after you've written your prompt           |"
echo "|                                                           |"
echo "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|"
echo ""

BLUE='\033[1;34m'
GREEN="\e[38;2;137;207;153m"
RESET='\033[0m'

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do
  ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/human-prompt.mp3 2> /dev/null

  echo -e -n "${BLUE}"
  echo -e "\e[4mYou\e[0m"
  echo -e "${RESET}"

  echo -e -n "${BLUE}"
  arecord -d 600 -q -f cd -t wav -r 44100 > $HOME/projects/jarvis/sound/tmp.wav &
  read input

  kill $!
  echo -e -n "${RESET}"

  if [[ -z $input ]]; then
    echo "🎤"
    echo ""
    lame -r $HOME/projects/jarvis/sound/tmp.wav $HOME/projects/jarvis/sound/tmp.mp3 2> /dev/null
    api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@$HOME/projects/jarvis/sound/tmp.mp3" \
      -F "model=whisper-1")

    rm $HOME/projects/jarvis/sound/tmp.mp3
  fi

  ffplay -nodisp -hide_banner -autoexit $HOME/projects/jarvis/sound/assistant-prompt.mp3 2> /dev/null
  echo -e -n "${GREEN}"
  echo -e "\e[4mJarvis\e[0m"
  echo -e "${RESET}"

  echo -e -n "${GREEN}"
  if [[ -z $input ]]; then
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  else
    echo $input | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  fi
  echo -e -n "${RESET}"

  cat $HOME/projects/jarvis/ai-text-response | festival --tts

  rm $HOME/projects/jarvis/ai-text-response
  rm $HOME/projects/jarvis/sound/tmp.wav

  sleep 3s
done
