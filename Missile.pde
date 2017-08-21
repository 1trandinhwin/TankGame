//creates missile object

class Missile {
  //stores the position of the missile
  PVector position = new PVector();
  //stores the direction of the missile
  PVector direction = new PVector();
  //stores the initial velocity of the missile
  float velocity;
  //stores the acceleration of the missile
  PVector acceleration = new PVector();
  
  //image of the missiles
  PImage missile;
  PImage teleMissile;
  //these stores the locations and dimensions of the hit box of the missile
  PVector hitBoxPos = new PVector (15, 0);
  PVector hitBoxSize = new PVector (20, 20);
  
  //stores the strength of the missile
  int strength = 1;
  
  //holds whether the missile is from the player or enemy
  boolean fromPlayer = true;
  
  //constructor for the missile class
  //parameters are as follows:
  // - missileInitialPos: initial position of the missile
  // - missileDir: direction of the missile
  // - missileAccel: acceleration of the missile
  // - missileVel: initial velocity of the missile
  // - _strength: strength of the missile
  // - _fromPlayer: whether the missile is from the player or enemy
  Missile(PVector missileInitialPos, PVector missileDir, 
          PVector missileAccel, float missileVel, int _strength, boolean _fromPlayer) {
    //these assigns the parameters to the global variables in this class
    position.set(missileInitialPos);
    direction.set(missileDir);
    acceleration.set(missileAccel);
    velocity = missileVel;
    strength = _strength;
    fromPlayer = _fromPlayer;
    
    //loads the missile images and resizes it
    missile = loadImage("missile.png");
    missile.resize(50, 20);
    
    teleMissile = loadImage("teleMissile.png");
    teleMissile.resize(50, 20);
  }
  
  //this updates the strength of the missile using the parameter of s
  void setStrength (int s){
    strength = s;
  }
  
  //this sets the initial velocity of the missile
  void setVelocity() {
    direction.mult(velocity);
  }
  
  //this updates the position of the missile
  void update() {
    direction.add(acceleration);
    position.add(direction);
    
  }

  //this returns the current position of the missile
  PVector getPos() {
    return position;
  }

  //this detects for collisions between the missile and a rectangle
  //the hit box for the missile is a circle
  //parameters specify the position and dimensions of the rectangle
  //returns a true or false depending on if there is a collision or not
  boolean isColliding(PVector rectPos, PVector rectSize) {
    //stores the distance between the circle and rectangle
    PVector circleDistance = new PVector();
    //stores the distance between the rectangle's corner and the circle
    float cornerDistance;
    
    //calculates the absolute value of the distances
    circleDistance.x = abs(hitBoxPos.x - rectPos.x);
    circleDistance.y = abs(hitBoxPos.y - rectPos.y);

    //if the distance is larger than half of the rect and the radius of the circle hitbox
    if (circleDistance.x > (rectSize.x/2 + 10)) { 
      return false;
    }
    if (circleDistance.y > (rectSize.y/2 + 10)) { 
      return false;
    }

    //if distance is smaller
    if (circleDistance.x <= (rectSize.x/2)) { 
      return true;
    }
    if (circleDistance.y <= (rectSize.y/2)) { 
      return true;
    }
    
    //squares the distances
    circleDistance.x *= circleDistance.x;
    circleDistance.y *= circleDistance.y;

    //does pythagoras to find the distance between the corner and circle
    cornerDistance = circleDistance.x - rectSize.x/2 +
                     circleDistance.y - rectSize.y/2;

    //returns true if distance is smaller or equal to 100, false otherwise
    return (cornerDistance <= 100);
  }
  
  //checks for collision between two circles
  //parameters specify the position and radius of the other circle
  //returns true or false depending on if there is a collision or not
  boolean isColliding(PVector otherMissilePos, float missileSize) {
    //returns whether the distance between them is larger than the combined radius or not
    return PVector.dist(position, otherMissilePos) <= missileSize*2; 
  }
  
  boolean isColliding(float missileSize) {
    return (position.y < missileSize); 
  }
  
  /*
  void isColliding() {
    
  }*/
  
  //returns the current size of the hit box radius
  float getSize() {
    return hitBoxSize.x;
  }
  
  //this displays the missile
  void display() {
    //updates the position
    update();
    fill(255);
    
    //translates and rotates the grid to have missile point to its direction
    pushMatrix();
    translate(position.x, position.y);
    rotate(direction.heading());
    imageMode(CENTER);
    //draws the missile image
    if (this.getClass() == Missile.class) {
      //normal missile
      image(missile, 0, 0);
    } else {
      //teleporting missile
      image(teleMissile, 0, 0);
    }
    imageMode(CORNER);
    
    //sets the hit box position within the modified matrix
    rotate(-direction.heading() );
    hitBoxPos.set(10, 0);
    hitBoxPos.rotate(direction.heading() );    
    
    popMatrix();
    
    //updates the hit box position to match the normal matrix
    hitBoxPos.x += position.x;
    hitBoxPos.y += position.y;
  }
  

}