FINALPACKAGE = 1

export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/../headers

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Peekable
Peekable_CFLAGS = -fobjc-arc -I./headers
Peekable_FILES = Tweak.xm
Peekable_FRAMEWORKS = UIKit
Peekable_LIBRARIES = MobileGestalt
Peekable_LDFLAGS += ./AppSupport.tbd ./IOKit.tbd

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += settings
include $(THEOS_MAKE_PATH)/aggregate.mk
