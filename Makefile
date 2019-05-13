TARGET = :clang:11.2:7.0
ARCHS = arm64 arm64e
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Barmoji
Barmoji_FILES = Barmoji.xm $(wildcard *.m)
Barmoji_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += barmoji
include $(THEOS_MAKE_PATH)/aggregate.mk
