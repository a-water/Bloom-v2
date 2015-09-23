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
