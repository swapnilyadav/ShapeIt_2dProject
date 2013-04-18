public class Shape {
  float xCoordinate;
  float yCoordinate;
  float xCoordiante1;
  float yCoordinate2;
  float wide;
  float tall;
  String type;
  boolean locked;
  float rotation_angle;
  color c;

  public Shape(float xvalue, float yvalue, float wide, float tall, boolean locked, String type, float rotation_angle, color c)
  {
    this.xCoordinate = xvalue;
    this.yCoordinate = yvalue;
    this.wide=wide;
    this.tall=tall;
    this.locked=locked;
    this.type = type;
    this.rotation_angle=rotation_angle;
    this.c = c;
  }

  public int checkShape(String type)
  {
    if (type.equals("rectangle"))
    {
      return 1;
    }
    else if (type.equals("circle"))
    {
      return 2;
    }
    else if (type.equals("ellipse"))
    {
      return 3;
    }
    return 0;
  }


  // these four funtions as follows returns min and max values of X and Y used to track whether mouse is within the shape or not.
  public float get_min_X()
  {
    float diagonal_length = sqrt(sq(this.wide) + sq(this.tall));
    float diagonal_angle = degrees(acos(this.wide / diagonal_length));
    float upper_right_x = (this.xCoordinate + this.wide * cos(radians(this.rotation_angle)));
    float lower_left_x = (this.xCoordinate + this.tall * cos(radians(this.rotation_angle + 90)));
    float lower_right_x = (this.xCoordinate + diagonal_length * cos(radians(this.rotation_angle + diagonal_angle)));
    return min(this.xCoordinate, upper_right_x, min(lower_left_x, lower_right_x));
  }

  public float get_max_X()
  {
    float diagonal_length = sqrt(sq(this.wide) + sq(this.tall));
    float diagonal_angle = degrees(acos(this.wide / diagonal_length));
    float upper_right_x = (this.xCoordinate + this.wide * cos(radians(this.rotation_angle)));
    float lower_left_x = (this.xCoordinate + this.tall * cos(radians(this.rotation_angle + 90)));
    float lower_right_x = (this.xCoordinate + diagonal_length * cos(radians(this.rotation_angle + diagonal_angle)));
    return max(this.xCoordinate, upper_right_x, max(lower_left_x, lower_right_x));
  }

  public float get_min_Y()
  {
    float diagonal_length = sqrt(sq(this.wide) + sq(this.tall));
    float diagonal_angle = degrees(acos(this.wide / diagonal_length));
    float upper_right_y = (this.yCoordinate + this.wide * sin(radians(this.rotation_angle)));
    float lower_left_y = (this.yCoordinate + this.tall * sin(radians(this.rotation_angle + 90)));
    float lower_right_y = (this.yCoordinate + diagonal_length * sin(radians(this.rotation_angle + diagonal_angle)));
    return min(this.yCoordinate, upper_right_y, min(lower_left_y, lower_right_y));
  }

  public float get_max_Y() {
    float diagonal_length = sqrt(sq(this.wide) + sq(this.tall));
    float diagonal_angle = degrees(acos(this.wide / diagonal_length));
    float upper_right_y = (this.yCoordinate + this.wide * sin(radians(this.rotation_angle)));
    float lower_left_y = (this.yCoordinate + this.tall * sin(radians(this.rotation_angle + 90)));
    float lower_right_y = (this.yCoordinate + diagonal_length * sin(radians(this.rotation_angle + diagonal_angle)));
    return max(this.yCoordinate, upper_right_y, max(lower_left_y, lower_right_y));
  }
}

