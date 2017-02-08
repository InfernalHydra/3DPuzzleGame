import processing.core.PApplet;
import processing.core.PVector;
import queasycam.QueasyCam;
import shapes3d.Box;
import shapes3d.Shape3D;


  QueasyCam cam;

  Box[] b = new Box[9];
  int[][] pos = { { 100, 100, 0 }, { 100, 100, -75 }, { 100, 100, 75 }};
  int[][] assign = { { 0, color(255, 115, 230) }, { 1, color(0, 115, 230) }, { 2, color(102, 255, 102) } };
  int[][] selected = { { -1, -1, -1 }, { -1, -1, -1 } };
  int[] indexes = { 0, 0 };
  int[] colors = {color(255, 115, 230),color(0, 115, 230),color(102, 255, 102)};
  int index = -1;
  int availible;

  PVector vec;
  Shape3D picked;

  String gameState;

  public void setup() {
    size(1920, 1080, P3D);
    noCursor();

    cam = new QueasyCam(this);
    cam.speed = 5; // default is 3
    cam.sensitivity = 0.5f; // default is 2
    // mono = createFont("vgafix", 32);
    // textFont(mono);
    for (int i = 0; i < assign.length; i++) {
      b[i] = new Box(this, 50, 50, 50);
      b[i].moveTo(pos[i][0], pos[i][1], pos[i][2]);
      b[i].fill(assign[i][1]);
      b[i].drawMode(Shape3D.SOLID | Shape3D.WIRE);
    }
  }

  public void draw() {
    background(0);
    text("Alpha v0.1", 10, 30, -150);
    pushMatrix();
    vec = cam.getForward();
    cursor(CROSS);
    picked = Shape3D.pickShape(this, width / 2, height / 2);
    for (int x = 0; x < assign.length; x++) {
      b[x].moveTo(pos[x][0], pos[x][1], pos[x][2]);
      b[x].draw();
    }
    popMatrix();
    if (selected[0][0] >= 0 && selected[1][0] >= 0) {
      int[] foo = { selected[0][0], selected[0][1], selected[0][2] };
      for (int x = 0; x < pos.length; x++) {
        pos[indexes[0]][x] = pos[indexes[1]][x];
      }
      for (int x = 0; x < pos.length; x++) {
        pos[indexes[1]][x] = foo[x];
      }
      indexes[0] = -1;
      indexes[1] = -1;
      for (int f = 0; f < selected.length; f++) {
        for (int z = 0; z < selected[f].length; z++) {
          selected[f][z] = -1;
        }
      }
    }
  }

  public void mouseClicked() {
    if (selected[0][0] <= 0)
      availible = 0;
    else if (selected[1][0] <= 0)
      availible = 1;
    for(int i = 0; i < b.length; i++) {
      if(picked == b[i]) {
        if(mouseButton == LEFT) {
          if(i >= 2) {
            b[i].fill(colors[2]);
          }
          index = i;
        }
        else if(mouseButton == RIGHT) {
          if(i >= 1) {
            b[i].fill(colors[1]);
          }
        }
      }
    }
    /*
    if (picked == b[0]) {
      if (mouseButton == LEFT) {
        // b[0].fill(color(102, 255, 102));
        index = 0;
      } else if (mouseButton == RIGHT) {
        // b[0].fill(color(0, 115, 230));
      }
    } else if (picked == b[1]) {
      if (mouseButton == LEFT) {
        // b[1].fill(color(102, 255, 102));
        index = 1;
      } else if (mouseButton == RIGHT) {
        b[1].fill(color(0, 115, 230));
      }
    } else if (picked == b[2]) {
      if (mouseButton == LEFT) {
        b[2].fill(color(102, 255, 102));
        index = 2;
      } else if (mouseButton == RIGHT) {
        b[2].fill(color(0, 115, 230));
      }
    }
    */
    if (index >= 0) {
      for (int i = 0; i < pos.length; i++) {
        selected[availible][i] = pos[index][i];
      }
      indexes[availible] = index;
    }

  }

  public void settings() {
    fullScreen(P3D);
  }