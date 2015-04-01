package
{
  import utils.ColorUtils;

  public class Constants
  {
    public function Constants() {}
    
    // colors
    public static const RED:uint = 0xcc0000;
    public static const ORANGE:uint = 0xff9900;
    public static const YELLOW:uint = 0xffff00;
    public static const GREEN:uint = 0x009900;
    public static const BLUE:uint = 0x0066ff;
    public static const PURPLE:uint = 0x9900ff;
    
    public static function getDarkerColor(color_:uint):uint
    {
      switch (color_)
      {
        case Constants.RED:
          return 0x660000;
        case Constants.ORANGE:
          return 0x993300;
        case Constants.YELLOW:
          return 0x999900;
        case Constants.GREEN:
          return 0x005500;
        case Constants.BLUE:
          return 0x001199;
        case Constants.PURPLE:
          return 0x440099;
        default:
          return ColorUtils.darkenColor(color_, 30);
      }
    }
    
  }
}