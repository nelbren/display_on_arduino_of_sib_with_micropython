# info.py
# v0.0.1 - 2018-12-01 - nelbren.com
# https://forum.micropython.org/viewtopic.php?t=1890
# https://docs.micropython.org/en/latest/esp8266/quickref.html
# http://nerdlabs.com.ar/blog/2018/4/18/esp8266-a-160mhz-con-micropython/
import sys
import network
import ubinascii
import machine
import utime
import os

def sys_info():
  print("   Platform: " + sys.platform)
  print("    Version: " + sys.version)
  print("    Modules: " + str(sys.modules))
  print("      Uname: " + str(os.uname()))

def mac_info():
  mac = ubinascii.hexlify(network.WLAN().config('mac'),':').decode()
  print("MAC address: " + mac)

def mem_info():
  print("Memory free: " + str(gc.mem_free()) + " bytes")

def frq_info():
  print("  Frequency: " + str(machine.freq()) + " hz")

def performance_test():
  secs = utime.ticks_ms()
  end_time = secs + 5000
  count = 0
  while utime.ticks_ms() < end_time:
    count += 1
  print("Count 5K ms:", count)

def tst_perf():
  performance_test()

def set_freq(turbo):
  if turbo: 
    machine.freq(160000000)
  else:
    machine.freq(80000000)

sys_info()
mac_info()
mem_info()
frq_info()
tst_perf()
set_freq(True)
frq_info()
tst_perf()
set_freq(False)
frq_info()
tst_perf()
