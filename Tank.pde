//creates turret object

//enums for the orientation of the tank
enum Orientation {
  LEFT_EDGE,
  BOTTOM_EDGE,
  RIGHT_EDGE,
  TOP_EDGE,
}

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
  
  //variable to store the orientation
  Orientation orientation = Orientation.BOTTOM_EDGE;
  
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
    
    tankBodyE = loadImage("tankBodyE.png");
    tankBodyE.resize(int(size.x), int(size.y) );
  }
  
  //moves the tank according to the keys pressed
  void move() {
    //tank moves differently depending on which edge it is on
    if (playerTank.orientation == Orientation.BOTTOM_EDGE ||
        playerTank.orientation == Orientation.TOP_EDGE) {
      if (key == 'd') {
        if ( (position.x + size.x/2 >= 280 && position.x < 300) || position.x + size.x/2 >= width) {
          //is past the limit
        } else {
          //moves to the right
          position.x += 5;
        }
      } else if (key == 'a') {
        if (position.x - (size.x/2 - 8) <= 0 || (position.x - (size.x/2 - 8) <= 320 && position.x > 300) ) {
          //is past the limit
        } else {
          //moves to the left
          position.x -= 5;
        }
      } 
    } else if (playerTank.orientation == Orientation.LEFT_EDGE) {
      if (key == 'd') {
        if (position.y + size.x/2 >= height - 50) {
          //is past the limit
        } else {
          //moves to down
          position.y += 5;
        }
      } else if (key == 'a') {
        if (position.y - (size.x/2 - 8) <= 0) {
          //is past the limit
        } else {
          //moves to the left
          position.y -= 5;
        }
      } 
    } else if (playerTank.orientation == Orientation.RIGHT_EDGE) {
      if (key == 'a') {
        if (position.y + size.x/2 >= height - 50) {
          //is past the limit
        } else {
          //moves to down
          position.y += 5;
        }
      } else if (key == 'd') {
        if (position.y - (size.x/2 - 8) <= 0) {
          //is past the limit
        } else {
          //moves to the left
          position.y -= 5;
        }
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
  void updatePosition(float xPos, float yPos) {
    //updates the position PVector
    position.x = xPos;
    position.y = yPos;
  }
  
  //this displays the tank
  void display() {
    //draws the images depending on whose tank it is    
    
    pushMatrix();
    translate(position.x, position.y);
    
    //rotates the tank according to its orientation
    switch (orientation) {
      case LEFT_EDGE:
        rotate(HALF_PI);
        break;
      case BOTTOM_EDGE:
        rotate(0);
        break;
      case RIGHT_EDGE:
        rotate(-HALF_PI);
        scale(-1, 1);
        break;
      case TOP_EDGE:
        rotate(PI);
        scale(-1, 1);
        break;
    }
    
    //display different images for player and enemy
    imageMode(CENTER);
    if (isPlayer) {
      image(tankBodyP, 0, 0);
    } else {
      image(tankBodyE, 0, 0);
    }
    imageMode(CORNER);
  
    popMatrix();
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