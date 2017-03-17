THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_USER = root
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:8.0

;FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = hkweixin
hkweixin_CFLAGS += -Wno-error
hkweixin_CFLAGS += -I./include -I./src
hkweixin_LDFLAGS += -lz
hkweixin_OBJ_FILES += libcurl.a

hkweixin_FILES = src/*.m src/Tweak.xm
hkweixin_FRAMEWORKS= UIKit Foundation

include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 WeChat"