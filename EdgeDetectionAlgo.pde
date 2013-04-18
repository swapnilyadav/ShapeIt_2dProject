public class ImageComparisonAlgo
{
  String level = "level1";
  ArrayList pixel_on_Edge_List_for_gamelevel_img = new ArrayList();
  ArrayList color_on_Edge_List_for_gamelevel_img = new ArrayList();

  ArrayList test_list = new ArrayList();

  // Class to store a pixel coordinates which lies on an edge
  public class pixel_on_Edge
  {
    int x; // pixel x coordinate
    int y; // pixel y coordinate
    color pixel_color; // color of the pixel

    // Class pixel_on_Edge constructor
    public pixel_on_Edge(int x, int y, color pixel_color)
    {
      this.x = x;
      this.y = y;
      this.pixel_color = pixel_color;
    }
  }

  // Class ImageComparisonAlgo constructor
  public ImageComparisonAlgo()
  {
  } 

  public boolean Match_Images(String level_name)
  {
    // Algorithm Part 1. Implementing a sort of pixel to pixel match
    // Assuming the drawn image is of size 400x400
    // Divide the image into 10x10 matrix

    // flag to check whether the user made image matches the goal image or not
    boolean match;

    // stores the current level
    this.level = level_name;

    color white = color(255, 255, 255);

    ArrayList pixel_on_Edge_List_for_users_img = new ArrayList();

    // If the current level is level1 then read the file level1.txt inside the data directory under Sketch folder
    // to read the edge information for the Goal Image of level1 and add that information to test_list
    if (this.level == "level1")
    {
      String lines[] = loadStrings("level1.txt");
      for (int i=0; i < lines.length; i++) 
      {
        int x = lines[i].length();
        String f = lines[i].substring(0, 3);
        String l = lines[i].substring(4, 7);
        String c = lines[i].substring(8, x);
        test_list.add(new pixel_on_Edge(Integer.parseInt(f), Integer.parseInt(l), Integer.parseInt(c)));
      }
    }

    // If the current level is level2 then read the file level2.txt inside the data directory under Sketch folder
    // to read the edge information for the Goal Image of level2 and add that information to test_list
    if (this.level == "level2")
    {
      String lines[] = loadStrings("level2.txt");
      for (int i=0; i < lines.length; i++) 
      {
        int x = lines[i].length();
        String f = lines[i].substring(0, 3);
        String l = lines[i].substring(4, 7);
        String c = lines[i].substring(8, x);
        test_list.add(new pixel_on_Edge(Integer.parseInt(f), Integer.parseInt(l), Integer.parseInt(c)));
      }
    }
    
    // If the current level is level3 then read the file level3.txt inside the data directory under Sketch folder
    // to read the edge information for the Goal Image of level2 and add that information to test_list
    if (this.level == "level3")
    {
      String lines[] = loadStrings("level3.txt");
      for (int i=0; i < lines.length; i++) 
      {
        int x = lines[i].length();
        String f = lines[i].substring(0, 3);
        String l = lines[i].substring(4, 7);
        String c = lines[i].substring(8, x);
        test_list.add(new pixel_on_Edge(Integer.parseInt(f), Integer.parseInt(l), Integer.parseInt(c)));
      }
    }

    // The following nested for loops will perform Edge-Detection
    for (int j=300; j<=700; j=j+10)
    {
      for (int i=100; i<500; i++)
      {
        if (get(i, j) != get(i+1, j))
        {
          if (get(i, j) == white)
          {
            // store (i+1, j) as the pixel on the edge
            pixel_on_Edge_List_for_users_img.add(new pixel_on_Edge(i+1, j, get(i+1, j)));  // Add pixel to the pixel list
          }
          else
          {
            // store (i, j) as the pixel on the edge
            pixel_on_Edge_List_for_users_img.add(new pixel_on_Edge(i, j, get(i, j)));
          }
        }
      }
    }

    // By now both ArrayList for pixel position and there respective color have been determined both for
    // users_image and gamelevel_image

    // Now we need to compare the pixel position lists and the color lists against each other.
    // If the comparing results are within an allowed error threshold then the two images can
    // be considered to be similar

    //this.getPixelList();
    match = this.ListMatch(pixel_on_Edge_List_for_users_img);

    println("value of match is:" + match);
    return match;
  }


  public boolean ListMatch(ArrayList pixel_list_for_users_img)
  {
    // Variables to error count due to miss alignment/color mismatch between goal image and player made image 
    int error_count = 0;
    int error_percent = 0;
    int align_error = 0, color_error = 0;

    // the length of the pixel lists of both user image and game level image should be equal
    //if (pixel_list_for_users_img.size() == this.pixel_on_Edge_List_for_gamelevel_img.size())
    if (abs(pixel_list_for_users_img.size() - this.test_list.size()) < 20)
    {
      int length;
      if (pixel_list_for_users_img.size() < this.test_list.size())
      {
        length = pixel_list_for_users_img.size();
      }

      else
      {
        length = test_list.size();
      }

      for (int i = length - 1; i >= 0; i--) 
      { 
        // An ArrayList doesn't know what it is storing,
        // so we have to cast the object coming out.
        pixel_on_Edge pixel_user_img = (pixel_on_Edge) pixel_list_for_users_img.get(i);

        pixel_on_Edge test_pixel = (pixel_on_Edge) this.test_list.get(i);


        if (abs(pixel_user_img.x - test_pixel.x) > 5 || abs(pixel_user_img.y - test_pixel.y) > 5)
        {
          error_count++;
          align_error++;
        }
        else if (pixel_user_img.pixel_color != test_pixel.pixel_color)
        {
          error_count++;
          color_error++;
        }
      }
      // Error threshold is 10%
      error_percent = (error_count * 100) / (pixel_list_for_users_img.size() + this.test_list.size());
      if (error_percent > 10)
      {
        println("user img pixel list size is: " + pixel_list_for_users_img.size());
        for (int i=0; i<pixel_list_for_users_img.size();i++)
        {
          pixel_on_Edge pixel = (pixel_on_Edge) pixel_list_for_users_img.get(i);
          println(pixel.x + " " + pixel.y + " " + pixel.pixel_color);
        }
        println("error greater than allowed");
        println("total error is: " + error_count++);
        println("align error is: " + align_error);
        println("color error is: " + color_error);
        return false; // if error is greater than 10% then images dont match and return false
      }

      else
      {
        println("Images are identical");
        return true; // if error is less than 10% then images match and return true
      }
    }
    else
    {
      println("user img pixel list size is: " + pixel_list_for_users_img.size());
      for (int i=0; i<pixel_list_for_users_img.size();i++)
      {
        pixel_on_Edge pixel = (pixel_on_Edge) pixel_list_for_users_img.get(i);
        println(pixel.x + " " + pixel.y + " " + pixel.pixel_color);
      }
      println("align error is: " + align_error);
      println("color error is: " + color_error);
      println("Images are not identical.");
      return false; // else return false because the if condition checks for the size equality of the pixel list of user img against gamelevel image and also for color list of user image against gamelevel image
    }
  }
}

