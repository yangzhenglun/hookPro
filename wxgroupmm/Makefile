THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2999
THEOS_USER = root
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:8.0

FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = wxgroupmm

thirdparty/UIView+SDAutoLayout.m_CFLAGS += -fobjc-arc
thirdparty/XMLDictionary.m_CFLAGS += -fobjc-arc
wxgroupmm_CFLAGS += -fobjc-weak
wxgroupmm_CFLAGS += -Wno-error
wxgroupmm_CFLAGS += -Ithirdparty
;wxgroupmm_CFLAGS += -ObjC
wxgroupmm_FILES = $(wildcard thirdparty/*.m *.xm)
wxgroupmm_FRAMEWORKS= UIKit Foundation NetworkExtension AVFoundation CoreMedia CoreVideo QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"

