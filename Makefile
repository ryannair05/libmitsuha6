FINALPACKAGE = 1

export TARGET = iphone:17.0.2:15.0
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3

ARCHS = arm64 arm64e

THEOS_PACKAGE_SCHEME=rootless

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libmitsuhaforever
$(LIBRARY_NAME)_OBJC_FILES = $(wildcard *.m)
$(LIBRARY_NAME)_FILES = $(wildcard *.swift)
$(LIBRARY_NAME)_SWIFTFLAGS += -enable-library-evolution
$(LIBRARY_NAME)_SWIFT_BRIDGING_HEADER = libmitsuhaforever-Bridging-Header.h

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
$(LIBRARY_NAME)_LDFLAGS += -install_name @rpath/libmitsuhaforever.dylib
endif

include $(THEOS_MAKE_PATH)/library.mk

after-install::
	install.exec "killall -9 SpringBoard"

stage::
	mkdir -p $(THEOS_STAGING_DIR)/usr/include/MitsuhaForever
	$(ECHO_NOTHING)rsync -a ./public/* $(THEOS_STAGING_DIR)/usr/include/MitsuhaForever $(FW_RSYNC_EXCLUDES)$(ECHO_END)
	mkdir -p $(THEOS)/include/MitsuhaForever
	cp -r ./public/* $(THEOS)/include/MitsuhaForever
ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	cp $(THEOS_STAGING_DIR)/usr/lib/libmitsuhaforever.dylib $(THEOS_LIBRARY_PATH)/iphone/rootless/libmitsuhaforever.dylib
else
	cp $(THEOS_STAGING_DIR)/usr/lib/libmitsuhaforever.dylib $(THEOS_LIBRARY_PATH)/libmitsuhaforever.dylib
endif
