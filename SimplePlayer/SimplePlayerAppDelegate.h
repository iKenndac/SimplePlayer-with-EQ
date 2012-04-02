//
//  SimplePlayerAppDelegate.h
//  SimplePlayer
//
//  Created by Daniel Kennett on 04/05/2011.
/*
 Copyright (c) 2011, Spotify AB
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface SimplePlayerAppDelegate : NSObject  <NSApplicationDelegate, SPSessionDelegate> {
@private
	NSWindow *__unsafe_unretained window;
	NSPanel *__unsafe_unretained loginSheet;
	NSTextField *__weak userNameField;
	NSSecureTextField *__weak passwordField;
	NSTimeInterval currentTrackPosition;
	
	SPPlaybackManager *playbackManager;
	NSTextField *__weak trackURLField;
	NSSlider *__weak playbackProgressSlider;
	__weak NSSlider *eqSlider1;
	__weak NSSlider *eqSlider2;
	__weak NSSlider *eqSlider3;
	__weak NSSlider *eqSlider4;
	__weak NSSlider *eqSlider5;
	__weak NSSlider *eqSlider6;
	__weak NSSlider *eqSlider7;
	__weak NSSlider *eqSlider8;
	__weak NSSlider *eqSlider9;
	__weak NSSlider *eqSlider10;
}

@property (weak) IBOutlet NSSlider *playbackProgressSlider;
@property (weak) IBOutlet NSTextField *trackURLField;
@property (weak) IBOutlet NSTextField *userNameField;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (unsafe_unretained) IBOutlet NSPanel *loginSheet;
@property (unsafe_unretained) IBOutlet NSWindow *window;

- (IBAction)login:(id)sender;
- (IBAction)quitFromLoginSheet:(id)sender;

#pragma mark -

@property (nonatomic, readwrite, strong) SPPlaybackManager *playbackManager;

- (IBAction)playTrack:(id)sender;
- (IBAction)seekToPosition:(id)sender;

#pragma mark - EQ

-(IBAction)eqSliderDidChange:(id)sender;

@property (weak) IBOutlet NSSlider *eqSlider1;
@property (weak) IBOutlet NSSlider *eqSlider2;
@property (weak) IBOutlet NSSlider *eqSlider3;
@property (weak) IBOutlet NSSlider *eqSlider4;
@property (weak) IBOutlet NSSlider *eqSlider5;
@property (weak) IBOutlet NSSlider *eqSlider6;
@property (weak) IBOutlet NSSlider *eqSlider7;
@property (weak) IBOutlet NSSlider *eqSlider8;
@property (weak) IBOutlet NSSlider *eqSlider9;
@property (weak) IBOutlet NSSlider *eqSlider10;

@end
