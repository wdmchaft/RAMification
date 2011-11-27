//
//  AKPAppDelegate.m
//  RAMification
//
//  Created by Michael Starke on 24.11.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import "RMFAppDelegate.h"
#import "RMFCreateRamDiskOperation.h"

// predefined values (private)
NSString *const defaultName = @"Ramdisk";
const NSUInteger defaultSize = 1024;

// actual implemenation

@implementation RMFAppDelegate

@synthesize statusItem = _statusItem;
@synthesize settingsController = _settingsController;
@synthesize menu = _menu;
@synthesize ramdiskname = _ramdiskname;
@synthesize ramdisksize = _ramdisksize;

- (void)dealloc
{
  [super dealloc];
  // remove the toolbardelegate from the 
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // intialize settings window toolbar delegate
  queue = [[NSOperationQueue alloc] init];
  [self createMenu];
  [self createStatusItem];
  
  self.ramdiskname = defaultName;
  self.ramdisksize = defaultSize;
}

- (void) createMenu
{
  _menu = [[NSMenu alloc] initWithTitle:@"menu"];
  // Create ramdisk
  NSMenuItem *item;
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Create Ramdisk" action:@selector(createRamdisk) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [self.menu addItem:item];
  [item release];
  
  // Destroy ramdisk
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Destroy Ramdisk" action:@selector(removeRamdisk) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [self.menu addItem:item];
  [item release];

  // Separation
  [self.menu addItem:[NSMenuItem separatorItem]];

  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Manage Presets..." action:@selector(showSettings) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask];
  [item setTarget:self];
  [self.menu addItem:item];
  [item release];

  // Separation
  [self.menu addItem:[NSMenuItem separatorItem]];
  
  // Quit
  item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Quit" action:@selector(quitApplication) keyEquivalent:@""];
  [item setEnabled:YES];
  [item setTarget:self];
  [self.menu addItem:item];
  [item release];
}

- (void) createStatusItem
{
  NSStatusBar *bar = [NSStatusBar systemStatusBar];
  self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
  //[self.statusItem setTitle:@"RAMification"];
  [self.statusItem setImage: [NSImage imageNamed:NSImageNameActionTemplate]];
  [self.statusItem setEnabled:YES];
  [self.statusItem setHighlightMode:YES];
  [self.statusItem setMenu:self.menu];
}

- (void) quitApplication
{
  //Unmount ramdisk?
  [[NSApplication sharedApplication] terminate:nil];
}

- (void) showSettings
{
  if(self.settingsController == nil)
  {
   _settingsController = [[RMFSettingsController alloc] init];
  }
  [self.settingsController showWindow];
}

- (void) createRamdisk
{
  RMFCreateRamDiskOperation *mountOperation = [[RMFCreateRamDiskOperation alloc] initWithSize:self.ramdisksize andLabel:self.ramdiskname];
  [queue cancelAllOperations];
  [queue addOperation:mountOperation];
  [mountOperation release];
}

- (void) removeRamdisk
{
  [queue cancelAllOperations];
  // search if a ramdisk is active and detach it by calling
  // hdutil detach <Device>
}

@end
