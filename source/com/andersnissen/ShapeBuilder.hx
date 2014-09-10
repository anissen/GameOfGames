package com.andersnissen;

import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class ShapeBuilder
{
    public static function createRect(x :Float, y :Float, width :Int, height :Int, color :Int, ?borderColor :Int = FlxColor.BLACK, ?borderWidth :Int = 2) :FlxSprite
    {
        return new FlxSprite(x, y)
            .makeGraphic(width, height, borderColor)
            .drawRect(borderWidth, borderWidth, width - borderWidth * 2, height - borderWidth * 2, color);
    }

    public static function createCircle(x :Float, y :Float, radius :Int, color :Int, ?borderColor :Int = FlxColor.BLACK, ?borderWidth :Int = 2) :FlxSprite
    {
        return new FlxSprite(x, y)
            .makeGraphic(radius * 2, radius * 2, ColorScheme.TRANSPARENT)
            .drawCircle(radius, radius, radius, borderColor)
            .drawCircle(radius, radius, radius - borderWidth, color);
    }
}
