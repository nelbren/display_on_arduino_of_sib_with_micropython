# Display_on_Arduino_of_System_Information_Bar_-_esp8266_nodemcu.py
# v0.0.1 - 2018-11-12 - nelbren.com
from machine import Pin, I2C
from esp8266_i2c_lcd import I2cLcd
import network, utime, urequests as requests
import wifi

link = "http://104.251.217.217/si.txt"
LCD_COLS,LCD_ROWS = 20,4; n = 0
i2c = I2C(scl=Pin(5), sda=Pin(4), freq=100000)
lcd = I2cLcd(i2c, 0x27, LCD_ROWS, LCD_COLS)

def wait_time():
  lcd.blink_cursor_off()
  lcd.move_to(LCD_COLS - 3, LCD_ROWS - 1)
  lcd.putstr('{:03}'.format(n))
  lcd.move_to(LCD_COLS - 1, LCD_ROWS - 1)
  lcd.blink_cursor_on()

def lcd_print(msg, r = 0):
  lcd.move_to(0, r)
  if len(msg) > LCD_COLS:
    if r >= LCD_ROWS - 1:
      lcd.putstr(msg[0:LCD_COLS - 3] + "...")
    else:
      lcd.putstr(msg[0:LCD_COLS])
      lcd_print(msg[LCD_COLS:], r + 1)
  else:  
    lcd.putstr(msg)

def setup():
  lcd.backlight_on()
  lcd_print("SSID: " + wifi.SSID, 0)
  nic = network.WLAN(network.STA_IF)
  nic.active(True)
  nic.connect(wifi.SSID, wifi.PASSWORD)
  n = 0
  while not nic.isconnected():
    lcd_print('{:020}'.format(n), 1)
    utime.sleep(1)
    n+=1
  lcd.clear()
  lcd_print("MYIP: " + nic.ifconfig()[0])

def display_error(msg, nn):
  global n
  lcd.clear()
  lcd_print(msg)
  lcd.backlight_on()
  n = nn

setup()
while True:
  wait_time()
  if n <= 0:
    n = 120
    try:
      r = requests.get(link)
    except:
      display_error('Communication error', 5)
      pass
    else:  
      if r.status_code == 200:
        lcd.backlight_on()
        lcd_print(r.text)
        utime.sleep(2)
        if r.text.find('*') == -1: lcd.backlight_off()
        r.close()
      else:      
        display_error('Get failed!', 5)
  else:
    utime.sleep(1)
  n-=1
