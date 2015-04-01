package starling.text.hyperlink
{
  import starling.text.CharLocation;
  
  /** @author Jum */
  public class HyperlinkLocation
  {
    private var _charLocation:CharLocation;
    private var _link:String;
    private var _isJoined:Boolean;
    
    public function HyperlinkLocation(charLocation_:CharLocation, link_:String, isJoined_:Boolean=false)
    {
      _charLocation = charLocation_;
      _link = link_;
      _isJoined = isJoined_;
    }
    
    public function get charLocation():CharLocation { return _charLocation; }
    public function get link():String { return _link; }
    public function get isJoined():Boolean { return _isJoined; }
  }
}