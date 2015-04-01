package view.scenes
{
  import flash.utils.getQualifiedClassName;
  
  import starling.display.Quad;
  import starling.display.Sprite;
  import starling.events.TouchEvent;
  import starling.events.TouchPhase;
  import starling.text.TextField;
  
  import view.display.Popup;
  
  public class Scene extends Sprite
  {
    private var _txtTouchCount:TextField;
    
    public function Scene()
    {
      super();
    }
    
    public function init():void {}
    public function deinit():void {}
    
    public function onAndroidBackButton():void
    {
      if (!Popup.instance.parent)
      {
        Popup.instance.setData("Exit?", Main.exitApp);
      }
      else
      {
        Popup.instance.hide();
      }
    }
    
    protected function addBackground():void
    {
      addChild(new Quad(Main.WIDTH, Main.HEIGHT, 0xeeeeee));
    }
    
    protected function addTitle():void
    {
      var className:String = getQualifiedClassName(this);
      className = className.substring(className.indexOf("::") + 2);
      addChild(new TextField(Main.WIDTH, 50, className, Fonts.ARIAL, 36, 0xcc0000));
    }
    
  }
}