include $(THEOS)/makefiles/common.mk

export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

BUNDLE_NAME = CCBackgrounder17
CCBackgrounder17_BUNDLE_EXTENSION = bundle
CCBackgrounder17_FILES = CCBackgrounder17.xm
CCBackgrounder17_PRIVATE_FRAMEWORKS = ControlCenterUIKit
CCBackgrounder17_INSTALL_PATH = /Library/ControlCenter/Bundles/
CCBackgrounder17_CFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += CCBackgrounder17Core CCBackgrounder17Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
