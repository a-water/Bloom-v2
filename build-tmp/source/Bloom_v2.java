import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import processing.opengl.*; 
import blobDetection.*; 
import java.awt.Polygon; 
import java.util.Collections; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Bloom_v2 extends PApplet {






SimpleOpenNI context;

int[] userClr = new int[] { 
	color(255,0,0),
	color(0,255,0),
	color(0,0,255),
	color(255,255,0),
	color(255,0,255),
	color(0,255,255)
};

PVector com = new PVector();                                   
PVector com2d = new PVector();  
ArrayList <SeedParticle> seedParticles;

// Experimental
float globalX, globalY, reScale;

int kinectWidth;
int kinectHeight;

PImage cam, blobs;

int NUM_FLOW_PARTICLES = 2200;

String[] palettes = {
	"-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634",
	"-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031",
	"-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
};

FlowParticle[] flowParticles = new FlowParticle[NUM_FLOW_PARTICLES];
PolygonBlob poly = new PolygonBlob();
BlobDetection blobDetection;


public void setup() {
	size(displayWidth, displayHeight);
	background(0);

	kinectWidth = width;
	kinectHeight = height;
	//  strokeWeight(3);
	//  smooth();  

	// Init seed particles
	seedParticles = new ArrayList<SeedParticle>();
	for(int i=0; i<10; i++) {
		seedParticles.add(new SeedParticle());
	}

	// Init Kinect things
	context = new SimpleOpenNI(this);
	if(context.isInit() == false) {
		println("Can't init SimpleOpenNI, maybe the camera is not connected!");
		exit();
		return;  
	}

	// enable depthMap generation 
	// context.enableDepth();

	// enable skeleton generation for all joints
	context.enableUser();

	// Experimental
	blobs = createImage(width, height, RGB);
	blobDetection = new BlobDetection(blobs.width, blobs.height);
	blobDetection.setThreshold(0.2f);
	reScale = (float) width/kinectWidth;
	setupFlowField();
}

public void draw() {
	// DEBUG
	frame.setTitle(str((int)frameRate));
 
	background(0);

	// Update seed particles and check for collisions 
	for(int i=0; i<10; i++) {
		seedParticles.get(i).update();
		for(int x=0; x<10; x++) {
			if(i != x) {
				seedParticles.get(i).checkForCollision(seedParticles.get(x)); 
			}
		}
		seedParticles.get(i).draw();
	}

	// Update Kinect
	context.update(); 

	// Draw to an image what the camera data is seeing
	// image(context.userImage(),0,0);

	int[] userList = context.getUsers();
	cam = createImage(width, height, RGB);
	int[] depthValues = context.depthMap();
	int[] userMap = null;

	for(int i=0; i<userList.length; i++) {
		if(context.isTrackingSkeleton(userList[i])) {
			drawSkeleton(userList[i]);

			userMap = context.userMap();
			cam.loadPixels();

			for(int y=0; y<context.depthHeight(); y++) {
				for(int x=0; x<context.depthWidth(); x++) {
					int index = x + y * context.depthWidth();
					if(userMap != null && userMap[index] > 0) {
						cam.set(x, y, 255);
					}
				}
			}
			cam.updatePixels();      
			// copy the image into the smaller blob image
			blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
			// blur the blob image
			blobs.filter(BLUR);
			// detect the blobs
			blobDetection.computeBlobs(blobs.pixels);
			// clear the polygon (original functionality)
			poly.reset();
			// create the polygon from the blobs (custom functionality, see class)
			poly.createPolygon();
			drawFlowField();
		}
	}

	if(userList.length > 0) {

	}
}

public void drawSkeleton(int userId) { 
	// Draw Head
	PVector jointPos = new PVector();
	context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPos);
	//  println(jointPos.x);
	//  println(jointPos.y);

	// convert real world point to projective space
	PVector jointPos_Proj = new PVector(); 
	context.convertRealWorldToProjective(jointPos,jointPos_Proj);

	// a 200 pixel diameter head
	float headsize = 200;

	// create a distance scalar related to the depth (z dimension)
	float distanceScalar = (525/jointPos_Proj.z);

	// set the fill colour to make the circle green
	fill(154, 201, 217); 

	// draw the circle at the position of the head with the head size scaled by the distance scalar
	ellipse(jointPos_Proj.x,jointPos_Proj.y, distanceScalar*headsize,distanceScalar*headsize);

  // draw limbs  
//  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

}

public void onNewUser(SimpleOpenNI curContext, int userId) {
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

public void onLostUser(SimpleOpenNI curContext, int userId) {
	println("onLostUser - userId: " + userId);
}

public void setupFlowField() {
	strokeWeight(1);

	// initialize all particles in the flow
	for(int i=0; i< flowParticles.length; i ++) {
		flowParticles[i] = new FlowParticle(i/10000.0f);
	}

	setRandomColors(1);
}

public void drawFlowField() {
	translate(0, (height-kinectHeight*reScale)/2); 
	scale(reScale);

	globalX = noise(frameCount * 0.01f) * width/2 + width/4;
	globalY = noise(frameCount * 0.005f + 5) * height;

	for (FlowParticle p : flowParticles) {
		p.updateAndDisplay();
	}
}

public void setRandomColors(int nthFrame) {
	if (frameCount % nthFrame == 0) {
		// turn a palette into a series of strings
		String[] paletteStrings = split(palettes[PApplet.parseInt(random(palettes.length))], ",");
		
		// turn strings into colors
		int[] colorPalette = new int[paletteStrings.length];
		for (int i=0; i < paletteStrings.length; i ++) {
			colorPalette[i] = PApplet.parseInt(paletteStrings[i]);
		}

		// set all particle colors randomly to color from palette (excluding first aka background color)
		for (int i=0; i < NUM_FLOW_PARTICLES; i ++) {
			flowParticles[i].col = colorPalette[PApplet.parseInt(random(1, colorPalette.length))];
		}
	}
}

public void keyPressed() {

}
class FlowParticle {
	// unique id, (previous) position, speed
	float id, x, y, xp, yp, s, d;
	int col; // color

	FlowParticle(float id) {
		this.id = id;
		s = random(2, 6); // speed
	}

	public void updateAndDisplay() {
		// let it flow, end with a new x and y position
		id += 0.01f;
		d = (noise(id, x/globalY, y/globalY)-0.5f)*globalX;
		x += cos(radians(d))*s;
		y += sin(radians(d))*s;

		// constrain to boundaries
		if(x < -10) {
			x = xp = kinectWidth + 10;
		} 
		if (x > kinectWidth + 10) {
			x = xp = -10;
		}
		if (y < -10) {
			y = yp = kinectHeight + 10;
		}
		if (y>kinectHeight+10) {
			y = yp = -10;
		}

		// if there is a polygon (more than 0 points)
		if (poly.npoints > 0) {
			// if this particle is outside the polygon
			if (!poly.contains(x, y)) {
				// while it is outside the polygon
				while(!poly.contains(x, y)) {
					// randomize x and y
					x = random(kinectWidth);
					y = random(kinectHeight);
				}

				// set previous x and y, to this x and y
				xp = x;
				yp = y;
			}
		}

		// individual particle color
		stroke(col);
		strokeWeight(2);

		// line from previous to current position
		point(x, y); 

		// line(xp, yp, x, y);
		// set previous to current position

		xp = x;
		yp = y;
	}
}


// Polygonblob class by Amnon Owed (15/09/12)

class PolygonBlob extends Polygon {
	public void createPolygon() {
	// an arrayList of arrayLists of PVectors
	// the arrayLists of PVectors are basically the person's contours (almost but not completely in a polygon-correct order)
	ArrayList <ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>();

	// vars to track selected contour and start end point
	int selectedContour = 0;
	int selectedPoint = 0;

	// create contours from blobs
	// go over all the detected blobs
	for (int n=0 ; n<blobDetection.getBlobNb(); n ++) {
		Blob b = blobDetection.getBlob(n);

		// for each blob
		if (b != null && b.getEdgeNb() > 100) {
			// create a new contour arrayList of PVectors
			ArrayList <PVector> contour = new ArrayList<PVector>();

			// go over all the edges in the blob
			for (int m=0; m <b.getEdgeNb() ; m++){

				// get the edgeVertices of the edge
				EdgeVertex eA = b.getEdgeVertexA(m);
				EdgeVertex eB = b.getEdgeVertexB(m);

				if (eA != null && eB != null) {
				// get next and previous edgeVertexA
				EdgeVertex fn = b.getEdgeVertexA((m+1) % b.getEdgeNb());
				EdgeVertex fp = b.getEdgeVertexA((max(0, m-1)));

					// calculate distance between vertexA and next and previous edgeVertexA respectively

					// positions are multiplied by kinect dimensions because the blob library returns normalized values
					float dn = dist(eA.x * kinectWidth, eA.y * kinectHeight, fn.x * kinectWidth, fn.y * kinectHeight);

					float dp = dist(eA.x * kinectWidth, eA.y * kinectHeight, fp.x * kinectWidth, fp.y * kinectHeight);

					// if either distance is bigger than 15
					if (dn > 15 || dp > 15) {

						// if the current contour size is bigger than zero
						if (contour.size() > 0) {

							// add final point
							contour.add(new PVector(eB.x * kinectWidth, eB.y * kinectHeight));

							// add current contour to the arrayList
							contours.add(contour);

							// start a new contour arrayList
							contour = new ArrayList();

						} else {
							// if the current contour size is 0 (aka it's a new list)
							// add the point to the list
							contour.add(new PVector(eA.x * kinectWidth, eA.y * kinectHeight));
						}

					} else {
						// if both distance are smaller than 15 (aka the points are close)
						// add the point to the list
						contour.add(new PVector(eA.x * kinectWidth, eA.y * kinectHeight));
					}
				}
			}
		}
	}

	// at this point in the code we have a list of contours (aka an arrayList of arrayLists of PVectors)

	// now we need to sort those contours into a correct polygon. To do this we need the correct order of contours and the correct direction of each contour

	// as long as there are contours left
	while (contours.size() > 0) {
		// find next contour

		float distance = 999999999;

		// if there are already points in the polygon
		if (npoints > 0) {
			
			// use the polygon's last point as a starting point
			PVector lastPoint = new PVector(xpoints[npoints-1], ypoints[npoints-1]);

			// go over all contours
			for (int i=0; i <contours.size(); i++) {
				ArrayList <PVector> c = contours.get(i);

				// get the contour's first point
				PVector fp = c.get(0);

				// get the contour's last point
				PVector lp = c.get(c.size()-1);

				// if the distance between the current contour's first point and the polygon's last point is smaller than distance
				if (fp.dist(lastPoint) < distance) {
					// set distance to this distance
					distance = fp.dist(lastPoint);

					// set this as the selected contour
					selectedContour = i;

					// set selectedPoint to 0 (which signals first point)
					selectedPoint = 0;
				}

				// if the distance between the current contour's last point and the polygon's last point is smaller than distance
				if (lp.dist(lastPoint) < distance) {
					// set distance to this distance
					distance = lp.dist(lastPoint);

					// set this as the selected contour
					selectedContour = i;

					// set selectedPoint to 1 (which signals last point)
					selectedPoint = 1;
				}
			}
		} else {
			// if the polygon is still empty, use a starting point in the lower-right

			PVector closestPoint = new PVector(width, height);

			// go over all contours
			for (int i=0; i < contours.size(); i ++) {
				ArrayList <PVector> c = contours.get(i);

				// get the contour's first point
				PVector fp = c.get(0);

				// get the contour's last point
				PVector lp = c.get(c.size()-1);

				// if the first point is in the lowest 5 pixels of the (kinect) screen and more to the left than the current closestPoint
				if (fp.y > kinectHeight-5 && fp.x < closestPoint.x) {
					// set closestPoint to first point
					closestPoint = fp;

					// set this as the selected contour
					selectedContour = i;

					// set selectedPoint to 0 (which signals first point)
					selectedPoint = 0;
				}

				// if the last point is in the lowest 5 pixels of the (kinect) screen and more to the left than the current closestPoint
				if (lp.y > kinectHeight-5 && lp.x < closestPoint.y) {
					// set closestPoint to last point
					closestPoint = lp;

					// set this as the selected contour
					selectedContour = i;

					// set selectedPoint to 1 (which signals last point)
					selectedPoint = 1;
				}
			}
		}

		// add contour to polygon
		ArrayList<PVector> contour = contours.get(selectedContour);

		// if selectedPoint is bigger than zero (aka last point) then reverse the arrayList of points

		if (selectedPoint > 0) { 
			Collections.reverse(contour); 
		}

		// add all the points in the contour to the polygon
		for (PVector p : contour) {
			addPoint(PApplet.parseInt(p.x), PApplet.parseInt(p.y));
		}

		// remove this contour from the list of contours
		contours.remove(selectedContour);

		// the while loop above makes all of this code loop until the number of contours is zero
		// all the points in all the contours should have been added to the polygon in the correct order (hopefully)
	}
}
}


class SeedParticle {

	private int speedX;
	private int speedY;
	public PVector vector;
	private final int SEED_RADIUS = 5;

	SeedParticle() {

		vector = new PVector(random(width), random(height));
		speedX = (int)random(1, 5);
		speedY = (int)random(1, 5);

	}

	public void update() {
		vector.x = vector.x + speedX;
		vector.y = vector.y + speedY;

		// Check Y values for the seed
		if(vector.y > height-SEED_RADIUS) {
			vector.y = height-SEED_RADIUS;
			speedY = speedY * -1;
		}

		if (vector.y < SEED_RADIUS) {
			vector.y = SEED_RADIUS;
			speedY = speedY * -1;
		}

		// Check X values for the seed
		if(vector.x > width-SEED_RADIUS) {
			vector.x = width-SEED_RADIUS;
			speedX = speedX * -1;
		}

		if (vector.x < SEED_RADIUS) {
			vector.x = SEED_RADIUS;
			speedX = speedX * -1;
		}
	}

	public void draw() {
		ellipse(vector.x, vector.y, SEED_RADIUS, SEED_RADIUS);
	} 

	public void checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, vector.x, vector.y) < SEED_RADIUS * 2) {
			speedX *= -1;
			speedY *= -1;
			println("COLLISION DETECTED!");  
		}
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Bloom_v2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
