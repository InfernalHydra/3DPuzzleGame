import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

import processing.core.PApplet;
import processing.core.PVector;
import shapes3d.Box;
import shapes3d.Shape3D;

final int STARTMENU = 0;
final int GAME = 1;
final int PAUSE = 2;

PeasyCam cam;
//Initial Position
int aX = 100;
int aY = 100;
int aZ = -75;
//Change in position per box
int dX = 75;
int dY = 75;
int dZ = 75;
int size = 5;
myBox[] puzzle = new myBox[(int) Math.pow(size, 3)];
//Menu positions
int bX = 100;
int bY = 100;
int bZ = -75;
myBox[] startMenu = new myBox[2];

int[][] selected = { { -1, -1, -1 }, { -1, -1, -1 } };
int[] indexes = { 0, 0 };
int[] colors = {color(255, 115, 230, 255), color(0, 115, 230, 255), color(102, 255, 102, 255)};
int[] colorsTrans = {color(255, 115, 230, 122), color(0, 115, 230, 122), color(102, 255, 102, 122)};
color pickedColor;
int index = -1;
int available;
int appState = 0; //determines whether we are in game menu, start menu, pause
boolean gameInitNotOccured = true; //returns true if game has not been initialized (game screen), set to false when game state runs

Shape3D picked;

//PImage goIntoGame;  //to be implemented later

public void setup() {
  size(1920, 1080, P3D);
  //initialize texture for menu box
  //goIntoGame = loadImage("startgame.png"); //to be implemented later
  //Camera stuff
  noCursor();
  cam = new PeasyCam(this, 250, 250, 450, 100);
  cam.setSuppressRollRotationMode();
  
  //initialize start menu, first object is the single box
  startMenu[0] = new myBox(new Box(this, 150, 150, 150), aX, aY, aZ, colors[0], 0, Shape3D.SOLID | Shape3D.WIRE);
  //temporary, create single box in front of menu box, can be selected (very front of the menu box)
  //will eventually change to possibly add new selection menus on side of box
  startMenu[1] = new myBox(new Box(this, 150, 150, 1), aX, aY, aZ+100, colors[0], 0, 0);
  //startMenu[0].getBox().setTexture(goIntoGame, Box.FRONT);  //to be implemented later
}

public void draw() {
  if (appState == STARTMENU) {
    menuScreen();
  }
  if (appState == GAME) {
    if (gameInitNotOccured == true) {
      gameInit();
      gameInitNotOccured = false;
    }
    playGame();
  }
}

public void settings() {
  fullScreen(P3D);
}

public void menuScreen() {
  background(0);
  //Picker
  picked = Shape3D.pickShape(this, width / 2, height / 2);
  //Draw boxes
  pushMatrix();
  render2();
  popMatrix();
  GUI();
}

public void gameInit() {
  //Make boxes in a cube pattern given as given size
  int index = 0;
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      for (int k = 0; k < size; k++) {
        int colorID = (int) (Math.random() * colors.length);
        puzzle[index] = new myBox(new Box(this, 50, 50, 50), aX, aY, aZ, colors[colorID], colorID, Shape3D.SOLID | Shape3D.WIRE);
        index++;
        aZ+=dZ;
      }
      aY+=dY;
      aZ = -75;
    }
    aX+=dX;
    aY = 100;
  }
}

public void playGame() {
  background(0);
  //Picker
  picked = Shape3D.pickShape(this, width / 2, height / 2);
  //Draw boxes
  pushMatrix();
  render();
  popMatrix();
  
  if (selected[0][0] >= 0 && selected[1][0] >= 0) {
    puzzle[indexes[0]].setColor(colors[puzzle[indexes[0]].getColorID()]);
    puzzle[indexes[1]].setColor(colors[puzzle[indexes[1]].getColorID()]);
    int[] foo = { selected[0][0], selected[0][1], selected[0][2] };
    puzzle[indexes[0]].setCoords(puzzle[indexes[1]].getX(), puzzle[indexes[1]].getY(), puzzle[indexes[1]].getZ());
    puzzle[indexes[1]].setCoords(foo[0], foo[1], foo[2]);
    indexes[0] = -1;
    indexes[1] = -1;
    for (int f = 0; f < selected.length; f++) {
      for (int z = 0; z < selected[f].length; z++) {
        selected[f][z] = -1;
      }
    }
    index = -1;
  }
  GUI();
}

public void GUI() {
  cam.beginHUD();
  rect(width/2,height/2,50,50);
  cam.endHUD();
}

public void mouseClicked() {
  if (appState == GAME) {
    if (selected[0][0] <= 0)
      available = 0;
    else if (selected[1][0] <= 0)
      available = 1;

    for (int i = 0; i < puzzle.length; i++) {
      if (picked == puzzle[i].getBox()) {
        if (mouseButton == LEFT) {
          index = i;
        } 
      }

      if (index >= 0) {
        selected[available] = puzzle[index].getCoords();
        indexes[available] = index;
        puzzle[index].setColor(colorsTrans[puzzle[index].getColorID()]);
      }
      
      if (mouseButton == RIGHT && index >= 0) {
        selected[0] = selected[1];
        indexes[0] = 0;
        puzzle[index].setColor(colors[puzzle[index].getColorID()]);
      }
    }
  }
  if (appState == STARTMENU) {
    if (picked == startMenu[1].getBox()) {
      if (mouseButton == LEFT) {
        appState = 1;
      }
    }
  }
}

public void render() {
  for (int i = 0; i < puzzle.length; i++) {
    puzzle[i].getBox().moveTo(puzzle[i].getX(), puzzle[i].getY(), puzzle[i].getZ());
    puzzle[i].getBox().fill(puzzle[i].getColor());
    puzzle[i].getBox().drawMode(puzzle[i].getDrawMode());
    puzzle[i].getBox().draw();
  }
}

public void render2() {
  for (int i = 0; i < startMenu.length; i++) {
    startMenu[i].getBox().moveTo(startMenu[i].getX(), startMenu[i].getY(), startMenu[i].getZ());
    startMenu[i].getBox().fill(startMenu[i].getColor());
    startMenu[i].getBox().drawMode(startMenu[i].getDrawMode());
    startMenu[i].getBox().draw();
  }
}

class myBox {
  private Box b;
  private int x, y, z, drawMode, colorID;
  private color c;

  public myBox(Box b, int x, int y, int z, color c, int colorID, int drawMode) {
    this.b = b;
    this.x = x;
    this.y = y;
    this.z = z;
    this.c = c;
    this.colorID = colorID;
    this.drawMode = drawMode;
  }
  public Box getBox() {
    return b;
  }
  public int getX() {
    return x;
  }
  public int getY() {
    return y;
  }
  public int getZ() {
    return z;
  }
  public color getColor() {
    return c;
  }
  public int getColorID() {
    return colorID;
  }
  public int[] getCoords() {
    int[] coords = {x, y, z};
    return coords;
  }
  public int getDrawMode() {
    return drawMode;
  }
  public void setCoords(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  public void setColor(color c) {
    this.c = c;
  }
  
  public void setDrawMode(int drawMode) {
    this.drawMode = drawMode;
  }
}