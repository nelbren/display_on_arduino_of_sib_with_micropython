#!/bin/bash
#
# upload_and_run.bash
#
# v0.0.1 - 2012-12-01 - nelbren.com
#

use() {
  myself=$(basename $0)
  echo "Usage: "
  echo "       $myself [OPTION]..."
  echo ""
  echo "Multi wrapper for install, setup, flash, and manage Board and MicroPython."
  echo ""
  echo -e "Where: "
  echo -e "       -i|--install\t\t\t\tInstall and setup"
  echo -e "       -fe|--flash_erase\t\t\tFlash erase"
  echo -e "       -ff|--flash_firmware\t\t\tFlash firmware"
  echo -e "       -fs|--flash_status\t\t\tFlash status"
  echo -e "       -s|--serial\t\t\t\tSerial connection"
  echo -e "       -ap=PROGRAM|--ampy_put=PROGRAM\t\tUpload PROGRAM to board"
  echo -e "       -ad=PROGRAM|--ampy_delete=PROGRAM\tDelete PROGRAM from board"
  echo -e "       -al|--ampy_ls\t\t\t\tList contect from board"
  echo -e "       -ar=PROGRAM|--ampy_run=PROGRAM\t\tRun PROGRAM from board"
  echo ""
  echo -e "       -di|--demo_info_sys\t\t\tDEMO of run Show Information System"
  echo -e "       -ds|--demo_shift_cipher\t\t\tDEMO of run Shift Cipher"
  echo -e "       -dm|--demo_main\t\t\t\tDEMO of put and reset of:"
  echo -e "           Display_on_Arduino_of_System_Information_Bar_-_esp8266_nodemcu.py => main.py"
  echo ""
  echo -e "       -h|--help\t\t\t\tShow this information."
  echo ""
  echo "Please check more information, articles, tools and stuff at my website https://nelbren.com"
  exit 0
}

params() {
  task=""
  for i in "$@"; do
    case $i in
      -i|--install) task=install; shift;;
      -fe|--flash_erase) task=flash_erase; shift;;
      -ff|--flash_firmware) task=flash_firmware; shift;;
      -fs|--flash_status) task=flash_status; shift;;
      -s|--serial) task=serial; shift;;
      -ap=*|--ampy_put=*) task=ampy_put; program="${i#*=}"; shift;;
      -ad=*|--ampy_delete=*) task=ampy_delete; program="${i#*=}"; shift;;
      -al|--ampy_ls) task=ampy_ls; shift;;
      -ar=*|--ampy_run=*) task=ampy_run; program="${i#*=}"; shift;;
      -di|--demo_info_sys) task=demo_info_sys; shift;;
      -ds|--demo_shift_cipher) task=demo_shift_cipher; shift;;
      -dm|--demo_main) task=demo_main; shift;;
      -h|--help) use;;
      *) use;;
    esac
  done
  [ -z "$task" ] && use
}

get_driver() {
  echo "+ Get CP210x USB to UART Bridge VCP Drivers at:"
  echo "  https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers"
  exit 6
}

config() {
  if [ ! -x cfg.bash ]; then
    echo "Please rename 'cfg.bash.example' to 'cfg.bash', and change wifi and port config"
    exit 1 
  fi
  . cfg.bash

  if [ -z $port ]; then
    echo "Please configure the 'port' in 'cfg.bash'"
    exit 5
  fi

  if [ ! -c $port ]; then
    echo "Please:"
    echo "+ Connect the board or"
    get_driver
  fi

  firmware=esp8266-20180511-v1.9.4.bin
}

set_resources() {
  if [ ! -d resources ]; then
    mkdir resources
  fi
}

get_python_and_pip() {
  echo -n "python3..."
  python=$(which python3)
  if [ -n "$python" ]; then 
    echo "DONE."
    echo -n "pip3..."
    pip=$(which pip3)
    if [ -z "$pip" ]; then
      echo "Please install pip3"
      exit 2
    else
      echo "DONE."
    fi
  else
    echo -n "python..."
    python=$(which python)
    if [ -z "$python" ]; then
      echo "Please install python"
      exit 3
    else
      echo "DONE."
    fi
    echo -n "pip..."
    pip=$(which pip)
    if [ -z "$pip" ]; then
      echo "Please install pip"
      exit 4
    else
      echo "DONE."
    fi
  fi
}

get_python_package() {
  package=$1
  echo -n "$package..."
  if $pip list | grep $package 2>/dev/null 1>&2; then
    echo "DONE."
  else
    echo "installing:"
    $pip install $package
  fi
}

get_python_packages() {
  get_python_package esptool
  get_python_package adafruit-ampy
}

get_firmware() {
  echo -n "firmware..."
  if [ -r resources/$firmware ]; then
    echo "DONE."
  else
    echo "getting:"
    wget -c $url1/$firmware -O resources/$firmware
  fi
}

get_code() {
  code=shift_cipher.py
  echo -n "${code}..."
  if [ -r resources/$code ]; then
    echo "DONE."
  else
    echo "getting:"
    wget $url2/$code -O resources/$code
  fi
}

get_libraries() {
  echo -n "esp8266_i2c_lcd.py..."
  if [ -r resources/esp8266_i2c_lcd.py ]; then
    echo "DONE."
  else
    echo "getting:"
    wget $url3/esp8266_i2c_lcd.py -O resources/esp8266_i2c_lcd.py
  fi
  echo -n "lcd_api.py..."
  if [ -r resources/lcd_api.py ]; then
    echo "DONE."
  else
    wget $url3/lcd_api.py -O resources/lcd_api.py
  fi
}

install() {
  url1=http://micropython.org/resources/firmware
  url2=https://raw.githubusercontent.com/nelbren/my_codes_in_sololearn/master
  url3=https://raw.githubusercontent.com/dhylands/python_lcd/master/lcd

  set_resources
  get_python_and_pip
  get_python_packages
  get_firmware
  get_code
  get_libraries
}

exit_check() {
  e=$1
  if [ "$e" == "0" ]; then
    echo "DONE."
  else
    echo "FAIL"
  fi
}
 
question() {
  echo "Sure? (Yes/Any=No):"
  read answer
}

esptool_flash_erase() {
  question
  if [ "$answer" == "Yes" ]; then
    esptool.py -p $port erase_flash
  fi
}

esptool_flash_firmware() {
  question
  if [ "$answer" == "Yes" ]; then
    esptool.py -p $port write_flash -fm qio 0x0000 resources/$firmware
  fi
}

esptool_flash_status() {
  esptool.py -p $port read_flash_status
  # erased
  # Status value: 0x0200
}

serial() {
  # NOTE: CONTROL+A + :quit

  screen=$(which screen)
  if [ -n "$screen" ]; then
    screen $port 115200
  else
    echo "Please install screen"
  fi
}

ampy_put() {
  echo -n "put $program..."
  ampy --port=$port put $program
  exit_check $?
}

ampy_delete() {
  echo -n "rm $program..."
  ampy --port=$port rm $program
  exit_check $?
}

ampy_ls() {
  ampy --port=$port ls 
}

ampy_run() {
  no_new_line=$1
  if [ "$no_new_line" == "1" ]; then
    echo -n "run $program..."
  else
    echo "run $program:"
  fi
  ampy --port=$port run $program
  exit_check $?
}

ampy_reset() {
  echo -n "reset $program:"
  ampy --port=$port reset
  exit_check $?
}

demo_info_sys() {
  program=mysources/info.py 
  ampy_run
}

demo_shift_cipher() {
  echo "RUN BOARD:"
  echo "=========="
  program=mysources/160Mhz.py 
  ampy_run
  program=mysources/shift_cipher.py 
  time ampy --port=$port run $program
  program=mysources/080Mhz.py 
  ampy_run
  program=mysources/shift_cipher.py 
  time ampy --port=$port run $program
  echo ""
  echo "RUN LOCAL:"
  echo "----------"
  time python $program
}

put_library() {
  library=$1
  echo -n "put $library..."
  if ampy --port=$port ls | grep -q $library; then
    echo "DONE."
  else
    echo "uploading:"
    program=resources/$library
    ampy_put
  fi
}

wifi_config() {
  if [ -z "$main_ssid" -o \
       "$main_ssid" == "CHANGE-TO-YOUR-SSID" ]; then
    echo "Please configure the 'main_ssid' in 'cfg.bash'"
    exit 7
  fi
  if [ -z "$main_pass" -o \
       "$main_pass" == "CHANGE-TO-YOUR-PASSWORD" ]; then
    echo "Please configure the 'main_pass' in 'cfg.bash'"
    exit 8
  fi
  #sed -i "s/SSID,PASSWORD.*/SSID,PASSWORD = '$main_ssid','$main_pass'/" mysources/wifi.py
  echo "SSID,PASSWORD = '$main_ssid','$main_pass'" > mysources/wifi.py
}

demo_main() {
  wifi_config

  put_library esp8266_i2c_lcd.py
  put_library lcd_api.py

  program=mysources/wifi.py
  ampy_put

  program=mysources/main.py 
  ampy_put

  #ampy_reset
  program=mysources/reset.py
  ampy_run 1
}

config
params "$@"

case $task in
  install) install;;
  flash_erase) esptool_flash_erase;;
  flash_firmware) esptool_flash_firmware;;
  flash_status) esptool_flash_status;;
  serial) serial;;
  ampy_put) ampy_put;;
  ampy_delete) ampy_delete;;
  ampy_ls) ampy_ls;;
  ampy_run) ampy_run;;
  demo_info_sys) demo_info_sys;;
  demo_shift_cipher) demo_shift_cipher;;
  demo_main) demo_main;;
  *) echo "unknown";;
esac
