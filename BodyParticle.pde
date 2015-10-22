class BodyParticle {

	private float x;
	private float y;

	PVector location;
	color particleColor;
	float radius;

	BodyParticle(float x, float y, color particleColor) {

		this.x = x + random(-35, 35);
		this.y = y + random(-35, 35);

		location = new PVector(this.x, this.y);

		this.particleColor = particleColor;
	
		this.radius = 20;
	}

	public void draw() {
		noStroke();
	    fill(particleColor, random(100, 200));

	    beginShape(TRIANGLES);    
		vertex(location.x, location.y, radius, radius);
		vertex(location.x + random(-120, 120), location.y + random(-120, 120));
		vertex(location.x + random(-120, 120), location.y + random(-120, 120));
		endShape();
	} 
}
