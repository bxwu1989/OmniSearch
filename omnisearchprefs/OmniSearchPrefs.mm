#import <Preferences/Preferences.h>

@interface OmniSearchPrefsListController: PSListController {
}
@end

@implementation OmniSearchPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"OmniSearchPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
