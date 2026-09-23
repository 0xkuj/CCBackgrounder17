export TARGET = iphone:clang:14.5:14.5
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCBackgrounder17Prefs

CCBackgrounder17Prefs_FILES = CCBackgrounder17ListController.m
CCBackgrounder17Prefs_FRAMEWORKS = UIKit
CCBackgrounder17Prefs_PRIVATE_FRAMEWORKS = Preferences
CCBackgrounder17Prefs_INSTALL_PATH = /Library/PreferenceBundles
CCBackgrounder17Prefs_EXTRA_FRAMEWORKS = AltList
CCBackgrounder17Prefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
