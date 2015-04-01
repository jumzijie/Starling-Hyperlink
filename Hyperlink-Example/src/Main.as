package
{
  import flash.desktop.NativeApplication;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.geom.Rectangle;
  import flash.system.Capabilities;
  import flash.ui.Keyboard;
  
  import starling.core.Starling;
  import starling.events.Event;
  import starling.textures.Texture;
  import starling.utils.AssetManager;
  
  [SWF(frameRate="60", backgroundColor="#eeeeee")]
  public class Main extends Sprite
  {
    public static var WIDTH:int   = 320;
    public static var HEIGHT:int  = 480;
    
    // Startup image for SD screens
    [Embed(source="../assets/startup.png")]
    private static var Background:Class;
    
    // Startup image for HD screens
    [Embed(source="../assets/startupHD.png")]
    private static var BackgroundHD:Class;
    
    private var _starling:Starling;
    private var _root:Root;
    
    public function Main()
    {
      WIDTH = 320;
      HEIGHT = Math.ceil(stage.fullScreenHeight / stage.fullScreenWidth * 320);
      
      // set general properties
      var stageWidth:int   = WIDTH;
      var stageHeight:int  = HEIGHT;
      var iOS:Boolean      = Capabilities.manufacturer.indexOf("iOS") != -1;
      
      Starling.multitouchEnabled = true;  // useful on mobile devices
      Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory! unless if CameraUI is used.
      
      var viewPort:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
      
      if (iOS)
      {
        viewPort.y = 40;
        viewPort.height -= 40;
      }
      
      var scaleFactor:int = viewPort.width <= 320 ? 1 : 2;
      var assets:AssetManager = new AssetManager(scaleFactor, true);
      assets.verbose = Capabilities.isDebugger;
      
      var backgroundClass:Class = scaleFactor == 1 ? Background : BackgroundHD;
      var background:Bitmap = new backgroundClass();
      Background = BackgroundHD = null; // no longer needed!
      
      background.width = viewPort.width;
      background.scaleY = background.scaleX;
      background.x = (viewPort.width - background.width) / 2;
      background.y = (viewPort.height - background.height) / 2;
      background.smoothing = true;
      addChild(background);
      
      // launch Starling
      _starling = new Starling(Root, stage, viewPort);
      _starling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
      _starling.stage.stageHeight = stageHeight; // <- same size on all devices!
      _starling.simulateMultitouch  = false;
      _starling.enableErrorChecking = Capabilities.isDebugger;
      if (Capabilities.isDebugger)
      {
        //_starling.showStats = true;
        //_starling.showStatsAt("right", "top");
      }
      _starling.antiAliasing = 1;
      _starling.addEventListener(starling.events.Event.ROOT_CREATED,
        function(event_:Object, app_:Root):void
        {
          _root = app_;
          
          _starling.removeEventListener(starling.events.Event.ROOT_CREATED, arguments.callee);
          removeChild(background);
          background = null;
          
          var bgTexture:Texture = Texture.fromEmbeddedAsset(backgroundClass, false, false, scaleFactor);
          
          app_.start(bgTexture, assets);
          _starling.start();
        });
      
      // When the game becomes inactive, we pause Starling; otherwise, the enter frame event
      // would report a very long 'passedTime' when the app is reactivated.
      NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onActivate);
      
      NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
      
      // Prevent the game from exitting when BACK button is pressed for Android
      NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
    }
    
    private function onActivate(e:flash.events.Event):void
    {
      _starling.start();
      if (stage) stage.quality = stage.quality;
      if (_root) _root.reactivate();
    }
    
    private function onDeactivate(e:flash.events.Event):void
    {
      _starling.stop();
      if (_root) _root.deactivate();
    }
    
    private function onKeyPressed(e:KeyboardEvent):void
    {
      switch (e.keyCode)
      {
        case Keyboard.BACK:
          e.preventDefault();
          _root.onAndroidBackButton();
          break;
      }
    }
    
    public static function exitApp():void
    {
      NativeApplication.nativeApplication.exit();
    }
    
    public static function get isDebugger():Boolean { return Capabilities.isDebugger; }
  }
}