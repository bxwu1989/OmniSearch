//
//  SearchProviderTableViewController.m
//  OrderedTableViewDemo
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

#define kCCLoaderSettingsPath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Preferences/com.wujames.omnisearchprefs.plist"]


@interface SearchProviderTableViewController ()

@property (nonatomic, strong) NSMutableArray * enabledSearchProviders;
@property (nonatomic, strong) NSMutableArray * disabledSearchProviders;

@end


@implementation SearchProviderTableViewController

@synthesize enabledSearchProviders = _enabledSearchProviders;
@synthesize disabledSearchProviders = _disabledSearchProviders;

- (instancetype)init {
    NSLog(@"init called");
    
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
    
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView setEditing:YES];
    NSLog(@"ViewDidLoad called with following providers: enabled = %@ disabled = %@", self.enabledSearchProviders, self.disabledSearchProviders);
}


- (UITableView *) tableView
{
    return (UITableView *)self.view;
}


- (void)loadView {
    NSLog(@"Load view called");
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
    NSLog(@"# of rows called");
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
    NSString * sourceProvider = [self getSearchProviderNameForIndexPath:sourceIndexPath];
    [self insertSearchProvider:sourceProvider AtIndexPath:destinationIndexPath];

    [self removeSearchProviderAtIndexPath:sourceIndexPath];
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
        [self.enabledSearchProviders insertObject:providerName atIndex:indexPath.row];
        NSLog(@"Completed Inserting into enabled");

    } else if(indexPath.section == DISABLED_SEARCH_PROVIDERS_SECTION) {
        [self.disabledSearchProviders insertObject:providerName atIndex:indexPath.row];
        NSLog(@"Completed Inserting into disabled");

    }
}

- (void) loadPrefs {
    
    /** load from saved preferences or if it doesn't exist, enable all */
    NSDictionary *savedPreferences = [NSDictionary dictionaryWithContentsOfFile:SAVED_PREFERENCES_PLIST];
    
    if(![savedPreferences valueForKey:@"Initialized"]) {
        [self loadPrefsForFirstTime];
        [self savePrefs];
    } else {
        self.enabledSearchProviders = [savedPreferences[@"Enabled"] mutableCopy];
        self.disabledSearchProviders = [savedPreferences[@"Disabled"] mutableCopy];
    }

    NSLog(@"Loaded prefs enabled: %@, disabled: %@", self.enabledSearchProviders, self.disabledSearchProviders);

}

- (void) savePrefs {
    
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    
    prefs[@"Enabled"] = self.enabledSearchProviders;
    prefs[@"Disabled"] = self.disabledSearchProviders;
    
    prefs[@"Initialized"] = @"Done";
    
    [prefs.copy writeToFile:kCCLoaderSettingsPath atomically:YES];
    
}

- (void) loadPrefsForFirstTime {
    
    /** load all the available providers */
    NSArray * allSearchProviders = [NSDictionary dictionaryWithContentsOfFile:ALL_SEARCH_PROVIDERS_PLIST][@"searchProviders"];
    
    for(NSDictionary *searchProvider in allSearchProviders) {
        [self.enabledSearchProviders addObject:[searchProvider[@"ProviderName"] copy]];
    }
}

- (NSMutableArray *) enabledSearchProviders {
    if(!_enabledSearchProviders) {
        _enabledSearchProviders = [[NSMutableArray alloc] init];
    }
    return _enabledSearchProviders;
}

- (NSMutableArray *) disabledSearchProviders {
    if(!_disabledSearchProviders) {
        _disabledSearchProviders = [[NSMutableArray alloc] init];
    }
    return _disabledSearchProviders;
}

@end
