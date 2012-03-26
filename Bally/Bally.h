//
//  Bally.h
//  Bally
//
//  Created by Saida Memon on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"
#import "MusicHandler.h"

// Bally
@interface Bally : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
    b2BodyDef bodyDef,bodyDef1;
    
    b2Body* ground;

    b2Vec2 initVel;
    b2PolygonShape shape;
    b2CircleShape circleShape;
    b2FixtureDef fd;
    b2RevoluteJointDef revJointDef;
    b2DistanceJointDef jointDef;
    b2Vec2 pos;
    
    MyContactListener *contactListener;
    
    b2PolygonShape boxy;
    b2Body* ball;
    
    BOOL muted;
    BOOL stopWater;
    CCSprite *sprite;
    CCTexture2D *texture;
    b2Body* polygon1;
    
    int score;
    int highscore;
    CCLabelTTF *highscoreLabel;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *highscoreLabel2;
    CCLabelTTF *scoreLabel2;
    
    CCMenuItemToggle *pause;
    NSMutableArray* bodyPointsArray;
    
    NSArray *crossArray;
    NSString *crossStrings[4];
}

// returns a CCScene that contains the Bally as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void)compoundBody:(BOOL)isSecondSecreen;
- (float)randomValueBetween:(float)low andValue:(float)high;
- (void)turnOnMusic;
- (void)restoreData;
- (CCAction*)createBlinkAnim:(BOOL)isTarget;
- (void)updateScore;
- (void)saveData;
- (void)scored:(b2Body*)bodyB;
-(void)starterBoard;
-(void)randomScreenLayout;
@end