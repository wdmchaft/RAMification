//
//  RMFMenuController.m
//  RAMification
//
//  Created by Michael Starke on 14.12.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import "RMFMenuController.h"
#import "RMFRamdisk.h"
#import "RMFFavoriteManager.h"
#import "RMFAppDelegate.h"
#import "RMFCreateRamDiskOperation.h"
#import "NSString+RMFVolumeTools.h"

NSString *const RMFMenuIconTemplateImage = @"MenuItemIconTemplate"; 

@implementation RMFMenuController

#pragma mark object lifecycle
- (id)init
{
  self = [super init];
  if (self)
  {
    queue = [[NSOperationQueue alloc] init];
    favouritesMap = [[NSMutableDictionary alloc] init];
    [self createMenu];
    [self createStatusItem];
    [((RMFAppDelegate*)[NSApp delegate]).favoritesManager addObserver:self
                                                          forKeyPath:@"favourites"
                                                          options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                                                          context:nil];
  }
  return self;
}

- (void)dealloc {
  [queue release];
  [statusItem release];
  [menu release];
  [favouritesMap release];
  
  queue = nil;
  statusItem = nil;
  menu = nil;
  favouritesMap = nil;
  
  [super dealloc];
}

# pragma mark create/update menu

- (void)createFavouritesMenu
{
  NSMenuItem *item;
  RMFFavoriteManager *manager = ((RMFAppDelegate*)[NSApp delegate]).favoritesManager;
  favoritesMenu = [[NSMenu alloc] initWithTitle:@"PresetsSubmenu"];
  
  for(RMFRamdisk *favorite in manager.favourites)
  {
    item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:favorite.label action:@selector(updateFavouriteState:) keyEquivalent:@""];
    //[item setState:NSMixedState];
    [favorite addObserver:self forKeyPath:@"label" options:0 context:nil];
    [item setTarget:self];
    [favoritesMenu addItem:item];
    [favouritesMap setObject:favorite forKey:[NSValue valueWithPointer:item]];
    [item release];
  }
  
  if([manager.favourites count] == 0)
  {
    
    item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"MENU_NO_FAVOURITES_DEFINED", @"Menu Item - No Favourites defined") action:nil keyEquivalent:@""];
    [favoritesMenu addItem:item];
    [item release];
  }
  
  [favoritesMenu addItem:[NSMenuItem separatorItem]];
}

- (void) createMenu
{
  menu = [[NSMenu alloc] initWithTitle:@"menu"];
  NSMenuItem *item;

  // About
  NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
  NSString *aboutString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"MENU_ABOUT", @"The lolcalized Version of About"), appName];
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:aboutString action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setTarget:NSApp];
  [menu addItem:item];
  [item release];
  
  // Preferences
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"MENU_ITEM_PREFERENCES", @"Menu Item - Preferences")] action:@selector(showSettingsTab:) keyEquivalent:@""];
  [item setRepresentedObject:[RMFGeneralSettingsController identifier]];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [menu addItem:item];
  [item release];
  
  [menu addItem:[NSMenuItem separatorItem]];
  
  // Create ramdisk
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"MENU_CREATE_RAMDISK", @"Create Ramdisk") action:@selector(updateFavouriteState:) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [menu addItem:item];
  [item release];
  
  // Destroy ramdisk
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"MENU_UNMOUNT_RAMDISK", @"Destroy Ramdisk") action:@selector(removeRamdisk) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [menu addItem:item];
  [item release];
  
  // Favourites
  [self createFavouritesMenu];
  
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"MENU_MANAGE_FAVOURITES", @"Menu Manage Favourites")] action:@selector(showSettingsTab:) keyEquivalent:@""];
  [item setRepresentedObject:[RMFFavoritesSettingsController identifier]];
  [item setEnabled:YES];
  [item setTarget:self];
  [favoritesMenu addItem:item];
  [item release];
  
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"COMMON_PLURAL_FAVOURITE", @"Favourites") action:nil keyEquivalent:@""];
  [item setEnabled:YES];
  [item setTarget:self];
  [item setSubmenu:favoritesMenu];
  [menu addItem:item];
  [item release];
  
  // Separation
  [menu addItem:[NSMenuItem separatorItem]];
   
  // Quit
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"COMMON_QUIT", @"Quit") action:@selector(quitApplication) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setTarget:self];
  [menu addItem:item];
  [item release];
}

- (void) createStatusItem
{
  NSStatusBar *bar = [NSStatusBar systemStatusBar];
  statusItem = [[bar statusItemWithLength:NSVariableStatusItemLength] retain];
  NSImage *menuIconImage = [NSImage imageNamed:RMFMenuIconTemplateImage];
  [statusItem setImage:menuIconImage];
  [statusItem setEnabled:YES];
  [statusItem setHighlightMode:YES];
  [statusItem setMenu:menu];
}

- (void)updateFavouritesMenu
{
  for(NSMenuItem *item in [favoritesMenu itemArray])
  {
    RMFRamdisk *preset = [favouritesMap objectForKey:[NSValue valueWithPointer:item]];
    if(preset != nil)
    {
      [item setTitle:preset.label];
      if(preset.isMounted)
      {
        //[item setState:NSOnState];
      }
      else
      {
        //[item setState:NSOffState];
      }
    }
  }
}


# pragma mark actions

- (void) quitApplication
{
  //Unmount ramdisk?
  [[NSApplication sharedApplication] terminate:nil];
}

- (void) showSettingsTab:(id)sender
{
  [((RMFAppDelegate*)[NSApp delegate]).settingsController showSettings:[sender representedObject]];
}

- (void)updateFavouriteState:(id)sender
{
  NSMenuItem* item = sender;
  RMFRamdisk* itemPreset = [[favouritesMap objectForKey:[NSValue valueWithPointer:item]] retain];
  if(itemPreset.isMounted)
  {
    [self eject:itemPreset];
  }
  else
  {
    [self mount:itemPreset];
  }
  [itemPreset release];
}

# pragma mark mount/unmount

- (void) mount:(RMFRamdisk*) preset
{
  RMFCreateRamDiskOperation *mountOperation = [[RMFCreateRamDiskOperation alloc] initWithRamdisk:preset];
  [queue cancelAllOperations];
  [queue addOperation:mountOperation];
  [mountOperation release];
}

- (void)eject:(RMFRamdisk *)preset
{
  [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:[preset.label volumePath]];
}

- (void) removeRamdisk
{
  [queue cancelAllOperations];
  // search if a ramdisk is active and detach it by calling
  // hdutil detach <Device>
}

# pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  [self updateFavouritesMenu];
}
@end
