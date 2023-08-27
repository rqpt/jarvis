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

ROOT_DIR=$HOME/projects/jarvis
SOUND_DIR=$ROOT_DIR/sound

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do
  echo -e -n "${BLUE}"
  echo -e "\e[4mYou\e[0m"
  echo -e "${RESET}"

  echo -e -n "${BLUE}"
  arecord -d 600 -q -f cd -t wav -r 44100 > $SOUND_DIR/tmp.wav &
  read input

  kill $!
  echo -e -n "${RESET}"

  if [[ -z $input ]]; then
    echo "🎤"
    echo ""
    lame -r $SOUND_DIR/tmp.wav $SOUND_DIR/tmp.mp3 2> /dev/null

    api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@$SOUND_DIR/tmp.mp3" \
      -F "model=whisper-1")

    rm $SOUND_DIR/tmp.mp3
  fi

  echo -e "${GREEN}"
  echo -e "\e[4mJarvis\e[0m"
  echo -e "${RESET}"

  echo -e -n "${GREEN}"
  if [[ -z $input ]]; then
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  else
    echo $input | sgpt --chat $session_arg | tee $HOME/projects/jarvis/ai-text-response
  fi
  echo -e "${RESET}"

  if [[ -z $input ]]; then
    cat $HOME/projects/jarvis/ai-text-response | festival --tts
  fi

  rm $ROOT_DIR/ai-text-response
  rm $SOUND_DIR/tmp.wav

  sleep 3s
done
