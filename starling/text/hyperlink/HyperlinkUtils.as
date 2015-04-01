package starling.text.hyperlink
{
  /** @author Jum */
  public class HyperlinkUtils
  {
    public static const OPEN_TAG_EXPRESSION:RegExp = /<\s*a[^>]*>/gi;
    public static const CLOSE_TAG_EXPRESSION:RegExp = /<\/a>/gi;
    
    public static const CLOSE_TAG:String = "</a>";
    
    public function HyperlinkUtils()
    {
    }
    
    public static function hasHyperlink(text_:String):Boolean
    {
      var closeIndex:int = text_.search(CLOSE_TAG_EXPRESSION);
      var openIndex:int = text_.search(OPEN_TAG_EXPRESSION);
      return (closeIndex != -1 && openIndex != -1 && closeIndex > openIndex);
    }
    
    public static function removeHyperlink(text_:String):String
    {
      var closeIndex:int;
      var substring:String;
      var openTagMatches:Array;
      var openIndex:int;
      var hyperlink:String;
      
      var openTag:String;
      var closeTag:String;
      
      // update indexes
      closeIndex = text_.search(CLOSE_TAG_EXPRESSION);
      openIndex = text_.search(OPEN_TAG_EXPRESSION);
      while (closeIndex != -1 && openIndex != -1 && closeIndex > openIndex)
      {
        // find close tag first
        closeIndex = text_.search(CLOSE_TAG_EXPRESSION) + CLOSE_TAG.length;
        // substring to closeIndex
        substring = text_.substring(0, closeIndex);
        // find open tag matches
        openTagMatches = substring.match(OPEN_TAG_EXPRESSION);
        // find last open tag
        openIndex = substring.lastIndexOf(openTagMatches[openTagMatches.length - 1]);
        // extract hyperlink
        hyperlink = substring.substring(openIndex, closeIndex);
        // remove hyperlink
        openTag = hyperlink.match(OPEN_TAG_EXPRESSION)[0];
        closeTag = hyperlink.match(CLOSE_TAG_EXPRESSION)[0];
        hyperlink = hyperlink.substring(openTag.length, hyperlink.length - closeTag.length);
        // update string
        text_ = text_.substring(0, openIndex) + hyperlink + text_.substring(closeIndex);
        // update indexes
        closeIndex = text_.search(CLOSE_TAG_EXPRESSION);
        openIndex = text_.search(OPEN_TAG_EXPRESSION);
      }
      return text_;
    }
    
    public static function extractHyperlinks(text_:String):Vector.<Hyperlink>
    {
      var links:Vector.<Hyperlink> = new Vector.<Hyperlink>();
      // find matches to the open and close tags
      var openTagMatches:Array = text_.match(OPEN_TAG_EXPRESSION);
      var closeTagMatches:Array = text_.match(CLOSE_TAG_EXPRESSION);
      
      // record their type, index, and the matching string
      var indexes:Vector.<HyperlinkTag> = new Vector.<HyperlinkTag>();
      var length:int = openTagMatches.length;
      var i:int;
      var index:int = 0;
      for (i = 0; i < length; i++)
      {
        index = text_.indexOf(openTagMatches[i], index);
        indexes.push(new HyperlinkTag(HyperlinkTag.TYPE_OPEN, index, openTagMatches[i]));
        index++;
      }
      
      length = closeTagMatches.length;
      index = 0;
      for (i = 0; i < length; i++)
      {
        index = text_.indexOf(closeTagMatches[i], index);
        indexes.push(new HyperlinkTag(HyperlinkTag.TYPE_CLOSE, index + CLOSE_TAG.length, closeTagMatches[i]));
        index++;
      }
      
      // sort by ascending index
      indexes.sort(sortByIndex);
      
      var startIndex:int = -1;
      var endIndex:int;
      var hyperlink:Hyperlink;
      var indexModifier:int = 0;
      var openTagCount:int = 0;
      length = indexes.length;
      for (i = 0; i < length; i++)
      {
        if (startIndex == -1)
        {
          // find start index
          if (indexes[i].isOpenTag)
          {
            startIndex = indexes[i].index;
          }
        }
        else
        {
          // find end index
          if (indexes[i].isOpenTag)
          {
            openTagCount++;
          }
          else
          {
            if (openTagCount > 0)
            {
              openTagCount--;
            }
            else
            {
              endIndex = indexes[i].index;
              hyperlink = new Hyperlink(text_.substring(startIndex, endIndex), startIndex - indexModifier, endIndex - indexModifier);
              indexModifier = endIndex - hyperlink.endIndex;
              links.push(hyperlink);
              startIndex = -1;
            }
          }
        }
      }
      return links;
    }
    
    private static function sortByIndex(a:HyperlinkTag, b:HyperlinkTag):Number
    {
      if (a.index > b.index)
      {
        return 1;
      }
      else if (a.index < b.index)
      {
        return -1;
      }
      else
      {
        return 0;
      }
    }
    
  }
}


class HyperlinkTag
{
  public static const TYPE_OPEN:int = 0;
  public static const TYPE_CLOSE:int = 1;
  
  private var _type:int;
  private var _index:int;
  private var _matchString:String;
  
  public function HyperlinkTag(type_:int, index_:int, matchString_:String)
  {
    _type = type_;
    _index = index_;
    _matchString = matchString_;
  }
  
  public function get type():int { return _type; }
  public function get index():int { return _index; }
  public function get matchString():String { return _matchString; }
  
  public function get isOpenTag():Boolean { return _type == TYPE_OPEN; }
}