//
//  plpSoundController.m
//  Edgar_the_Explorer
//
//  Created by Paul on 17.03.19.
//  Copyright © 2019 Polip. All rights reserved.
//

#import "plpSoundController.h"

/*
 manages:
 - when sound gets muted
 - when sound should / should not get played
 
*/

@implementation plpSoundController

- (id)init
{
    NSLog(@"init sound controller");

    self = [super init];
    
    if(self){
        // TODO check for silent mode, headphones etc. here
        self.muteSoundFX = FALSE;
        self.muteMusic = FALSE;
    }
    else{
        return nil;
    }
    
    return self;
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

- (void)setMuteMusic: (BOOL) muted{
    self -> muteMusic = muted;
}
- (void)setMuteSoundFX: (BOOL) muted{
    self -> muteSoundFX = muted;
}
- (BOOL)getMuteMusic{
    return self -> muteMusic;
}
- (BOOL)getMuteSoundFX{
    return self -> muteSoundFX;
}

- (void)initSounds {
    // platformSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_elevateur.wav"];
    // jumpSound = [SKAction playSoundFileNamed:@"Sounds/fx_jump.wav" waitForCompletion:NO];
}

- (void) playJumpSound {
    if ( !self -> muteSoundFX ){
        // [self runAction: jumpSound];
    }
}

// TODO: add music methods from plpMyScene here

@end
