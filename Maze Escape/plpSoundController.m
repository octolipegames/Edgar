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
    if (!self) return nil;

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
    platformSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_elevateur.wav"];
    [self->platformSound runAction: [SKAction play]];
    NSLog(@"end init inner func");
}



@end
