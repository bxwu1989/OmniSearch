export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = OmniSearch
OmniSearch_FILES = OmniSearch.m
OmniSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
OmniSearch_BUNDLE_EXTENSION = searchBundle
OmniSearch_LDFLAGS = -lspotlight
OmniSearch_PRIVATE_FRAMEWORKS = Search
OmniSearch_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

clean::
	rm -rf obj
	rm -rf omnisearchprefs/obj

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/OmniSearch.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp OmniSearch.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/OmniSearch.plist

	cp SearchProviders.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SearchProviders.plist

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"
SUBPROJECTS += omnisearchprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
