THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 armv7s arm64
TARGET = iphone:latest:8.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = mycontacts
mycontacts_FILES = contacts.xm
mycontacts_FRAMEWORKS = UIKit AddressBook AddressBookUI Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Contacts"
