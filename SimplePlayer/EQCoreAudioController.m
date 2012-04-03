//
//  EQCoreAudioController.m
//  SimplePlayer with EQ
//
//  Created by Daniel Kennett on 02/04/2012.
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
#import "EQCoreAudioController.h"

@implementation EQCoreAudioController {
	AUNode eqNode;
	AudioUnit eqUnit;
}

-(void)applyBandsToEQ:(NSArray *)tenBands {
	
	if (eqUnit == NULL) return;
	
	// Loop through our bands and update them.
	for (NSUInteger bandIndex = 0; bandIndex < MIN(10, tenBands.count); bandIndex++) {
		Float32 bandValue = [[tenBands objectAtIndex:bandIndex] floatValue];
		AudioUnitSetParameter(eqUnit, bandIndex, kAudioUnitScope_Global, 0, bandValue, 0);
	}
}

#pragma mark - Setting up the EQ

-(BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError **)error {
	
	// Override this method to connect the source node to the destination node via an EQ node.
	
	// A description for the EQ Device
	AudioComponentDescription eqDescription;
	eqDescription.componentType = kAudioUnitType_Effect;
	eqDescription.componentSubType = kAudioUnitSubType_GraphicEQ;
	eqDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	eqDescription.componentFlags = 0;
    eqDescription.componentFlagsMask = 0;
	
	// Add the EQ node to the AUGraph
	OSStatus status = AUGraphAddNode(graph, &eqDescription, &eqNode);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't add EQ node");
		return NO;
    }
	
	// Get the EQ Audio Unit from the node so we can set bands directly later
	status = AUGraphNodeInfo(graph, eqNode, NULL, &eqUnit);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't get EQ unit");
        return NO;
    }
	
	// Init the EQ
	status = AudioUnitInitialize(eqUnit);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't init EQ!");
        return NO;
    }
	
	// Set EQ to 10-band
	status = AudioUnitSetParameter(eqUnit, 10000, kAudioUnitScope_Global, 0, 0.0, 0);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't set EQ parameter");
        return NO;
    }
	
	// Connect the output of the source node to the input of the EQ node
	status = AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, eqNode, 0);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't connect converter to eq");
        return NO;
    }
	
	// Connect the output of the EQ node to the input of the destination node, thus completing the chain.
	status = AUGraphConnectNodeInput(graph, eqNode, 0, destinationNode, destinationInputBusNumber);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't connect eq to output");
        return NO;
    }
	
	return YES;
}

-(void)disposeOfCustomNodesInGraph:(AUGraph)graph {
	
	// Shut down our unit.
	AudioUnitUninitialize(eqUnit);
	eqUnit = NULL;
	
	// Remove the unit's node from the graph.
	AUGraphRemoveNode(graph, eqNode);
	eqNode = 0;
}


@end
