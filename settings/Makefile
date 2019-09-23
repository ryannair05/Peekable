SHARED_CFLAGS = -fobjc-arc
CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -fobjc-arc
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

BUNDLE_NAME = Peekable
Peekable_FILES = PABRootListController.m PABAppSettingsController.m OrderedDictionary.m
Peekable_INSTALL_PATH = /Library/PreferenceBundles
Peekable_FRAMEWORKS = UIKit
Peekable_LDFLAGS += ./Preferences.tbd ./SpringBoardServices.tbd
Peekable_CFLAGS = -fobjc-arc -I./headers

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Peekable.plist$(ECHO_END)
