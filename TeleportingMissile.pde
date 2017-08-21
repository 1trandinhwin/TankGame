//class for missiles that allow for movement


class TeleportingMissile extends Missile {
  //constructor for class
  //same as for Missile class but without missileStrength
  TeleportingMissile (PVector missileInitialPos, PVector missileDir, 
                      PVector missileAccel, float missileVel, boolean _fromPlayer) {
    //constructs parent class using above values
    super(missileInitialPos, missileDir, missileAccel, missileVel, 0, _fromPlayer);
  }
  
  //checks for collisions with screen edges
  //returns true if there is a collision, false otherwise
  boolean isColliding() {
    if (fromPlayer) {
      //player's missile
      if (position.y <= 0) {
        //top edge collision
        //sets player's tanks to the position where the missile detonated
        playerTank.position.x = position.x;
        playerTank.position.y = playerTank.getSize().y/2;
        //sets orientation of the tank for it to rotate on edges
        playerTank.orientation = Orientation.TOP_EDGE;
        return true;
      } else if (position.y >= height - 55) {
        //bottom edge collision
        playerTank.position.x = position.x;
        playerTank.position.y = height - 50;
        playerTank.orientation = Orientation.BOTTOM_EDGE;
        return true;
      } else if (position.x <= 0) {
        //left edge collision
        playerTank.position.y = position.y;
        playerTank.position.x = playerTank.getSize().y/2;
        playerTank.orientation = Orientation.LEFT_EDGE;
        return true;
      } else if (position.x >= width) {
        //right edge collision
        playerTank.position.y = position.y;
        playerTank.position.x = width - playerTank.getSize().y/2;
        playerTank.orientation = Orientation.RIGHT_EDGE;
        return true;
      }
    } else if (!fromPlayer) {
      //enemy missile
      //same process as above but with different variables
      if (position.y <= 0) {
        //top edge
        enemyTank.position.x = position.x;
        enemyTank.position.y = playerTank.getSize().y/2;
        enemyTank.orientation = Orientation.TOP_EDGE;
        return true;
      } else if (position.y >= height - 55) {
        //bottom edge
        enemyTank.position.x = position.x;
        enemyTank.position.y = height - 50;
        enemyTank.orientation = Orientation.BOTTOM_EDGE;
        return true;
      } else if (position.x <= 0) {
        //left edge
        enemyTank.position.y = position.y;
        enemyTank.position.x = playerTank.getSize().y/2;
        enemyTank.orientation = Orientation.LEFT_EDGE;
        return true;
      } else if (position.x >= width) {
        //right edge
        enemyTank.position.y = position.y;
        enemyTank.position.x = width - playerTank.getSize().y/2;
        enemyTank.orientation = Orientation.RIGHT_EDGE;
        return true;
      }
    }
    //if it reaches here, then there is no collision
    return false;
  }
  
  
  
}