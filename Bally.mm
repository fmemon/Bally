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

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

enum {
	kLongShort = 1,
	kShortShort,
	kJack,
    kSquare
};


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
        
        self.isTouchEnabled = YES; 
        
        // enable accelerometer
        
        self.isAccelerometerEnabled = YES; 
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height); 
        
        // Define the gravity vector.
        
        b2Vec2 gravity;
        
        gravity.Set(0.0f, -10.0f); 
        
        // Do we want to let bodies sleep?
        
        // This will speed up the physics simulation
        
        bool doSleep = true; 
        
        // Construct a world object, which will hold and simulate the rigid bodies.
        
        world = new b2World(gravity, doSleep); 
        
        world->SetContinuousPhysics(true); 
        
        // Debug Draw functions
        
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        
        world->SetDebugDraw(m_debugDraw); 
        
        uint32 flags = 0;
        
        flags += b2DebugDraw::e_shapeBit;
        
        //  flags += b2DebugDraw::e_jointBit;
        
        //  flags += b2DebugDraw::e_aabbBit;
        
        //  flags += b2DebugDraw::e_pairBit;
        
        //  flags += b2DebugDraw::e_centerOfMassBit;
        
        m_debugDraw->SetFlags(flags);  
        
        //initial settings
        muted = FALSE;
        [self restoreData];
        
        
        ground = NULL;
        b2BodyDef bd;
        ground = world->CreateBody(&bd);

        
        //Box
        b2BodyDef groundBodyDef;
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        //shape.SetAsEdge(b2Vec2(0.000000f, 0.000000f), b2Vec2(15.000000f, 0.000000f)); //bottom wall
        shape.SetAsEdge(b2Vec2(0.000000f, 0.000000f), b2Vec2(30.000000f, 0.000000f)); //bottom wall
        groundBody->CreateFixture(&shape,0);
       // shape.SetAsEdge(b2Vec2(15.000000f, 0.000000f), b2Vec2(15.000000f, 10.000000f)); //right wall
        shape.SetAsEdge(b2Vec2(30.000000f, 0.000000f), b2Vec2(30.000000f, 10.000000f)); //right wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(30.000000f, 10.000000f), b2Vec2(0.000000f, 10.000000f)); //top wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(0.000000f, 10.000000f), b2Vec2(0.000000f, 0.000000f)); //;left wall
        groundBody->CreateFixture(&shape,0);

        
        //background
        CCSprite *sprite2 = [CCSprite spriteWithFile:@"backLand2x.png"];
        sprite2.anchorPoint = CGPointZero;
        //sprite2.position = ccp(screenSize.width/2, screenSize.height/2);
        sprite2.position = CGPointZero;
        //sprite2.anchorPoint = CGPointZero;
        [self addChild:sprite2 z:-11];
        
        
        //spritesheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"matty.plist"];
        CCSpriteBatchNode* spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"matty.png"];
        [self addChild:spriteSheet2];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"rolly.plist"];
        CCSpriteBatchNode*  spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rolly.png"];
        [self addChild:spriteSheet];
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        
        //adding fixture
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
        texture = [[CCTextureCache sharedTextureCache] addImage:@"bricks.jpg"];
        sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.52*64.0f, 0.52*64.0f)];
        //CCSprite *sprite = [CCSprite spriteWithTexture:texture rect:CGRectMake(0, 0, 1.72f*64.0f, 0.4*64.0f)];
        sprite.position = CGPointMake(480.0f / 2, 360.0f / 2);
        [sprite.texture setTexParameters:&params];
        //[self addChild:sprite];
        
        
        
        //sound
        // Preload effect
        [MusicHandler preload];
        // Enable touches        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        //Pause Toggle can not sure frame cache for sprites!!!!!
		CCMenuItemSprite *playItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseON.png"]
                                                             selectedSprite:[CCSprite spriteWithFile:@"newPauseONSelect.png"]];
        
		CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"newPauseOFF.png"]
                                                              selectedSprite:[CCSprite spriteWithFile:@"newPauseOFFSelect.png"]];
        CCMenuItemToggle *pause;
		if (!muted)  {
            pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:playItem, pauseItem, nil];
            pause.position = ccp(screenSize.width*0.06, screenSize.height*0.90f);
        }
        else {
            pause = [CCMenuItemToggle itemWithTarget:self selector:@selector(turnOnMusic)items:pauseItem, playItem, nil];
            pause.position = ccp(screenSize.width*0.06, screenSize.height*0.90f);
        }
        
        
		//Create Menu with the items created before
		CCMenu *menu = [CCMenu menuWithItems:pause, nil];
		menu.position = CGPointZero;
		[self addChild:menu z:11];
        
        
     /*   [self addPolygon1:CGPointMake(4.764226f, 7.320508f)];
        [self addPolygon1:CGPointMake(1.779086f, 5.100423f)];
        [self compoundBody];
       */ 

        [self setupBoard];
        
        [self schedule: @selector(tick:)]; 
        
    }
    return self; 
}

-(void)addPolygon1:(CGPoint)newPoint {

    newPoint.x = [self randomValueBetween:1.0f andValue:10.0f];
    newPoint.y = [self randomValueBetween:1.0f andValue:10.0f];

    //polygon1
    bodyDef.type=b2_dynamicBody;
    bodyDef.position.Set(newPoint.x, newPoint.y);
    bodyDef.angle = 0.000000f;
    b2Body* polygon1 = world->CreateBody(&bodyDef);
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
    
    
    pos.Set(newPoint.x, newPoint.y);;
    revJointDef.Initialize(polygon1, ground, pos);
    revJointDef.collideConnected = false;
    world->CreateJoint(&revJointDef);
}


-(void)setupBoard {    
    //stores the number of cells avaible 4 across x 3 down
    NSMutableArray *cellNum = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 12; i++) {
        [cellNum addObject:[NSNumber numberWithInt:i]];
    }

    //stores the types of bodies to be placed
    NSMutableArray *cellType = [NSMutableArray arrayWithCapacity:6];
    for (int i = 1; i < 7; i++) {
        [cellType addObject:[NSNumber numberWithInt:i]];
    }

    //stores the first 3 numbers to be shuffled for which row gets each type 1, 2,3
    NSMutableArray *cellRow = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 3; i++) {
        [cellRow addObject:[NSNumber numberWithInt:i]];
    }

    
    NSMutableArray *whichCell = [NSMutableArray arrayWithCapacity:6];
    
    //do the first 3 types via shuffling
    
    NSLog(@"shuffle array before : %@", cellRow);
    //randomise the nArray
    srandom(time(NULL));
    
    for (NSInteger x = 0; x < [cellRow count]; x++)
    {
        NSInteger randInt = (random() % ([cellRow count] - x)) + x;
        [cellRow exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    for (NSInteger x = 0; x < [cellRow count]; x++)
    {
        int val = [[cellRow objectAtIndex:x] integerValue] + (x*3);
        [whichCell addObject:[NSNumber numberWithInt:val]];
        [whichCell addObject:[NSNumber numberWithInt:val+1]];
    }
    //now remove these affected cells from our choosing cells
    for (NSInteger x = 0; x < [cellRow count]; x++)
    {
       // int val = [[cellRow objectAtIndex:x] integerValue];
       // [cellNum removeObjectAtIndex:val];
        
        [cellNum removeObjectsInArray:whichCell];
    }

    
    NSLog(@"shuffle array before : %@", cellRow);
    NSLog(@"shuffle array WhichCell : %@", whichCell);
    NSLog(@"shuffle array cellNum : %@", cellNum);

    

    int posKey, posValue;
    for (int i=4;i <7; i++) {
        posKey = (int)arc4random() % ([cellNum count]);
        posValue = [[cellNum  objectAtIndex: posKey] integerValue]; //or arc4random() & 3
        
        [whichCell addObject:[NSNumber numberWithInt:posValue]];
        [cellNum removeObjectAtIndex:posKey];
        
        NSLog(@"posKey %i and posValue  %i",posKey, posValue);
    }
    
    NSLog(@"shuffle array WhichCell : %@", whichCell);
    NSLog(@"shuffle array cellNum : %@", cellNum);

    
    //actaully add the pieces the screen
   // CGPoint newPoint;
   // newPoint.x = [self randomValueBetween:1.5 andValue:[[whichCell objectAtIndex:0] integerValue]];
   // newPoint.y = [self randomValueBetween:1.0f andValue:10.0f];
    //[self LongShort:newPoint];

    for (int i = 0;i < [whichCell count];i++) {
        
        if (i ==1 || i == 3 || i == 5) continue;
        CGPoint newPoint =[self calcNewPoint:[[whichCell objectAtIndex:i] integerValue]];
        NSLog(@"cellNum is %i and the CGPoint is x:%f y:%f",[[whichCell objectAtIndex:i] integerValue],newPoint.x, newPoint.y  );
    }
    
    [self starterLedgeAndBall];


    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:0] integerValue]]];
    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:1] integerValue]]];
    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:2] integerValue]]];
    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:3] integerValue]]];
    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:4] integerValue]]];
    [self LongShort:[self calcNewPoint:[[whichCell objectAtIndex:5] integerValue]]];

    
}

-(CGPoint)calcNewPoint:(int)cellNum {

    int multiplierY = 1;
    int multiplierX = 4;
    int remainder = cellNum % 4;
    
    if (cellNum >=9) {
        multiplierY = 1;
    } else if (cellNum >=5){
        multiplierY = 2;
    }else {
        multiplierY = 3;
    }
    
    if (cellNum == 0)multiplierX = 0;
    else if (remainder == 0) multiplierX = 4;
    else if (remainder == 1) multiplierX = 1;
    else if (remainder == 2) multiplierX = 2;
    else if (remainder == 3) multiplierX = 3;
    
   // CGPoint newPoint = CGPointMake(1.0f + (multiplierX *3.0f),1.5f + (multiplierY * 3.0f) );
    
    
    
    //float lowX, highX, lowY, highY;
    
    switch(cellNum) {
        case 0:
            multiplierX = 0;
            multiplierY = 0;
            break;
        case 1:
            multiplierX = 1;
            multiplierY = 0;
            break;
        case 2:
            multiplierX = 2;
            multiplierY = 0;
            break;
        case 3:
            multiplierX = 3;
            multiplierY = 0;
            break;
        case 4:
            multiplierX = 0;
            multiplierY = 1;
            break;
        case 5:
            multiplierX = 1;
            multiplierY = 1;
            break;
        case 6:
            multiplierX = 2;
            multiplierY = 1;
            break;
        case 7:
            multiplierX = 3;
            multiplierY = 1;
            break;
        case 8:
            multiplierX = 0;
            multiplierY = 2;
            break;
        case 9:
            multiplierX = 1;
            multiplierY = 2;
            break;
        case 10:
            multiplierX = 2;
            multiplierY = 2;
            break;
        case 11:
            multiplierX = 3;
            multiplierY = 2;
            break;
        default:break;
    }

     CGPoint starterPoint = CGPointMake(1.0f + (multiplierX *3.0f),1.5f + (multiplierY * 3.0f) );
    CGPoint newPoint;
    newPoint.x = [self randomValueBetween:starterPoint.x andValue:starterPoint.x+3.0f];
    newPoint.y = [self randomValueBetween:starterPoint.y andValue:starterPoint.y+3.0f];
    NSLog(@"whichCell is %i and the CGPoint is x:%f y:%f",0,newPoint.x, newPoint.y  );

    return newPoint;
}

-(void)LongShort:(CGPoint)newPoint {

    //staticBody2 Long
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.5f*64.0f, 0.36*64.0f)];
    [self addChild:sprite];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(newPoint.x, newPoint.y);
    bodyDef1.angle = -0.025254f;
    b2Body* staticBody2 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody2->SetLinearVelocity(initVel);
    staticBody2->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody2_vertices[4];
    staticBody2_vertices[0].Set(-1.5f, -0.361702f);
    staticBody2_vertices[1].Set(1.5f, -0.361702f);
    staticBody2_vertices[2].Set(1.5f, 0.361702f);
    staticBody2_vertices[3].Set(-1.5f, 0.361702f);
    shape.Set(staticBody2_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody2->CreateFixture(&shape,0);
    
    
    //staticBody4 short
    //bodyDef.userData = sprite;
    bodyDef1.position.Set(newPoint.x + 4.1f, newPoint.y);
    bodyDef1.angle = 0.020196f;
    b2Body* staticBody4 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody4->SetLinearVelocity(initVel);
    staticBody4->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody4_vertices[4];
    staticBody4_vertices[0].Set(-1.723404f, -0.404255f);
    staticBody4_vertices[1].Set(1.723404f, -0.404255f);
    staticBody4_vertices[2].Set(1.723404f, 0.404255f);
    staticBody4_vertices[3].Set(-1.723404f, 0.404255f);
    shape.Set(staticBody4_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody4->CreateFixture(&shape,0);
    
}

-(void)Slant:(CGPoint)newPoint {
    //staticBody3 short slant
    sprite = [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.52*64.0f, 0.52*64.0f)];
    [self addChild:sprite];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(8.670213f, 1.212766f);
    bodyDef1.angle = -0.507438f;
    b2Body* staticBody3 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody3->SetLinearVelocity(initVel);
    staticBody3->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody3_vertices[4];
    staticBody3_vertices[0].Set(-1.2f, -0.382979f);
    staticBody3_vertices[1].Set(1.2f, -0.382979f);
    staticBody3_vertices[2].Set(1.521277f, 0.382979f);
    staticBody3_vertices[3].Set(-1.521277f, 0.382979f);
    shape.Set(staticBody3_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody3->CreateFixture(&shape,0);
}

-(void)starterLedgeAndBall {
    //staticBody1
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.35*64.0f, 0.20*64.0f)];
    [self addChild:sprite];
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
    fd.restitution = 0.9f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);        
    staticBody1->CreateFixture(&boxy,0);
    
    
    //ball
    // CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
    CCSprite *ballSprite = [CCSprite spriteWithSpriteFrameName:@"blinkie1.png"];
    ballSprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:ballSprite z:3 tag:11];
    [ballSprite runAction:[self createBlinkAnim:YES]];
    bodyDef.type = b2_dynamicBody;
    bodyDef.userData = ballSprite;
    bodyDef.position.Set(0.468085f, 9.574468f);
    bodyDef.angle = 0.000000f;
    ball = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    ball->SetLinearVelocity(initVel);
    ball->SetAngularVelocity(0.000000f);
    //circleShape.m_radius = 0.406489f;
    //circleShape.m_radius = (sprite.contentSize.width / 32.0) * 0.5f;
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.05f;
    
    fd.shape = &circleShape;
    //  fd.density = 0.196374f;
    // fd.friction = 0.300000f;
    // fd.restitution = 0.600000f;
    fd.density = 5.0f*CC_CONTENT_SCALE_FACTOR();
    fd.friction = 0.0f;
    fd.restitution = 1.0f; //toobouncy
    //fd.restitution = 0.8f;
    
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    ball->CreateFixture(&fd);
    
    //Hole
    sprite = [CCSprite spriteWithSpriteFrameName:@"hole.png"];
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:88];
    bodyDef.type = b2_staticBody;
    bodyDef.userData = sprite;
    bodyDef.position.Set(480.0f/2/PTM_RATIO, 6.574468f);
    bodyDef.angle = 0.000000f;
    bodyDef.type = b2_staticBody;
    b2Body* hole = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    hole->SetLinearVelocity(initVel);
    hole->SetAngularVelocity(0.000000f);
    //circleShape.m_radius = 0.406489f;
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.10f;//was 0.05f - too tiny
    fd.shape = &circleShape;
    fd.density = 0.196374f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    hole->CreateFixture(&fd);
}

-(void)compoundBody {
    
  /*  ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"bricks.jpg"];
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.52*64.0f, 0.52*64.0f)];
    //CCSprite *sprite = [CCSprite spriteWithTexture:texture rect:CGRectMake(0, 0, 1.72f*64.0f, 0.4*64.0f)];
    sprite.position = CGPointMake(480.0f / 2, 360.0f / 2);
    [sprite.texture setTexParameters:&params];
    //[self addChild:sprite];
   */
    
    //polygon1
    bodyDef.type=b2_dynamicBody;
    bodyDef.position.Set(4.764226f, 7.320508f);
    bodyDef.angle = 0.000000f;
    b2Body* polygon1 = world->CreateBody(&bodyDef);
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
    
    
    pos.Set(4.764226f, 7.320508f);;
    revJointDef.Initialize(polygon1, ground, pos);
    revJointDef.collideConnected = false;
    world->CreateJoint(&revJointDef);
    
    //polygon2
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.65*64.0f, 0.35*64.0f)];
    [self addChild:sprite];
    bodyDef.userData = sprite;
    bodyDef.position.Set(1.779086f, 5.100423f);
    bodyDef.angle = 0.000000f;
    b2Body* polygon2 = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    polygon2->SetLinearVelocity(initVel);
    polygon2->SetAngularVelocity(0.000000f);
    //b2PolygonShape boxy;
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
    
    

    //staticBody2
    sprite= [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 3.05*64.0f, 0.36*64.0f)];
    [self addChild:sprite];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(5.946951f, 2.903825f);
    bodyDef1.angle = -0.025254f;
    b2Body* staticBody2 = world->CreateBody(&bodyDef1);
    /*   
     //this adds a ball at the end but change the vertices to 0, 6 from -3 and 3 to make it go at the end
     circleShape.m_radius = 0.406489f;
     fd.shape = &circleShape;
     fd.density = 0.196374f;
     fd.friction = 0.300000f;
     fd.restitution = 0.600000f;
     staticBody2->CreateFixture(&fd);
     */ 
    initVel.Set(0.000000f, 0.000000f);
    staticBody2->SetLinearVelocity(initVel);
    staticBody2->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody2_vertices[4];
    staticBody2_vertices[0].Set(-3.053178f, -0.361702f);
    staticBody2_vertices[1].Set(3.053178f, -0.361702f);
    staticBody2_vertices[2].Set(3.053178f, 0.361702f);
    staticBody2_vertices[3].Set(-3.053178f, 0.361702f);
    shape.Set(staticBody2_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    staticBody2->CreateFixture(&shape,0);
    
    /*UIImage *myImage = [UIImage imageNamed:@"bricks.jpg"];
     CCSprite *mySprite = [CCSprite spriteWithTexture:[[CCTexture2D alloc]initWithImage:myImage]];
     mySprite.position = ccp(100,100);
     [self addChild:mySprite];
     */
    

    
    //staticBody3
    sprite = [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 1.52*64.0f, 0.52*64.0f)];
    [self addChild:sprite];
    bodyDef1.userData = sprite;
    bodyDef1.position.Set(8.670213f, 1.212766f);
    bodyDef1.angle = -0.507438f;
    b2Body* staticBody3 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody3->SetLinearVelocity(initVel);
    staticBody3->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody3_vertices[4];
    staticBody3_vertices[0].Set(-1.521277f, -0.382979f);
    staticBody3_vertices[1].Set(1.521277f, -0.382979f);
    staticBody3_vertices[2].Set(1.521277f, 0.382979f);
    staticBody3_vertices[3].Set(-1.521277f, 0.382979f);
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
    //bodyDef.userData = sprite;
    bodyDef1.position.Set(11.574468f, 2.851064f);
    bodyDef1.angle = 0.020196f;
    b2Body* staticBody4 = world->CreateBody(&bodyDef1);
    initVel.Set(0.000000f, 0.000000f);
    staticBody4->SetLinearVelocity(initVel);
    staticBody4->SetAngularVelocity(0.000000f);
    b2Vec2 staticBody4_vertices[4];
    staticBody4_vertices[0].Set(-1.723404f, -0.404255f);
    staticBody4_vertices[1].Set(1.723404f, -0.404255f);
    staticBody4_vertices[2].Set(1.723404f, 0.404255f);
    staticBody4_vertices[3].Set(-1.723404f, 0.404255f);
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
    bodyDef.position.Set(11.914894f, 0.882979f);
    bodyDef.angle = 0.000000f;
    sprite =nil;
    sprite = [[CCSprite alloc] initWithTexture:texture rect:CGRectMake(0, 0, 0.85*64.0f, 0.85*64.0f)];
    [self addChild:sprite];
    bodyDef.userData=sprite;
    b2Body* block = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    block->SetLinearVelocity(initVel);
    block->SetAngularVelocity(0.000000f);
    b2Vec2 block_vertices[4];
    block_vertices[0].Set(-0.851064f, -0.840426f);
    block_vertices[1].Set(0.851064f, -0.840426f);
    block_vertices[2].Set(0.851064f, 0.840426f);
    block_vertices[3].Set(-0.851064f, 0.840426f);
    shape.Set(block_vertices, 4);
    fd.shape = &shape;
    fd.density = 0.015000f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    block->CreateFixture(&fd);
    
    //Circles
    
    
    //circle2
    bodyDef.position.Set(9.361702f, 4.276596f);
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
    

    
    //ball
   // CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
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
    //circleShape.m_radius = 0.406489f;
    //circleShape.m_radius = (sprite.contentSize.width / 32.0) * 0.5f;
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.05f;

    fd.shape = &circleShape;
    //  fd.density = 0.196374f;
    // fd.friction = 0.300000f;
    // fd.restitution = 0.600000f;
    fd.density = 5.0f*CC_CONTENT_SCALE_FACTOR();
    fd.friction = 0.0f;
    fd.restitution = 1.0f; //toobouncy
    //fd.restitution = 0.8f;
    
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    ball->CreateFixture(&fd);
    
    
    //Revolute joints

    pos.Set(1.779086f, 5.100423f);
    revJointDef.Initialize(polygon2, ground, pos);
    revJointDef.collideConnected = false;
    world->CreateJoint(&revJointDef); 
    
    //Hole
    sprite = [CCSprite spriteWithSpriteFrameName:@"hole.png"];
    sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
    [self addChild:sprite z:2 tag:88];
    bodyDef.userData = sprite;
    bodyDef.position.Set(480.0f/2/PTM_RATIO, 6.574468f);
    bodyDef.angle = 0.000000f;
    bodyDef.type = b2_staticBody;
    b2Body* hole = world->CreateBody(&bodyDef);
    initVel.Set(0.000000f, 0.000000f);
    hole->SetLinearVelocity(initVel);
    hole->SetAngularVelocity(0.000000f);
    //circleShape.m_radius = 0.406489f;
    circleShape.m_radius = (sprite.contentSize.width / PTM_RATIO) * 0.10f;//was 0.05f - too tiny
    fd.shape = &circleShape;
    fd.density = 0.196374f;
    fd.friction = 0.300000f;
    fd.restitution = 0.600000f;
    fd.filter.groupIndex = int16(0);
    fd.filter.categoryBits = uint16(65535);
    fd.filter.maskBits = uint16(65535);
    hole->CreateFixture(&fd);
}

- (void)gotoHS {
    [[CCDirector sharedDirector] replaceScene:[GameOverScene node]];
}


- (void)restoreData {
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

     NSLog(@"Is muted value BEFORE %d", muted);
    
    if ([defaults boolForKey:@"IsMuted"]) {
        muted = [defaults boolForKey:@"IsMuted"];
    }
    
    NSLog(@"Is muted value afterward %d", muted);
}

- (void)turnOnMusic {
    if ([[SimpleAudioEngine sharedEngine] mute]) {
        // This will unmute the sound
        muted = FALSE;
        // [[SimpleAudioEngine sharedEngine] setMute:0];
    }
    else {
        //This will mute the sound
        muted = TRUE;
        //[[SimpleAudioEngine sharedEngine] setMute:1];
    }
    [[SimpleAudioEngine sharedEngine] setMute:muted];
    //NSLog(@"in mute Siund %d", muted);
    
    
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
            if (spriteA.tag == 11 || spriteB.tag == 11) [MusicHandler playBounce];

            // Is sprite A a cat and sprite B a car? 
            if (spriteA.tag == 88 && spriteB.tag == 11) {
                NSLog(@"Game Ended");
                [MusicHandler playWater];
                [[CCDirector sharedDirector] replaceScene:[GameOverScene node]];

            } 
            // Is sprite A a car and sprite B a cat?  
            else if (spriteA.tag == 11 && spriteB.tag == 88) {
                [MusicHandler playWater];
                NSLog(@"Game Ended");
                [[CCDirector sharedDirector] replaceScene:[GameOverScene node]];

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
        }
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		//[self addNewSpriteWithCoords: location];
	}
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
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
