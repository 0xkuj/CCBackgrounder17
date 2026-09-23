export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCBackgrounder17Core

CCBackgrounder17Core_FILES = CCBackgrounder17Core.xm
CCBackgrounder17Core_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
