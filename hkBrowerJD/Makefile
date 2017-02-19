THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 armv7s
TARGET = iphone:latest:7.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = qqBrower

qqBrower_FRAMEWORKS= UIKit
qqBrower_FILES = Tweak.xm

include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 mttlite"