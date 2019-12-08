ifeq ($(SIMJECT),1)
TARGET = simulator:clang:latest:8.0
export ARCHS = x86_64
else
endif

FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Barmoji
Barmoji_FILES = Barmoji.xm $(wildcard *.m)
Barmoji_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += barmoji

include $(THEOS_MAKE_PATH)/aggregate.mk
