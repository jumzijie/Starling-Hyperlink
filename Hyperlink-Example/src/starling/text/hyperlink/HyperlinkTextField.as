package starling.text.hyperlink
{
  import starling.core.RenderSupport;
  import starling.display.DisplayObjectContainer;
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.text.TextField;
  
  /** @author Jum */
  public class HyperlinkTextField extends Sprite
  {
    private var _txt:TextField;
    
    public function HyperlinkTextField(txt_:TextField)
    {
      super();
      
      _txt = txt_;
      
      onAdded(null);
      
      _txt.addEventListener(Event.ADDED, onAdded);
      _txt.addEventListener(Event.REMOVED, onRemoved);
      _txt.addEventListener(Event.CHANGE, onChange);
    }
    
    private function onAdded(event_:Event):void
    {
      var parent:DisplayObjectContainer = _txt.parent;
      if (parent && parent != this)
      { 
        var index:int = parent.getChildIndex(_txt);
        addChildAt(_txt, 0);
        parent.addChildAt(this, index);
      }
    }
    
    private function onRemoved(event_:Event):void
    {
      this.removeFromParent();
    }
    
    private function onChange(event_:Event):void
    {
      updateHyperlinkQuads();
    }
    
    private function updateHyperlinkQuads():void
    {
      if (_txt.hyperlinkQuads)
      {
        var hyperlinkQuad:HyperlinkQuad;
        const length:int = _txt.hyperlinkQuads.length;
        for (var i:int = 0; i < length; i++)
        {
          hyperlinkQuad = _txt.hyperlinkQuads[i];
          hyperlinkQuad.x = hyperlinkQuad.initialX + _txt.x;
          hyperlinkQuad.y = hyperlinkQuad.initialY + _txt.y;
          if (!hyperlinkQuad.parent)
          {
            addChild(hyperlinkQuad);
            hyperlinkQuad.addEventListener(Event.TRIGGERED, onTriggered);
          }
        }
      }
    }
    
    private function onTriggered(event_:Event):void
    {
      if (event_.data)
      {
        _txt.dispatchEventWith(Event.TRIGGERED, false, event_.data);
      }
    }
    
    override public function render(support:RenderSupport, parentAlpha:Number):void
    {
      if (_txt) _txt.redraw();
      super.render(support, parentAlpha);
    }
    
    public function get txt():TextField { return _txt; }
  }
}