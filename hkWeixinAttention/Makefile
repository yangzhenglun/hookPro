THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_USER = root
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:7.0

;FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = hkweixinattention
hkweixinattention_CFLAGS += -Wno-error
hkweixinattention_CFLAGS += -I./curl
hkweixinattention_LDFLAGS += -lz
hkweixinattention_OBJ_FILES += libcurl.a

hkweixinattention_FILES = Tweak.xm
hkweixinattention_FRAMEWORKS= UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"