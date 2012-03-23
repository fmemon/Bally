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
    
}

// returns a CCScene that contains the Bally as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void)addPolygon1:(CGPoint)pos;
-(void)compoundBody;
- (float)randomValueBetween:(float)low andValue:(float)high;


@end