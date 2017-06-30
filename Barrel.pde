//creates barrel of turret

//constructor of barrel class
class Barrel {
  //stores the direction of the barrel
  PVector direction = new PVector();
  //stores the mouse position values passed into the constructor
  PVector mousePos = new PVector();
  //stores the position of the tank
  PVector tankPos = new PVector();
  
  //images for the barrel
  //P is for player, E is for enemy
  PImage tankBarrelP;
  PImage tankBarrelE;
  
  //boolean of whether the class is for the player or enemy
  boolean isPlayer;
  
  //takes in four parameters for constructor
  //parameters are as follows:
  // - tankPosition: position of the tank
  // - mousex: x position of the mouse when this was called
  // - mousey: y position of the mouse when this was called
  // - isPlayer: true if it's the player's barrel, false if it is the enemy's
  Barrel(PVector tankPosition, float mousex, float mousey, boolean isPlayer) {
    //sets mousePos PVector using mousex and mousey variables
    mousePos.set(mousex, mousey);
    //sets the tankPos with the tank position
    tankPos.set(tankPosition);
    
    //loads the images and resizes them
    tankBarrelP = loadImage("tankBarrelP.png");
    //273x53 approx for original size
    tankBarrelP.resize(5, 27);
    
    tankBarrelE = loadImage("tankBarrelE.png");
    tankBarrelE.resize(5, 27);
    
    //sets the local isPlayer variable to global isPlayer variable
    this.isPlayer = isPlayer;
  }
  
  //this sets the direction of the barrel
  void setDirection() {
    //sets the direction to the direction between the two PVectors
    direction.set(PVector.sub(mousePos, tankPos) );
    //normalizes direction to one
    direction.normalize();
  }
  
  //this updates the position of the barrel
  //parameters are as follows: 
  // - position: position of tank
  // - mousex: x position of mouse during calling of method
  // - mousey: y position of mouse during calling of method
  void updatePos(PVector position, float mousex, float mousey) {
    //updates tankPos variable
    tankPos.set(position);
    //limits the movement of the barrel to 90 degrees
    if (mousey > 550) {
      mousey = 550;
    }
    if (mousex < playerTank.currentPosition().x) {
      mousex = playerTank.currentPosition().x;
    }
    //updates mousePos variable
    mousePos.set(mousex, mousey);
  }
  
  //this method returns the direction of the barrel
  PVector getDirection() {
    return direction;
  }
  
  //this displays the barrel
  void display() {
    //calls the setDirection method
    setDirection();
    
    //this draws the barrel
    pushMatrix();
    //this translates the origin to the location of the barrel
    if (isPlayer) {
      translate(tankPos.x+11, tankPos.y-6);
    } else {
      translate(tankPos.x-11, tankPos.y-6);
    }

    //this rotates the grid to the heading of the barrel
    rotate(direction.heading() - HALF_PI);
    //displays the actual barrel image
    if (isPlayer) {
      image(tankBarrelP, -2.5, 0);
    } else {
      image(tankBarrelE, -2.5, 0);
    }
    popMatrix();
  }
  
}