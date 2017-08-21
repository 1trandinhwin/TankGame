/*
Winnie T.
Last Modified: June 15, 2017
This program uses networking to create a tank game between two users.
The tanks are controlled through key clicks and the shooting of the missiles
are controlled via mouse.
The bricks are gradually created to stand in between the two players, and
upon breaking of brick, it spawns a powerup to the player that did the last hit.

Changes from original:
- rightclick mouse to shoot teleporting missile; it has zero damage and if it
  hits an edge of the screen, it teleports player to it
- bricks come down from both sides

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
//boolean to control whether there is sound or not
boolean sound = true;
boolean bgm = true;
//boolean to control whether it is using networking or not
boolean network = true;

//creates tank object to represent player
Tank playerTank;
//creates barrel object to represent player
Barrel playerBarrel;
//creates missile object to represent player
Missile playerMissile;
//creates teleporting object to represent player
TeleportingMissile playerTeleportingMissile;

//creates tank object to represent opponent
Tank enemyTank;
//creates barrel object to represent opponent
Barrel enemyBarrel;


//variable to store the gif of the explosion of the missiles
Gif missileExplosion;
Gif teleExplosion;

//stores explosion of missile and launching of missile soundfiles
Minim minim = new Minim(this);
//SoundFile explosion;
//SoundFile launch;
AudioPlayer explosion;
AudioPlayer launch;

//stores background music for the program
AudioPlayer battle;
AudioPlayer title;
AudioPlayer victory;
AudioPlayer defeat;

//PVector storing the initial position of the player's tank
PVector initialLocation = new PVector (100, 550);
//stores the size of the tank
PVector tankSize = new PVector (60, 23);
//stores the velocity of the missile
float missileVel = 1;
float enemyMissileVel = 0;
//stores the acceleration of the missiles
PVector accel = new PVector (0, 1);

//controls whether the velocity should increase or not
boolean velIncrease = true;

//arrayLists of missile object and missile explosions for player
ArrayList<Missile> missiles = new ArrayList<Missile> ();
ArrayList<Gif> missileExplosions = new ArrayList<Gif>();
//this arrayList controls whether the missiles should be displayed or not
ArrayList<Boolean> showMissiles = new ArrayList<Boolean>();
ArrayList<TeleportingMissile> teleportingMissiles = new ArrayList<TeleportingMissile> ();

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
boolean fromTop;

//arrayList storing the different powerups
ArrayList<Powerup> powerups; 

//string that is being sent; first number represents whether a
//missile is being created or not (0 or 1), and the second number
//represents the initial velocity of the new missile
String sendData = "0 -1" ;
//creates client for networking
Client client;
//creates server
Server server;
//string to store IP
String IP = "192.168.1.12";
//boolean to store whether the receiving data is incorrect or not
boolean dataError = false;
//boolean to store whether to create a server or not
boolean runInit = true;

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
//Declare Images for Title Screen
PImage titleTank;
PImage titleMissile;

//the gif used for fire
Gif fire;

//this is called once at the start of the program
void setup() {
  bricks = new ArrayList<Brick>();
  
  //sets size of canvas to 600x600 pixels
  size(600, 600);
  //sets framerate of program to 60
  frameRate(60);
  
  //these loads the images and resizes them
  victoryScreen = loadImage("victoryScreen.jpg");
  victoryScreen.resize(int(1280*.75), int(780*.75) );
  
  victoryTank = loadImage("victoryTank.png");
  victoryTank.resize(int(2534*.1), int(1477*.1) ); 
  
  defeatScreen = loadImage("defeatScreen.jpg");
  defeatScreen.resize(int(1280*.75), int(780*.75) );
  titleTank = loadImage ("titleTank.png");
  titleMissile = loadImage ("missile.png");
  titleMissile.resize(round (titleMissile.width*0.25), round (titleMissile.height*0.25));
  //this loads the fire gif and loops it
  fire = new Gif(this, "fire.gif");
  fire.loop();
  
  //initializes the powerups arrayList
  powerups = new ArrayList<Powerup>();
  
  //loads the missile explosion gif
  missileExplosion = new Gif(this, "missileExplosion.gif");
  teleExplosion = new Gif(this, "teleMissileExplosion.gif");
  
  if (sound) {
    println("sound enabled");
    //these loads the various soundfiles  
    //explosion = new SoundFile(this, "explosion.mp3");
    explosion = minim.loadFile("explosion.mp3");
    launch = minim.loadFile("missileLaunch.mp3");
    battle = minim.loadFile("battle.mp3");
    title = minim.loadFile("title.mp3");
    victory = minim.loadFile("victory.mp3");
    defeat = minim.loadFile("defeat.mp3");
  } else {
    println("sound disabled");
  }
  
  //constructs the tank object for player
  playerTank = new Tank(initialLocation, tankSize, true);
  //constructs the barrel object for player
  playerBarrel = new Barrel(playerTank.currentPosition(), mouseX, mouseY, true);
  
  //creates the initial position of the enemy and constructs the objects as seen above
  PVector enemyTankPos = new PVector (width-initialLocation.x, 550);
  enemyTank = new Tank(enemyTankPos, tankSize, false);
  enemyBarrel = new Barrel(enemyTank.currentPosition(), mouseX, mouseY, false);
  
  //adds all invincible bricks into arraylist
  bricks.add(new Brick(40, 0, true) );
  bricks.add(new Brick(40, height-40, false) );
  bricks.add(new Brick(40, 40, true) );
  bricks.add(new Brick(40, height-80, false) );
  bricks.add(new Brick(40, 80, true) );
  fromTop = false;
  
  //loads all the brick images
  for (int i = 0; i < brickImages.length; i++) {    
    brickImages[i] = loadImage ("Wall"+i+".jpg");    
  }
  
  //sets up server
  if (network && runInit) {
    server = new Server(this, 1245);
  } else {
    println("network disabled");
  }
  
  //loops the title music
  if (sound) {
    title.loop();
  }
}

//this is called whenever the game state is "battle" and the mouse is being pressed
void missileCharge() {
  //this draws the gauge
  playerBarrel.display(true, missileVel);
  
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

//this is called whenever the mouse is released
void mouseReleased() {
  //if the current game state is "title"
  if (gameState.equals("title") ) {
    //switch game state to "battle"
    gameState = "battle";

  } else if (gameState.equals("battle") ) {    //if game state is "battle"
    //constructs a new missile object and adds to player missile's arrayList
    if (mouseButton == LEFT) {
      //adds a normal missile
      missiles.add(new Missile(playerTank.currentPosition(), playerBarrel.getDirection(), 
                               accel, missileVel, playerTank.missileStrength, true) );
      //send data to tell other user that a missile was created
      //"1" signifies a missile being sent, and is followed by the velocity of the missile
      sendData = "1" + " " + missileVel;

    } else if (mouseButton == RIGHT) {     
      //adds a teleporting missile
      missiles.add(new TeleportingMissile(playerTank.currentPosition(), playerBarrel.getDirection(), 
                               accel, missileVel, true) );
      //send data to tell other user that a missile was created
      //"2" signifies a teleporting missile being sent, and is followed by the velocity of the missile
      sendData = "2" + " " + missileVel;

    }  
    //gets the most recent missile and sets velocity of missile
    missiles.get(missiles.size()-1).setVelocity();
    
    //resets velocity of missile to 1
    missileVel = 1;
    
    //adds true into showMissiles arrayList
    showMissiles.add(true);
    //plays the missile launch sound once 
    if (sound) {
      launch.rewind();
      launch.play();
    }
  } else if (gameState.equals("victory") || gameState.equals("defeat") ) {
    //if game state is "victory" or "defeat"
    //stops previous music
    if (sound) {
      victory.pause();
      victory.rewind();
      defeat.pause();
      defeat.rewind();
      //loops title music
      title.loop();
    }
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
    //do not create another server
    runInit = false;
    setup();
  }
}


//this method is responsible for displaying/updating the enemy
//returns a true if the receiving data is correct
//returns a false if the receiving data is incorrect, such as missing data
boolean enemyDisplay() {
  //input stores the string that the other user sends
  //input format: tankXPos enemyBarrel.x enemyBarrel.y missileShot(0 or 1) missileVel missileStrength      
  //              tankYPos, orientation
  String input;
  //these arrays store the data in more organized ways
  String data[];
  float refinedData[][] = new float [6][6];
  
  //gets new bytes
  client = server.available();
  if (client != null) {
    println("c is available");
    //read the receiving data and store as input string
    input = client.readString();
    
    println("input: " + input);
    //if input does not contain "PI", it is missing data so return false
    if (input.contains("PI") == false) {
      return false;
    }
    //runs if the last character of the input is "I" from "PI"
    if (input.charAt(input.length()-1) == 'I') {
      //only reads the string up to "PI"
      input = input.substring(0, input.indexOf("PI"));
      //splits input on each new line
      data = split(input, '\n');
      //for each new line, splits on each space and converts to float
      for (int i = 0; i < data.length; i++) {
        refinedData[i] = float(split(data[i], " ") );
      }
      
      //checks length of arrays for missing info so return false if there is missing data
      if (refinedData[0].length != 6 || refinedData[1].length != 2) {
        println("data is too short: ");
        print(refinedData[0]);
        print(refinedData[1]);
        return false;
      }

      //updates the position of the enemy tank using the values received
      enemyTank.updatePosition(refinedData[0][0], refinedData[1][0]);
      enemyBarrel.updatePos(enemyTank.currentPosition(), refinedData[0][1], refinedData[0][2]);
      enemyBarrel.setDirection();
      //if the enemy created a missile, then create a missile object and add to enemy missiles arrayList
      //is the same process as adding a player missile but with different values
      if (refinedData[0][3] == 1 || refinedData[0][3] == 2) {
        if (refinedData[0][3] == 1) {
          //normal missile created
          enemyMissiles.add(new Missile(enemyTank.currentPosition(), enemyBarrel.getDirection(), 
                                  accel, refinedData[0][4], int(refinedData[0][5]), false) );
        } else {
          //teleporting missile created
          enemyMissiles.add(new TeleportingMissile(enemyTank.currentPosition(), enemyBarrel.getDirection(), 
                                  accel, refinedData[0][4], false) );
        }
        enemyMissiles.get(enemyMissiles.size()-1).setVelocity();
        showEnemyMissiles.add(true);
      }
      
      //uses enemy's orientation so that their tank rotates correctly
      if (refinedData[1][1] == 0) {
        enemyTank.orientation = Orientation.BOTTOM_EDGE;
      } else if (refinedData[1][1] == 1) {
        enemyTank.orientation = Orientation.RIGHT_EDGE;
      } else if (refinedData[1][1] == 2) {
        enemyTank.orientation = Orientation.TOP_EDGE;
      } else if (refinedData[1][1] == 3) {
        enemyTank.orientation = Orientation.LEFT_EDGE;
      }
      
      //stores the enemy's missile vel
      enemyMissileVel = int(refinedData[0][4]);

      println("successful input");
      
    } else {
      println("'I' not found");
      return false;
    }
    
  }
  //this runs if there is no errors in data
  return true;
}


//this is used for offline testing using data of player as enemy data; enemy mirrors player
boolean enemyDisplayTest() {
  //input stores the string that the other user sends
  //input format: tankXPos enemyBarrel.x enemyBarrel.y missileShot(0 or 1) missileVel missileStrength 
  //              tankYPos, orientation
  String input;
  //these arrays store the data in more organized ways
  String data[];
  float refinedData[][] = new float [6][6];

    int orientation = 0;
    if (playerTank.orientation == Orientation.BOTTOM_EDGE) {
      orientation = 0;
    } else if (playerTank.orientation == Orientation.LEFT_EDGE) {
      orientation = 1;
    } else if (playerTank.orientation == Orientation.TOP_EDGE) {
      orientation = 2;
    } else if (playerTank.orientation == Orientation.RIGHT_EDGE) {
      orientation = 3;
    }
    //uses the same data as the one being sent
    if (sendData.contains("1 ") || sendData.contains("2 ") ) {
    String [] sendDataRefined = sendData.split(" ");
    sendData = sendDataRefined[0];
    missileVel = float(sendDataRefined[1] );
    } else {
      sendData = "0";
    }
    input = (width - playerTank.currentPosition().x + " " + (width - mouseX) + " " + mouseY + " " + sendData + " " + missileVel + " " + playerTank.missileStrength + '\n' + 
                 playerTank.currentPosition().y + " " + orientation + "PI");
    if (sendData.equals("1") || sendData.equals("2") ) {
      missileVel = 0;
    }
    sendData = "0 -1";
    
    println("input: " + input);
    //if input does not contain "PI", it is missing data so return false
    if (input.contains("PI") == false) {
      return false;
    }
    //runs if the last character of the input is "I" from "PI"
    if (input.charAt(input.length()-1) == 'I') {
      //only reads the string up to "PI"
      input = input.substring(0, input.indexOf("PI"));
      //splits input on each new line
      data = split(input, '\n');
      //for each new line, splits on each space and converts to float
      for (int i = 0; i < data.length; i++) {
        refinedData[i] = float(split(data[i], " ") );
      }
      
      //if there is not 5 numbers, then there is missing data so return false
      if (refinedData[0].length != 6 || refinedData[1].length != 2) {
        println("data is too short: ");
        print(refinedData[0]);
        print(refinedData[1]);
        return false;
      }

      //updates the position of the enemy tank using the values received
      enemyTank.updatePosition(refinedData[0][0], refinedData[1][0]);
      enemyBarrel.updatePos(enemyTank.currentPosition(), refinedData[0][1], refinedData[0][2]);
      enemyBarrel.setDirection();
      //if the enemy created a missile, then create a missile object and add to enemy missiles arrayList
      //is the same process as adding a player missile but with different values
      if (refinedData[0][3] == 1 || refinedData[0][3] == 2) {
        if (refinedData[0][3] == 1) {
          enemyMissiles.add(new Missile(enemyTank.currentPosition(), enemyBarrel.getDirection(), 
                                  accel, refinedData[0][4], int(refinedData[0][5]), false) );
        } else {
          enemyMissiles.add(new TeleportingMissile(enemyTank.currentPosition(), enemyBarrel.getDirection(), 
                                  accel, refinedData[0][4], false) );
        }
        enemyMissiles.get(enemyMissiles.size()-1).setVelocity();
        showEnemyMissiles.add(true);
      }
      
      if (refinedData[1][1] == 0) {
        enemyTank.orientation = Orientation.BOTTOM_EDGE;
      } else if (refinedData[1][1] == 1) {
        enemyTank.orientation = Orientation.RIGHT_EDGE;
      } else if (refinedData[1][1] == 2) {
        enemyTank.orientation = Orientation.TOP_EDGE;
      } else if (refinedData[1][1] == 3) {
        enemyTank.orientation = Orientation.LEFT_EDGE;
      }
      
      enemyMissileVel = int(refinedData[0][5]);
      
      println("successful input");
      
    } else {
      println("'I' not found");
      return false;
    }
  //this runs if there is no errors in data
  return true;
}




//this method sends the player data to the other user
void sendData() {
  //stores orientation of player in int
  int orientation = 0;
  if (playerTank.orientation == Orientation.BOTTOM_EDGE) {
    orientation = 0;
  } else if (playerTank.orientation == Orientation.LEFT_EDGE) {
    orientation = 1;
  } else if (playerTank.orientation == Orientation.TOP_EDGE) {
    orientation = 2;
  } else if (playerTank.orientation == Orientation.RIGHT_EDGE) {
    orientation = 3;
  }
  if (sendData.contains("1 ") || sendData.contains("2 ") ) {
    //missile is shot
    //split two values inside sendData
    String [] sendDataRefined = sendData.split(" ");
    //first value is missile type
    sendData = sendDataRefined[0];
    //second value is missile velocity
    missileVel = float(sendDataRefined[1] );
  } else {
    //no missile is shot
    //takes away second value inside the variable
    sendData = "0";
  }
  println("sending: " + (width - playerTank.currentPosition().x) + " " + (width - mouseX) + " " + mouseY + " " + sendData + "PI");
  //sends the data
  server.write(width - playerTank.currentPosition().x + " " + (width - mouseX) + " " + mouseY + " " + sendData + " " + missileVel + " " + playerTank.missileStrength + '\n' + 
               playerTank.currentPosition().y + " " + orientation + "PI");
  if (sendData.equals("1") || sendData.equals("2") ) {
    //resets missile velocity after creating a missile
    missileVel = 0;
  }
  //resets to if the player does not send a missile
  sendData = "0 -1";
}

//this method displays the missiles of either the player or enemy
//parameters are as follows:
// - missiles: which missile arrayList to use, either the player or enemy
// - explosions: which explosion arrayList to use, either the player or enemy
// - showMissiles: which showMissiles arrayList to use, either the player or enemy
void missileDisplay(ArrayList<Missile> missiles, ArrayList<Gif> explosions, ArrayList<Boolean> showMissiles) {
  //runs for each missile
  for (int i = 0; i < missiles.size(); i++) {
    //if the position of the missile is past a certain distance from the top side of the screen
    if (missiles.get(i).getPos().y > height - 45) {
      //detonate the missile as it is supposed to hit the ground
      if (showMissiles.get(i) == true) {    //only runs if the missile has not already detonated
        //adds the explosion gif into the arrayList
        explosions.add(new Gif(this, "missileExplosion.gif") );
        //sets the gif to play and to ignore repeats
        explosions.get(explosions.size() - 1).play();
        explosions.get(explosions.size() - 1).ignoreRepeat();
        
        if (sound) {
          //for sound of the explosion
          explosion.rewind();
          explosion.setVolume(0.8);
          explosion.play();
        }
  
        //sets the display to false so that the missile no longer shows
        showMissiles.set(i, false);
      }
    }
  }

  //displays each missile
  for (int i = 0; i < missiles.size(); i++) {
    if (showMissiles.get(i) == true) {
      //only runs if the display is true
      //calls display method to display the missile
      missiles.get(i).display();
      
      //checks for missile to tank collision
      if (missiles.get(i).getClass() == Missile.class) {
        if (missiles == this.missiles) {
          //runs if the player's missiles are being checked
          if (missiles.get(i).isColliding(enemyTank.currentPosition(), enemyTank.getSize() ) == true) {
            //runs if there is a collision between a player missile and the enemy tank; determined by isColliding method
            //these are the same as above to detonate a missile
            explosions.add(new Gif(this, "missileExplosion.gif") );
            //missileExplosions.get(i).resize(200, 200);
            explosions.get(explosions.size() - 1).play();
            explosions.get(explosions.size() - 1).ignoreRepeat();
             
            if (sound) {
              //for sound
              explosion.rewind();
              explosion.setVolume(0.8);
              explosion.play();
            }
          
            showMissiles.set(i, false);
            
            //updates the heatlh of the enemy according to the strength of the missile
            enemyTank.updateHealth(missiles.get(i).strength);
          }
        } else {
          //this is the same process but with enemy missiles and the player's tank
          if (missiles.get(i).isColliding(playerTank.currentPosition(), playerTank.getSize() ) == true) {
            explosions.add(new Gif(this, "missileExplosion.gif") );
            explosions.get(explosions.size() - 1).play();
            explosions.get(explosions.size() - 1).ignoreRepeat();
             
            if (sound) {
              //for sound
              explosion.rewind();
              explosion.setVolume(0.8);
              explosion.play();
            }
            
            showMissiles.set(i, false);
            
            playerTank.updateHealth(missiles.get(i).strength);
          }
        }
      }
      
      //checks for missile to block hit collision
      for (int j = 0; j < bricks.size(); j++) {
        if (missiles.get(i).isColliding(bricks.get(j).currentPosition(), bricks.get(j).getSize() ) == true && showMissiles.get(i) ) {
          //runs if there is a collision; determined by calling the isColliding method
          //this is the same process as before to detonate the missile
          explosions.add(new Gif(this, "missileExplosion.gif") );

          explosions.get(explosions.size() - 1).play();
          explosions.get(explosions.size() - 1).ignoreRepeat();
           
          if (sound) {
            //for sound
            explosion.rewind();
            explosion.setVolume(0.8);
            explosion.play();
          }
        
          showMissiles.set(i, false);
          
          //checks who did the last hit to the block
          if (missiles.get(i).fromPlayer) {
            //if player did last hit
            bricks.get(j).lastHit = 1;    
          }    
          else {    
            //if enemy did last hit
            bricks.get(j).lastHit = -1;    
          }    
          //updates the health of the blocks according to the strength of the missiles
          bricks.get(j).updateHealth (missiles.get(i).strength);
          //this break prevents a missile from damaging multiple blocks at the same time
          break;
        }
      }
      
      //checks for missile to missile collision
      if (missiles == this.missiles) {
        //if the missile being compared is the player's missiles
        for (int j = 0; j < enemyMissiles.size(); j++) {
          //checks for collision between all enemy missiles
          if (missiles.get(i).isColliding(enemyMissiles.get(j).getPos(), missiles.get(i).getSize() ) && showEnemyMissiles.get(j) ) {
            //if there is a collision; determined by isColliding method
            //the missile is detonated the same way as above
            explosions.add(new Gif(this, "missileExplosion.gif") );
            
            explosions.get(explosions.size() - 1).play();
            explosions.get(explosions.size() - 1).ignoreRepeat();
             
            if (sound) {
              //for sound
              explosion.rewind();
              explosion.setVolume(0.8);
              explosion.play();
            }
          
            showMissiles.set(i, false);
            
            //also detonates the enemy's missile upon contact
            enemyMissileExplosions.add(new Gif(this, "missileExplosion.gif") );
            enemyMissileExplosions.get(enemyMissileExplosions.size() - 1).play();
            enemyMissileExplosions.get(enemyMissileExplosions.size() - 1).ignoreRepeat();
            showEnemyMissiles.set(j, false);
          }
        }
      }
        
      if (missiles.get(i).getClass() == TeleportingMissile.class) {
        //if the missile type is a teleporting missile
        //create the teleporting missile object
        TeleportingMissile teleMis = (TeleportingMissile)missiles.get(i);
        if (teleMis.isColliding() ) {
          //collides with a screen edge
          //missile is detonated but with a different gif
          explosions.add(new Gif(this, "teleMissileExplosion.gif") );
          explosions.get(explosions.size() - 1).play();
          explosions.get(explosions.size() - 1).ignoreRepeat();
          
          if (sound) {
            //for sound
            explosion.rewind();
            explosion.setVolume(0.8);
            explosion.play();
          }
          
          showMissiles.set(i, false);
          
        }        
      }
      
    }
  }

  //this plays all the explosion gifs of the detonating missiles
  for (int i = 0; i < explosions.size(); i++) {
    if (explosions.get(i).currentFrame() != 0 || explosions.get(i).isPlaying() ) {
      //only runs while the gif is not finished playing yet
      //image(explosions.get(i), missiles.get(i).getPos().x - 75, missiles.get(i).getPos().y-100);
      imageMode(CENTER);
      image(explosions.get(i), missiles.get(i).getPos().x, missiles.get(i).getPos().y);
      imageMode(CORNER);
    } else {
      //otherwise remove all missile components from its respective arrayLists
      explosions.remove(i);
      missiles.remove(i);
      showMissiles.remove(i);
    }
  }

}

//this method displays all the bricks
void showBricks() {
  if (destroyingBricks) {
    //if the powerup "destroy bricks" is active
    for (Brick b: bricks) {
      //sets all brick's health to 1
      b.health = 1;
    }
  }  
  //checks if it is in middle of destroying bricks
  if (destroyingBricks && cooldown <= 0){    
    if (bricks.size() <= 5){  
      //checks if there is less than or equal to five bricks
      destroyingBricks = false;    
      return;    
    }    
    //subtract health of highest destroyable brick
    bricks.get(5).health--;    
    //resets cooldown
    cooldown = 5;    
  }    
  else {    
    cooldown--;    
  }
  
  //if 5 seconds has passed since last new brick
  if (millis()-timeElapsed >= 5000 && bricks.size() < 15 ) {
    //adds a new brick and resets the timer
    bricks.add(new Brick(fromTop) );
    if (fromTop) {
      fromTop = false;
    } else {
      fromTop = true;
    }
    timeElapsed = millis();
  }
  
  //updates and displays each brick
  for (int i = 0; i < bricks.size(); i++) {
    bricks.get(i).update();
    bricks.get(i).display();
  }
}

//this method displays the health of the player and enemy
void displayHealth() {
  //stores the hp of each player in a new variable
  int playerHealth = playerTank.getHealth();
  int enemyHealth = enemyTank.getHealth();
  //if the player has zero or less health
  if (playerHealth <= 0) {
    //player loses
    //change game state to "defeat"
    gameState = "defeat";
    if (sound) {
      //stops battle music and loops defeat music
      battle.pause();
      battle.rewind();
      defeat.loop();
    }
  }
  //if enemy has zero or less health
  if (enemyHealth <= 0) {
    //player wins
    //change game state to "victory"
    gameState = "victory";
    if (sound) {
      //stops battle music and plays victory music
      battle.pause();
      battle.rewind();
      victory.loop();
    }
  }
  //this creates a rectangle for health and displays it accordingly
  textSize(20);
  fill(0);
  text("Player", 50, 50);
  fill(255);
  rect(110, 30, 100, 20);
  fill(255-playerHealth*10, playerHealth*12.75f, 0);
  rect(110, 30, 100*(playerHealth/20.f), 20);
  
  fill(0);
  text("Enemy", 380, 50);
  fill(255);
  rect(450, 30, 100, 20);
  fill(255-enemyHealth*10, enemyHealth*12.75f, 0);
  rect(450, 30, 100*(enemyHealth/20.f), 20);

  fill(255);
  textSize(15);
}

//this method displays the time since the battle started
void displayTime() {
  textSize(20);
  fill(0);
  text("Time: " + ( (millis()-startTime) /1000), 250, 50);
  fill(255);
  textSize(15);
}

//this method is called while the game state is "victory"
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
  image (missileExplosion, width-70,height*0.85);//Show Gif
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

//this method is called whenever a powerup appears
//parameter is list, which is an arrayList of powerups
void powerupDisplay(ArrayList<Powerup> list){    
  for (Powerup p: list){    
    //updates position of the powerup
    p.update(playerTank);    
    p.show();    
    if (p.hittingTank(playerTank)){  
      //hit collision between tank and powerups
      //sets owner and gives ability to owner
      p.owner = playerTank;    
      p.giveAbility();    
    }    
    if (p.hittingTank(enemyTank)){    
      //same as above but for enemy
      p.owner = playerTank;    
      p.giveAbility();    
    }    
  }    
      
}

//this method is called when the game state is "victory"
void victory() {
  //displays the images
  image(victoryScreen, 0, 0, width, height);
  imageMode(CENTER);
  //image(victoryScreen, 300, 300);
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

//this method is called periodically while the program runs
void draw() {
  if (gameState.equals("title") ) {
    //if game state is "title", call the title method
    title();
  } else if (gameState.equals("battle") ) {
    //if the game state is "battle"
    if (startTime == -1 && network == true && client != null) {
      //once the other user is connected, this runs
      if (sound) {
        //stops title music
        title.pause();
        title.rewind();
        if (bgm) {
          //loops battle music at lower volume
          battle.setVolume(0.1);
          battle.loop();
        }
      }
      //sets timers
      startTime = millis();
      timeElapsed = millis();
      for (int i = bricks.size()-1; i > 4; i--) {
        bricks.remove(i);
      }
    }
    
    //creates basic background
    background(255);
    fill(200);
    rect(0, 500, 600, 100);
    fill(255);
    
    //if key is pressed, call the move method from the tank class
    if (keyPressed) {
      playerTank.move();
    }
    
    //if the mouse if pressed, call the missileCharge method
    if (mousePressed) {
      missileCharge();
    }
    
    //calls the missileDisplay method to show the missiles
    missileDisplay(missiles, missileExplosions, showMissiles);
    
    //calls the showBricks method to display the bricks
    showBricks();
    
    //displays the player tank
    playerTank.display();
    //updates tank and barrel
    playerBarrel.updatePos(playerTank.currentPosition(), mouseX, mouseY);
    playerBarrel.display(false, 0);    //also updates direction
    
    //calls sendData method to send data to other user
    if (network) {
      client = server.available();
      sendData();
    }
    
    //if program is receiving data
    if (network == true && client != null) {
      if (dataError == false) {
        //if the previous input was not faulty
        if (enemyDisplay() == false) {
          //calls enemyDisplay method and if it returns false, make dataError true
          dataError = true;
        }
      } else {
        //previous data was faulty, so skip this input
        dataError = false;
        println("skipped");
      }
    } else {
      //no data is being received from the other user
      //println("c unavailable");
      fill (255,0,0);
      text ("Disconnected", width*0.1, height*0.15);
      fill (255);
    }
    
    //testing using offline data
    //enemyDisplayTest();
    
    //displays the enemy tank, barrel, and missiles
    missileDisplay(enemyMissiles, enemyMissileExplosions, showEnemyMissiles);
    enemyTank.display();
    enemyBarrel.display(true, enemyMissileVel);
    
    //display healths, time, and powerups
    displayHealth();
    displayTime();
    powerupDisplay(powerups);

    fill(255);
    
  } else if (gameState.equals("victory") ) {
    //if game state is "victory"
    //calls victory method
    victory();
  } else if (gameState.equals("defeat") ) {
    //if game state is "defeat"
    //calls defeat method
    defeat();
  }
}