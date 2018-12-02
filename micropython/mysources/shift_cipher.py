#!/usr/bin/python
# shift_cipher_v0.0.2.py
# nelbren@nelbren.com
# FormatFix4MicroPython
def shift_str(x,d):
  r=''
  for c in x:
    o = ord(c)
    r += chr(o if o == 32 else o + d - 26 if o + d > 90 else o + d)
  return r
def cipher2text(x):
  for d in range(0, 25):
    print("intento " + '{:02}'.format(d) + ": " + shift_str(x,d))
cipher2text('PHHW PH DIWHU WKH WRJD SDUWB')
