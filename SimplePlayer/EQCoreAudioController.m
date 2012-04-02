//
//  EQCoreAudioController.m
//  SimplePlayer with EQ
//
//  Created by Daniel Kennett on 02/04/2012.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

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

	
	// Connect the sourceNode to the destinationNode via an EQ node. 
	
	// Connect the output of the source node to the input of the EQ node
	status = AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, eqNode, 0);
	if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't connect converter to eq");
        return NO;
    }
	
	// Connect the output of the EQ node to the input of the destination node.
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
