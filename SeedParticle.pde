class SeedParticle {

	private int speedX;
	private int speedY;
	private float rotation;
	public PVector vector;
	PShape seedSVG;

	private final int seedRadius = 8;
	private final int seedSvgWidth = 50;
	private final int seedSvgHeight = 30;

	SeedParticle() {

		vector = new PVector(random(width), random(height));
		speedX = (int)random(1, 2);
		speedY = (int)random(1, 2);
		rotation = random(0, 360);

		// Load svg and rotate it
		seedSVG = loadShape("seed_01.svg");
		pushMatrix();
		translate(vector.x, vector.y);
		seedSVG.rotate(radians(rotation));
		popMatrix();
	}

	public void update() {
		vector.x = vector.x + speedX;
		vector.y = vector.y + speedY;

		// Check Y values for the seed
		if(vector.y > height-seedRadius) {
			vector.y = height-seedRadius;
			speedY = speedY * -1;
		}

		if (vector.y < seedRadius) {
			vector.y = seedRadius;
			speedY = speedY * -1;
		}

		// Check X values for the seed
		if(vector.x > width-seedRadius) {
			vector.x = width-seedRadius;
			speedX = speedX * -1;
		}

		if (vector.x < seedRadius) {
			vector.x = seedRadius;
			speedX = speedX * -1;
		}
	}

	public void draw() {
		shape(seedSVG, vector.x, vector.y, seedSvgWidth/2.5, seedSvgHeight/2.5);
	} 

	public void checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, vector.x, vector.y) < seedRadius * 2) {
			speedX *= -1;
			speedY *= -1;
			// println("COLLISION DETECTED!");  
		}
	}

	public int getSeedRadius() {
		return seedRadius;
	}
}
