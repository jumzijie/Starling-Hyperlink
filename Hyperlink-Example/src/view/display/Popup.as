package view.display
{
  import starling.core.Starling;
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.text.TextField;
  
  /** @author Jum */
  public class Popup extends Sprite
  {
    private static var _instance:Popup;
    
    private static const PADDING:int = 10;
    
    private var _bgShadow:RoundedQuad;
    private var _bg:RoundedQuad;
    private var _btnOk:RoundedButton;
    private var _btnCancel:RoundedButton;
    private var _txt:TextField;
    
    private var _onOkListener:Function;
    private var _onCancelListener:Function;
    
    public function Popup(e:SingletonEnforcer)
    {
      super();
      
      _bgShadow = new RoundedQuad(262, 166, 16, 0x999999);
      
      _bg = new RoundedQuad(260, 160, 16, 0xffffff);
      _bg.x = 1;
      _bg.y = 1;
      
      _btnOk = new RoundedButton("OK", 80, 25, 16, Constants.GREEN);
      _btnCancel = new RoundedButton("Cancel", _btnOk.initialWidth, _btnOk.initialHeight, 16, Constants.RED);
      
      _btnOk.x = _bg.x + _bg.width / 2 + PADDING;
      _btnCancel.x = _bg.y + _bg.width / 2 - _btnCancel.width - PADDING;
      
      _btnOk.y = _bg.y + _bg.height - _btnOk.height - PADDING;
      _btnCancel.y = _btnOk.y;
      
      _txt = new TextField(_bg.width - PADDING * 2, _btnOk.y - PADDING * 2 - 5, "", Fonts.ARIAL, 18, 0x333333);
      _txt.autoScale = true;
      _txt.x = _bg.x + (_bg.width - _txt.width) / 2;
      _txt.y = _bg.y + PADDING;
      
      addChild(_bgShadow);
      addChild(_bg);
      addChild(_btnOk);
      addChild(_btnCancel);
      addChild(_txt);
      
      this.x = (Main.WIDTH - this.width) / 2;
      this.y = (Main.HEIGHT - this.height) / 2;
    }
    
    public function setData(text_:String, onOkListener_:Function, onCancelListener_:Function=null):void
    {
      _txt.text = text_;
      _onOkListener = onOkListener_;
      _onCancelListener = onCancelListener_;
      
      show();
    }
    
    public function show():void
    {
      if (!this.parent)
      {
        init();
        Starling.current.stage.addChild(this);
      }
    }
    
    public function hide():void
    {
      if (this.parent)
      {
        this.removeFromParent();
        deinit();
      }
    }
    
    private function init():void
    {
      _btnOk.addEventListener(Event.TRIGGERED, onTriggered);
      _btnCancel.addEventListener(Event.TRIGGERED, onTriggered);
    }
    
    private function deinit():void
    {
      _btnOk.removeEventListener(Event.TRIGGERED, onTriggered);
      _btnCancel.removeEventListener(Event.TRIGGERED, onTriggered);
    }
    
    private function onTriggered(event_:Event):void
    {
      switch (event_.target)
      {
        case _btnOk:
          hide();
          if (_onOkListener != null)
          {
            _onOkListener();
          }
          break;
        
        case _btnCancel:
          hide();
          if (_onCancelListener != null)
          {
            _onCancelListener();
          }
          break;
      }
    }
    
    public static function get instance():Popup
    {
      if (!_instance)
      {
        _instance = new Popup(new SingletonEnforcer());
      }
      return _instance;
    }
    
  }
}
class SingletonEnforcer{}