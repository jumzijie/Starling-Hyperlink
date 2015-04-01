package
{
  public class Utils
  {
    public function Utils()
    {
    }
    
    public static function getNumberWithCommas(value_:int):String
    {
      var valueStr:String = value_.toString();
      var str:String = "";
      for(var i:int = valueStr.length-1; i >= 0; i--)
      {
        str = valueStr.charAt(i) + str;
        if (i != 0 && i % 3 == valueStr.length % 3)
        {
          str = "," + str;
        }
      }
      return str;
    }
    
  }
}