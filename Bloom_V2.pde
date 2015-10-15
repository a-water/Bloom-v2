import SimpleOpenNI.*;
import processing.opengl.*;
import java.util.Iterator;

PImage img;

// kinect 
SimpleOpenNI context;
float zoomF = 0.1f;
float rotX = radians(180); 
float rotY = radians(0);
boolean autoCalib = true;
PVector com = new PVector();  
int steps = 18;  // to speed up the drawing, draw every third point

// seeds
int numInitialSeeds = 20;
ArrayList<SeedParticle> seedParticles;

// environment 
color darkPurpleCol = color(20, 20, 29);
color magentaCol = color(231, 68, 152);
color cyanCol = color(95, 253, 255);
color seedCol = color(3, 255, 180);

color[] colors = new color[] {
	color(random(255), random(255), random(255)),
	color(231, 68, 152),
	color(95, 253, random(200, 255))
};

color currentColor = colors[2];
color currentLineColor = colors[1];

// background agents
int agentCount = 1000;
int currentCount = 1;

Agent[] agents = new Agent[10000];
ArrayList<Agent> userAgents = new ArrayList<Agent>();

float noiseScale = 100;
float noiseStrength = 10.0;
float noiseZRange = 0.4;
float overlayAlpha = 20;
float agentsAlpha = 120;
float strokeWidth = 0.5;

// body particles
ArrayList<BodyParticle> bodyParticles = new ArrayList<BodyParticle>();


void setup() {

	size(1280, 800, P3D);
	smooth();

	// load texture 
	img = loadImage("texture.png");

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
	seedParticles = new ArrayList<SeedParticle>();
	for(int i=0; i<numInitialSeeds; i++) {
		seedParticles.add(new SeedParticle());
	}

	perspective(radians(45), float(width)/float(height), 10, 1500);
}

void draw() {
	fill(darkPurpleCol, 100);
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
	fill(seedCol);
	for(int i=0; i<seedParticles.size(); i++) {
		seedParticles.get(i).update();
		for(int x=0; x<seedParticles.size(); x++) {
			if(i != x) {
				seedParticles.get(i).checkForCollision(seedParticles.get(x)); 
			}
		}
		seedParticles.get(i).draw();
	}

	// update kinect
	context.update();

	// get list of users, draw skeletons
	// int[] userList = context.getUsers();
	// for(int i=0; i<userList.length; i++) {
	// 	println("USER: " + userList[i]);
	// }

	// set the scene pos
	translate(width/2, height/2, 0);
	rotateX(rotX);
	rotateY(rotY);
	scale(zoomF);

	int[] depthMap = context.depthMap();
	int[] userMap = context.userMap();
	int index;
	
	// EDIT 3rd PARAM TO ADJUST KINECT DEPTH, the more negative the #, the further away it will capture
	translate(0, 0, -3500);  // set the rotation center of the scene 1000 infront of the camera


	setParticleColors();

	int lineCount = 0;
	PVector realWorldPoint;

	ArrayList<Float> linePoints = new ArrayList<Float>();

	// draw pointcloud
	for(int y=0;y < context.depthHeight(); y+=steps) {
		for(int x=0;x < context.depthWidth(); x+=steps) {
			index = x + y * context.depthWidth();
			if(depthMap[index] > 0) {

	        	// draw the projected point
	        	realWorldPoint = context.depthMapRealWorld()[index];

	        	pushMatrix();
	        	translate(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);

	        	if(userMap[index] != 0) {

	        		if(random(1) > 0.5) {

	        			BodyParticle bp = new BodyParticle(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z, currentColor);

	        			int rando = (int)random(1, 30);
	        			if(rando == 5) {
	        				bodyParticles.add(bp);
	        			} else {
	        				bp.draw();
	        			}
	        		}

	        		// if(random(1) > 0.3) {
	        		// 	linePoints.add(realWorldPoint.x);
	        		// 	linePoints.add(realWorldPoint.y);
	        		// 	lineCount++;
	        		// }

	        		// if(lineCount == 4) {
	        		// 	stroke(currentLineColor);
	        		// 	strokeWeight(2);
	        		// 	// line(linePoints.get(0), linePoints.get(1), linePoints.get(2), linePoints.get(3));
	        		// 	quad(linePoints.get(0), linePoints.get(1), linePoints.get(2), linePoints.get(3), linePoints.get(4), linePoints.get(5), linePoints.get(6), linePoints.get(7));
	        		// 	// reset line count and line arraylist
	        		// 	lineCount = 0;
	        		// 	linePoints.clear();
	        		// }

	        		// for(int i=0; i<seedParticles.size(); i++) {	        			 
	        		// 	if(bodyParticle.checkForCollision(seedParticles.get(i))) {
	        		// 		seedParticles.remove(i);
	        		// 	}

	        		// }
	        		// userAgents.add(new Agent(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z));
	        	}

	        	popMatrix();
	        }
	    } 
	}	


	beginShape(TRIANGLES);
	stroke(255);
	strokeWeight(2.0);
	Iterator<BodyParticle> it = bodyParticles.iterator();
	while(it.hasNext()) {

		BodyParticle bp = it.next();
		PVector gravity = new PVector(0, 0.1 * bp.radius);
		bp.applyForce(gravity);
		bp.update();
		bp.draw();

		if(bp.isDead) {
			it.remove();
		}
	}
	endShape();

}

void setParticleColors() {
	if(frameCount % 60 == 0) {
		currentColor = colors[(int)random(0, 2)];
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
