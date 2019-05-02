TARGET = :clang:11.2:7.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Barmoji
Barmoji_FILES = BarmojiRootListController.mm $(wildcard *.m)
Barmoji_INSTALL_PATH = /Library/PreferenceBundles
Barmoji_FRAMEWORKS = UIKit MessageUI Social CoreGraphics
Barmoji_PRIVATE_FRAMEWORKS = Preferences
Barmoji_LDFLAGS = -lMobileGestalt

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Barmoji.plist$(ECHO_END)
