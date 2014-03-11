include theos/makefiles/common.mk

BUNDLE_NAME = OmniSearchPrefs
OmniSearchPrefs_FILES = OmniSearchPrefs.mm
OmniSearchPrefs_INSTALL_PATH = /Library/PreferenceBundles
OmniSearchPrefs_FRAMEWORKS = UIKit
OmniSearchPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

clean::
	rm -rf obj
	rm -rf omnisearchprefs/obj

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OmniSearchPrefs.plist$(ECHO_END)
