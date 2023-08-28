# Intro

This is essentially a convenience wrapper for another amazing tool called shell-gpt.
It enables you to interact with chatGPT using either text or voice, and receive
voice and text responses back.

User input is kept very minimal.

## Compatibility

This should be usable from linux or macOS systems. Testing still needs to be done to confirm this.

## Installation

No installation for the tool itself, it is simply a bash script. You will just need to install a few dependencies-
```bash
sudo apt install lame festival jq curl
pip install shell-gpt
```
## Setup

1. Set your openai api key in your bashrc -
```bash
OPENAI_API_KEY=<key>
```
2. Put the script in your ~/.local/bin/ directory.
3. Set create a folder anywhere where the script's temporary files can be stored
4. Open the script file and set the ROOT_DIR variable to the path for the folder you just created.

## Use

### Prompt
Call `jarvis` and a voice recording will start. 
Press enter and the recording will be used as a chatgpt prompt. 
You can alternatively type your prompt, and that will be used as the prompt instead.

### Response
You will get both a text and an audio response.
The audio can be skipped by pressing enter.
Hit enter again to begin the next prompt
