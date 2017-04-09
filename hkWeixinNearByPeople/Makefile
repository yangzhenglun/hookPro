THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_USER = root
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:7.0

;FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = hkweixinnearbypeople
hkweixinnearbypeople_CFLAGS += -Wno-error
hkweixinnearbypeople_CFLAGS += -I./curl
hkweixinnearbypeople_LDFLAGS += -lz
hkweixinnearbypeople_OBJ_FILES += libcurl.a

hkweixinnearbypeople_FILES = Tweak.xm
hkweixinnearbypeople_FRAMEWORKS= UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"