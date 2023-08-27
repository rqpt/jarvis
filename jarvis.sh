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

PROMPT_COLOUR='\033[1;34m'
RESPONSE_COLOUR="\e[1;35m"
RESET_COLOUR='\033[0m'

ROOT_DIR=$HOME/projects/jarvis

while true; do
  echo -e -n "${PROMPT_COLOUR}"
  echo -e "\e[4mYou\e[0m"
  echo -e "${RESET_COLOUR}"

  echo -e -n "${PROMPT_COLOUR}"
  arecord -d 600 -q -f cd -t wav -r 44100 > $ROOT_DIR/tmp.wav &
  read text_input
  pkill arecord
  echo -e -n "${RESET_COLOUR}"

  if [[ -z $text_input ]]; then
    echo "🎤"
    echo ""
    lame -r $ROOT_DIR/tmp.wav $ROOT_DIR/tmp.mp3 2> /dev/null

    api_response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@$ROOT_DIR/tmp.mp3" \
      -F "model=whisper-1")

    rm $ROOT_DIR/tmp.mp3
  fi

  echo -e "${RESPONSE_COLOUR}"
  echo -e "\e[4mJarvis\e[0m"
  echo -e "${RESET_COLOUR}"

  echo -e -n "${RESPONSE_COLOUR}"

  if [[ -z $text_input ]]; then
    echo -n $api_response | jq -r '.text' | sgpt --chat temp | tee $ROOT_DIR/ai-text-response
  else
    echo -n $text_input | sgpt --chat temp | tee $ROOT_DIR/ai-text-response
  fi

  festival --tts $ROOT_DIR/ai-text-response &
  read -n 1
  pkill festival
  read -sn 1

  echo -e -n "${RESET_COLOUR}"

  rm $ROOT_DIR/ai-text-response
  rm $ROOT_DIR/tmp.wav

done
