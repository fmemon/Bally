//
//  Bally.mm
//  Bally
//
//  Created by Saida Memon on 3/8/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "Bally.h"
#import "MyContactListener.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"

/// returns a random float between X and Y
#define CCRANDOM_X_Y(__X__, __Y__) new_xor128_float_x_y((__X__), (__Y__))


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

/** Convert the given position into the box2d world. */
static inline float ptm(float d)
{
    return d / PTM_RATIO;
}

/** Convert the given position into the cocos2d world. */
static inline float mtp(float d)
{
    return d * PTM_RATIO;
}

// Bally implementation
@implementation Bally

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Bally *layer = [Bally node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


-(id)init

{
    
    if( (self=[super init])) { 
        
        // enable touches
       // self.isTouchEnabled = YES;
        
        // enable accelerometer
        self.isAccelerometerEnabled = YES; 
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // Define the gravity vector.
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f); 
        
        
        // This will speed up the physics simulation
        bool doSleep = true; 
        
        // Construct a world object, which will hold and simulate the rigid bodies.
        world = new b2World(gravity, doSleep); 
        world->SetContinuousPhysics(true); 
        
  /*      // Debug Draw functions
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        world->SetDebugDraw(m_debugDraw); 
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        m_debugDraw->SetFlags(flags);  
        */
        
        //initial settings
        score  = 0;
        highscore = 0;
        stopWater = TRUE;
        muted = FALSE;
        [self restoreData];

        ground = NULL;
        b2BodyDef bd;
        ground = world->CreateBody(&bd);

        //Box
        b2BodyDef groundBodyDef;
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        shape.SetAsEdge(b2Vec2(0.000000f, 0.000000f), b2Vec2(30.000000f, 0.000000f)); //bottom wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(30.000000f, 0.000000f), b2Vec2(30.000000f, 10.000000f)); //right wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(30.000000f, 10.000000f), b2Vec2(0.000000f, 10.000000f)); //top wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(0.000000f, 10.000000f), b2Vec2(0.000000f, 0.000000f)); //;left wall
        groundBody->CreateFixture(&shape,0);

        //background
        CCSprite *sprite2 = [CCSprite spriteWithFile:@"backLand2xY.png"];
        sprite2.anchorPoint = CGPointZero;
        sprite2.position = CGPointZero;
        [self addChild:sprite2 z:-11];
        
        //spritesheet        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bally.plist"];
        CCSpriteBatchNode*  spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"bally.png"];
        [self addChild:spriteSheet];
        //[[CCTextureCache sharedTextureCache] addImage:@"brickssm.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"star.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"blinkie1.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"blinkie2.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"heart.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"flowersm.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"target.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"club.png" ]; 
        [[CCTextureCache sharedTextureCache] addImage:@"flower2.png" ]; 

        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        //adding fixture
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
        //NSArray *textureList = [[NSArray alloc] initWithObjects:@"brickssm.png",@"goldstars1sm.png",@"acornsm.png", 
         //                       @"clubsm.png",@"targetsm.png",@"flowersm.png", @"border1.png",nil ];
        
        NSArray *textureList = [[NSArray alloc] initWithObjects:@"star.png", @"heart.png", @"flower2.png", @"club.png",@"target.png",@"flowersm.png",nil ];
        
        texture = [[CCTextureCache sharedTextureCache] addImage:[textureList objectAtIndex:arc4random() % [textureList count]]];
        sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.50*64.0f, 0.40*64.0f)];
        sprite.position = CGPointMake(480.0f / 2, 360.0f / 2);
        [sprite.texture setTexParameters:&params];        
        
        
        //show scores
        highscoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HighScore: %i",highscore] fontName:@"Arial" fontSize:24];
        highscoreLabel.color = ccc3(26, 46, 149);
        highscoreLabel.position = ccp(340.0f, 300.0f);
        [self addChild:highscoreLabel z:10];
        
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"       Score: %i",score] fontName:@"Arial" fontSize:24];
        scoreLabel.position = ccp(340.0f, 280.0f);
        scoreLabel.color = ccc3(26, 46, 149);
        [self addChild:scoreLabel z:10];
        
        highscoreLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HighScore: %i",highscore] fontName:@"Arial" fontSize:24];
        highscoreLabel2.color = ccc3(26, 46, 149);
        highscoreLabel2.position = ccp(820.0f, 300.0f);
        [self addChild:highscoreLabel2 z:10];
        
        scoreLabel2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"       Score: %i",score] fontName:@"Arial" fontSize:24];
        scoreLabel2.position = ccp(820.0f, 280.0f);
        scoreLabel2.color = ccc3(26, 46, 149);
        [self addChild:scoreLabel2 z:10];

        
        // Preload effect
        [MusicHandler preload];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

        //Pause Toggle can not sure frame cache for sprites!!!!!
		CCMenuItemSprite *playItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseON.png"]
                                                             selectedSprite:[CCSprite spriteWithFile:@"newPauseONSelect.png"]];
        
		CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseOFF.png"]
                                                              selectedSprite:[CCSprite spriteWithFile:@"newPauseOFFSelect.png"]];
        
		if (!muted)  {
            pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:playItem, pauseItem, nil];
            pause.position = ccp(screenSize.width*0.03, screenSize.height*0.95f);
        }
        else {
            pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:pauseItem, playItem, nil];
            pause.position = ccp(screenSize.width*0.03, screenSize.height*0.95f);
        }
        
		//Create Menu with the items created before
		CCMenu *menu = [CCMenu menuWithItems:pause, nil];
		menu.position = CGPointZero;
		[self addChild:menu z:11];
        
        [self starterBoard];
        [self randomScreenLayout];

        //create array of crosses to choose
        crossArray = [NSArray arrayWithObjects:@"cross6.png", @"cross5.png",@"cross4.png",@"cross3.png",nil ];
        
        [self schedule: @selector(tick:)]; 
    }
    return self; 
}

-(void)randomScreenLayout {
    NSMutableArray *screens = [[NSMutableArray alloc] initWithCapacity:12];
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 7.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(1.8f, 5.18f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(5.98f, 2.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 1.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 7.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(11.8f, 8.18f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(5.98f, 2.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(2.7f, 1.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 7.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(11.8f, 2.8f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(2.98f, 2.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 5.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 5.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 6.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(11.7f, 2.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(3.8f, 2.18f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(2.98f, 5.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 9.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 7.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 5.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 8.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(10.2f, 7.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(1.8f, 2.18f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(7.98f, 4.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 1.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(11.7f, 5.8f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(3.8f, 5.8f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(7.98f, 9.1f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 1.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(9.0f, 4.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(3.8f, 5.18f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(9.98f, 9.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(10.7f, 8.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(6.6f, 1.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(11.4f, 5.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 3.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(4.8f, 7.8f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(10.98f, 8.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(11.7f, 7.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(9.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 3.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(4.8f, 7.8f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(10.98f, 8.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(11.7f, 6.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(2.6f, 2.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 0.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(9.4f, 4.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [[NSMutableArray alloc] initWithObjects:
                       [ NSValue valueWithCGPoint:CGPointMake(4.7f, 7.3f)], //polygon1
                       [ NSValue valueWithCGPoint:CGPointMake(11.8f, 2.8f)], //polygon2
                       [ NSValue valueWithCGPoint:CGPointMake(2.98f, 2.8f)], //long
                       [ NSValue valueWithCGPoint:CGPointMake(8.7f, 2.2f)], //slant
                       [ NSValue valueWithCGPoint:CGPointMake(11.6f, 6.8f)], //short
                       [ NSValue valueWithCGPoint:CGPointMake(11.9f, 6.9f)], //block
                       [ NSValue valueWithCGPoint:CGPointMake(1.5f, 3.9f)], //triangle
                       [ NSValue valueWithCGPoint:CGPointMake(3.4f, 5.3f)], //circle
                       [ NSValue valueWithCGPoint:CGPointMake(480.0f/2/PTM_RATIO, 6.6f)],//hole
                       nil];
    [screens addObject:bodyPointsArray];
    [bodyPointsArray release];
    bodyPointsArray = nil;
    
    bodyPointsArray = [screens objectAtIndex:arc4random() % 2];
    [self compoundBody:NO];
    bodyPointsArray = [screens objectAtIndex:arc4random() % 2];
    [self compoundBody:YES];
}

-(void)starterBoard {
    //staticBody1
    sprite = [CCSprite spriteWithSpriteFrameName:@"ledge.png"];
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:-1];
    bodyDef1.userData = sprite;

    bodyDef1.position.Set(1.379107f, 8.495184f);
    bodyDef1.angle = -0.222508f;
    b2Body* staticBody1 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody1->SetLinearVelocity(initVel);
    staticBody1->SetAngularVelocity(0.000000f);
    boxy.SetAsBox(1.35f, 0.20f);
    fd.shape = &boxy;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);        
    staticBody1->CreateFixture(&boxy,0);
    
    //ball
    bodyDef.type =b2_dynamicBody;
    CCSprite *ballSprite = [CCSprite spriteWithSpriteFrameName:@"blinkie1.png"];
    ballSprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:ballSprite z:3 tag:11];
    [ballSprite runAction:[self createBlinkAnim:YES]];
    
    bodyDef.userData = ballSprite;
    bodyDef.position.Set(0.468085f, 9.574468f);
    bodyDef.angle = 0.000000f;
    ball = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    ball->SetLinearVelocity(initVel);
    ball->SetAngularVelocity(0.000000f);
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.05f;
    
    fd.shape = &circleShape;
    fd.density = 5.0f*CC_CONTENT_SCALE_FACTOR();
    fd.friction = 0.0f;
    fd.restitution = 1.0f; //toobouncy    
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    ball->CreateFixture(&fd);
}

-(ccColor3B)getMeColor {
    int colorNum = arc4random() % 5;
    ccColor3B myColor;
    switch (colorNum) {
        case 0:
            myColor = ccBLUE;
            break;
        case 1:
            myColor = ccRED;
            break;
        case 2:
            myColor = ccORANGE;
            //myColor = ccc3(255,118, 0);
            break;
        case 3:
            myColor = ccMAGENTA;
            break;
        case 4:
        default:
            myColor = ccGREEN;
            break;
    }
    return myColor;
}


-(void)compoundBody:(BOOL)isSecondSecreen {
    
    int i = 0;
    float delta = 0.0f;
    if (isSecondSecreen) delta = 15.0f;
    
    NSValue *val = [bodyPointsArray objectAtIndex:i++];
    CGPoint p = [val CGPointValue];

    //polygon1
    sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"cross%i.png", 5+(arc4random() % 2)]];
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:33];
    bodyDef.userData = sprite;
    bodyDef.type=b2_dynamicBody;
    bodyDef.position.Set(p.x +delta, p.y);
    bodyDef.angle = 0.000000f;
    polygon1 = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    polygon1->SetLinearVelocity(initVel);
    polygon1->SetAngularVelocity(0.000000f);
    boxy.SetAsBox(1.65f, 0.35f);
    fd.shape = &boxy;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.9000000f; //was 0.6 now faster
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    polygon1->CreateFixture(&fd);
    boxy.SetAsBox(0.35f,1.65f);
    fd.shape = &boxy;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    polygon1->CreateFixture(&fd);
    pos.Set(p.x + delta, p.y);
    revJointDef.Initialize(polygon1, ground, pos);
    revJointDef.collideConnected = false;
    world->CreateJoint(&revJointDef);
    
    //polygon2
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    
    sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"cross%i.png", 5+(arc4random() % 2)]];
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:33];
    bodyDef.userData = sprite;
    bodyDef.position.Set(p.x +delta, p.y);
    bodyDef.angle = 0.000000f;
    b2Body* polygon2 = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    polygon2->SetLinearVelocity(initVel);
    polygon2->SetAngularVelocity(0.000000f);
    boxy.SetAsBox(1.65f, 0.35f);
    fd.shape = &boxy;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    polygon2->CreateFixture(&fd);
    boxy.SetAsBox(0.35f,1.65f);
    fd.shape = &boxy;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    polygon2->CreateFixture(&fd);   
    pos.Set(p.x + delta, p.y);
    revJointDef.Initialize(polygon2, ground, pos);
    revJointDef.collideConnected = false;
    world->CreateJoint(&revJointDef); 
    
    //staticBody2
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 2.9*64.0f, 0.40*64.0f)];
    sprite.color = ccBLUE;
    [self addChild:sprite z:2 tag:33];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(p.x +delta, p.y);
    bodyDef1.type = b2_staticBody;
    bodyDef1.angle = -0.025254f;
    b2Body* staticBody2 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody2->SetLinearVelocity(initVel);
    staticBody2->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody2_vertices[4];
    staticBody2_vertices[0].Set(-2.9f, -0.40f);
    staticBody2_vertices[1].Set(2.9f, -0.40f);
    staticBody2_vertices[2].Set(2.9f, 0.40f);
    staticBody2_vertices[3].Set(-2.9f, 0.40f);
    shape.Set(staticBody2_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody2->CreateFixture(&shape,0);
    
    //staticBody3
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    sprite = [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.50f*64.0f, 0.40*64.0f)];
    sprite.color = ccBLUE;
    [self addChild:sprite z:2 tag:33];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(p.x +delta, p.y);
    bodyDef1.angle = -0.507438f;
    bodyDef1.type = b2_staticBody;
    b2Body* staticBody3 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody3->SetLinearVelocity(initVel);
    staticBody3->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody3_vertices[4];
    staticBody3_vertices[0].Set(-1.50f, -0.40f);
    staticBody3_vertices[1].Set(1.50f, -0.40f);
    staticBody3_vertices[2].Set(1.50f, 0.40f);
    staticBody3_vertices[3].Set(-1.50f, 0.40f);
    shape.Set(staticBody3_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody3->CreateFixture(&shape,0);
    
    //staticBody4
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    bodyDef1.position.Set(p.x +delta, p.y);
    sprite = [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.50*64.0f, 0.40*64.0f)];
    sprite.color = ccBLUE;
    [self addChild:sprite z:2 tag:33];
    bodyDef1.userData = sprite;
    bodyDef1.angle = 0.020196f;
    bodyDef1.type = b2_staticBody;
    b2Body* staticBody4 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody4->SetLinearVelocity(initVel);
    staticBody4->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody4_vertices[4];
    staticBody4_vertices[0].Set(-1.50f, -0.40f);
    staticBody4_vertices[1].Set(1.50f, -0.40f);
    staticBody4_vertices[2].Set(1.50f, 0.40f);
    staticBody4_vertices[3].Set(-1.50f, 0.40f);
    shape.Set(staticBody4_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody4->CreateFixture(&shape,0);
    
    //block
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    bodyDef.position.Set(p.x +delta, p.y);
    bodyDef.angle = 0.000000f;
    bodyDef.type = b2_dynamicBody;
    sprite = [CCSprite spriteWithSpriteFrameName:@"square.png"];
    sprite.color = [self getMeColor];
                                                        
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:33]; 
    bodyDef.userData = sprite;
    b2Body* block = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    block->SetLinearVelocity(initVel);
    block->SetAngularVelocity(0.000000f);
    b2Vec2 block_vertices[4];
    block_vertices[0].Set(-0.85f, -0.85f);
    block_vertices[1].Set(0.85f, -0.85f);
    block_vertices[2].Set(0.85f, 0.85f);
    block_vertices[3].Set(-0.85f, 0.85f);
    shape.Set(block_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    block->CreateFixture(&fd);
    
    //triangle
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    sprite = [CCSprite spriteWithSpriteFrameName:@"triangle.png"];
    sprite.color = ccBLUE;
    sprite.color = [self getMeColor];

    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:33];  
    bodyDef.userData = sprite;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x +delta, p.y);
    bodyDef.angle = 0.000000f;
    b2Body* triangle = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    triangle->SetLinearVelocity(initVel);
    triangle->SetAngularVelocity(0.000000f);
    b2Vec2 triangle_vertices[3];
    triangle_vertices[0].Set(-0.851064f, -0.840426f);
    triangle_vertices[1].Set(0.851064f, -0.840426f);
    triangle_vertices[2].Set(0.851064f, 0.840426f);
    shape.Set(triangle_vertices, 3);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    triangle->CreateFixture(&fd);
    
    //circle2
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    sprite = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
    sprite.color = ccBLUE;
    sprite.color = [self getMeColor];

    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:33]; 
    bodyDef.userData = sprite;
    bodyDef.position.Set(p.x + delta, p.y);
    bodyDef.type = b2_dynamicBody;
    bodyDef.angle = 0.000000f;
    b2Body* circle2 = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    circle2->SetLinearVelocity(initVel);
    circle2->SetAngularVelocity(0.000000f);
    circleShape.m_radius = 1.175038f;
    fd.shape = &circleShape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    circle2->CreateFixture(&fd);
    
    //Hole
    val = [bodyPointsArray objectAtIndex:i++];
    p = [val CGPointValue];
    sprite = [CCSprite spriteWithFile:@"holeBX3.png"];
    //sprite = [CCSprite spriteWithSpriteFrameName:@"holeBX.png"];
    sprite.color = ccWHITE;
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:88];
    bodyDef.userData = sprite;
    bodyDef.position.Set(p.x +delta, p.y);
    bodyDef.type = b2_staticBody;
    bodyDef.angle = 0.000000f;
    bodyDef.type = b2_staticBody;
    b2Body* hole = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    hole->SetLinearVelocity(initVel);
    hole->SetAngularVelocity(0.000000f);
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.5;//was 0.05f - too tiny
    fd.shape = &circleShape;
    fd.density = 0.196374f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    hole->CreateFixture(&fd);
}

- (void)scored:(b2Body*)bodyB {
    [MusicHandler playBounce];
    score += 15;
    [self updateScore];
}

- (void)endGame:(b2Body*)bodyB {
    if (stopWater) {[MusicHandler playWater];
        stopWater = FALSE;
        bodyB->SetLinearVelocity(b2Vec2(0,0));
        bodyB->SetAngularVelocity(0);
        
        [self saveData];
        [self performSelector:@selector(gotoHS) withObject:nil afterDelay:0.3];
    }
}

- (void)gotoHS {
    [[CCDirector sharedDirector] replaceScene:[GameOverScene node]];
}

- (void)updateScore {
    [scoreLabel setString:[NSString stringWithFormat:@"       Score: %i",score]];
    [scoreLabel2 setString:[NSString stringWithFormat:@"       Score: %i",score]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"score"];
    [defaults synchronize];
    
    
}
- (void)saveData {   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:score forKey:@"newHS"];

    [defaults synchronize];
}
- (void)restoreData {
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:@"HS1"]) {
        highscore = [defaults integerForKey:@"HS1"];
        [highscoreLabel setString:[NSString stringWithFormat:@"HighScore: %i",highscore]];
        [highscoreLabel2 setString:[NSString stringWithFormat:@"HighScore: %i",highscore]];
    }
    
    
    if ([defaults boolForKey:@"IsMuted"]) {
        muted = [defaults boolForKey:@"IsMuted"];
        [[SimpleAudioEngine sharedEngine] setMute:muted];
    }
}

- (void)turnOnMusic {
    if ([[SimpleAudioEngine sharedEngine] mute]) {
        // This will unmute the sound
        muted = FALSE;
    }
    else {
        //This will mute the sound
        muted = TRUE;
    }
    [[SimpleAudioEngine sharedEngine] setMute:muted];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:muted forKey:@"IsMuted"];
    [defaults synchronize];
}

- (CCAction*)createBlinkAnim:(BOOL)isTarget {
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    
[walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blinkie1.png"]];
    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blinkie2.png"]];

    CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.1f];
    
    CCAnimate *blink = [CCAnimate actionWithDuration:0.2f animation:walkAnim restoreOriginalFrame:YES];
    
    CCAction *walkAction = [CCRepeatForever actionWithAction:
                            [CCSequence actions:
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*2.0f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*3.0f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*0.2f],
                             blink,
                             [CCDelayTime actionWithDuration:CCRANDOM_0_1()*2.0f],
                             nil]
                            ];
    
    return walkAction;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            if (myActor.position.x < 0.5f || myActor.position.x > 29.5f) [myActor runAction:[CCMoveTo actionWithDuration:0.1f position:ccp(myActor. position.x+1.0f, myActor.position.y)]];
		}	
	}
    
    
    
    // Loop through all of the box2d bodies that are currently colliding, that we have
    // gathered with our custom contact listener...
    std::vector<MyContact>::iterator pos2;
    for(pos2 = contactListener->_contacts.begin(); pos2 != contactListener->_contacts.end(); ++pos2) {
        MyContact contact = *pos2;
        
        // Get the box2d bodies for each object
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();

            //ball is 11 adn hole is 88
            if (spriteA.tag == 88 && spriteB.tag == 11) {
                [self endGame:bodyB];
            } else if (spriteA.tag == 11 && spriteB.tag == 88) {
                [self endGame:bodyB];
            } 
            else if (spriteA.tag == 11)  {
                [self scored:bodyA];
            }
            else if (spriteB.tag == 11)  {
                [self scored:bodyB];
            }

        }  
    }
    
    // ball is moving.
    if (ball)
    {
        b2Vec2 position = ball->GetPosition();
        CGPoint myPosition = self.position;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // Move the camera.
        if (position.x > screenSize.width / 2.0f / PTM_RATIO)
        {
            myPosition.x = -MIN(screenSize.width * 2.0f - screenSize.width, position.x * PTM_RATIO - screenSize.width / 2.0f);
            self.position = myPosition;
            pause.position = ccp((screenSize.width*0.03)+480.0f, screenSize.height*0.95f);
        }
        else if (position.x < screenSize.width / 2.0f / PTM_RATIO) {
           // [pause runAction:[CCMoveTo actionWithDuration:0.05f  position:ccp(0.0f, pause.position.y)]];
            pause.position = ccp(screenSize.width*0.03, screenSize.height*0.95f);
        }
    
    }
    
}

/*
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}
*/

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [crossArray release];
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
