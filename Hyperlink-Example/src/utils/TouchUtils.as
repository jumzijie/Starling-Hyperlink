package utils
{
  import flash.geom.Point;
  
  import starling.display.DisplayObject;
  import starling.events.Touch;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  
  /** @author Jum */
  public class TouchUtils
  {
    public static function checkTouchEnded(touchEvent:TouchEvent, touchTarget:DisplayObject, checkForWithinBounds:Boolean = true):Boolean
    {
      return checkTouch(touchEvent, touchTarget, TouchPhase.ENDED, checkForWithinBounds);
    }
    
    public static function checkTouchMoved(touchEvent:TouchEvent, touchTarget:DisplayObject, checkForWithinBounds:Boolean = true):Boolean
    {
      return checkTouch(touchEvent, touchTarget, TouchPhase.MOVED, checkForWithinBounds);
    }
    
    private static function checkTouch(touchEvent:TouchEvent, touchTarget:DisplayObject, touchPhase:String, checkForWithinBounds:Boolean = true):Boolean
    {
      var touch:Touch = touchEvent.getTouch(touchTarget, touchPhase);
      if (touch)
      {
        if (checkForWithinBounds)
        {
          var touchPoint:Point = touch.getLocation(touchTarget.parent);
          if (touchTarget.bounds.contains(touchPoint.x, touchPoint.y))
          {
            return true;
          }
        }
        else
        {
          return true;
        }
      }
      return false;
    }
    
  }
}