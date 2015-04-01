// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.text
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;
    import starling.utils.HAlign;
    import starling.utils.VAlign;
    
    import starling.text.hyperlink.Hyperlink;
    import starling.text.hyperlink.HyperlinkLocation;
    import starling.text.hyperlink.HyperlinkUtils;

    /** <p><i>NOTE: This class has been modified by: Jum, <a href="https://github.com/jumzijie">https://github.com/jumzijie</a></i></p>
     * 
     * The BitmapFont class parses bitmap font files and arranges the glyphs 
     *  in the form of a text.
     *
     *  The class parses the XML format as it is used in the 
     *  <a href="http://www.angelcode.com/products/bmfont/">AngelCode Bitmap Font Generator</a> or
     *  the <a href="http://glyphdesigner.71squared.com/">Glyph Designer</a>. 
     *  This is what the file format looks like:
     *
     *  <pre> 
     *  &lt;font&gt;
     *    &lt;info face="BranchingMouse" size="40" /&gt;
     *    &lt;common lineHeight="40" /&gt;
     *    &lt;pages&gt;  &lt;!-- currently, only one page is supported --&gt;
     *      &lt;page id="0" file="texture.png" /&gt;
     *    &lt;/pages&gt;
     *    &lt;chars&gt;
     *      &lt;char id="32" x="60" y="29" width="1" height="1" xoffset="0" yoffset="27" xadvance="8" /&gt;
     *      &lt;char id="33" x="155" y="144" width="9" height="21" xoffset="0" yoffset="6" xadvance="9" /&gt;
     *    &lt;/chars&gt;
     *    &lt;kernings&gt; &lt;!-- Kerning is optional --&gt;
     *      &lt;kerning first="83" second="83" amount="-4"/&gt;
     *    &lt;/kernings&gt;
     *  &lt;/font&gt;
     *  </pre>
     *  
     *  Pass an instance of this class to the method <code>registerBitmapFont</code> of the
     *  TextField class. Then, set the <code>fontName</code> property of the text field to the 
     *  <code>name</code> value of the bitmap font. This will make the text field use the bitmap
     *  font.  
     */ 
    public class BitmapFont
    {
        /** Use this constant for the <code>fontSize</code> property of the TextField class to 
         *  render the bitmap font in exactly the size it was created. */ 
        public static const NATIVE_SIZE:int = -1;
        
        /** The font name of the embedded minimal bitmap font. Use this e.g. for debug output. */
        public static const MINI:String = "mini";
        
        private static const CHAR_SPACE:int           = 32;
        private static const CHAR_TAB:int             =  9;
        private static const CHAR_NEWLINE:int         = 10;
        private static const CHAR_CARRIAGE_RETURN:int = 13;
        
        private var mTexture:Texture;
        private var mChars:Dictionary;
        private var mName:String;
        private var mSize:Number;
        private var mLineHeight:Number;
        private var mBaseline:Number;
        private var mOffsetX:Number;
        private var mOffsetY:Number;
        private var mHelperImage:Image;
        private var mCharLocationPool:Vector.<CharLocation>;
        
        /** Creates a bitmap font by parsing an XML file and uses the specified texture. 
         *  If you don't pass any data, the "mini" font will be created. */
        public function BitmapFont(texture:Texture=null, fontXml:XML=null)
        {
            // if no texture is passed in, we create the minimal, embedded font
            if (texture == null && fontXml == null)
            {
                texture = MiniBitmapFont.texture;
                fontXml = MiniBitmapFont.xml;
            }
            
            mName = "unknown";
            mLineHeight = mSize = mBaseline = 14;
            mOffsetX = mOffsetY = 0.0;
            mTexture = texture;
            mChars = new Dictionary();
            mHelperImage = new Image(texture);
            mCharLocationPool = new <CharLocation>[];
            
            if (fontXml) parseFontXml(fontXml);
        }
        
        /** Disposes the texture of the bitmap font! */
        public function dispose():void
        {
            if (mTexture)
                mTexture.dispose();
        }
        
        private function parseFontXml(fontXml:XML):void
        {
            var scale:Number = mTexture.scale;
            var frame:Rectangle = mTexture.frame;
            var frameX:Number = frame ? frame.x : 0;
            var frameY:Number = frame ? frame.y : 0;
            
            mName = fontXml.info.attribute("face");
            mSize = parseFloat(fontXml.info.attribute("size")) / scale;
            mLineHeight = parseFloat(fontXml.common.attribute("lineHeight")) / scale;
            mBaseline = parseFloat(fontXml.common.attribute("base")) / scale;
            
            if (fontXml.info.attribute("smooth").toString() == "0")
                smoothing = TextureSmoothing.NONE;
            
            if (mSize <= 0)
            {
                trace("[Starling] Warning: invalid font size in '" + mName + "' font.");
                mSize = (mSize == 0.0 ? 16.0 : mSize * -1.0);
            }
            
            for each (var charElement:XML in fontXml.chars.char)
            {
                var id:int = parseInt(charElement.attribute("id"));
                var xOffset:Number = parseFloat(charElement.attribute("xoffset")) / scale;
                var yOffset:Number = parseFloat(charElement.attribute("yoffset")) / scale;
                var xAdvance:Number = parseFloat(charElement.attribute("xadvance")) / scale;
                
                var region:Rectangle = new Rectangle();
                region.x = parseFloat(charElement.attribute("x")) / scale + frameX;
                region.y = parseFloat(charElement.attribute("y")) / scale + frameY;
                region.width  = parseFloat(charElement.attribute("width")) / scale;
                region.height = parseFloat(charElement.attribute("height")) / scale;
                
                var texture:Texture = Texture.fromTexture(mTexture, region);
                var bitmapChar:BitmapChar = new BitmapChar(id, texture, xOffset, yOffset, xAdvance); 
                addChar(id, bitmapChar);
            }
            
            for each (var kerningElement:XML in fontXml.kernings.kerning)
            {
                var first:int = parseInt(kerningElement.attribute("first"));
                var second:int = parseInt(kerningElement.attribute("second"));
                var amount:Number = parseFloat(kerningElement.attribute("amount")) / scale;
                if (second in mChars) getChar(second).addKerning(first, amount);
            }
        }
        
        /** Returns a single bitmap char with a certain character ID. */
        public function getChar(charID:int):BitmapChar
        {
            return mChars[charID];   
        }
        
        /** Adds a bitmap char with a certain character ID. */
        public function addChar(charID:int, bitmapChar:BitmapChar):void
        {
            mChars[charID] = bitmapChar;
        }
        
        /** Creates a sprite that contains a certain text, made up by one image per char. */
        public function createSprite(width:Number, height:Number, text:String,
                                     fontSize:Number=-1, color:uint=0xffffff, 
                                     hAlign:String="center", vAlign:String="center",      
                                     autoScale:Boolean=true, 
                                     kerning:Boolean=true):Sprite
        {
            var charLocations:Vector.<CharLocation> = arrangeChars(width, height, text, fontSize, 
                                                                   hAlign, vAlign, autoScale, kerning)[0];
            var numChars:int = charLocations.length;
            var sprite:Sprite = new Sprite();
            
            for (var i:int=0; i<numChars; ++i)
            {
                var charLocation:CharLocation = charLocations[i];
                var char:Image = charLocation.char.createImage();
                char.x = charLocation.x;
                char.y = charLocation.y;
                char.scaleX = char.scaleY = charLocation.scale;
                char.color = color;
                sprite.addChild(char);
            }
            
            return sprite;
        }
        
        /** Draws text into a QuadBatch. */
        public function fillQuadBatch(quadBatch:QuadBatch, width:Number, height:Number, text:String,
                                      //fontSize:Number=-1, color:uint=0xffffff, 
                                      fontSize:Number=-1, color:uint=0xffffff, hyperlinkColor:uint=0x0000ff, 
                                      hAlign:String="center", vAlign:String="center",      
                                      autoScale:Boolean=true, 
                                      //kerning:Boolean=true):void
                                      kerning:Boolean=true):Vector.<HyperlinkLocation>
        {
            // added by Jum -------  
            /*
            var charLocations:Vector.<CharLocation> = arrangeChars(width, height, text, fontSize, 
                                                                   hAlign, vAlign, autoScale, kerning);
            */
            var arrangedChars:Array = arrangeChars(width, height, text, fontSize, hAlign, vAlign, autoScale, kerning);
            var charLocations:Vector.<CharLocation> = arrangedChars[0];
            // end of added by Jum -------
            
            var numChars:int = charLocations.length;
            mHelperImage.color = color;
            
            if (numChars > 8192)
                throw new ArgumentError("Bitmap Font text is limited to 8192 characters.");
            
            // added by Jum -------
            var hyperlinkLocations:Vector.<HyperlinkLocation> = arrangedChars[1];
            const length:int = hyperlinkLocations ? hyperlinkLocations.length : -1;
            var updateColor:Boolean = false;
            // end of added by Jum -------
            
            for (var i:int=0; i<numChars; ++i)
            {
                var charLocation:CharLocation = charLocations[i];
                // added by Jum -------
                if (updateColor)
                {
                  updateColor = false;
                  mHelperImage.color = color;
                }
                for (var j:int=0; j<length; j++)
                {
                  if (charLocation == hyperlinkLocations[j].charLocation)
                  {
                    if (j % 2 == 0)
                    {
                      mHelperImage.color = hyperlinkColor;
                    }
                    else
                    {
                      updateColor = true;
                    }
                  }
                }
                // end of added by Jum -------
                mHelperImage.texture = charLocation.char.texture;
                mHelperImage.readjustSize();
                mHelperImage.x = charLocation.x;
                mHelperImage.y = charLocation.y;
                mHelperImage.scaleX = mHelperImage.scaleY = charLocation.scale;
                quadBatch.addImage(mHelperImage);
            }
            
            // added by Jum -------
            return hyperlinkLocations;
            // end of added by Jum -------
        }
        
        /** Arranges the characters of a text inside a rectangle, adhering to the given settings. 
         *  Returns a Vector of CharLocations. */
        private function arrangeChars(width:Number, height:Number, text:String, fontSize:Number=-1,
                                      hAlign:String="center", vAlign:String="center",
                                      //autoScale:Boolean=true, kerning:Boolean=true):Vector.<CharLocation>
                                      autoScale:Boolean=true, kerning:Boolean=true):Array
        {
            // added by Jum -------
            var hyperlinks:Vector.<Hyperlink>;
            var hyperlinkIndex:int;
            var hyperlink:Hyperlink;
            var hasHyperlink:Boolean = HyperlinkUtils.hasHyperlink(text);
            var hyperlinkLocations:Vector.<HyperlinkLocation>;
            var addHyperlinkLocation:Boolean;
            if (hasHyperlink)
            {
              hyperlinks = HyperlinkUtils.extractHyperlinks(text);
              hyperlinkLocations = new Vector.<HyperlinkLocation>();
              text = HyperlinkUtils.removeHyperlink(text);
            }
            
            //if (text == null || text.length == 0) return new <CharLocation>[];
            if (text == null || text.length == 0) return [new <CharLocation>[], null];
            // end of added by Jum -------
            if (fontSize < 0) fontSize *= -mSize;
            
            var lines:Array = [];
            var finished:Boolean = false;
            var charLocation:CharLocation;
            var numChars:int;
            var containerWidth:Number;
            var containerHeight:Number;
            var scale:Number;
            
            while (!finished)
            {
                // added by Jum -------
                if (hasHyperlink)
                {
                  hyperlinkIndex = 0;
                  hyperlink = hyperlinks[hyperlinkIndex];
                  hyperlinkLocations.splice(0, hyperlinkLocations.length);
                }
                // end of added by Jum -------
              
                lines.length = 0;
                scale = fontSize / mSize;
                containerWidth  = width / scale;
                containerHeight = height / scale;
                
                if (mLineHeight <= containerHeight)
                {
                    var lastWhiteSpace:int = -1;
                    var lastCharID:int = -1;
                    var currentX:Number = 0;
                    var currentY:Number = 0;
                    var currentLine:Vector.<CharLocation> = new <CharLocation>[];
                    
                    numChars = text.length;
                    for (var i:int=0; i<numChars; ++i)
                    {
                        var lineFull:Boolean = false;
                        var charID:int = text.charCodeAt(i);
                        var char:BitmapChar = getChar(charID);
                        
                        if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
                        {
                            lineFull = true;
                        }
                        else if (char == null)
                        {
                            trace("[Starling] Missing character: " + charID);
                        }
                        else
                        {
                            if (charID == CHAR_SPACE || charID == CHAR_TAB)
                                lastWhiteSpace = i;
                            
                            if (kerning)
                                currentX += char.getKerning(lastCharID);
                            
                            charLocation = mCharLocationPool.length ?
                                mCharLocationPool.pop() : new CharLocation(char);
                            
                            charLocation.char = char;
                            charLocation.x = currentX + char.xOffset;
                            charLocation.y = currentY + char.yOffset;
                            currentLine.push(charLocation);
                            
                            currentX += char.xAdvance;
                            lastCharID = charID;
                            
                            if (addHyperlinkLocation)
                            {
                              addHyperlinkLocation = false;
                              hyperlinkLocations.push(new HyperlinkLocation(currentLine[currentLine.length - 1], hyperlink.link, true));
                            }
                            
                            if (charLocation.x + char.width > containerWidth)
                            {
                                // when autoscaling, we must not split a word in half -> restart
                                if (autoScale && lastWhiteSpace == -1)
                                    break;

                                // remove characters and add them again to next line
                                var numCharsToRemove:int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
                                var removeIndex:int = currentLine.length - numCharsToRemove;
                                
                                currentLine.splice(removeIndex, numCharsToRemove);
                                
                                if (currentLine.length == 0)
                                    break;
                                
                                i -= numCharsToRemove;
                                lineFull = true;
                                
                                // added by Jum -------
                                if (hasHyperlink)
                                {
                                  if (hyperlink && i < hyperlink.startIndex && (i + numCharsToRemove) > hyperlink.startIndex)
                                  {
                                    hyperlinkLocations.pop();
                                  }
                                  if (hyperlinkLocations.length % 2 == 1)
                                  {
                                    addHyperlinkLocation = true;
                                    var index:int = 1;
                                    while (currentLine[currentLine.length - index].char.charID == CHAR_SPACE ||
                                      currentLine[currentLine.length - index].char.charID == CHAR_TAB)
                                    {
                                      index++;
                                    }
                                    hyperlinkLocations.push(new HyperlinkLocation(currentLine[currentLine.length - index], hyperlink.link));
                                  }
                                }
                                // end of added by Jum -------
                            }
                            
                            // added by Jum -------
                            else if (hasHyperlink)
                            {
                              if (hyperlink && i == hyperlink.startIndex)
                              {
                                hyperlinkLocations.push(new HyperlinkLocation(charLocation, hyperlink.link));
                              }
                              else if (hyperlink && i == hyperlink.endIndex - 1)
                              {
                                hyperlinkLocations.push(new HyperlinkLocation(charLocation, hyperlink.link));
                                hyperlinkIndex++;
                                if (hyperlinkIndex < hyperlinks.length)
                                {
                                  hyperlink = hyperlinks[hyperlinkIndex];
                                }
                                else
                                {
                                  hyperlink = null;
                                }
                              }
                            }
                            // end of added by Jum -------
                        }
                        
                        if (i == numChars - 1)
                        {
                            lines.push(currentLine);
                            finished = true;
                        }
                        else if (lineFull)
                        {
                            lines.push(currentLine);
                            
                            if (lastWhiteSpace == i)
                                currentLine.pop();
                            
                            if (currentY + 2*mLineHeight <= containerHeight)
                            {
                                currentLine = new <CharLocation>[];
                                currentX = 0;
                                currentY += mLineHeight;
                                lastWhiteSpace = -1;
                                lastCharID = -1;
                            }
                            else
                            {
                                break;
                            }
                        }
                    } // for each char
                } // if (mLineHeight <= containerHeight)
                
                if (autoScale && !finished && fontSize > 3)
                  fontSize -= 1;
                else
                    finished = true; 
            } // while (!finished)
            
            var finalLocations:Vector.<CharLocation> = new <CharLocation>[];
            var numLines:int = lines.length;
            var bottom:Number = currentY + mLineHeight;
            var yOffset:int = 0;
            
            if (vAlign == VAlign.BOTTOM)      yOffset =  containerHeight - bottom;
            else if (vAlign == VAlign.CENTER) yOffset = (containerHeight - bottom) / 2;
            
            for (var lineID:int=0; lineID<numLines; ++lineID)
            {
                var line:Vector.<CharLocation> = lines[lineID];
                numChars = line.length;
                
                if (numChars == 0) continue;
                
                var xOffset:int = 0;
                var lastLocation:CharLocation = line[line.length-1];
                var right:Number = lastLocation.x - lastLocation.char.xOffset 
                                                  + lastLocation.char.xAdvance;
                
                if (hAlign == HAlign.RIGHT)       xOffset =  containerWidth - right;
                else if (hAlign == HAlign.CENTER) xOffset = (containerWidth - right) / 2;
                
                for (var c:int=0; c<numChars; ++c)
                {
                    charLocation = line[c];
                    charLocation.x = scale * (charLocation.x + xOffset + mOffsetX);
                    charLocation.y = scale * (charLocation.y + yOffset + mOffsetY);
                    charLocation.scale = scale;
                    
                    if (charLocation.char.width > 0 && charLocation.char.height > 0)
                        finalLocations.push(charLocation);
                    
                    // return to pool for next call to "arrangeChars"
                    mCharLocationPool.push(charLocation);
                }
            }
            
            //return finalLocations;
            return [finalLocations, hyperlinkLocations];
        }
        
        /** The name of the font as it was parsed from the font file. */
        public function get name():String { return mName; }
        
        /** The native size of the font. */
        public function get size():Number { return mSize; }
        
        /** The height of one line in points. */
        public function get lineHeight():Number { return mLineHeight; }
        public function set lineHeight(value:Number):void { mLineHeight = value; }
        
        /** The smoothing filter that is used for the texture. */ 
        public function get smoothing():String { return mHelperImage.smoothing; }
        public function set smoothing(value:String):void { mHelperImage.smoothing = value; } 
        
        /** The baseline of the font. This property does not affect text rendering;
         *  it's just an information that may be useful for exact text placement. */
        public function get baseline():Number { return mBaseline; }
        public function set baseline(value:Number):void { mBaseline = value; }
        
        /** An offset that moves any generated text along the x-axis (in points).
         *  Useful to make up for incorrect font data. @default 0. */ 
        public function get offsetX():Number { return mOffsetX; }
        public function set offsetX(value:Number):void { mOffsetX = value; }
        
        /** An offset that moves any generated text along the y-axis (in points).
         *  Useful to make up for incorrect font data. @default 0. */
        public function get offsetY():Number { return mOffsetY; }
        public function set offsetY(value:Number):void { mOffsetY = value; }
    }
}

/*
import starling.text.BitmapChar;

class CharLocation
{
    public var char:BitmapChar;
    public var scale:Number;
    public var x:Number;
    public var y:Number;
    
    public function CharLocation(char:BitmapChar)
    {
        this.char = char;
    }
}
*/