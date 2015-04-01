package starling.text.hyperlink
{
  /** @author Jum */
  public class Hyperlink
  {
    private static const HREF:String = "href=";
    
    private var _startIndex:int;
    private var _endIndex:int;
    
    private var _link:String;
    private var _text:String;
    
    public function Hyperlink(hyperlink_:String, startIndex_:int, endIndex_:int)
    { 
      var hrefIndex:int = hyperlink_.indexOf(HREF) + HREF.length;
      var endHrefIndex:int = hyperlink_.indexOf(hyperlink_.charAt(hrefIndex), hrefIndex + 1);
      _link = hyperlink_.substring(hrefIndex + 1, endHrefIndex);
      
      _text = HyperlinkUtils.removeHyperlink(hyperlink_);
      
      _startIndex = startIndex_;
      _endIndex = endIndex_ - (hyperlink_.length - _text.length);
    }
    
    public function get startIndex():int { return _startIndex; }
    public function get endIndex():int { return _endIndex; }
    
    public function get link():String { return _link; }
    public function get text():String { return _text; }
    
    public function toString():String
    {
      return "Hyperlink(text: " + _text + ", start: " + _startIndex + ", end: " + _endIndex + ")";
    }
  }
}