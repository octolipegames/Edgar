//
//  plpMyScene.h
//  Edgar The Explorer
//

//  Copyright (c) 2014-2016 Filipe Mathez and Paul Ronga
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation; either version 2.1 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////////////////////////

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JSTileMap.h"
#import "plpHero.h"
#import "plpAlien.h"
#import "plpScientist.h"
#import "plpTrain.h"
#import "plpPlatform.h"
#import "plpItem.h"
#import "plpSoundController.h"
#import "plpButton.h"

#define LAST_LEVEL_INDEX 8
#define SEMAPHORE_LEVEL_INDEX 5
#define FIRST_DARK_LEVEL 2
#define USE_ALTERNATE_CONTROLS 0
#define DEFAULT_EDGAR_VELOCITY 500 // was 150
#define HUD_VERTICAL_THIRD 1200/3
#define HUD_VERTICAL_SPAN 1200/6
#define HUD_HORIZONTAL_SPAN 2400/6
#define BUTTON_HORIZONTAL_SPAN HUD_HORIZONTAL_SPAN*1.8
#define BUTTON_VERTICAL_SPAN (HUD_VERTICAL_THIRD*0.5)-600

#define DEATH_RESET 0
#define DEATH_SPIKE 1
#define DEATH_ENEMY 2
#define DEATH_PLATFORM 3

#define TAKING_SCREENSHOTS FALSE

float contextVelocityX;


@interface plpMyScene : SKScene <SKPhysicsContactDelegate>
{
    // Objects
    plpHero *Edgar;
    SKPhysicsBody *EdgarCircleBody;
    JSTileMap *myLevel;
    SKNode *myWorld;
    SKNode *HUD;
    SKCameraNode *myCamera;
    SKSpriteNode *myFinishRectangle;
    
    // Physics
    BOOL freeCamera;
    BOOL willLoseContextVelocity;
    float EdgarVelocity;
    CGPoint startPosition;
    CGPoint debugPosition;
    BOOL isEdgarPinned;
    NSTimer *endContactTimer;
    
    // Character actions:
    SKAction *moveLeftAction;
    SKAction *moveRightAction;
    SKAction *moveUp;
    
    // Prefs
    BOOL useSwipeGestures;
    BOOL enableDebug;
    
    // Audio
    plpSoundController *soundController;
    SKAction *takeCellSound;
    SKAction *activateLiftSound;
    SKAction *takeLiftSound;
    SKAction *liftReadySound;
    SKAction *leftFootstepSound;
    SKAction *rightFootstepSound;
    BOOL pushingCrate;
    SKAction *crateSound;
    SKAction *trainImpactSound;
    NSTimer *setNearHeroTimer;
    NSMutableArray *platformNodes;
    
    // Input
    dispatch_source_t _timer;
    CGPoint touchStartPosition;
    BOOL waitForTap;
    BOOL isJumping;
    BOOL ignoreNextTap;
    BOOL moveLeftRequested;
    BOOL moveRightRequested;
    BOOL moveUpRequested;
    BOOL bigJumpRequested;
    BOOL stopRequested;
    BOOL gonnaCrash;
    BOOL movingLeft;
    BOOL movingRight;
    BOOL listensToContactEvents;
    BOOL levelTransitioning;
    BOOL pauseEnabled;
    
    // User interface
    UIView *containerView;
    UITextView *myTextView;
    BOOL needsInfoBar;
    BOOL runningOniPad;
    float screenCenterX;
    float screenRatio;
    SKLabelNode *fileCountLabel;
    
    // Game data
    int globalCounter;
    int currentLevelIndex;
    
    NSInteger lifeCount;
    NSInteger levelFileCount;
    NSInteger levelTotalFileCount;
    NSInteger fileCount;
    
    double initialTime;
    double additionalSavedTime;
    double additionalLevelTime;
    
    BOOL liftReady;
    BOOL isDying;
    BOOL cheatsEnabled;
}

-(void)loadAssets:(JSTileMap*) tileMap;
-(void)addCollisionLayer:(JSTileMap*) tileMap;
-(void)EdgarDiesOf:(int)deathType;
-(void)resetEdgar;
-(BOOL)isPauseEnabled;
-(void)getsPaused;
-(void)resumeAfterPause;
-(void)resumeFromLevel:(NSInteger)theLevel;
-(void)updateVolumes;
-(void)saveHighScoreForUser:(NSString*)userName;
-(void)saveInitialTime;
-(void)saveAdditionalTime:(float)additionalTime;
-(void)saveAdditionalTime;
-(void)computeSceneCenter;
-(void)setNearHero;



@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
//@property(nonatomic, weak) SKNode *listener;

@end
