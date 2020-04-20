//
//  plpIntroScene.m
//
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

#import "plpIntroScene.h"

@implementation plpIntroScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        NSLog(@"Init intro scene");
        
        self.size = CGSizeMake(2400, 1200);
        
        SKCameraNode *myCamera = [SKCameraNode node];
        
        self.camera = myCamera;
        [self addChild:myCamera];
        
        SKTextureAtlas *scenesAtlas = [SKTextureAtlas atlasNamed:@"scenes"];

        animationFrames = [NSMutableArray array];
        currentFrame = 0;
        for (int i = 0; i <= 3; i++) {
            NSString *textureName = [NSString stringWithFormat:@"scene1_%02d", i];
            //NSLog(textureName);
            SKTexture *temp = [scenesAtlas textureNamed:textureName];
            [animationFrames addObject: temp];
        }
        
        
        /*
        SKSpriteNode *upperCurtain = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800 * x3, 250 * x3) ];
        SKSpriteNode *lowerCurtain = [upperCurtain copy];
        upperCurtain.anchorPoint = CGPointMake(0.5, 0);
        upperCurtain.position = CGPointMake(0, self.size.height/2);
        upperCurtain.zPosition = 40;
        upperCurtain.name = @"upperCurtain";
        
        lowerCurtain.anchorPoint = CGPointMake(0.5, 1);
        lowerCurtain.position = CGPointMake(0, -self.size.height/2);
        lowerCurtain.zPosition = 40;
        lowerCurtain.name = @"lowerCurtain";
        [myCamera addChild:upperCurtain];
        [myCamera addChild:lowerCurtain];*/
        
        animationNode = [[SKSpriteNode alloc] initWithTexture: animationFrames[0]];
        
        if (animationNode) {
            NSLog(@"animationNode created");
            animationNode.size = CGSizeMake(2400, 1200);
            animationNode.position = CGPointMake(0, 0);
            animationNode.zPosition = 20;

            [self addChild: animationNode];
            
            
            
            /*[animationNode runAction: [SKAction repeatActionForever:
                [SKAction animateWithTextures: animationFrames
                timePerFrame: 0.1f
                resize:NO
                restore:YES]] withKey:@"scene1"];*/
        }
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch event!");
    currentFrame++;
    if(currentFrame <= [animationFrames count]){
        [animationNode setTexture: animationFrames[currentFrame]];
    }
    
}

@end
