#!/bin/bash

if [[ "$EUID" -ne 0 ]] && [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Please run as root! (sudo ./build_all.sh)"
  exit 1
fi

# macOS specific setup: find Qt5 and libusb paths
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Find libusb path
  if [[ -d "/opt/homebrew/opt/libusb" ]]; then
    export C_INCLUDE_PATH="/opt/homebrew/opt/libusb/include"
  elif [[ -d "/usr/local/opt/libusb" ]]; then
    export C_INCLUDE_PATH="/usr/local/opt/libusb/include"
  fi
  # Find Qt5 path
  if [[ -d "/opt/homebrew/opt/qt@5" ]]; then
    export CMAKE_PREFIX_PATH="/opt/homebrew/opt/qt@5"
  elif [[ -d "/usr/local/opt/qt@5" ]]; then
    export CMAKE_PREFIX_PATH="/usr/local/opt/qt@5"
  else
    QT_PREFIX=$(qmake -query QT_INSTALL_PREFIX 2>/dev/null)
    if [[ -n "$QT_PREFIX" ]]; then
      export CMAKE_PREFIX_PATH="$QT_PREFIX"
    fi
  fi
fi

(
cd IMSProg_programmer
rm -rf build/
mkdir build/
cmake -S . -B build/
cmake --build build/ --parallel
cmake --install build/
rm -rf build/
)
(
cd IMSProg_editor
rm -rf build/
mkdir build/
cmake -S . -B build/
cmake --build build/ --parallel
cmake --install build/
rm -rf build/
)
# Reloading the USB rules for Linux
[[ "$OSTYPE" != "darwin"* ]] && udevadm control --reload-rules
