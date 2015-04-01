package
{
  import starling.errors.AbstractClassError;

  public class Fonts
  {
    public function Fonts() { throw new AbstractClassError(); }
    
    [Embed(source="../assets/fonts/arial_0.png")]
    public static const arial_0:Class;
    
    [Embed(source="../assets/fonts/arial.fnt", mimeType="application/octet-stream")]
    public static const arial_fnt:Class;
    
    // Starling 1.4 now uses texture file name as name for bitmap font.
    public static const ARIAL:String    = "arial_0";
    
  }
}