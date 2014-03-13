//
//  OmniSearch.m
//  OmniSearch
//
//  Created by Kirbyk on 18.02.2014.
//  Copyright (c) 2014 Kirbyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)
#define GET_INT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).intValue : default)
#define GET_STR(key, default) (prefs[key] ? prefs[key] : default)

#define ALL_SEARCH_PROVIDERS_PLIST @"Library/SearchLoader/Preferences/SearchProviders.plist"
#define SAVED_PREFERENCES_PLIST @"/var/mobile/Library/Preferences/com.wujames.omnisearchprefs.plist"

@interface TLOmniSearchDatastore : NSObject <TLSearchDatastore> {
    BOOL $usingInternet;
}
@end

@implementation TLOmniSearchDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
    
    NSMutableArray *searchResults = [NSMutableArray array];
    
    /** Load the all preconfigured search providers */
    NSDictionary *allSearchProviders = [[NSDictionary dictionaryWithContentsOfFile:@"/Library/SearchLoader/Preferences/SearchProviders.plist"] copy];
    
    NSString *searchString = [[query searchString] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    /** Load the saved preferences */
    BOOL prefExists = [[NSFileManager defaultManager] fileExistsAtPath:SAVED_PREFERENCES_PLIST];
    
    NSArray *enabledSearchProviders = prefExists ? [[NSDictionary dictionaryWithContentsOfFile:SAVED_PREFERENCES_PLIST][@"Enabled"] copy] : [allSearchProviders allKeys];
    
    for(NSString *enabledProviderName in enabledSearchProviders) {
        SPSearchResult *result = [[SPSearchResult alloc] init];
        
        [result setTitle:[@"Search " stringByAppendingString:enabledProviderName]];
        
        NSString *url = [NSString stringWithFormat:allSearchProviders[enabledProviderName], searchString];
        
        [result setUrl:url];
        
        [searchResults addObject:result];
    }
    
    TLCommitResults(searchResults, TLDomain(@"com.wujames.omnisearch", @"OmniSearch"), results);
    
    TLFinishQuery(results);
}

- (NSArray *)searchDomains {
    return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.wujames.omnisearch", @"OmniSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
    return @"com.wujames.omnisearch";
}

- (BOOL)blockDatastoreComplete {
    return $usingInternet;
}
@end
