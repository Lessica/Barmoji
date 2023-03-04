export ARCHS = arm64 arm64e
export TARGET = iphone:clang:15.4.1:13.0
export PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Barmoji
Barmoji_FILES = $(wildcard  *.xm *.m)
Barmoji_CFLAGS += -fobjc-arc -include prefix.pch

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += barmoji

include $(THEOS_MAKE_PATH)/aggregate.mk
