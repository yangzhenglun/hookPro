THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:7.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = AAAHKJD

AAAHKJD_CFLAGS += -Wno-error
AAAHKJD_CFLAGS += -I./include
AAAHKJD_LDFLAGS += -lz
AAAHKJD_OBJ_FILES += libcurl.a

AAAHKJD_FILES = Tweak.xm
AAAHKJD_FRAMEWORKS= UIKit Foundation


include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 JD4iPhone"
