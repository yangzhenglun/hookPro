THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:7.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = HKSpringBoard

HKSpringBoard_CFLAGS += -Wno-error
HKSpringBoard_CFLAGS += -I./curl
HKSpringBoard_LDFLAGS += -lz
HKSpringBoard_OBJ_FILES += libcurl.a
HKSpringBoard_FRAMEWORKS= UIKit
HKSpringBoard_FILES = Tweak.xm

include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
