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
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/Library/SearchLoader/Preferences/SearchProviders.plist"];
    
    NSString *searchString = [[query searchString] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSArray * allSearchProviders = prefs[@"searchProviders"];
    
    /** Load the saved preferences */
    NSArray *enabledSearchProviders = [NSDictionary dictionaryWithContentsOfFile:SAVED_PREFERENCES_PLIST][@"Enabled"];
    
    for(NSDictionary *searchProvider in allSearchProviders) {
        
        NSString *providerName = searchProvider[@"ProviderName"];
        
        /** filter out disabled search providers */
        if([enabledSearchProviders containsObject:providerName]) {
            SPSearchResult *result = [[SPSearchResult alloc] init];
            
            [result setTitle:[@"Search " stringByAppendingString:searchProvider[@"ProviderName"]]];
            
            NSString *url = [NSString stringWithFormat:searchProvider[@"QueryString"], searchString];
            
            [result setUrl:url];
            
            [searchResults addObject:result];
        }
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
