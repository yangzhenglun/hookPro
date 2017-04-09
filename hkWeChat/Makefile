THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:8.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = AAAHKWX
AAAHKWX_CFLAGS += -Wno-error
AAAHKWX_CFLAGS += -I./curl
AAAHKWX_LDFLAGS += -lz
AAAHKWX_OBJ_FILES += libcurl.a

AAAHKWX_FILES = Tweak.xm
AAAHKWX_FRAMEWORKS= UIKit Foundation

include /opt/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
