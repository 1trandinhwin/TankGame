/*
creates bricks for wall
*/

class Brick {
  //Max = 15
  PVector size;
  float yPos;
  //float gravity = 0.1;
  float gravity = 0.1;                      //blocks do not fall
  PVector pos;
  PVector vel;
  boolean indestructable = false;//USed to set infinite health blocks, used for the bottom 3
  int health = 0;
  double finalDest;//Position ehre it should be based on its index in the array
  boolean destroyed = false;//Used to store dead bricks, just for one frame
  
  PImage currentImage;
  int maxHealth = 12;//Lamit on max health to prevent OP bricks
  
  int lastHit = 0;//Used to store which tank hit it last 1 = player, -1 = enemy
  
  //boolean to store whether brick belongs on top or bottom half
  boolean fromTop;
  //boolean arrived = false;
  //double prevFinalDest;

  //constructor for invincible bricks
  Brick(float brickSize, float yPosition, boolean _fromTop) {
    pos = new PVector (width/2, yPosition);
    vel = new PVector (0,0); 
    size = new PVector(brickSize, brickSize);
    indestructable = true;
    yPos = yPosition;
    fromTop = _fromTop;
  }

  
  Brick(boolean _fromTop) {//Constructor that is used to make the falling bricks
    pos = new PVector (width/2, -height/3);//Set position off the screen
    size = new PVector(40,40);//Set size and velocity
    vel = new PVector (0,gravity); 
    fromTop = _fromTop;
    //Set health
    if (bricks.size()>13){
     health = 12;
    }
    else {
      health = bricks.size()-1;
    }
    indestructable = false;//Make the bricks destructable
    //set the destination of the brick after it falls
    if (fromTop) {
      finalDest = bricks.get(bricks.size()-2).currentPosition().y + size.y;
    } else {
      finalDest = bricks.get(bricks.size()-2).currentPosition().y - size.y;
    }

  }
  
  void update() {//Update position
    
   int topBricks = 2;
   int bottomBricks = 2;
   if (fromTop) {
     for (int i = 5; i < bricks.size(); i++) {
       if (bricks.get(i).fromTop) {
         //topBricks.add(bricks.get(i) );
         topBricks++;
         //println("top bricks: " + topBricks);
         if (bricks.get(i).equals(this) ) {
           finalDest = (topBricks)*size.y;
         }
       } 
     }
   } else {
     for (int i = 5; i < bricks.size(); i++) {
       if (!bricks.get(i).fromTop) {
         //topBricks.add(bricks.get(i) );
         bottomBricks++;
         //println("bottom bricks: " + bottomBricks);
         if (bricks.get(i).equals(this) ) {
           finalDest = height - (bottomBricks)*size.y;
         }
       }
     }
   }
     
     
     //println(bricks.indexOf(this) + " is " + arrived);
     
     
     /*
     if (bricks.indexOf(this) > 3) {
       //println(bricks.indexOf(this) );
       if (fromTop) {
         if (bricks.get(bricks.indexOf(this)-2).fromTop == true) {
           //finalDest = bricks.get(bricks.indexOf(this)-2).currentPosition().y + size.y;
           //println("true top");
         } else {
          //finalDest = bricks.get(bricks.indexOf(this)-3).currentPosition().y + size.y;
          //println("false top");
         }
        } else {
         if (bricks.get(bricks.indexOf(this)-2).fromTop == false) {
           //finalDest = bricks.get(bricks.indexOf(this)-2).currentPosition().y - size.y;
           //println("true bottom");
         } else {
          //finalDest = bricks.get(bricks.indexOf(this)-3).currentPosition().y - size.y;
          //println("false bottom");
         }
          //finalDest = bricks.get(bricks.indexOf(this)-2).currentPosition().y - size.y;
        }
     }
     //println(finalDest);
     */
     
     
   if (health <0){//Stops negative health, need this to map healt to the right image
     health = 0;
   }
   int index = brickImages.length-1 - round((brickImages.length * health)/maxHealth);//Set image based on health
  if (index<0){
     index = 0;
   }
   currentImage = brickImages [index];
       
  //does not run for unbreakable blocks
  if (bricks.indexOf(this) > 4) {
     //Actually moves brick
     if (floor(pos.y) < finalDest - vel.y ) {//Need to subtract velocity so it perfecctly lines up without that there is a small gap
       //moving bricks down
       vel.add(0,gravity);
       pos.add(vel);
     } else if (pos.y == finalDest - vel.y) {
       //brick is in correct position
       vel.set(0, 0);
     } else {
        //moves brick up
        if (floor(pos.y) > finalDest + vel.y) {
          vel.add(0,gravity);
          pos.sub(vel);
        } else {
          //brick is in position
          vel.set(0,0);
       }
    }
  }
  
}
  
  //Display Brick
  void display(){
    //if Health is 0 and its not permanent remove it
    if (health<=0 && !indestructable){
      destroyed = true;
      bricks.remove(this);
      //Release a powerup
      powerups.add(new Powerup(pos, lastHit, bricks.indexOf(this)));

    }
    //Make sure the invincible ones never take damage
    if (indestructable){
      health = maxHealth-1;
      destroyed = false;
      fill(0);
    } else{
      fill(255, 0, 0);
    }
    if (!destroyed){
      textMode(CENTER);
      imageMode(CENTER);
      rectMode(CENTER);
      //ACtually draw the brick
      fill (127);
      rect (pos.x, pos.y, size.x+1, size.y+1);
      image(currentImage, pos.x, pos.y, size.x, size.y);
      fill (255);
       //text ("Final Dest:" + finalDest + "pos: " + pos.y, width/2, height/2);

      if (!indestructable) {
        //Display health on brick
        text (health, pos.x-2,pos.y);
      } else {
        //If its indestructable make it say infinite health
        text("\u221e", pos.x-3, pos.y);
      }
    
      textMode(CORNER);    
      imageMode(CORNER);
      rectMode(CORNER);
    }
    fill(255);
    
  }
  
  ///Takes damage
  void updateHealth(int damage) {
    health -= damage;
  }
  
  PVector currentPosition() {
    return pos;
  }
  
  PVector getSize() {
    return size;
  }
  
}