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
        
        self->pushingCrate = FALSE;

        [self updateVolumes];
    }
    else{
        return nil;
    }
    
    return self;
}

- (void) getStoredVolumes{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL volumeSaved = [defaults boolForKey:@"volumeSaved"];
    
    if(volumeSaved == YES){
        float savedMusicVolume = [defaults floatForKey:@"musicVolume"];
        
        // Performance issues with volume-controlled sound effects
        // float savedFxVolume = [defaults floatForKey:@"fxVolume"];
        BOOL playFX = [defaults boolForKey:@"playFX"];
        
        self->musicVolume = savedMusicVolume;
        if(savedMusicVolume == 0){
            self.muteMusic = TRUE;
        }
        if(playFX == TRUE){
            self->fxVolume = 1;
        }else{
            self->fxVolume = 0;
            self.muteSoundFX = TRUE;
        }
    } else {
        NSLog(@"(soundController) No saved volumes found in prefs");
        self->musicVolume = 1.0f;
        self->fxVolume = 1.0f;
    }
    NSLog(@"Stored volumes retrieved: %f / %f", self->musicVolume, self->fxVolume);
}

- (void) updateVolumes{
    [self getStoredVolumes];
    self.audioPlayer.volume = self->musicVolume;
    
    self.crateAudioPlayer.volume = self->fxVolume;
    /*
    // lower performance but allows volume control
    self.jumpAudioPlayer.volume = self->fxVolume;
    self.alienAudioPlayer.volume = self->fxVolume;
    self.crateAudioPlayer.volume = self->fxVolume;
    self.takeCellAudioPlayer.volume = self->musicVolume;
    self.liftReadyAudioPlayer.volume = self->musicVolume;
    self.takeLiftAudioPlayer.volume = self->musicVolume;
    self.trainImpactAudioPlayer.volume = self->musicVolume;
     
    */
    // self.footstepAudioPlayer.volume = self->musicVolume;
}

- (float) getFxVolume{
    return self->fxVolume;
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            NSLog(@"Headphones in");
            return YES;
    }
    return NO;
}

-(void)startPlaying
{
    if(self.audioPlayer){
        [self.audioPlayer play];
    }else{
        NSLog(@"WARNING: no audioPlayer yet");
    }
}

-(void)playTune:(NSString*)filename loops:(int)loops
{
    NSLog(@"playTune called");
    if( !self->muteMusic ){
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
        NSError *error = nil;
        
        if(fadingOut){
            NSLog(@"stop fade out");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = loops;
        self.audioPlayer.volume = self->musicVolume;
        if (!self.audioPlayer) {
            NSLog(@"Error creating player: %@", error);
        }
        [NSThread detachNewThreadSelector:@selector(startPlaying) toTarget:self withObject:nil];
    }
}

- (void)doVolumeFade
{
    fadingOut = TRUE;
    if (self.audioPlayer.volume > 0.1) {
        self.audioPlayer.volume = self.audioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        fadingOut = FALSE;
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = self->musicVolume;
    }
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

- (void)initProjectorSound {
    
    if ( self -> muteSoundFX){
        return;
    }
    
    projectorSound = [SKAction playSoundFileNamed:@"Sounds/fx2_projecteur.wav" waitForCompletion: NO];

    /*
    // allows volume control but lower performance
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        NSError* error = nil;

        NSURL *projectorSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx2_projecteur" withExtension:@"wav"];
        self.projectorAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: projectorSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.projectorAudioPlayer setVolume:self->fxVolume];
            [self.projectorAudioPlayer prepareToPlay];
        }
    });
    */
}

- (void)initSounds {
    
    if( self -> muteSoundFX){
        NSLog(@"Sound fx muted - we dont initialize sounds");
        return;
    }
    
    // lagge trop avec AVAudioPlayer
    leftFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_gauche.aif" waitForCompletion:YES];
    rightFootstepSound = [SKAction playSoundFileNamed:@"Sounds/fx_pas_droit.aif" waitForCompletion:YES];

    jumpSound = [SKAction playSoundFileNamed:@"Sounds/fx_jump.wav" waitForCompletion: NO];
    alienSound = [SKAction playSoundFileNamed:@"Sounds/fx_alien.wav" waitForCompletion: NO];
    deathSound = [SKAction playSoundFileNamed:@"Sounds/fx2_mort.wav" waitForCompletion: NO];

    takeCellSound = [SKAction playSoundFileNamed:@"Sounds/fx_pile.aif" waitForCompletion: NO];
    liftReadySound = [SKAction playSoundFileNamed:@"Sounds/fx_bouton_porte.wav" waitForCompletion: NO];
    takeLiftSound = [SKAction playSoundFileNamed:@"Sounds/fx_arrivee_ascenseur.wav" waitForCompletion: NO];
    trainImpactSound = [SKAction playSoundFileNamed:@"Sounds/fx_chariot_tombe" waitForCompletion: NO];
    killScientistSound = [SKAction playSoundFileNamed:@"Sounds/fx2_saut_sur_scientifique.wav" waitForCompletion: NO];
    anxietySound = [SKAction playSoundFileNamed:@"Sounds/fx3_cri_peur.wav" waitForCompletion: NO];
    takeFileSound = [SKAction playSoundFileNamed:@"Sounds/fx3_classeur+voix.wav" waitForCompletion: NO];
    
    NSError* error = nil;
    NSURL *crateSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_caisse_short" withExtension:@"wav"];
    self.crateAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: crateSoundURL error:&error];
    if (error != nil) {
        NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
    } else {
        [self.crateAudioPlayer setVolume:self->fxVolume];
        [self.crateAudioPlayer prepareToPlay];
    }
    
    // sons avec AVAudioPlayer
    // allows volume control but lower performance
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        NSError* error = nil;

        NSURL *jumpSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_jump" withExtension:@"wav"];
        self.jumpAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:jumpSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.jumpAudioPlayer setVolume:self->fxVolume];
            [self.jumpAudioPlayer prepareToPlay];
        }
    
        NSURL *alienSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_alien" withExtension:@"wav"];
        self.alienAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: alienSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.alienAudioPlayer setVolume:self->fxVolume];
            [self.alienAudioPlayer prepareToPlay];
        }
        
        NSURL *deathSoundURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx3_mort" withExtension:@"wav"];
        self.deathAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: deathSoundURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.deathAudioPlayer setVolume:self->fxVolume];
            // [self.deathAudioPlayer prepareToPlay];
        }
    
        NSURL *takeCellURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_pile" withExtension:@"aif"];
        self.takeCellAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:takeCellURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.takeCellAudioPlayer setVolume:self->fxVolume];
            [self.takeCellAudioPlayer prepareToPlay];
        }
    
        NSURL *liftReadyURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_bouton_porte" withExtension:@"wav"];
        self.liftReadyAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:liftReadyURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.liftReadyAudioPlayer setVolume:self->fxVolume];
            [self.liftReadyAudioPlayer prepareToPlay];
        }
    
        NSURL *takeLiftURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_arrivee_ascenseur" withExtension:@"wav"];
        self.takeLiftAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:takeLiftURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.takeLiftAudioPlayer setVolume:self->fxVolume];
            [self.takeLiftAudioPlayer prepareToPlay];
        }
    
        NSURL *trainImpactURL = [[NSBundle mainBundle] URLForResource:@"Sounds/fx_chariot_tombe" withExtension:@"wav"];
        self.trainImpactAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:trainImpactURL error:&error];
        if (error != nil) {
            NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
        } else {
            [self.trainImpactAudioPlayer setVolume:self->fxVolume];
            [self.trainImpactAudioPlayer prepareToPlay];
        }
    });
    */
    NSLog(@"Init sounds done");
}

- (void) playProjectorSound {
    if ( !self -> muteSoundFX ){
        [self runAction: projectorSound];
        /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self.jumpAudioPlayer play];
            [self.jumpAudioPlayer prepareToPlay];
        });*/
    }
}

- (void) playJumpSound {
    if ( !self -> muteSoundFX ){
        [self runAction: jumpSound];
        /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self.jumpAudioPlayer play];
            [self.jumpAudioPlayer prepareToPlay];
        });*/
    }
}

- (void) playTakeCellSound {
    [self runAction: takeCellSound];
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if( !self->muteSoundFX){
            [self.takeCellAudioPlayer play];
        }
    });*/
}

- (void) playLiftReadySound {
    if ( ! self -> muteSoundFX ){
        [self runAction: liftReadySound];
    }
}
- (void) playTakeLiftSound {
    if ( ! self -> muteSoundFX ){
        [self runAction: takeLiftSound];
    }
}

- (void) playTakeFileSound {
    if ( ! self -> muteSoundFX ){
        [self runAction: takeFileSound];
    }
}

- (void) playTrainImpactSound {
    if ( ! self -> muteSoundFX ){
        [self runAction: trainImpactSound];
    }
}

- (void) playFootstepSound {
    if ( ! self -> muteSoundFX ){
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence: @[rightFootstepSound, leftFootstepSound]]] withKey:@"footstepSound"];
    }
}
-(void) stopFootstepSound {
    if ( !self -> muteSoundFX ){
        [self removeActionForKey:@"footstepSound"];
    }
}


- (void) playCrateSound {
    if ( !self -> muteSoundFX ){
        if(!pushingCrate){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                self.crateAudioPlayer.volume = self->fxVolume;
                [self.crateAudioPlayer play];
                self->pushingCrate = true;
            });
        }
    }
}
- (void) fadeOutCrateSound {
    if (!pushingCrate){
        if (self.crateAudioPlayer.volume > 0.15) {
            self.crateAudioPlayer.volume -= 0.15;
            [self performSelector:@selector(fadeOutCrateSound) withObject:nil afterDelay:0.1];
        }else{
            [self.crateAudioPlayer stop];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                [self.crateAudioPlayer prepareToPlay];
            });
        }
    }
}
- (void) stopCrateSound {
    if ( !self -> muteSoundFX ){
        // NSLog(@"stopit");
        [self performSelector:@selector(fadeOutCrateSound) withObject:nil afterDelay:0.5];
        pushingCrate = false;
        
    }
}

- (void) playAlienSound {
    if ( !self -> muteSoundFX ){
        [self runAction: alienSound];
    }
}
- (void) playDeathSound {
    if ( !self -> muteSoundFX ){
        [self runAction: deathSound];
    }
}
- (void) playKillScientistSound {
    if ( !self -> muteSoundFX ){
        [self runAction: killScientistSound];
    }
}
- (void) playAnxietySound {
    if ( !self -> muteSoundFX ){
        [self runAction: anxietySound];
    }
}

@end
