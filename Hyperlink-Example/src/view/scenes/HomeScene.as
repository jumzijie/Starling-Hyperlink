package view.scenes
{
  import flash.net.URLRequest;
  import flash.net.navigateToURL;
  
  import starling.events.Event;
  import starling.text.TextField;
  
  import view.display.Popup;

  public class HomeScene extends Scene
  {
    private static const PADDING:int = 10;
    
    private var _txtTest:TextField;
    private var _link:String;
    
    public function HomeScene()
    {
      super();
      
      addBackground();
      
      var testStr:String = "<a href=\"https://www.google.com\">Hello</a> <a href=\"github.com\">World</a>";
      testStr += " Hello World <a href=\"mailto:test@gmail.com\">Hello</a> World";
      testStr += " <a href=\"test2@gmail.com\">Hello World</a>";
      _txtTest = new TextField(Main.WIDTH - PADDING * 2, 100, testStr, Fonts.ARIAL, 18, 0x0);
      _txtTest.autoScale = true;
      _txtTest.border = true;
      _txtTest.hyperlinkColor = 0xff9900;
      
      _txtTest.x = PADDING;
      _txtTest.y = (Main.HEIGHT - _txtTest.height) / 2;
      addChild(_txtTest);
    }
    
    override public function init():void
    {
      _txtTest.addEventListener(Event.TRIGGERED, onTriggered);
    }
    
    override public function deinit():void
    {
      _txtTest.removeEventListener(Event.TRIGGERED, onTriggered);
    }
    
    private function onTriggered(event_:Event):void
    {
      switch (event_.target)
      {
        case _txtTest:
          _link = String(event_.data);
          Popup.instance.setData("You are about to visit\n" + _link + ".\nContinue?", onOpenLink);
          break;
      }
    }
    
    private function onOpenLink():void
    {
      navigateToURL(new URLRequest(_link));
    }
    
  }
}