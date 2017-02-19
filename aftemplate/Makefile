THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2226
THEOS_USER = root
ARCHS = armv7
#;armv7s arm64
TARGET = iphone:latest:8.0

#;FINALPACKAGE = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = aftemplate
aftemplate_CFLAGS += -Ilayout/Library/Frameworks/AFNetWorking.framework/Headers
aftemplate_CFLAGS += -Wno-error

aftemplate_LDFLAGS += -force_load layout/Library/Frameworks/AFNetworking.framework/AFNetworking
aftemplate_FILES = Tweak.xm
aftemplate_FRAMEWORKS= UIKit Foundation
# aftemplate_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"

include $(THEOS_MAKE_PATH)/aggregate.mk
