import SimpleOpenNI.*;
import processing.opengl.*;
import java.util.Iterator;

// kinect 
SimpleOpenNI context;
float zoomF = 0.25f;
float rotX = radians(180); 
float rotY = radians(0);
boolean autoCalib = true;
PVector com = new PVector();  

int steps = 12;  // to speed up the drawing, draw every third point


// seeds
int numInitialSeeds = 30;

// environment 
color darkPurpleCol = color(20, 20, 29);
color magentaCol = color(231, 68, 152);
color cyanCol = color(95, 253, 255);

// background agents
int agentCount = 1000;
int currentCount = 1;

Agent[] agents = new Agent[10000];

float noiseScale = 100;
float noiseStrength = 10.0;
float noiseZRange = 0.4;
float overlayAlpha = 20;
float agentsAlpha = 120;
float strokeWidth = 0.5;


void setup() {
	size(displayWidth/2, displayHeight/2, P3D);
	smooth();

	// init kinect
	context = new SimpleOpenNI(this);
	if(context.isInit() == false) {
		println("Can't init SimpleOpenNI");
		exit();
		return;  
	}

	context.enableDepth();
	context.setMirror(true);
	context.enableUser(); // enable skeleton generation for all joints

	// init agents
	for(int i = 0; i < agents.length; i++) {
		agents[i] = new Agent();
	}

	// init seed particles
	// seedParticles = new ArrayList<SeedParticle>();
	// for(int i=0; i<numInitialSeeds; i++) {
	// 	seedParticles.add(new SeedParticle());
	// }

	perspective(radians(45), float(width)/float(height), 10,1500);
}

void draw() {
	fill(darkPurpleCol, 190);
	noStroke();
	rect(0, 0, width, height);

	// debug
	frame.setTitle(str((int)frameRate));
	//  context.drawCamFrustum();
	// image(context.userImage(),0,0);

	// draw agents
	stroke(cyanCol, agentsAlpha);
	for(int i = 0; i < agentCount; i++) {
		agents[i].updateAgent();
	}

	// update seeds, check for collisions
	// for(int i=0; i<seedParticles.size(); i++) {
	// 	seedParticles.get(i).update();
	// 	for(int x=0; x<seedParticles.size(); x++) {
	// 		if(i != x) {
	// 			seedParticles.get(i).checkForCollision(seedParticles.get(x)); 
	// 		}
	// 	}
	// 	seedParticles.get(i).draw();
	// }

	// update kinect
	context.update();

	// get list of users, draw skeletons
	// int[] userList = context.getUsers();
	// for(int i=0; i<userList.length; i++) {
	// 	if(context.isTrackingSkeleton(userList[i])) {
	// 		drawSkeleton(userList[i]);
	// 	}
	// }

	// set the scene pos
	translate(width/2, height/2, 0);
	rotateX(rotX);
	rotateY(rotY);
	scale(zoomF);

	int[] depthMap = context.depthMap();
	int[] userMap = context.userMap();
	int index;
	
	PVector realWorldPoint;

	// EDIT 3rd PARAM TO ADJUST KINECT DEPTH, the more negative the #, the further away it will capture
	translate(0,0,-1500);  // set the rotation center of the scene 1000 infront of the camera

	// draw pointcloud
	for(int y=0;y < context.depthHeight();y+=steps) {
		for(int x=0;x < context.depthWidth();x+=steps) {
			index = x + y * context.depthWidth();
			if(depthMap[index] > 0) {

	        	// draw the projected point
	        	realWorldPoint = context.depthMapRealWorld()[index];

	        	if(userMap[index] != 0) {
	        		noStroke();
	        		fill(95, 253, random(200, 255));        
	        		pushMatrix();
	        		translate(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
	        		float ellipseSize = random(5, 15);
	        		ellipse(realWorldPoint.x, realWorldPoint.y, ellipseSize, ellipseSize);
	        		popMatrix();
	        	}
	        }
	    } 
	} 

}

void onNewUser(SimpleOpenNI curContext, int userId) {
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
	println("onLostUser - userId: " + userId);
}
