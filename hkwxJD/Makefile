THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_USER = root
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:7.0

;FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = hkwxjd
hkwxjd_FILES = Tweak.xm
hkwxjd_FRAMEWORKS= UIKit Foundation

include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 WeChat"