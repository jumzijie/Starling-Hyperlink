package starling.text.hyperlink
{
  import flash.geom.Point;
  
  import starling.display.DisplayObject;
  import starling.display.Quad;
  import starling.events.Event;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  
  /** @author Jum */
  public class HyperlinkQuad extends Quad
  {
    private var _link:String;
    private var _joinedQuads:Vector.<HyperlinkQuad>;
    
    private var _initialX:Number;
    private var _initialY:Number;
    
    private var _isDown:Boolean;
    
    public function HyperlinkQuad(width:Number, height:Number, color:uint, initialX:Number, initialY:Number)
    {
      super(width, height, color);
      
      _initialX = initialX;
      _initialY = initialY;
      
      onUp();
      
      addEventListener(TouchEvent.TOUCH, onTouch);
    }
    
    public function joinQuad(quad_:HyperlinkQuad):void
    {
      if (!_joinedQuads) _joinedQuads = new Vector.<HyperlinkQuad>();
      _joinedQuads.push(quad_);
    }
    
    private function onTouch(event_:TouchEvent):void
    {
      var touch:Touch = event_.getTouch(this, TouchPhase.BEGAN);
      if (touch)
      {
        onDown();
        return;
      }
      
      touch = event_.getTouch(this, TouchPhase.MOVED);
      if (touch)
      {
        if (isTouchWithinBounds(touch, this))
        {
          if (!_joinedQuads) onDown();
        }
        else
        {
          onUp();
        }
        return;
      }
      
      touch = event_.getTouch(this, TouchPhase.ENDED);
      if (touch)
      {
        if (_isDown && isTouchWithinBounds(touch, this))
        {
          this.dispatchEventWith(Event.TRIGGERED, false, _link);
        }
        onUp();
        return;
      }
    }
    
    private function isTouchWithinBounds(touch:Touch, touchTarget:DisplayObject):Boolean
    {
      var touchPoint:Point = touch.getLocation(touchTarget.parent);
      if (touchTarget.bounds.contains(touchPoint.x, touchPoint.y))
      {
        return true;
      }
      return false;
    }
    
    public function onUp(fromTouch_:Boolean=true):void
    {
      _isDown = false;
      alpha = 0;
      if (fromTouch_ && _joinedQuads)
      {
        const length:int = _joinedQuads.length;
        for (var i:int = 0; i < length; i++)
        {
          _joinedQuads[i].onUp(false);
        }
      }
    }
    
    public function onDown(fromTouch_:Boolean=true):void
    {
      _isDown = true;
      alpha = 0.25;
      if (fromTouch_ && _joinedQuads)
      {
        const length:int = _joinedQuads.length;
        for (var i:int = 0; i < length; i++)
        {
          _joinedQuads[i].onDown(false);
        }
      }
    }
    
    public function get link():String { return _link; }
    public function set link(value:String):void { _link = value; }
    
    public function get joinedQuads():Vector.<HyperlinkQuad> { return _joinedQuads; }
    
    public function get initialX():Number { return _initialX; }
    public function get initialY():Number { return _initialY; }
    
  }
}