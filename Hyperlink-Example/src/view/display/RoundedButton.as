package view.display
{
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  import starling.text.TextField;
  
  import utils.TouchUtils;
  
  /** @author Jum */
  public class RoundedButton extends Sprite
  {
    private var _bg:RoundedQuad;
    private var _bgShadow:RoundedQuad;
    private var _txt:TextField;
    
    public function RoundedButton(text_:String, width_:Number, height_:Number, roundAmount_:Number=16, color_:uint=Constants.BLUE)
    {
      super();
      
      _bg = new RoundedQuad(width_, height_, roundAmount_, color_);
      _bgShadow = new RoundedQuad(width_, height_, roundAmount_, Constants.getDarkerColor(color_));
      
      _txt = new TextField(_bg.width, _bg.height, text_, Fonts.ARIAL, 18, 0xffffff);
      _txt.touchable = false;
      
      addChild(_bgShadow);
      addChild(_bg);
      addChild(_txt);
      
      _bgShadow.y = 5;
      
      onUp();
      
      this.addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    public function redraw(width_:Number, height_:Number):void
    {
      _bg.redraw(width_, height_);
      _bgShadow.redraw(width_, height_);
      _txt.width = width_;
      _txt.height = height_;
    }
    
    private function onTouch(event_:TouchEvent):void
    {
      if (event_.getTouch(this, TouchPhase.BEGAN))
      {
        onDown();
      }
      else if (event_.getTouch(this, TouchPhase.MOVED))
      {
        if (TouchUtils.checkTouchMoved(event_, this))
        {
          onDown();
        }
        else
        {
          onUp();
        }
      }
      else if (event_.getTouch(this, TouchPhase.ENDED))
      {
        onUp();
        if (TouchUtils.checkTouchEnded(event_, this))
        {
          this.dispatchEventWith(Event.TRIGGERED, true);
        }
      }
    }
    
    private function onDown():void
    {
      var posY:Number = _bgShadow.y - 2;
      if (_bg.y != posY)
      {
        _bg.y = _txt.y = posY;
      }
    }
    
    private function onUp():void
    {
      var posY:Number = 0;
      if (_bg.y != posY)
      {
        _bg.y = _txt.y = posY;
      }
    }
    
    public function get fontName():String { return _txt.fontName; }
    public function set fontName(value:String):void { _txt.fontName = value; }
    
    public function get fontSize():Number { return _txt.fontSize; }
    public function set fontSize(value:Number):void{ _txt.fontSize = value; }
    
    public function get fontColor():uint { return _txt.color; }
    public function set fontColor(value:uint):void { _txt.color = value; }
    
    public function get text():String { return _txt.text; }
    public function set text(value:String):void { _txt.text = value; }
    
    /** Width used to construct button. */
    public function get initialWidth():Number { return _bg.width; }
    /** Height used to construct button. */
    public function get initialHeight():Number { return _bg.height; }
    
  }
}