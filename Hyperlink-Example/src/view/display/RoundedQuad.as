package view.display
{
  import flash.display.BitmapData;
  import flash.display.Shape;
  
  import starling.core.Starling;
  import starling.display.Image;
  import starling.textures.Texture;
  
  /** @author Jum */
  public class RoundedQuad extends Image
  {
    private var _width:Number;
    private var _height:Number;
    private var _roundAmount:Number;
    private var _color:uint;
    
    public function RoundedQuad(width:Number, height:Number, roundAmount:Number, color:uint=0xffffff)
    {
      _width = width;
      _height = height;
      _roundAmount = roundAmount;
      _color = color;
      
      super(drawTexture(width, height));
    }
    
    private function drawTexture(width:Number, height:Number):Texture
    {
      return getTexture(width, height, _roundAmount, _color);
    }
    
    public function redraw(width:Number, height:Number):void
    {
      _width = width;
      _height = height;
      this.texture = drawTexture(width, height);
      this.readjustSize();
    }
    
    public function get roundAmount():Number { return _roundAmount; }
    public function set roundAmount(value:Number):void
    {
      _roundAmount = value;
      redraw(_width, _height);
    }
    
    override public function get color():uint { return _color; }
    override public function set color(value:uint):void
    {
      _color = value;
      redraw(_width, _height);
    }
    
    /**
    * @param yModifier_: Moves the texture by this amount on the y-axis. Note, the output height will be changed by this amount.
    */
    public static function getTextureWithShadow(width:Number, height:Number, roundAmount:Number, color:uint, shadowColor:uint, shadowHeight:Number=2, yModifier_:Number=0):Texture
    {
      return getCustomTexture(width, height, roundAmount, color, yModifier_, shadowHeight, shadowColor);
    }
    
    /**
     * @param yModifier_: Moves the texture by this amount on the y-axis. Note, the output height will be changed by this amount.
     */
    public static function getTexture(width:Number, height:Number, roundAmount:Number, color:uint, yModifier_:Number=0):Texture
    {
      return getCustomTexture(width, height, roundAmount, color, yModifier_);
    }
    
    private static function getCustomTexture(width:Number, height:Number, roundAmount:Number, color:uint, yModifier_:Number=0, shadowHeight:Number=0, shadowColor:uint=0x0):Texture
    {
      var scale:Number = Starling.contentScaleFactor;
      while (width * scale > 2048 || height * scale > 2048)
      {
        scale -= 0.1;
      }
      
      var bgShape:Shape = new Shape();
      if (shadowHeight > 0)
      {
        bgShape.graphics.beginFill(shadowColor);
        bgShape.graphics.drawRoundRect(0, (yModifier_ + shadowHeight) * scale, width * scale, (height - shadowHeight) * scale, roundAmount, roundAmount);
        bgShape.graphics.endFill();
        
        bgShape.graphics.beginFill(color);
        bgShape.graphics.drawRoundRect(0, yModifier_ * scale, width * scale, (height - shadowHeight) * scale, roundAmount, roundAmount);
        bgShape.graphics.endFill();
      }
      else
      {
        bgShape.graphics.beginFill(color);
        bgShape.graphics.drawRoundRect(0, (yModifier_ * scale), width * scale, height * scale, roundAmount, roundAmount);
        bgShape.graphics.endFill();
      }
      
      var bgBitmapData:BitmapData = new BitmapData(width * scale, (yModifier_ + height) * scale, true, 0x0);
      bgBitmapData.draw(bgShape);
      return Texture.fromBitmapData(bgBitmapData, false, false, scale);
    }
    
  }
}