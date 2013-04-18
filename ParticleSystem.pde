
// Class which maintains the all the particles in the particle system
class ParticleSystem
{
  ArrayList<Particle> particles;
  
  // specifies the start location of each particle
  PVector start_location;
  
  // specifies whether the particle to be generated is rectangle or ellipse
  String s;


  // Constructor
  ParticleSystem(PVector location, String s)
  {
    start_location = location.get();
    this.s = s;
    particles = new ArrayList<Particle>();
  }

  // Adds a particle to the existing ArrayList
  void addParticle()
  {
    particles.add(new Particle(start_location, s, 0));
  }

  // Changes the position of particle with every tick
  void run() 
  {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext ()) 
    {
      Particle p = it.next();
      // if the particle crosses the window and is no longer seen, it is deleted
      p.run();
      if (p.isDead()) 
      {
        it.remove();
      }
    }
  }
}

class Particle
{
  
  // x and y location of the particle
  PVector location;
  
  // particle x and y is accerelated with this value
  PVector acceleration;
  
  // speed of the particle
  PVector velocity;
  
  // time span since the particle exists
  float lifespan;
  
  // Whether the particle is ellipse or rectangle
  String s;
  
  // angle in which the particle is generated. This field is used since ellipse and 
  // rectangle come from diagonally opposite ends
  float angle;

  // Constructor to initialise each particle
  Particle(PVector l, String s, float angle) 
  {
    if (s == "rectangle")
    {
      acceleration = new PVector(0.02, -0.02);
    }
    else
    {
      acceleration = new PVector(-0.05, 0.05);
    }
    velocity = new PVector(random(-1, 1), random(-2, 0));
    location = l.get();
    lifespan = 255.0;
    this.s = s;
    this.angle = angle;
  }

  void run() 
  {
    update();
    display();
  }

  // updating the position of each particle
  void update() 
  {
    this.velocity.add(acceleration);
    this.location.add(velocity);
    this.lifespan = lifespan - 1.0;
    this.angle = angle * PI/180;
  }

  // draw function for a particle
  void display() 
  {
    fill(0);
    if (this.s == "rectangle")
    {
      stroke(240, 80, 80);
      rect(location.x, location.y, 20, 20);
    }
    else 
    {
      stroke(80, 240, 235);
      ellipse(location.x, location.y, 20, 10);
    }
  }


  // Checks the life of the particle
  boolean isDead() 
  {
    if (lifespan < 0.0) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }
}

