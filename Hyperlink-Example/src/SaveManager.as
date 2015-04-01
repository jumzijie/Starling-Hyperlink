package
{
  import flash.net.SharedObject;

  public class SaveManager
  {
    private static const SO_HIGH_SCORE:String = "high_score";
    
    public function SaveManager()
    {
    }
    
    public static function getHighScore():int
    {
      var so:SharedObject = SharedObject.getLocal(SO_HIGH_SCORE);
      if (so.data[SO_HIGH_SCORE] != null)
      {
        return so.data[SO_HIGH_SCORE];
      }
      return 0;
    }
    
    public static function saveHighScore(value:int):Boolean
    {
      var so:SharedObject = SharedObject.getLocal(SO_HIGH_SCORE);
      if (so.data[SO_HIGH_SCORE] == null || value > so.data[SO_HIGH_SCORE])
      {
        so.data[SO_HIGH_SCORE] = value;
        so.flush();
        return true;
      }
      return false;
    }
    
  }
}