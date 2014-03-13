//
//  SearchProviderTableViewController.m
//  OmniSearch
//
//  Created by James Wu on 3/9/14.
//  Copyright (c) 2014 James Wu. All rights reserved.
//

#import "SearchProviderTableViewController.h"

#define NUMBER_OF_SECTIONS 2
#define ENABLED_SEARCH_PROVIDERS_SECTION 0
#define DISABLED_SEARCH_PROVIDERS_SECTION 1
#define ALL_SEARCH_PROVIDERS_PLIST @"Library/SearchLoader/Preferences/SearchProviders.plist"
#define SAVED_PREFERENCES_PLIST @"/var/mobile/Library/Preferences/com.wujames.omnisearchprefs.plist"
#define APP_VERSION @"0.5"

@interface SearchProviderTableViewController ()

@property (nonatomic, strong) NSMutableOrderedSet * enabledSearchProviders;
@property (nonatomic, strong) NSMutableOrderedSet * disabledSearchProviders;

@end


@implementation SearchProviderTableViewController

@synthesize enabledSearchProviders = _enabledSearchProviders;
@synthesize disabledSearchProviders = _disabledSearchProviders;

- (instancetype)init {
    
    self = [super init];
    if(self) {
        self.title = @"OmniSearch";
        [self loadPrefs];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.table setAllowsSelectionDuringEditing:YES];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.table setEditing:YES];
}


- (UITableView *) table
{
    return (UITableView *)self.view;
}


- (void)loadView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.view = tableView;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > DISABLED_SEARCH_PROVIDERS_SECTION) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section <= DISABLED_SEARCH_PROVIDERS_SECTION);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == ENABLED_SEARCH_PROVIDERS_SECTION) {
        return [self.enabledSearchProviders count];
    } else if(section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        return [self.disabledSearchProviders count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self getSearchProviderNameForIndexPath:indexPath];
    cell.showsReorderControl = YES;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == ENABLED_SEARCH_PROVIDERS_SECTION) {
        return @"Enabled Search Providers";
    } else if(section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        return @"Disabled Search Providers";
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSString * providerToMove = [[self getSearchProviderNameForIndexPath:sourceIndexPath] copy];
    
    if(sourceIndexPath.section == destinationIndexPath.section) {
        if(sourceIndexPath.section == ENABLED_SEARCH_PROVIDERS_SECTION) {
            [self.enabledSearchProviders removeObjectAtIndex:sourceIndexPath.row];
            if(destinationIndexPath.row > (self.enabledSearchProviders.count - 1)) {
                [self.enabledSearchProviders addObject:providerToMove];
            } else {
                [self.enabledSearchProviders insertObject:providerToMove atIndex:destinationIndexPath.row];
            }
            
        } else if(sourceIndexPath.section == DISABLED_SEARCH_PROVIDERS_SECTION) {
            [self.disabledSearchProviders removeObjectAtIndex:sourceIndexPath.row];
            if(destinationIndexPath.row > (self.enabledSearchProviders.count - 1)) {
                [self.disabledSearchProviders addObject:providerToMove];
            } else {
                [self.disabledSearchProviders insertObject:providerToMove atIndex:destinationIndexPath.row];
            }
        }
    } else {
        [self insertSearchProvider:providerToMove AtIndexPath:destinationIndexPath];
        [self removeSearchProviderAtIndexPath:sourceIndexPath];
    }
    [self savePrefs];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}

- (NSString *) getSearchProviderNameForIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == ENABLED_SEARCH_PROVIDERS_SECTION) {
        return self.enabledSearchProviders[indexPath.row];
    } else if(indexPath.section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        return self.disabledSearchProviders[indexPath.row];
    } else {
        NSLog(@"How did we end up here????");
        return nil;
    }
}

- (void) removeSearchProviderAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == ENABLED_SEARCH_PROVIDERS_SECTION) {
        [self.enabledSearchProviders removeObjectAtIndex:indexPath.row];
    } else if(indexPath.section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        [self.disabledSearchProviders removeObjectAtIndex:indexPath.row];
    }
}

- (void) insertSearchProvider:(NSString *)providerName AtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == ENABLED_SEARCH_PROVIDERS_SECTION) {
        if(!self.enabledSearchProviders.count) {
            [self.enabledSearchProviders addObject:providerName];
        } else {
            [self.enabledSearchProviders insertObject:providerName atIndex:indexPath.row];
        }
    } else if(indexPath.section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        if(!self.disabledSearchProviders.count) {
            [self.disabledSearchProviders addObject:providerName];
        } else {
            [self.disabledSearchProviders insertObject:providerName atIndex:indexPath.row];
        }
    }
}

- (void) loadPrefs {
    
    /** load from saved preferences or if it doesn't exist, enable all */
    NSDictionary *savedPreferences = [NSDictionary dictionaryWithContentsOfFile:SAVED_PREFERENCES_PLIST];
    
    /* if preferences do not exist or if the version has changed, we will reload the preferences */
    NSString *version = [savedPreferences valueForKey:@"Version"];
    
    if(!version || ![version isEqualToString:APP_VERSION]) {
        [self loadPrefsForFirstTime];
        [self savePrefs];
    } else {
        self.enabledSearchProviders = [NSMutableOrderedSet orderedSetWithArray:savedPreferences[@"Enabled"]];
        self.disabledSearchProviders = [NSMutableOrderedSet orderedSetWithArray:savedPreferences[@"Disabled"]];
    }
}

- (void) savePrefs {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    
    prefs[@"Enabled"] = self.enabledSearchProviders.array;
    prefs[@"Disabled"] = self.disabledSearchProviders.array;
    
    prefs[@"Version"] = APP_VERSION;
    
    [prefs.copy writeToFile:SAVED_PREFERENCES_PLIST atomically:YES];
}

- (void) loadPrefsForFirstTime {
    
    /** load all the available providers */
    NSDictionary * allSearchProviders = [NSDictionary dictionaryWithContentsOfFile:ALL_SEARCH_PROVIDERS_PLIST];
    
    for(NSString *searchProvider in [allSearchProviders allKeys]) {
        [self.enabledSearchProviders addObject:[searchProvider copy]];
    }
}

- (NSMutableOrderedSet *) enabledSearchProviders {
    if(!_enabledSearchProviders) {
        _enabledSearchProviders = [[NSMutableOrderedSet alloc] init];
    }
    return _enabledSearchProviders;
}

- (NSMutableOrderedSet *) disabledSearchProviders {
    if(!_disabledSearchProviders) {
        _disabledSearchProviders = [[NSMutableOrderedSet alloc] init];
    }
    return _disabledSearchProviders;
}

@end
