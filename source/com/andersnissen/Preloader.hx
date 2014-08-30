
package com.andersnissen;

import flixel.system.FlxBasePreloader;
import flash.display.*;
import flash.text.*;
import flash.Lib;
import openfl.display.Sprite;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
 
// @:bitmap("assets/images/CustomPreload/gamepopper-logo.png") class LogoImage extends BitmapData { }
// @:font("assets/data/GameBoy.ttf") class CustomFont extends Font {}
 
class Preloader extends FlxBasePreloader
{
    // #if !js
    var logo:Sprite;
    var text:TextField;

    public override function new(minDisplayTime :Float = 5, ?allowedURLs:Array<String>) 
    {
        super(minDisplayTime, allowedURLs);
        trace("PRELOADER new");
    }
     
    override function create():Void 
    {
        trace("PRELOADER create");

        this._width = Lib.current.stage.stageWidth;
        this._height = Lib.current.stage.stageHeight;
         
        var ratio :Float = this._width / Settings.WIDTH; //This allows us to scale assets depending on the size of the screen.
         
        logo = new Sprite();
        logo.addChild(new Bitmap(new LogoImage(0,0))); //Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
        logo.scaleX = logo.scaleY = ratio;
        logo.x = ((this._width) / 2) - ((logo.width) / 2);
        logo.y = (this._height / 2) - ((logo.height) / 2);
        addChild(logo); //Adds the graphic to the NMEPreloader's buffer.
         
        Font.registerFont(CustomFont);
        text = new TextField();
        text.defaultTextFormat = new TextFormat("Early GameBoy Regular", Std.int(24 * ratio), 0xffffff, false, false, false, "", "", TextFormatAlign.CENTER);
        text.embedFonts = true;
        text.selectable = false;
        text.multiline = false;
        text.x = 0;
        text.y = 5.2 * this._height / 6;
        text.width = _width;
        text.height = Std.int(32 * ratio);
        text.text = "Loading";
        addChild(text);
         
        super.create();
    }
     
    override function update(percent :Float):Void 
    {
        text.text = "Loading " + Std.int(percent * 100) + "%";
        super.update(percent);
    }
    // #end
}
