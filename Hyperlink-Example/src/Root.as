package
{
  import flash.filesystem.File;
  import flash.geom.Rectangle;
  import flash.media.AudioPlaybackMode;
  import flash.media.SoundMixer;
  import flash.system.System;
  
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.display.Image;
  import starling.display.Quad;
  import starling.display.Sprite;
  import starling.textures.Texture;
  import starling.utils.AssetManager;
  
  import view.display.ProgressBar;
  import view.scenes.*;
  
  public class Root extends Sprite
  {
    private static var _assets:AssetManager;
    
    private var _isIntroComplete:Boolean;
    private var _progressBar:ProgressBar;
    
    private var _activeScene:Scene;
    
    public function Root()
    {
    }
    
    public function start(background_:Texture, assets_:AssetManager):void
    {
      // the asset manager is saved as a static variable; this allows us to easily access
      // all the assets from everywhere by simply calling "Root.assets"
      _assets = assets_;
      
      // The background is passed into this method for two reasons:
      //
      // 1) we need it right away, otherwise we have an empty frame
      // 2) the Startup class can decide on the right image, depending on the device.
      var bg:Image = new Image(background_);
      bg.x = (Main.WIDTH - bg.width) / 2;
      bg.y = (Main.HEIGHT - (Starling.current.viewPort.y / 2) - bg.height) / 2;
      addChild(bg);
      
      // because we are not using fullscreen for this app,
      // we need to redefine the height we are allocated
      // AFTER we have set the background image on stage
      Main.HEIGHT = Starling.current.nativeStage.stageHeight / Starling.current.nativeStage.stageWidth * 320;
      
      loadAssets();
      
      _isIntroComplete = false;
      if (!Main.isDebugger) Starling.juggler.delayCall(fadeOut, 1, bg);
      else
      {
        bg.removeFromParent(true);
        fadeComplete();
      }
    }
    
    public function deactivate():void
    {
    }
    
    public function reactivate():void
    {
    }
    
    public function onAndroidBackButton():void
    {
      if (_activeScene)
      {
        _activeScene.onAndroidBackButton();
      }
      else
      {
        Main.exitApp();
      }
    }
    
    private function loadAssets():void
    {
      if (!_progressBar)
      {
        _progressBar = new ProgressBar(Main.WIDTH * 0.6, 20);
        _progressBar.x = (Main.WIDTH - _progressBar.width) / 2;
        _progressBar.y = Main.HEIGHT * 0.8;
      }
      _progressBar.ratio = 0.01;
      
      var appDir:File = File.applicationDirectory;
      assets.enqueue(appDir.resolvePath("fonts"));
      assets.enqueue(appDir.resolvePath("audio"));
      assets.loadQueue(onProgress);
    }
    
    private function onProgress(ratio_:Number):void
    {
      _progressBar.ratio = ratio_;
      if (ratio_ == 1)
      {
        Starling.juggler.delayCall(function():void
        {
          _progressBar.removeFromParent();
          
          // Do complete here
          firstLoad();
          
          // now would be a good time for a clean-up 
          System.pauseForGCIfCollectionImminent(0);
          System.gc();
        }, 0.15);
      }
    }
    
    private function fadeOut(bg_:Image):void
    {
      var tween:Tween = new Tween(bg_, 1);
      tween.fadeTo(0);
      tween.onComplete = function():void
      {
        Starling.juggler.remove(tween);
        tween = null;
        bg_.removeFromParent(true);
        
        _isIntroComplete = true;
        Starling.juggler.delayCall(fadeComplete, 0.5);
      };
      Starling.juggler.add(tween);
    }
    
    private function fadeComplete():void
    {
      _isIntroComplete = true;
      if (_progressBar && _progressBar.ratio < 1)
      {
        addChild(_progressBar);
      }
      firstLoad();
    }
    
    private function firstLoad():void
    {
      if (_isIntroComplete && _progressBar && _progressBar.ratio == 1)
      {
        SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
        
        // initialize Constants
        Constants;
        
        // add white quad as background
        var quad:Quad = new Quad(Main.WIDTH, Main.HEIGHT);
        addChild(quad);
        
        showScene(HomeScene);
      }
    }
    
    private function showScene(sceneClass:Class):void
    {
      removeScene();
      _activeScene = new sceneClass();
      addChild(_activeScene);
      _activeScene.init();
    }
    
    private function removeScene():void
    {
      if (_activeScene)
      {
        _activeScene.deinit();
        _activeScene.removeFromParent(true);
        _activeScene = null;
      }
    }
    
    public static function get instance():Root { return Starling.current.root as Root; }
    public static function get assets():AssetManager { return _assets; }
    
  }
}