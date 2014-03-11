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

@interface TLOmniSearchDatastore : NSObject <TLSearchDatastore> {
    BOOL $usingInternet;
}
@end

@implementation TLOmniSearchDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
    
    /** Load the all preconfigured search providers */
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/Library/SearchLoader/Preferences/SearchProviders.plist"];
    
    NSString *searchString = [[query searchString] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSMutableArray *searchResults = [NSMutableArray array];
    NSArray * allSearchProviders = prefs[@"searchProviders"];
    
    /** Load the enabled search providers from preferences */
    NSDictionary *enabledProvidersPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.wujames.omnisearchprefs.plist"];
    
    for(NSDictionary *searchProvider in allSearchProviders) {
        
        NSString *providerName = searchProvider[@"ProviderName"];
        
        /** filter out disabled search providers, we do it here because somehow PreferenceLoader does not put default value into the plist from PSSwitchCell */
        if(!enabledProvidersPrefs[providerName] || [enabledProvidersPrefs[providerName] boolValue]) {
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
