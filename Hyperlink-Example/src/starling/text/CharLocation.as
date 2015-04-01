package starling.text
{
  import starling.text.BitmapChar;
  
  /** This class is originally embedded within the class <b>BitmapFont</b>. */
  public class CharLocation
  {
    private var mChar:BitmapChar;
    private var mScale:Number;
    private var mX:Number;
    private var mY:Number;
    
    public function CharLocation(char:BitmapChar)
    {
      this.char = char;
    }
    
    public function get char():BitmapChar { return mChar; }
    public function set char(value:BitmapChar):void { mChar = value; }
    
    public function get scale():Number { return mScale; }
    public function set scale(value:Number):void { mScale = value; }
    
    public function get x():Number { return mX; }
    public function set x(value:Number):void { mX = value; }
    
    public function get y():Number { return mY; }
    public function set y(value:Number):void { mY= value; }
    
  }
}