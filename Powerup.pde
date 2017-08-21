//creates powerup object


int powerupIndex = 0;

//Enum used to determine powerup types
enum Type {
   HEALTH,
   //LARGERMISSILE,
   POWERFULMISSILE,
   DESTROYWALL;     
   static Type getPowerup(int index){
     return values()[index];
   }
}
  
class Powerup {  
  Type type;//Type object to store types
  PVector pos;
  PVector vel;
  PVector acc;
  float size = 30;
  PImage image;
  Tank owner;//Tank object used to store owners  info 
  
  @Deprecated 
  Powerup (Type _type, PVector _pos, PVector initVel){
    acc = new PVector (0, 0.1f);
    pos = _pos;
    vel = initVel;
    type = _type;
    image = loadImage(type+".png");
    
  }
  Powerup (PVector initPos, int direction, int index) {
    type = Type.getPowerup((timeElapsed/5000)%3);//Set type based on time
    powerupIndex++;//generate powerups in an orderly fahsion
    if (powerupIndex>2){
      powerupIndex =0;
    }
    //type = Type.HEALTH;
    acc = new PVector (0, 1);//Set accelatation
    pos = initPos;
    vel = new PVector (-direction*7 , 4.5 * (index-2)  );//Set velocity, cannot be random, because its networked
    image = loadImage(type+".png");
  }
  void update(Tank t){
   if (owner != null){//If it has an owner than don;t updat the position
     return;
   }
    vel.add(acc);
    pos.add(vel);
    if (pos.x<0-size/2){//Make it bounce off the sides
     vel.x *=-1;
    }
    //Check if it is colliding with tank
    if (isColliding(t.position, t.size)){
      background (255,0,255);
    }
  }
  
  boolean hittingTank(Tank t){//Check if hittong other tanks
    return isColliding(t.position, t.size) && owner ==null;
  }
  
  //ACtually five the owner his abbility
  void giveAbility(){
    switch (type){
      case HEALTH:
      //Prevents going over max health
      if (owner.health>=15) {
        owner.health = 20;
      }
      else{
        owner.health+=5;//Add health
      }
        return;
        
      case POWERFULMISSILE:
        owner.missileStrength++;//Increase the strength of the missile
        return;
       case DESTROYWALL:
         initDestruction(bricks);//Start destroying the wall
         fromTop = false;
         return;
    }
    
  }
  
  void initDestruction (ArrayList<Brick> list){
    for (Brick b: list){
      b.health = 1;//Set the whole walls health to 1
    }
    destroyingBricks = true;//Set boolean to true, that will continue destruction
  }
  
  
  void show(){
    //Actually show the powerup
    if (owner != null){//If it has an owner don't show it
      return;
    }
    imageMode(CENTER);
    ellipse(pos.x, pos.y, size, size);//Draw circle
    float ratio = image.height/image.width;//Remember aspect ratio
    
    image(image, pos.x, pos.y, size*0.65f, size*ratio*0.65f);//Show image of powerup
    imageMode(CORNER);

  }
  
  //Hit detect between circle and square
  //same as hit detection in missile class
  boolean isColliding(PVector rectPos, PVector rectSize) {
    PVector circleDistance = new PVector();
    float cornerDistance;
        
    circleDistance.x = abs(pos.x - rectPos.x);//get delta y
    circleDistance.y = abs(pos.y - rectPos.y);//get delta x
    
    //println(circleDistance);

    if (circleDistance.x > (rectSize.x/2 + 10)) { 
      return false;
    }
    if (circleDistance.y > (rectSize.y/2 + 10)) { 
      return false;
    }

    if (circleDistance.x <= (rectSize.x/2)) { 
      return true;
    }
    if (circleDistance.y <= (rectSize.y/2)) { 
      return true;
    }

    circleDistance.x *= circleDistance.x;//Use the equation of a circle to check if in corners
    circleDistance.y *= circleDistance.y;

    cornerDistance = circleDistance.x - rectSize.x/2 +
                     circleDistance.y - rectSize.y/2;

    return (cornerDistance <= 100);
  }
  
}