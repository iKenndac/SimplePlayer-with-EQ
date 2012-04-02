//
//  SimplePlayerAppDelegate.m
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

#import "SimplePlayerAppDelegate.h"
#import "EQCoreAudioController.h"

//#error Please get an appkey.c file from developer.spotify.com and remove this error before building.
#include "appkey.c"

@interface SimplePlayerAppDelegate ()

@property (nonatomic, readwrite, strong) EQCoreAudioController *audioController;

@end

@implementation SimplePlayerAppDelegate

@synthesize eqSlider1;
@synthesize eqSlider2;
@synthesize eqSlider3;
@synthesize eqSlider4;
@synthesize eqSlider5;
@synthesize eqSlider6;
@synthesize eqSlider7;
@synthesize eqSlider8;
@synthesize eqSlider9;
@synthesize eqSlider10;

@synthesize playbackProgressSlider;
@synthesize trackURLField;
@synthesize userNameField;
@synthesize passwordField;
@synthesize loginSheet;
@synthesize window;
@synthesize playbackManager;
@synthesize audioController;

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
	
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"com.spotify.SimplePlayer"
												   error:nil];
	[self.window center];
	[self.window orderFront:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	[[SPSession sharedSession] setDelegate:self];
	
	self.audioController = [[EQCoreAudioController alloc] init];
	
	self.playbackManager = [[SPPlaybackManager alloc] initWithAudioController:self.audioController
															  playbackSession:[SPSession sharedSession]];
	
	[self addObserver:self
		   forKeyPath:@"playbackManager.trackPosition"
			  options:0
			  context:nil];
	
	[NSApp beginSheet:self.loginSheet
	   modalForWindow:self.window
		modalDelegate:nil
	   didEndSelector:nil 
		  contextInfo:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if ([SPSession sharedSession].connectionState == SP_CONNECTION_STATE_LOGGED_OUT ||
		[SPSession sharedSession].connectionState == SP_CONNECTION_STATE_UNDEFINED) 
		return NSTerminateNow;
	
	[[SPSession sharedSession] logout];
	return NSTerminateLater;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	// Invoked when the current playback position changed (see below). This is a bit of a workaround
	// to make sure we don't update the position slider while the user is dragging it around. If the position
	// slider was read-only, we could just bind its value to playbackManager.trackPosition.
	
    if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
        if (![[self.playbackProgressSlider cell] isHighlighted]) {
			[self.playbackProgressSlider setDoubleValue:self.playbackManager.trackPosition];
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)quitFromLoginSheet:(id)sender {
	
	// Invoked by clicking the "Quit" button in the UI.
	
	[NSApp endSheet:self.loginSheet];
	[NSApp terminate:self];
}

- (IBAction)login:(id)sender {
	
	// Invoked by clicking the "Login" button in the UI.
	
	if ([[userNameField stringValue] length] > 0 && 
		[[passwordField stringValue] length] > 0) {
		
		[[SPSession sharedSession] attemptLoginWithUserName:[userNameField stringValue]
												   password:[passwordField stringValue]
										rememberCredentials:NO];
	} else {
		NSBeep();
	}
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	
	// Invoked by SPSession after a successful login.
	
	[self.loginSheet orderOut:self];
	[NSApp endSheet:self.loginSheet];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    
	// Invoked by SPSession after a failed login.
	
    [NSApp presentError:error
         modalForWindow:self.loginSheet
               delegate:nil
     didPresentSelector:nil
            contextInfo:nil];
}

-(void)sessionDidLogOut:(SPSession *)aSession; {
	[[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {

	[[NSAlert alertWithMessageText:aMessage
					 defaultButton:@"OK"
				   alternateButton:@""
					   otherButton:@""
		 informativeTextWithFormat:@"This message was sent to you from the Spotify service."] runModal];
}

#pragma mark -
#pragma mark Playback

- (IBAction)playTrack:(id)sender {
	
	// Invoked by clicking the "Play" button in the UI.

	if ([[trackURLField stringValue] length] > 0) {
		
		NSURL *trackURL = [NSURL URLWithString:[trackURLField stringValue]];
		SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
		
		if (track != nil) {
			
			if (!track.isLoaded) {
				// Since we're trying to play a brand new track that may not be loaded, 
				// we may have to wait for a moment before playing. Tracks that are present 
				// in the user's "library" (playlists, starred, inbox, etc) are automatically loaded
				// on login. All this happens on an internal thread, so we'll just try again in a moment.
				[self performSelector:@selector(playTrack:) withObject:sender afterDelay:0.1];
				return;
			}
			
			NSError *error = nil;
			
			if (![self.playbackManager playTrack:track error:&error]) {
				[self.window presentError:error];
			}
			return;
		}
	}
	NSBeep();
}

- (IBAction)seekToPosition:(id)sender {
	
	// Invoked by dragging the position slider in the UI.
	
	if (self.playbackManager.currentTrack != nil && self.playbackManager.isPlaying) {
		[self.playbackManager seekToTrackPosition:[sender doubleValue]];
	}
}

#pragma mark - EQ

-(IBAction)eqSliderDidChange:(id)sender {
	
	NSMutableArray *bands = [NSMutableArray arrayWithCapacity:10];
	
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider1.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider2.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider3.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider4.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider5.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider6.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider7.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider8.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider9.floatValue]];
	[bands addObject:[NSNumber numberWithFloat:self.eqSlider10.floatValue]];
	
	[self.audioController applyBandsToEQ:bands];
}

@end
