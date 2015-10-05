class SeedParticle {

	private int speedX;
	private int speedY;
	private float rotation;
	public PVector vector;
	PShape seedSVG;

	private final int SEED_RADIUS = 8;
	private final int SEED_SVG_WIDTH = 75;
	private final int SEED_SVG_HEIGHT = 45;

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
		shape(seedSVG, vector.x, vector.y, SEED_SVG_WIDTH/2.5, SEED_SVG_HEIGHT/2.5);
	} 

	public void checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, vector.x, vector.y) < SEED_RADIUS * 2) {
			speedX *= -1;
			speedY *= -1;
			// println("COLLISION DETECTED!");  
		}
	}

	public int getSeedRadius() {
		return SEED_RADIUS;
	}
}
