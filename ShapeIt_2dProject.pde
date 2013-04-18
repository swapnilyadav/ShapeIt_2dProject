import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.*;
import java.util.Set;
import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;
import javax.swing.JOptionPane;
import javax.swing.*;
import java.awt.event.*;

// Variable to keep track of the current level
String level = "level1";

// Flag to check whether player has made the correct image or not
// Flag value "false" means the image made by player does not match the goal image
boolean incorrect_img = false;

int shapetype=0;

int color_pal_x = 620, color_pal_y = 395;
int compare_x = 280, compare_y = 250;
int draw_here_x = 100, draw_here_y = 295;

// Variable to keep track of mouse offset when it is clicked inside a Shape
float xOffset, yOffset;

// Declaring a new concurrent HashMap
//This is the data structure used to store all the primitive datatypes that are spawned on to the screen
ConcurrentMap shapeList = new ConcurrentHashMap();
Set st = shapeList.entrySet();

//This sets up the color for the color palatte
Palette p = new Palette(this);

//Count to determin the keyvalues for the basic images to be stored
int Count=1;

//Constants to be used for creation of the scale button
int scaleButtonX = 620;
int scaleButtonY = 300;
int scaleButtonwidth = 60;
int scaleButtonheight = 20;
int scaleTextX = 650;
int scaleTextY = 310;

//Constants to be used for creation of the rotate button
int rotateButtonX = 700;
int rotateButtonY = 300;
int rotateButtonwidth = 60;
int rotateButtonheight = 20;
int rotateTextX = 750;
int rotateTextY = 310;

int milli=0;
int minutes = 0;
int seconds = 0;
int hours = 0;
int factor = 1000;
int optionsChecked=0;

//Variables used to create the particle system.
ParticleSystem ps, ps1;
Particle p1, p2;

// This flag turns true if compare button is hit to keep track of the sine wave display
boolean compareFlag = false;

// Timer variables
int savedTime, passedTime;


//Constants for sine wave

// Space between consecutive horizontal locations
int xspacing = 15;   

// Total width of the wave
int wave_width;

// Starting angle
float angle_theta = 0.0;

// Maximum height of the wave
float wave_height = 50.0;

// Difference of pixels after which the new wave starts
float period = 250.0;

// Variable for incrementing x
float delta_x;

// Array to store height at different y locations in the wave
float[] amplitude;


void setup()
{
  size(800, 800);
  drawToolbox();
  drawDrawingArea();

  // The following lines a rectangle, circle and an ellipse respectively to the toolbox area
  shapeList.put(Count++, new Shape(620, 20, 50, 50, false, "rectangle", 0, #FFFFFF));
  shapeList.put(Count++, new Shape(750, 50, 75, 75, false, "circle", 0, #FFFFFF));
  shapeList.put(Count++, new Shape(650, 130, 75, 50, false, "ellipse", 0, #FFFFFF));

  // The following code adds the color palette to the toolbox
  setUpColors();

  ps = new ParticleSystem (new PVector(0, 800), "rectangle");
  ps1 = new ParticleSystem(new PVector(800, 0), "ellipse");
  
  //Initialising the sine wave 
  wave_width = width+16;
  delta_x = (TWO_PI / period) * xspacing;
  amplitude = new float[wave_width/xspacing];
}

//This funtions sets up the colors to be be added to the color palette
void setUpColors()
{
  p.addColor(color(255, 106, 0));
  p.addColor(color(71, 69, 80));
  p.addColor(color(164, 223, 36));
  p.addColor(color(19, 34, 41));
  p.addColor(color(95, 133, 117));
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Functions for rendering
//////////////////////////////////////////////////////////////////////////////////////////////////
//The draw function checks which option is selected and based on the
//option selected loads the particular area.

void draw()
{

  switch(optionsChecked)
  {
  case 1: 
    if (compareFlag)
    {
      passedTime = millis() - savedTime;    
      if (passedTime < 2000)
      {
        color_pal_x = 620;
        compare_x = 280;
        draw_here_x = 100;
        drawSineWave();
        
      }
      else
      {
        color_pal_x += 47;
        draw_here_x += 35;
        compare_x += 25;
        savedTime = millis();
        compareFlag = false;
      }
    }
    else
    {
      savedTime = millis();
      loadGamearea();
    }
    break;
  case 2: 
    loadInstructionspage();
    break;
  case 3: 
    background(0);
    ps.addParticle();
    ps.run();
    ps1.addParticle();
    ps1.run();
    fill(255);
    textSize(32);
    text("Game Finished", 300, 400);
    break;
  default: 
    loadArea();
    break;
  }
}

// Function displays a moving sine wave when the two images are matched
void drawSineWave()
{
  background(0);
  color red = color(255, 0, 0);
  fill(red);
  textSize(32);
  textAlign(CENTER);
  text("Comparing", 200, 50);

  measureSineWave();
  trackSineWave();
}

// Function measures the height at various points over the sine wave
void measureSineWave() 
{
  angle_theta += 0.020;

  // Corresponding each x, gets its respective y using sine function
  float x = angle_theta;
  for (int i = 0; i < amplitude.length; i++) 
  {
    amplitude[i] = sin(x)*wave_height;
    x+=delta_x;
  }
}

// Function displays small ellipses as a point over the sine wave
void trackSineWave() 
{
  color blue = color(0, 0, 255);
  fill(blue);

  // Draw ellipses to represent the wave
  for (int x = 0; x < amplitude.length; x++) {
    ellipse(x*xspacing, height/2+amplitude[x], 16, 16);
  }
}

//When optionselected = 1 it loads the main game area with tool box and all buttons
void loadGamearea()
{

  background(255);
  fill(255);
  stroke(0);
  drawToolbox();
  drawDrawingArea();
  drawGoalImage();
  calculateTime();

  //To change the default cursor to arrow
  cursor(ARROW);

  Iterator it = st.iterator();
  //This iterates through all objects in hash map
  while (it.hasNext ()) 
  {
    Map.Entry me = (Map.Entry)it.next();
    Shape shpObj = (Shape)me.getValue();
    int keyValue = (Integer)me.getKey();
    //code to get the type of shape
    shapetype = shpObj.checkShape(shpObj.type);
    //This if displays only the rectangle which are selected
    if (shpObj.locked) 
    {
      //condition to check the shape and display the shape accordingly
      switch(shapetype) 
      {
      case 1: 
        fill(shpObj.c);
        stroke(153);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        rect(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      case 2: 
        fill(shpObj.c);
        stroke(153);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        ellipse(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      case 3: 
        fill(shpObj.c);
        stroke(153);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        ellipse(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      default : 
        break;
      }
    }

    //This displays the rectangle which are not selected
    else 
    {
      //condition to check the shape and display the shape accordingly
      switch(shapetype) 
      {
      case 1: 
        fill(shpObj.c);
        stroke(0);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        rect(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      case 2: 
        fill(shpObj.c);
        stroke(0);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        ellipse(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      case 3: 
        fill(shpObj.c);
        stroke(0);
        translate(shpObj.xCoordinate, shpObj.yCoordinate);
        rotate(radians(shpObj.rotation_angle));
        ellipse(0, 0, shpObj.wide, shpObj.tall);
        resetMatrix();
        break;
      default : 
        break;
      }
    }
  }
}

//When option=2 is selected it loads the instructions page.
void loadInstructionspage()
{
  
      background(255);
      textSize(18);
      fill(0);
      text("The game window consists of 3 sections namely the toolbox(right hand side section),\n"+ 
      "goal image (upper left section) and the drawing area(lower left section). \n\n" +
      "The toolbox consists of various shapes like circle, ellipse and rectangle.\n"+ 
      "Using these shapes the player has to create an image in drawing area which looks similar\n"+
      "to the gaol image."+
      "In this process player might need to perform certain operations \n"+
      "like scaling and rotation.These operations can be performed using two buttons \n"+
      "'S' and 'R' which perform scaling and rotation respectively.\n"+
      "Each click on 'S' button increases the size of the shape from all sides.\n"+ 
      "Each click on 'R' button rotates the shape in clockwise direction.\n"+
      "On pressing d or D the player can delete the selected object and also on.\n"+
      "pressing ESC key the player can exit the game at any time.\n"+
      "It also consists of a color palette to fill in color in the drawn shapes.\n"+
      "\n\nThe drawing area provided is of size 400 X 400 pixels. Above the drawing area \n"+
      "there is 'COMPARE' button. At any stage the similarity of the two images can be \n"+
      "checked by clicking this button. If succes then the player proceeds to the next level.\n"+
      "This game consists of 3 levels.\n In each level the player has to create the image in\n"+ 
      "the drawing area similar to goal image, only the level of difficulty increases.\n\n"+
      "In order to proceed from one level to another following conditions must be fulfilled:\n"+
      "1. The image in drawing area must be exactly same as the goal image w.r.t color \n and shapes.\n" +
      "2. The image in the drawing area should cover the entire drawing area\n"+
      "(i.e. image formed will be of size 400 X 400).\n", 10,60);
      fill(160);
      textSize(32);
      text("GO BACK",10,20);
}

//This is the page that is loaded at the first time. it also, implements the particle system.
void loadArea()
{
  background(0);
  
  // runs the particle system consisting of rectangles
  ps.addParticle();
  ps.run();
  
  // runs the particle system consisting of ellipses
  ps1.addParticle();
  ps1.run();
  
  fill(255);
  textSize(32);
  text("PLAY", 300, 400);
  //rect(300,420,230,30);
  text("INSTRUCTIONS", 300, 450);
  
  // Displays 'SHAPE-IT' at a certain angle
  textSize(120);
  translate(100, 500);
  rotate(radians(-45));
  text("SHAPE-IT", 0, 0);
}

//Code to draw the tool box area.
void drawToolbox()
{
  //fill the color for the tool options to white
  fill(255);
  //This creates the tool box area of 200 X 800
  rect(600, 0, 200, 800, 7);
  //This creates a rectangle as a button on the tool box.
  rect(620, 20, 50, 50);
  //This creates a circle as a button on the tool box.
  ellipse(750, 50, 75, 75);
  //This creates the button for scale
  rect(scaleButtonX, scaleButtonY, scaleButtonwidth, scaleButtonheight);
  fill(0);
  text("S", scaleTextX, scaleTextY);
  //this creates the button for rotation
  fill(255);
  rect(rotateButtonX, rotateButtonY, rotateButtonwidth, rotateButtonheight);
  // textFont(f,16);
  fill(0);
  text("R", rotateTextX, rotateTextY);
  // Creates the color palette
  text("COLOR PALETTE", color_pal_x, color_pal_y); 
  for (int i = 0, j = 620; i < p.totalSwatches(); i++, j = j + 35) 
  {
    fill(p.getColor(i));
    rect(j, 400, 35, 30);
  }
  //This creates the button to spawn a ellipse
  fill(255);
  ellipse(650, 130, 75, 50);
}


// Draws the area in which the player has to draw his image
void drawDrawingArea() 
{
  fill(0);
  text("DRAW HERE", draw_here_x, draw_here_y);
  fill(255);
  rect(100, 300, 400, 400);
  
  fill(255);
  rect(260,230,100,30);
  fill(255,0,0);
  text("COMPARE", compare_x, compare_y);
}

// Draws the goal image based on the level
void drawGoalImage()
{
  if (this.incorrect_img)
  {
    text("INCORRECT PLEASE TRY AGAIN!!", 200, 270);
  }

  if (level == "level1")
  {
    color white = color(255, 255, 255);
    fill(white);
    rect(225, 50, 150, 150);

    fill(color(164, 223, 36));
    rect(225, 50, 150, 150);

    fill(color(white));
    triangle(225, 50, 225, 125, 300, 50);

    fill(color(white));
    triangle(225, 125, 225, 200, 300, 200);

    fill(color(white));
    triangle(300, 200, 375, 200, 375, 125);

    fill(color(white));
    triangle(375, 125, 375, 50, 300, 50);
  }

  if (level == "level2")
  {
    color white = color(255, 255, 255);
    fill(white);
    rect(225, 50, 150, 150);
    
    fill(color(255, 106, 0));
    rect(225, 50, 75, 75);
    
    fill(color(164, 223, 36));
    ellipse(337.5, 87.5, 75, 75);
    
    fill(color(164, 223, 36));
    ellipse(262.5, 162.5, 75, 75);
    
    fill(color(255, 106, 0));
    rect(300, 125, 75, 75);
  }
  
  if (level == "level3")
  {
    color white = color(255, 255, 255);
    fill(white);
    rect(225, 50, 150, 150);
    
    fill(color(255, 106, 0));
    rect(225, 50, 75, 75);
    
    fill(color(164, 223, 36));
    ellipse(262.5, 162.5, 75, 75);
    
    fill(color(19, 34, 41));
    ellipse(337.5, 125, 75, 150);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Mouse Event Handlers
///////////////////////////////////////////////////////////////////////////////////////////////////////

// EventHandler to Mouse Button Down Events
void mousePressed()
{
  if (mouseButton==LEFT)
  {
    //This condition, checks if the "GO BACK" button is selected in the instructions area.
    if(mouseX>=10 && mouseY<=135 && mouseY>=0 && mouseY<=20 & optionsChecked==2)
    {
      optionsChecked=4;
    }
    //This condition, checks if the "PLAy" button is selected in the instructions area.
    if (mouseX>=275 && mouseX<=375 && mouseY>=325 && mouseY<=425 && optionsChecked!=1)
    {
      if (optionsChecked==2)
      {
        optionsChecked = optionsChecked;
      }
      else {
        optionsChecked=1;
      }
    }
    
    //This condition, checks if the "INSTRUCTIONS" button is selected in the instructions area.
    if (mouseX>=300 && mouseX<=530 && mouseY>=420 && mouseY<=450 && optionsChecked!=2) {
      if (optionsChecked==1)
      {
        optionsChecked = optionsChecked;
      }
      else {
        optionsChecked=2;
      }
    }
    
    //This condition checks if the mouse coordinates are within the shapes spawn on the drawing area.
    // if yes then the selected object can be dragged, scaled, translated and rotated
    else
    {
      Iterator it = st.iterator();
      while (it.hasNext ())
      {

        Map.Entry me = (Map.Entry)it.next();
        Shape shpObj = (Shape)me.getValue();
        int keyValue = (Integer)me.getKey();

        //code to check if the mouse coordinates are inside the shapes of the toolbox
        shapetype = shpObj.checkShape(shpObj.type);
        switch(shapetype)
        {
        case 1: 
          checkMouserect(shpObj, keyValue, it);
          break;
        case 2: 
          checkMousecircle(shpObj, keyValue, it);
          break;
        case 3: 
          checkMouseellipse(shpObj, keyValue, it);
          break;
        default: 
          break;
        }
      }

      // now if the scale button is checked scale the selected image
      Iterator it1 = st.iterator();
      if (mouseX>=scaleButtonX && mouseX<=scaleButtonX+scaleButtonwidth && mouseY>=scaleButtonY && mouseY<=scaleButtonY + scaleButtonheight)
      {
        // now if the scale button is checked scale the selected image
        System.out.println("Inside Scale Button");
        while (it1.hasNext ())
        {
          Map.Entry me = (Map.Entry)it1.next();
          Shape shpObj = (Shape)me.getValue();
          int keyValue = (Integer)me.getKey();
          if (shpObj.locked)
          {
            it1.remove();
            shapeList.put(keyValue, scaleObj(shpObj));
          }
        }
      }
      System.out.println("before rotate");
      //Code to check if the rotate button has been pressed.
      if (mouseX>=rotateButtonX && mouseX<=rotateButtonX + rotateButtonwidth && mouseY>=rotateButtonY && mouseY<=rotateButtonY + rotateButtonheight)
      {
        while (it1.hasNext ())
        {
          Map.Entry me = (Map.Entry)it1.next();
          Shape shpObj = (Shape)me.getValue();
          int keyValue = (Integer)me.getKey();
          if (shpObj.locked)
          {
            it1.remove();
            shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle+15, shpObj.c));
          }
        }
      }

      // Filling only the selected shape with the selected color
      int i = 0;
      if (mouseX >= 620 && mouseX <= 795 && mouseY >= 400 && mouseY <= 430)
      {
        for (float j = 620; j <= 795; j = j + 35)
        {
          if (mouseX >= j && mouseX <= j+30)
          {
            break;
          }
          else
          {
            i++;
          }
        }

        Iterator it2 = st.iterator();
        while (it2.hasNext ())
        {
          Map.Entry me = (Map.Entry)it2.next();
          Shape shpObj = (Shape)me.getValue();
          int keyValue = (Integer)me.getKey();
          if (shpObj.locked)
          {
            it2.remove();
            shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle, p.getColor(i)));
          }
        }
      }

      // If the mouse click is inside Compare Button it will first show a sine wave indicating that comparison is 
      // in process and then call the Edge Detection Algo to check for the similarity of two images
      if (mouseX >= 270 && mouseX <= 330 && mouseY >= 240 && mouseY <= 250)
      {
        println("Calling the Compare button");
        savedTime = millis();
        compareFlag = true;
        Compare_Image(level);
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////
// Mouse Drag
/////////////////////////////////////////////////////////////////////////////////////
// Event Handler to be called upon Mouse Drag Event. If any object is selected
// it will dragged with the mouse
void mouseDragged()
{
  Iterator it = st.iterator();
  while (it.hasNext ())
  {
    Map.Entry me = (Map.Entry)it.next();
    Shape shpObj = (Shape)me.getValue();
    int keyValue = (Integer)me.getKey();
    if (shpObj.locked)
    {
      float newX = mouseX - xOffset;
      float newY = mouseY - yOffset;
      it.remove();
      shapeList.put(keyValue, new Shape(newX, newY, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
  }
}

////////////////////////////////////////////////////////////////////////////
// Mouse Release
////////////////////////////////////////////////////////////////////////////
// This function will always call SnapToGrid to check when
// the image is released is it falling nearby any edge
void mouseReleased() 
{
  SnapToGrid();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Key Event Handler
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Event Handler to be called upon Key Events
void keyPressed()
{
  // On Key Event "d" or "D" it will delete the selected Shape
  if (key=='d' || key=='D')
  {
    Iterator it = st.iterator();
    while (it.hasNext ())
    {
      Map.Entry me = (Map.Entry)it.next();
      Shape shpObj = (Shape)me.getValue();
      int keyValue = (Integer)me.getKey();
      if (shpObj.locked)
      {
        it.remove();
      }
    }
  }

  // On Key Event "Esc" it will pop up a dialog user asking player about exiting the game
  if (key==ESC)
  {
    System.exit(0);
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Image Comparing Algo Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Event Handler to be called when Mouse Left Button Down event occurs
// over Compare Button
void Compare_Image(String level_name)
{ 
  //SnapToGrid();
  
  boolean match = false;
  
  ImageComparisonAlgo Compare_Algo = new ImageComparisonAlgo();
  match = Compare_Algo.Match_Images(level_name);
  if (match)
  {
    if (level == "level1")
    {
      // Flag is set to false, which means user made the right image to clear the level
      this.incorrect_img = false;

      //This functions clears the all the objects from the drawing area
      clearLevel();

      // once the above function is called depending on the level load the appropriate goal image
      level = "level2";

      // Proceed to next level;
    }
    else if (level == "level2")
    {
      // Flag is set to false, which means user made the right image to clear the level
      this.incorrect_img = false;

      //This functions clears the all the objects from the drawing area
      clearLevel();

      level = "level3";
      // Game Over
    }
    
    else if (level == "level3")
    {
      // Flag is set to false, which means user made the right image to clear the level
      this.incorrect_img = false;

      //This functions clears the all the objects from the drawing area
      clearLevel();

      level = "GameOver";
      // Game Over
    }
  }
  else
  {
    // Flag is set to false, which means user made incorrect image and displays "TRY AGAIN" message
    this.incorrect_img = true;

    //This functions clears the all the objects from the drawing area
    clearLevel();
  }
}


// Function to implement snapping to grid algo. When the user made image falls near any edge
// within a threshold of -5 to +5 it will realign the image to be at the edge and its
// coordinates gets arranged accordingly
void SnapToGrid()
{
  float obj_min_x = 0.0, obj_max_x = 0.0;
  float obj_min_y = 0.0, obj_max_y = 0.0;
  float obj_width_half = 0.0, obj_height_half = 0.0;

  Iterator it = st.iterator();
  //This iterates through all objects in hash map
  while (it.hasNext ()) 
  {
    Map.Entry me = (Map.Entry)it.next();
    Shape shpObj = (Shape)me.getValue();
    int keyValue = (Integer)me.getKey();
    if (keyValue != 1 && keyValue != 2 && keyValue != 3)
    {
      obj_width_half = shpObj.wide / 2;
      obj_height_half = shpObj.tall / 2;

      // Condition to check for circle and ellipse
      if (shpObj.type == "circle" || shpObj.type == "ellipse")
      {
        obj_min_x = shpObj.xCoordinate - obj_width_half;
        obj_max_x = shpObj.xCoordinate + obj_width_half;
        obj_min_y = shpObj.yCoordinate - obj_height_half;
        obj_max_y = shpObj.yCoordinate + obj_height_half;

        // Condition to check left vertical border of the drawing area
        if (obj_min_x <= 105 && obj_min_x >= 95)
        {
          obj_min_x = 100;
          shpObj.xCoordinate = obj_min_x + obj_width_half;
        }
        // Condition to check right vertical border of the drawing area
        if (obj_max_x <= 505 && obj_max_x >= 495)
        {
          obj_max_x = 500;
          shpObj.xCoordinate = obj_max_x - obj_width_half;
        }
        // Condition to check upper horizontal border of the drawing area
        if (obj_min_y <= 305 && obj_min_y >= 295)
        {
          obj_min_y = 300;
          shpObj.yCoordinate = obj_min_y + obj_height_half;
        }
        // Condition to check lower horizontal border of the drawing area
        if (obj_max_y <= 705 && obj_max_y >= 695)
        {
          obj_max_y = 700;
          shpObj.yCoordinate = obj_max_y - obj_height_half;
        }
      }

      // Condition to check for the rectangles
      else if (shpObj.type == "rectangle")
      {
        obj_min_x = shpObj.xCoordinate;
        obj_max_x = shpObj.xCoordinate + shpObj.wide;
        obj_min_y = shpObj.yCoordinate;
        obj_max_y = shpObj.yCoordinate + shpObj.tall;
        
        // Condition to check left vertical border of the drawing area
        if (obj_min_x <= 105 && obj_min_x >= 95)
        {
          obj_min_x = 100;
          shpObj.xCoordinate = obj_min_x;
        }
        // Condition to check right vertical border of the drawing area
        if (obj_max_x <= 505 && obj_max_x >= 495)
        {
          obj_max_x = 500;
          shpObj.xCoordinate = obj_max_x - shpObj.wide;
        }
        // Condition to check upper horizontal border of the drawing area
        if (obj_min_y <= 305 && obj_min_y >= 295)
        {
          obj_min_y = 300;
          shpObj.yCoordinate = obj_min_y;
        }
        // Condition to check lower horizontal border of the drawing area
        if (obj_max_y <= 705 && obj_max_y >= 695)
        {
          obj_max_y = 700;
          shpObj.yCoordinate = obj_max_y - shpObj.tall;
        }
      }
    }
    
    it.remove();
    shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, shpObj.locked, shpObj.type, shpObj.rotation_angle, shpObj.c));
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Scaling Function
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Returns the shape based upon its coordinates, width, height and rotation angle
Shape scaleObj(Shape shpObj)
{
  float xCoordinate=0.0, yCoordinate=0.0, wide=0.0, tall=0.0;

  //Code to check which shape is being selected currently in the drawing canvas and scale it
  shapetype = shpObj.checkShape(shpObj.type);

  // If the shape is a rectangle/square
  if (shapetype==1)
  {
    float center_x = 0.0, center_y = 0.0;
    float old_width_half = 0.0, old_height_half = 0.0;
    float new_width_half = 0.0, new_height_half = 0.0;

    old_width_half = shpObj.wide / 2;
    old_height_half = shpObj.tall / 2;

    center_x = shpObj.xCoordinate + old_width_half;
    center_y = shpObj.yCoordinate + old_height_half;

    wide = shpObj.wide + 25;
    tall = shpObj.tall + 25;
    if (wide == 200 && shpObj.rotation_angle != 0)
    {
      wide = sqrt(2)*wide;
      tall = sqrt(2)*tall;
    }

    new_width_half = wide / 2;
    new_height_half = tall / 2;

    xCoordinate = center_x - new_width_half;
    yCoordinate = center_y - new_height_half;
  }

  // If the shape is a circle
  else if (shapetype==2)
  {
    wide = shpObj.wide + 25;
    tall = shpObj.tall + 25;
    xCoordinate = shpObj.xCoordinate;
    yCoordinate = shpObj.yCoordinate;
  }

  // If the shape is an ellipse
  else if (shapetype==3)
  {
    wide = shpObj.wide + 25.0;
    tall = shpObj.tall + 12.5;
    xCoordinate = shpObj.xCoordinate;
    yCoordinate = shpObj.yCoordinate;
  }

  return new Shape(xCoordinate, yCoordinate, wide, tall, shpObj.locked, shpObj.type, shpObj.rotation_angle, shpObj.c);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Functions to check mouse click events in the tool box area
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*This function is developed to check if the mouse coordinates are inside the rectangle if yes then 
appropriate actions are considered depending on the conditions */
void checkMouserect(Shape shpObj, int keyValue, Iterator it)
{
  //This checks if the mouse coordinates are the between the rectangle selected.
  if (mouseX >= shpObj.get_min_X() && mouseX <= shpObj.get_max_X() && mouseY >= shpObj.get_min_Y() && mouseY <= shpObj.get_max_Y())
  {
    //This condition checks if rectangle button in the tool box is selected if, yes then spawns a new rectangle
    if (keyValue==1)
    {
      shapeList.put(Count++, new Shape(25, 300, 50, 50, false, "rectangle", 0, #FFFFFF));
    }
    //If the rectangle button is not selected, then select the object on the drawing area.
    else
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle, shpObj.c));
      xOffset = mouseX - shpObj.xCoordinate;
      yOffset = mouseY - shpObj.yCoordinate;
    }
  }
  else 
  {
    //Check if the mouse coordinates are in toolbox if yes don't change the state of the object
    if (mouseX>=400 && mouseX<=800 && mouseY>=0 && mouseY<=800)
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, shpObj.locked, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
    //if mouse is clicked other then the toolbox area deselect the selected object
    else 
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, false, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
  }
}

/*This function is developed to check if the mouse coordinates are inside the circle if yes then 
appropriate actions are considered depending on the conditions */
 
void checkMousecircle(Shape shpObj, int keyValue, Iterator it)
{
  float distance;
  distance = sqrt(sq(mouseX-shpObj.xCoordinate) + sq(mouseY-shpObj.yCoordinate));
  //This check if the mouse coordinates lie between the circle
  if (distance<=shpObj.wide/2) 
  {
    //This checks if the mouse coordinates are within the circle button of toolbox if yes spawns a new circle
    if (keyValue==2) 
    {
      System.out.println("creating a new circle");
      shapeList.put(Count++, new Shape(50, 450, 50, 50, false, "circle", 0, #FFFFFF));
    }
    //if the circle button on toolbox is not selected then select the circle
    
    else 
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle, shpObj.c));
      xOffset = mouseX - shpObj.xCoordinate;
      yOffset = mouseY - shpObj.yCoordinate;
    }
  }
  else 
  {
    //Check if the mouse coordinates are in toolbox if yes don't change the state of the object
    if (mouseX>=600 && mouseX<=800 && mouseY>=0 && mouseY<=600)
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, shpObj.locked, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
    //Check if the mouse coordinates are not in toolbox and anywhere else then deselect the selected object
    else 
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, false, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
  }
}


/*This function is developed to check if the mouse coordinates are inside the circle if yes then 
appropriate actions are considered depending on the conditions */

void checkMouseellipse(Shape shpObj, int keyValue, Iterator it)
{
  float distance;
  distance = sqrt(sq(mouseX-shpObj.xCoordinate) + sq(mouseY-shpObj.yCoordinate));
  //This check if the mouse coordinates lie between the ellipse
  if (distance<=shpObj.wide/2 && distance<=shpObj.tall/2) 
  {
    //This checks if the mouse coordinates are within the ellipse button of toolbox if yes spawns a new ellipse
    if (keyValue==3) 
    {
      System.out.println("creating a new ellipse");
      shapeList.put(Count++, new Shape(50, 600, 50, 25, false, "ellipse", 0, #FFFFFF));
    }
    //code to check if the circle i am clicking on is not the rectangle button
    else 
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, true, shpObj.type, shpObj.rotation_angle, shpObj.c));
      xOffset = mouseX - shpObj.xCoordinate;
      yOffset = mouseY - shpObj.yCoordinate;
    }
  }
  else 
  {
    //Check if the mouse coordinates are in toolbox if yes don't change the state of the object
    if (mouseX>=600 && mouseX<=800 && mouseY>=0 && mouseY<=600)
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, shpObj.locked, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
    //Check if the mouse coordinates are not in toolbox and anywhere else then deselect the selected object
    else 
    {
      it.remove();
      shapeList.put(keyValue, new Shape(shpObj.xCoordinate, shpObj.yCoordinate, shpObj.wide, shpObj.tall, false, shpObj.type, shpObj.rotation_angle, shpObj.c));
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function to operate timer in the toolbox
////////////////////////////////////////////////////////////////////////////////////////////////////////////
void calculateTime()
{
  if (optionsChecked==1)
  {  
    milli = millis();
    seconds = (milli/1000)%60;
    minutes = (milli/(1000*60))%60;
    hours = (milli/(1000*60*60))%24;
    fill(0);
    rect(610, 465, 150, 50, 7);
    textSize(16);
    text("Time", 660, 460);
    fill(0, 150, 153, 250);
    textSize(32);
    text(String.valueOf(hours) + ": ", 640, 500);
    text(String.valueOf(minutes) + ": ", 670, 500);
    text(String.valueOf(seconds), 700, 500);
    textSize(12);
  }
  else
  {
    fill(0);
    rect(610, 465, 150, 50, 7);
    textSize(16);
    text("Time", 660, 460);
    fill(0, 150, 153, 250);
    textSize(32);
    text(String.valueOf(hours) + ": ", 640, 500);
    text(String.valueOf(minutes) + ": ", 670, 500);
    text(String.valueOf(seconds), 700, 500);
    textSize(12);
  }
}


// Function to clean up the drawing area
void clearLevel()
{
  Iterator it = st.iterator();
  while (it.hasNext ()) 
  {
    Map.Entry me = (Map.Entry)it.next();
    int keyValue = (Integer)me.getKey();
    if (keyValue!=1 && keyValue!=2 && keyValue!=3) 
    {
      it.remove();
    }
  }
}

