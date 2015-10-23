import SimpleOpenNI.*;
import processing.opengl.*;
import java.util.Iterator;

// kinect 
SimpleOpenNI context;
float zoomF = 0.15f;
float rotX = radians(180); 
float rotY = radians(0); 
int steps = 36;

// environment 
// color darkPurpleCol = color(20, 20, 29);
color darkPurpleCol = color(0, 0, 0);
color[] colors = new color[] {
	color(41, 255, 244),
	color(118, 245, 158),
	color(140, 200, 255),
	color(236, 168, 255)
};

HashMap<Integer, Integer> userColorMap;

ArrayList<Agent> userAgents;
final int maxUserAgents = 1000;

float noiseScale = 230;
float noiseStrength = 15.0;
float noiseZRange = 10.8;
float overlayAlpha = 20;
float agentsAlpha = 230; 
float strokeWidth = 1.0;

// body particles
ArrayList<BodyParticle> bodyParticles;

void setup() {
	size(displayWidth, displayHeight, OPENGL);
	smooth();
        noCursor();

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
	userAgents = new ArrayList<Agent>();

	// init user colors
	userColorMap = new HashMap<Integer, Integer>();	

	// init body particles
	bodyParticles = new ArrayList<BodyParticle>();
}

void draw() {
	fill(darkPurpleCol, overlayAlpha);
	noStroke();
	rect(0, 0, width, height);

	// debug
	frame.setTitle(str((int)frameRate));

	// draw agents
	for(int i = 0; i < userAgents.size(); i++) {
		userAgents.get(i).updateAgent();
	}

	// get list of users, draw skeletons
	// int[] userList = context.getUsers();
	// for(int i=0; i<userList.length; i++) {
	// 	println("USER: " + userList[i]);
	// }

	// update kinect
	context.update();

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

	PVector realWorldPoint;

	perspective(radians(45), float(width)/float(height), 10, 1500);

	//draw pointcloud
	for(int y=0; y < context.depthHeight(); y+=steps) {
		for(int x=0; x < context.depthWidth(); x+=steps) {
			index = x + y * context.depthWidth();
			if(depthMap[index] > 0) {

	        	// draw the projected point
	        	realWorldPoint = context.depthMapRealWorld()[index];

	        	if(userMap[index] != 0) {
	        		strokeWeight(random(30));
	        		new BodyParticle(realWorldPoint.x, realWorldPoint.y, userColorMap.get(userMap[index])).draw();
	        	}
	        }
	    } 
	}
}

void onNewUser(SimpleOpenNI curContext, int userId) {
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	color userColor = colors[(int)random(0, colors.length)];
	userColorMap.put(userId, userColor);

	// add agents to userAgents
	int agentsPerUser = 100;
	if(userAgents.size() >= maxUserAgents) {
		userAgents.subList(0, agentsPerUser).clear();
	}

	for(int i = 0; i < agentsPerUser; i++) {
		userAgents.add(new Agent(userColor));
	}
}

void onLostUser(SimpleOpenNI curContext, int userId) {
	println("onLostUser - userId: " + userId);

	userColorMap.remove(userId);
}
