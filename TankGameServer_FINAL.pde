/*

Winnie T. & Ansar K.

Last Modified: May 18, 2017
This program uses networking to create a tank game between two users.
The tanks are controlled through key clicks and the shooting of the missiles
are controlled via mouse.
The bricks are gradually created to stand in between the two players, and
upon breaking of brick, it spawns a powerup to the player that did the last hit.
This is the server, and requires the client to run for full functionality.


*/



//imports the necessary libraries for the program to run
//gifAnimation allows for playing of gif files
import gifAnimation.*; 
//processing.net allows for network capabilities
import processing.net.*; 
//processing.sound allows for playing sound files
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;


//Declare Player Components
Tank playerTank;
Barrel playerBarrel;
Missile playerMissile;

//Declare Enemy Compnents
Tank enemyTank;
Barrel enemyBarrel;

//Declare Gif
Gif missileExplosion;

//Declare Soundfiles
AudioPlayer explosion;

AudioPlayer launch;
AudioPlayer battle;
AudioPlayer title;
AudioPlayer victory;
AudioPlayer defeat;

Minim m = new Minim(this);






//Declare Images for Title Screen
PImage titleTank;
PImage titleMissile;

//PVector storing the initial position of the player's tank
PVector initialLocation = new PVector (100, 550);
//stores the size of the tank
PVector tankSize = new PVector (60, 23);
//stores the velocity of the missile
float missileVel = 1;
//stores the acceleration of the missiles
PVector accel = new PVector (0, 1);

//controls whether the velocity should increase or not
boolean velIncrease = true;

//arrayLists of missile object and missile explosions for player
ArrayList<Missile> missiles = new ArrayList<Missile> ();
ArrayList<Gif> missileExplosions = new ArrayList<Gif>();
//this arrayList controls whether the missiles should be displayed or not
ArrayList<Boolean> showMissiles = new ArrayList<Boolean>();

//same as above but for opponent missiles
ArrayList<Missile> enemyMissiles = new ArrayList<Missile> ();
ArrayList<Gif> enemyMissileExplosions = new ArrayList<Gif>();
ArrayList<Boolean> showEnemyMissiles = new ArrayList<Boolean>();

//boolean controlling whether a brick should be added or not
boolean addBrick = false;
//stores whether the bricks are being destroyed or not
boolean destroyingBricks = false;    
//cooldown used for the destroying of bricks
int cooldown = 7;
//arrayList to store brick objects
ArrayList<Brick> bricks = new ArrayList<Brick>();
//array to store the different images of the bricks
PImage[] brickImages = new PImage[6];    

//arrayList storing the different powerups
ArrayList<Powerup> powerups; 

//string that is being sent; first number represents whether a
//missile is being created or not (0 or 1), and the second number
//represents the initial velocity of the new missile
String sendData = "0 -1" ;
//creates client for networking
Client c;
//Creates a server for networking
Server s;
//boolean to store whether the receiving data is incorrect or not
boolean dataError = false;

//string that stores the current game state
//possible values are: title, battle, victory, defeat
String gameState = "title";

//stores the start time once both players connect successfully
//allows for the time to be synced on both programs
int startTime = -1;
//used to make events only occur after a certain amount of time
int timeElapsed = -1;

//images for the victory screen, the tank on the victory screen,
//and the defeat screen
PImage victoryScreen;
PImage victoryTank;
PImage defeatScreen;

//the gif used for fire
Gif fire;

//This loop is ran once at the starting of the program
void setup() {
  //Sets the size of the canvas
  size(600, 600);
  
  //frameRate(60);
  powerups = new ArrayList<Powerup>();//Constructs list of powerups
  missileExplosion = new Gif(this, "missileExplosion.gif");//Construct GIF
  //missileExplosion.resize(20, 20);
  
  //Construct Sounds
  explosion = m.loadFile("explosion.mp3");
  launch =  m.loadFile("missileLaunch.mp3");
  
  
  battle = m.loadFile("battle.mp3");
  title = m.loadFile("title.mp3");
  victory = m.loadFile("victory.mp3");
  
  defeat = m.loadFile("defeat.mp3");
  
  //Load Images
  titleTank = loadImage ("titleTank.png");
  titleMissile = loadImage ("missile.png");
  titleMissile.resize(round (titleMissile.width*0.25), round (titleMissile.height*0.25));

   //these loads the images and resizes them
  victoryScreen = loadImage("victoryScreen.jpg");
  victoryScreen.resize(int(1280*.75), int(780*.75) );
  
  victoryTank = loadImage("victoryTank.png");
  victoryTank.resize(int(2534*.1), int(1477*.1) ); 
  
  defeatScreen = loadImage("defeatScreen.jpg");
  defeatScreen.resize(int(1280*.75), int(780*.75) );
  
  //this loads the fire gif and loops it
  fire = new Gif(this, "fire.gif");
  fire.loop();


  bricks = new ArrayList<Brick>();//construct brick list
  //Construct Player Components
  playerTank = new Tank(initialLocation, tankSize, true);
  playerBarrel = new Barrel(playerTank.currentPosition(), mouseX, mouseY, true);
  //Construct Enemy Components
  PVector enemyTankPos = new PVector (width-initialLocation.x, 550);
  enemyTank = new Tank(enemyTankPos, tankSize, false);
  enemyBarrel = new Barrel(enemyTank.currentPosition(), mouseX, mouseY, false);
  
  //Load Images of wall
  for (int i = 0; i < brickImages.length; i++) {
    brickImages[i] = loadImage ("Wall"+i+".jpg");
  }
  
  
  //Create indestructable part of wall, and add it to the array list
  for (int i = 1; i <= 3; i++) {
    bricks.add(new Brick(40, height-(40 * i) ) );
  }

  if (runInit) {
    //Construct Server
    s = new Server(this, 1245);
  }
  
  //Loop music
  title.loop();

}


//this is called whenever the game state is "battle" and the mouse is being pressed
void missileCharge() {
  //this draws the gauge
  fill(255);
  rect(100, 100, 400, 20);
  //changes colour and size according to the missile velocity
  fill(missileVel*6.375f, 255-missileVel*5, 0);
  rect(100, 100, missileVel*10, 20);
  fill(255);
  //these if statements prevent the velocity from being lower than zero or higher
  //than 40
  if (missileVel <= 0) {
    velIncrease = true;
  } else if (missileVel >= 40) {
    velIncrease = false;
  }
  //increases or decreases velocity depending on velIncrease value
  if (velIncrease == true) {
    missileVel++;
  } else {
    missileVel--;
  }  
}

boolean runInit = true;

//This is called when ever the mouse is released
void mouseReleased() {
  //Change gamestate if on start screen
  if (gameState.equals("title") ) {
    gameState = "battle";
    //if mouse pressed in game
  } else if (gameState.equals("battle")){
    //construct a new missile when the mouse is released
    missiles.add(new Missile(playerTank.currentPosition(), playerBarrel.getDirection(), 
                              accel, missileVel, playerTank.missileStrength, true) );
    //set velocity
    missiles.get(missiles.size()-1).setVelocity();
    //Add to string that a new missile has been shot
    sendData = "1" + " " + missileVel;
    missileVel = 1;
    
    showMissiles.add(true);
    launch.rewind();
    launch.play();
  } else if (gameState.equals("victory") || gameState.equals("defeat")) {
      //if game state is "victory" or "defeat"
    //stops previous music
   
      victory.pause();
      victory.rewind();
      defeat.pause();
      defeat.rewind();
      //loops title music
      title.loop();
    
    //change game state to "title"
    gameState = "title";
    //these resets all the data to the default values for a new game
    playerTank.health = 20;
    enemyTank.health = 20;
    for (int i = 0; i < bricks.size(); i++) {
      bricks.remove(i);
    }
    startTime = -1;
    timeElapsed = -1;
    playerTank.missileStrength = 1;
    enemyTank.missileStrength = 1;
    
    runInit = false;
    setup();

    
  }
}


boolean enemyDisplay() {//Function takes data from server and makis it into the tank
  //Format of the way data is sent
  //input format: tankXPos enemyBarrel.x enemyBarrel.y missileShot(0 or 1) missileVel
  //              
  String input;//String to Raw hold input
  String data[];//semi raw Data array
  float refinedData[][] = new float [6][6];//Array stores refined values
  
  c = s.available();//Gets new bytes
  if (c!=null) {
    println("c is available");
    input = c.readString();//reads from server
    println("input: " + input);
    //if (input.contains("PI") ) {
    if (!input.contains("PI")) {//Breaks out of loop if input does not contain PI
      return false;
    }
    //Checks if the last digit of the input is valid
    if (input.charAt(input.length()-1) == 'I') {
      //input = width - playerTank.currentPosition().x + " " + mouseX + " " + mouseY + " " + "0" + " " + "20" + "\n\n";
      input = input.substring(0, input.indexOf("PI")); // Take data from start to PI
      data = split(input, '\n');//Splits data
      //Populates arrray of refined data
      for (int i = 0; i < data.length; i++) {
        refinedData[i] = PApplet.parseFloat(split(data[i], " ") );
      }
      //Checks if data is too short
      if (refinedData[0].length != 6) {
        println("data is too short: ");
        print(refinedData[0]);
        return false;
      }


      enemyTank.updatePosition(refinedData[0][0]);//Update enemy tank position
      enemyBarrel.updatePos(enemyTank.currentPosition(), refinedData[0][1], refinedData[0][2]);//Update enemy barrel position
      enemyBarrel.setDirection();
      if (refinedData[0][3] == 1) {//Makes a new missile if a new missile has been released
        enemyMissiles.add(new Missile(enemyTank.currentPosition(), enemyBarrel.getDirection(), 
                                accel, refinedData[0][4], (int)refinedData[0][5], false) );
        enemyMissiles.get(enemyMissiles.size()-1).setVelocity();
        
        showEnemyMissiles.add(true);
      }
      
     
      
      println("successful input");
      //enemyTank.display();
      //enemyBarrel.display();
      
    } else {
      //Breaks if input does not have PI
      println("pi not found");
      return false;
    }
    
  }
  
  return true;//If sucessful returns true;

}


void sendData() {//Function used to send data to sercer
  println("sending: " + (width - playerTank.currentPosition().x) + " " + (width - mouseX) + " " + mouseY + " " + sendData + "PI");
  s.write(width - playerTank.currentPosition().x + " " + (width - mouseX) + " " + mouseY + " " + sendData  + " "+ playerTank.missileStrength + "PI");
  sendData = "0 -1";//Reset missile string
}


//Function used to display all missiles
void missileDisplay(ArrayList<Missile> missiles, ArrayList<Gif> explosions, ArrayList<Boolean> showMissiles) {
  for (int i = 0; i < missiles.size(); i++) {
    //Checks if missile is hitting the ground
    if (missiles.get(i).getPos().y > height - 50) {
      if (showMissiles.get(i) == true) {
        explosions.add(new Gif(this, "missileExplosion.gif") );//Add explosion gif
        explosions.get(explosions.size() - 1).play();//Play thr newest explosion
        explosions.get(explosions.size() - 1).ignoreRepeat();
  
        //for sound
        explosion.rewind();
        explosion.play();//Playes the sound
        explosion.setVolume(0.8f);//Sets volume
  
        showMissiles.set(i, false);
      }
    }
  }

  //displays each missile
  for (int i = 0; i < missiles.size(); i++) {
    if (showMissiles.get(i) == true) {
      missiles.get(i).display();
      
      //hit detect for missile to tank
      if (missiles == this.missiles) {
        if (missiles.get(i).isColliding(enemyTank.currentPosition(), enemyTank.getSize() ) == true) {//Check hiy
          explosions.add(new Gif(this, "missileExplosion.gif") );//Add explosion 
          explosions.get(explosions.size() - 1).play();//Play explosion
          explosions.get(explosions.size() - 1).ignoreRepeat();
          
          //for sound
          explosion.rewind();
          explosion.setVolume(0.8f);//Set volume
          explosion.play();//Play sound
          
          showMissiles.set(i, false);//DO not show missilies anymore
          enemyTank.updateHealth(missiles.get(i).strength);//Remove health from tank
        } else {
          println("no collision");
        }
      } else {
        if (missiles.get(i).isColliding(playerTank.currentPosition(), playerTank.getSize() ) == true) {//Hitting player tank
          explosions.add(new Gif(this, "missileExplosion.gif") );//Add explosion
          explosions.get(explosions.size() - 1).play();//Play explosion
          explosions.get(explosions.size() - 1).ignoreRepeat();
          
          //for sound
          explosion.rewind();
          explosion.setVolume(0.8f);//Set volume
          explosion.play();//Play sound
          
          
          showMissiles.set(i, false);
          playerTank.updateHealth(missiles.get(i).strength);
        } else {
          println("no collision");
        }
      }
      
      //Hit detect missile to block
      for (int j = 0; j < bricks.size(); j++) {
        //Check hit with ever brick
        if (missiles.get(i).isColliding(bricks.get(j).currentPosition(), bricks.get(j).getSize() ) == true && showMissiles.get(i)) {
          explosions.add(new Gif(this, "missileExplosion.gif") );//Add gif to livbrary
          explosions.get(explosions.size() - 1).play();//Play gif
          explosions.get(explosions.size() - 1).ignoreRepeat();
          
          //for sound
          explosion.rewind();
          explosion.setVolume(0.8f);//Set volume
          explosion.play();//Play sound
          
          showMissiles.set(i, false);//Do not show missile anymore
          //Sets who hit the brick last, for determining the powerup
          if (missiles.get(i).fromPlayer){
            bricks.get(j).lastHit = 1;
          }
          else{
            bricks.get(j).lastHit = -1;
          }
          //Make bricks take damage
          bricks.get(j).updateHealth (missiles.get(i).strength);
          break;
        } else {
          println("no collision");
        }
      }
      
      //missile to missile Hit detect
      if (missiles == this.missiles) {
        for (int j = 0; j < enemyMissiles.size(); j++) {
          //Check hit
          if (missiles.get(i).isColliding(enemyMissiles.get(j).getPos(), missiles.get(i).getSize()) && showEnemyMissiles.get(j)) {
            explosions.add(new Gif(this, "missileExplosion.gif") );// Add explosion
            explosions.get(explosions.size() - 1).play();//Play explosion
            explosions.get(explosions.size() - 1).ignoreRepeat();
            
            //for sound
            explosion.rewind();
            explosion.setVolume(0.8);//SEt volume
            explosion.play();//Play sound
            
            
            showMissiles.set(i, false);//DO not show missile
            
            enemyMissileExplosions.add(new Gif(this, "missileExplosion.gif") );//Explode enemy
            enemyMissileExplosions.get(enemyMissileExplosions.size() - 1).play();//Play another explosion
            enemyMissileExplosions.get(enemyMissileExplosions.size() - 1).ignoreRepeat();
            showEnemyMissiles.set(j, false);
            
          
          }
          
        }
      }
      
      
    }
  }

  //Handles Explosions
  for (int i = 0; i < explosions.size(); i++) {
    
    if (explosions.get(i).currentFrame() != 0 || explosions.get(i).isPlaying() ) {//If explosion is playing
      image(explosions.get(i), missiles.get(i).getPos().x - 75, missiles.get(i).getPos().y-100);//Draw the image
    } else {
      //Remove everything
      explosions.remove(i);
      missiles.remove(i);
      showMissiles.remove(i);
    }
  }
}



//Takes care of all bricks
void showBricks() {
  
  fill (255,0,0);
  //If in the middle of the destroy bricks powerup, set health to 1
  if (destroyingBricks){
      for (Brick b: bricks){
      b.health = 1;//Setting health to 1 rather than destroying it to prevent conccurent modification error
    }
  }
  //If in the middle of the powerup and it is time to destroy the block
  if (destroyingBricks && cooldown <= 0){
    if (bricks.size()<=3){//Check if there is only 3 blocks, and stop ddoing the powerup
      destroyingBricks = false;
      return;
    }
    bricks.get(3).health--;//Subtract health from 1 to zero
    cooldown = 10;//Reset cooldown
  }
  else{
    cooldown--;//Decrement cooldown if it not time to destoy a block
  }
  //if (timer % 5000 >= 0 && (timer % 5000 <= 1000/frameRate) && (timer >= 5000) ) {
  //if (millis() % 5000 >= 0 && (millis() % 5000 <= 1000/frameRate) && (millis() >= 5000) ){
  if (millis()-timeElapsed >= 5000) {//Add a new block every 5 seconds
    //bricks.add(new Brick(40, bricks.get(bricks.size()-1).getYPos() - 40) );
    bricks.add(new Brick() );
    timeElapsed = millis();
  }
  for (int i = 0; i < bricks.size(); i++) {
    bricks.get(i).update();//Update position of all bricks
    bricks.get(i).display();//Display all bricks
  }
}

//Function used to display health bar
void displayHealth() {
  int playerHealth = playerTank.getHealth();//Get health
  int enemyHealth = enemyTank.getHealth();
  if (playerHealth <= 0) {//Change state if dead
    gameState = "defeat";
    battle.pause();
    battle.rewind();
    defeat.loop();
  }
  if (enemyHealth <= 0) {//Change state if dead
    gameState = "victory";
    battle.pause();
    battle.rewind();
    
    victory.loop();
  }
  
  //Actuually draw health bar
  textSize(20);
  fill(0);
  text("Player", 50, 50);
  fill(255);
  rect(110, 30, 100, 20);
  fill(255-playerHealth*10, playerHealth*12.75f, 0);
  rect(110, 30, 100*(playerHealth/20.f), 20);
  //Actuually draw health bar
  fill(0);
  text("Enemy", 380, 50);
  fill(255);
  rect(450, 30, 100, 20);
  fill(255-enemyHealth*10, enemyHealth*12.75f, 0);
  rect(450, 30, 100*(enemyHealth/20.f), 20);

  fill(255);
    
  textSize(15);
}

//Used to display time remaining
void displayTime() {
  textSize(20);
  fill(0);
  text("Time: " + ( (millis()-startTime) /1000), 250, 50);//Get actual time in game and display it
  fill(255);
  textSize(15);
}

//USed for title screen
void title() {
  background(50);
  fill(255);
  imageMode(CENTER);
  //Draw Misisle
  pushMatrix();
    translate (width/2, height*0.72);
    scale (-1,1);
    image (titleTank, 0, 0, titleTank.width*0.45, titleTank.height*0.45);
  popMatrix();
  //Draw Misisle
  pushMatrix();
    translate(70,400);
    rotate (radians (-45));
    image (titleMissile, 0,0);
  popMatrix();
   //Draw Misisle
  pushMatrix();
    translate(width-70,400);
    rotate (radians (225));
   //   tint (255,0,0);
     // titleMissile.BLUE_MASK = 255;
    image (titleMissile, 0,0);
  popMatrix();
  //Draw Misisle
  pushMatrix();
    translate(70,70);
    rotate (radians (45));
    image (titleMissile, 0,0);
  popMatrix();
  //Draw Misisle
  pushMatrix();
    translate(width-70,70);
    rotate (radians (135));
    image (titleMissile, 0,0);
  popMatrix();
  
  missileExplosion.play();//Play gif
  image (missileExplosion, 70,height*0.85);//Show Gif
  image (missileExplosion, width-70,height*0.85);//Shoe Gif
  //image (titleMissie, width/2,350);
  imageMode(CORNER);
  textSize(35);
  fill (229,51,2);//Change coloe
  text ("The Ultimate Tank Battle", width*0.175, height/2);//Put text to screen

  fill (205);
  rect (width*0.2, height * 6.5/8,width*0.6, 70, 15);//Draw text box
  textSize(33);
    fill (65,71,36);
  text("Click Anywhere to Play", width*0.2, 530);//Write text on text box
}

//Handles all powerups
void powerupDisplay(ArrayList<Powerup> list){
  //Goes through each powerup
  for (Powerup p: list){
    p.update(playerTank);//UPdates position
    p.show();//Shows it
    if (p.hittingTank(playerTank)){//Checks hit with player
      p.owner = playerTank;//Sets owner to be player
      p.giveAbility();//Gives player ability
    }
    //Does the same as above except for enemy
    if (p.hittingTank(enemyTank)){
      p.owner = playerTank;
      p.giveAbility();
    }
  }
  
}

void draw() {

  if (gameState.equals("title") ) {//If on title screen
    title();//Run title graphics

  } else if (gameState.equals("battle") ) {//If in game
    if (c!=null && startTime == -1) {
      //Stop previous music
      title.pause();
      title.rewind();
      battle.setVolume(0.1);
      battle.loop();
 
      //Start timers
      startTime = millis();
      timeElapsed = millis();
      
      for (int i = bricks.size()-1; i > 2; i--){
        bricks.remove(i);
      }
      
    }
    background(255);
    fill(200);
    rect(0, 500, 600, 100);
    fill(255);

    
    if (keyPressed) {
      playerTank.move();
    }
    
    if (mousePressed) {
      missileCharge();
    }
    
  
    missileDisplay(missiles, missileExplosions, showMissiles);//show player missiles
    playerTank.display();//Show player tank
    //updates tank and mouse position
    playerBarrel.updatePos(playerTank.currentPosition(), mouseX, mouseY);//Upfate Barrel position
    playerBarrel.display();    //Display barrel
    
    c = s.available();
    sendData();//Send data to enemy
  
    if (c!=null) {//If connected
      if (dataError == false) {//If no errors in previous frames
        if (enemyDisplay() == false) {//Get next frame and check if it was succesful
          dataError = true;//If it messed up skip the next frame
        }
      } else {//if not keep going
        dataError = false;
        println("skipped");
      }
      //println("data sent");
    } else {
      println("c unavailable");
      //textSize (20);
      fill (255,0,0);
      text ("Disconnected", width*0.1, height*0.15);
      fill (255);
      
    }
    
    enemyTank.display();//Display enemy tank
    enemyBarrel.display();//Display enemy barrel
    missileDisplay(enemyMissiles, enemyMissileExplosions, showEnemyMissiles);//Display enemy missiles
    
    

    powerupDisplay(powerups);//Display powerups
    showBricks();//Show bricks
    displayHealth();//Show health bars
    displayTime();//Show time


    fill(255);
    
  } else if (gameState.equals("victory") ) {
    //victory stuff
    gameState = "victory";
    victory();
    
  } else if (gameState.equals("defeat") ) {
    //defeat stuff
    gameState = "defeat";
    defeat();
  }
    
}


//this method is called when the game state is "victory"
void victory() {
  //displays the images
  imageMode(CENTER);
  image(victoryScreen, 300, 300);
  image(victoryTank, 290, 104);
  imageMode(CORNER);
  
  textSize(25);
  text("Click anywhere to play again", 112, 521);
  textSize(15);
  
}

//this method is called when the game state is "defeat"
void defeat() {
  //sets up black background
  background(0);
  //displays images and fire gif
  imageMode(CENTER);
  image(defeatScreen, 300, 350);
  image(victoryTank, 300, 150);
  image(fire, 300, -25);
  imageMode(CORNER);
  
  textSize(25);
  text("Click anywhere to play again", 112, 521);
  textSize(15);
  
  
}