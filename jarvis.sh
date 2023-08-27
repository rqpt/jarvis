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
SOUND_DIR=$ROOT_DIR/sound

session_arg=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

while true; do
  echo -e -n "${PROMPT_COLOUR}"
  echo -e "\e[4mYou\e[0m"
  echo -e "${RESET_COLOUR}"

  echo -e -n "${PROMPT_COLOUR}"
  arecord -d 600 -q -f cd -t wav -r 44100 > $SOUND_DIR/tmp.wav &
  read input

  kill $!
  echo -e -n "${RESET_COLOUR}"

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

  echo -e "${RESPONSE_COLOUR}"
  echo -e "\e[4mJarvis\e[0m"
  echo -e "${RESET_COLOUR}"

  echo -e -n "${RESPONSE_COLOUR}"

  if [[ -z $input ]]; then
    echo $api_response | jq -r '.text' | sgpt --chat $session_arg | tee $ROOT_DIR/ai-text-response
    cat $HOME/projects/jarvis/ai-text-response | festival --tts
    rm $ROOT_DIR/ai-text-response
  else
    echo $input | sgpt --chat $session_arg
  fi

  echo -e "${RESET_COLOUR}"

  rm $SOUND_DIR/tmp.wav

  sleep 3s
done
