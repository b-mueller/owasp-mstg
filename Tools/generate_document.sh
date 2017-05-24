#!/bin/bash
type pandoc >/dev/null 2>&1 || { echo >&2 "I require pandoc but it's not installed.  Aborting."; exit 1; }
# How to generate Docx
cd ../Document
pandoc -f markdown_github --columns 10000 -t docx -o ../Generated/MSTG.docx \
0x00-Header.md \
Foreword.md \
0x02-Frontispiece.md \
0x03-Overview.md \
0x04-Testing-Processes-and-Techniques.md \
0x05-Android-Testing-Guide.md \
0x05a-Platform-Overview.md \
0x05b-Basic-Security_Testing.md \
0x05d-Testing-Data-Storage.md \
0x05e-Testing-Cryptography.md \
0x05f-Testing-Local-Authentication.md \
0x05g-Testing-Network-Communication.md \
0x05h-Testing-Platform-Interaction.md \
0x05i-Testing-Code-Quality-and-Build-Settings.md \
0x05c-Reverse-Engineering-and-Tampering.md \
0x05j-Testing-Resiliency-Against-Reverse-Engineering.md \
0x06-iOS-Testing-Guide.md \
0x06a-Platform-Overview.md \
0x06b-Basic-Security-Testing.md \
0x06d-Testing-Data-Storage.md \
0x06e-Testing-Cryptography.md \
0x06f-Testing-Local-Authentication.md \
0x06g-Testing-Network-Communication.md \
0x06h-Testing-Platform-Interaction.md \
0x06i-Testing-Code-Quality-and-Build-Settings.md \
0x06c-Reverse-Engineering-and-Tampering.md \
0x06j-Testing-Resiliency-Against-Reverse-Engineering.md \
0x07-Appendix.md \
0x07a-Testing-Authentication-and-Session-Management.md \
0x07b-Testing-Network-Communication.md \
0x07c-Testing-Cryptography.md \
0x07d-Assessing-Anti-Reverse-Engineering-Schemes.md \
0x08-Testing-Tools.md \
0x09-Suggested-Reading.md \
0x08-Testing-Tools.md \
0x09-Suggested-Reading.md
