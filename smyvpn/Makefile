THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_USER = root
include /opt/theos/makefiles/common.mk

TWEAK_NAME = smyvpn
smyvpn_FILES = Tweak.xm
smyvpn_FRAMEWORKS = UIKit
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:latest:7.0
ADDITIONAL_CCFLAGS  = -Qunused-arguments
ADDITIONAL_LDFLAGS  = -Wl,-segalign,4000
smyvpn_CFLAGS += -Wno-error
;ADDITIONAL_CFLAGS   = -Werror -Wobjc-method-access
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"
