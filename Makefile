ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Barmoji
Barmoji_FILES = $(wildcard  *.xm *.m)
Barmoji_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += barmoji

include $(THEOS_MAKE_PATH)/aggregate.mk
