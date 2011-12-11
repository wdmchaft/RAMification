//
//  RMFPresets.h
//  RAMification
//
//  Created by Michael Starke on 27.11.11.
//  Copyright (c) 2011 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
 
//  Represents the list of Presets the user has created
@interface RMFVolumePreset : NSObject

@property (retain) NSString* volumeLabel;
@property (assign) NSUInteger diskSize;
@property (assign) BOOL shouldAutoMount;

+ (RMFVolumePreset*) VolumePresetWithContentOfDict:(NSDictionary*)dict;
+ (RMFVolumePreset*) VolumePresetWithLable:(NSString*)aLabel andSize:(NSUInteger)aSize shouldAutoMount:(BOOL)mount;
+ (RMFVolumePreset*) VolumePreset;
+ (NSUInteger) defaultDiskSize;
+ (NSString *) defaultVolumeLabel;

- (id) initWithLabel:(NSString*)aLable andSize:(NSUInteger)aSize shouldMount:(BOOL)mount;
- (NSDictionary *) convertToDictionary;

@end
