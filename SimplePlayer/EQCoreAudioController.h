//
//  EQCoreAudioController.h
//  SimplePlayer with EQ
//
//  Created by Daniel Kennett on 02/04/2012.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface EQCoreAudioController : SPCoreAudioController

-(void)applyBandsToEQ:(NSArray *)tenBands;

@end
