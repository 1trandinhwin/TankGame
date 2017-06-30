//creates turret object


class Tank {
  //stores the position of the tank
  PVector position = new PVector();
  //stores the size of the tank
  PVector size = new PVector();
  //stores the health of the tank
  int health;
  //stores the missile strength
  int missileStrength = 1;
  
  //stores the images of the player and enemy tanks
  PImage tankBodyE;
  PImage tankBodyP;
  
  //stores which tank it is
  boolean isPlayer;
  
  //turret object constructer
  //parameters are as follows:
  // - tankPosition: position of the tank
  // - turretSize: size of the tank
  // - isPlayer: whether the tank is the player's or the enemy's
  Tank(PVector tankPosition, PVector turretSize, boolean isPlayer) {
    //updates the global variables in this class with the parameters
    position.set(tankPosition);
    size.set(turretSize);
    this.isPlayer = isPlayer;
    
    //sets health of tank to 20
    health = 20;
    
    //loads and resizes the images of the tank
    tankBodyP = loadImage("tankBodyP.png");
    //600x227 approx for original size
    tankBodyP.resize(int(size.x), int(size.y) );
    //tankBodyP.resize(60, 23);
    
    tankBodyE = loadImage("tankBodyE.png");
    tankBodyE.resize(int(size.x), int(size.y) );
  }
  
  //moves the tank according to the keys pressed
  void move() {
    if (key == 'd') {
      if (position.x + size.x/2 >= 280) {
        //is past the limit
      } else {
        //moves to the right
        position.x += 5;
      }
    } else if (key == 'a') {
      if (position.x - (size.x/2 - 8) <= 0) {
        //is past the limit
      } else {
        //moves to the left
        position.x -= 5;
      }
    } 
  }
  
  //returns the current position of the tank
  PVector currentPosition() {
    return position;
  }
  
  //returns the size of the tank
  PVector getSize() {
    return size;
  }
  
  //updates the position of the tank with a parameter of the xPos
  void updatePosition(float xPos) {
    //updates the position PVector
    position.x = xPos;
  }
  
  //this displays the tank
  void display() {
    //draws the images depending on whose tank it is    
    imageMode(CENTER);
    if (isPlayer) {
      image(tankBodyP, position.x, position.y);
    } else {
      image(tankBodyE, position.x, position.y);
    }
    imageMode(CORNER);
  }
  
  //updates the health of the tank
  //parameter is the damage taken
  void updateHealth(int damage) {
    //subtracts damage from health
    health -= damage;
  }
  
  //returns the current health of the tank
  int getHealth() {
    return health;
  }
  
}