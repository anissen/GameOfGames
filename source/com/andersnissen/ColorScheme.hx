
package com.andersnissen;

enum Color {
    TRANSPARENT;
    NAVY;
    BLUE;
    AQUA;
    TEAL;
    OLIVE;
    GREEN;
    LIME;
    YELLOW;
    ORANGE;
    RED;
    FUCHSIA;
    PURPLE;
    MAROON;
    WHITE;
    GRAY;
    SILVER;
    BLACK;
}

class ColorScheme
{
    static function getColor(color :Color): Int {
        return switch (color) {
            case TRANSPARENT: 0x00FFFFFF;
            case NAVY: 0xff001F3F;
            case BLUE: 0xff0074D9;
            case AQUA: 0xff7FDBFF;
            case TEAL: 0xff39CCCC;
            case OLIVE: 0xff3D9970;
            case GREEN: 0xff2ECC40;
            case LIME: 0xff01FF70;
            case YELLOW: 0xffFFDC00;
            case ORANGE: 0xffFF851B;
            case RED: 0xffFF4136;
            case FUCHSIA: 0xffF012BE;
            case PURPLE: 0xffB10DC9;
            case MAROON: 0xff85144B;
            case WHITE: 0xffffffff;
            case GRAY: 0xffaaaaaa;
            case SILVER: 0xffdddddd;
            case BLACK: 0xff111111;
            default: 0xffFF0000;
        }
    }

    // TODO: Make a fancy macro for expanding this:
    public static var TRANSPARENT :Int = getColor(Color.TRANSPARENT);
    public static var NAVY :Int = getColor(Color.NAVY);
    public static var BLUE :Int = getColor(Color.BLUE);
    public static var AQUA :Int = getColor(Color.AQUA);
    public static var TEAL :Int = getColor(Color.TEAL);
    public static var OLIVE :Int = getColor(Color.OLIVE);
    public static var GREEN :Int = getColor(Color.GREEN);
    public static var LIME :Int = getColor(Color.LIME);
    public static var YELLOW :Int = getColor(Color.YELLOW);
    public static var ORANGE :Int = getColor(Color.ORANGE);
    public static var RED :Int = getColor(Color.RED);
    public static var FUCHSIA :Int = getColor(Color.FUCHSIA);
    public static var PURPLE :Int = getColor(Color.PURPLE);
    public static var MAROON :Int = getColor(Color.MAROON);
    public static var WHITE :Int = getColor(Color.WHITE);
    public static var GRAY :Int = getColor(Color.GRAY);
    public static var SILVER :Int = getColor(Color.SILVER);
    public static var BLACK :Int = getColor(Color.BLACK);

    static var list :Array<Int> = [NAVY, BLUE, AQUA, TEAL, OLIVE, GREEN, LIME, YELLOW, ORANGE, RED, FUCHSIA, PURPLE, MAROON, WHITE, GRAY, SILVER, BLACK];

    public static function random() :Int
    {
        return flixel.util.FlxRandom.getObject(list);
    }

    public static function randomExcept(colors :Array<Int>) :Int
    {
        var newList = list.copy();
        for (c in colors) newList.remove(c);
        return flixel.util.FlxRandom.getObject(newList);
    }
}

class ColorSchemeBW 
{
    public static var TRANSPARENT :Int = 0x00FFFFFF;
    public static var GREEN :Int = 0xff2E2E2E;
    public static var YELLOW :Int = 0xffDCDCDC;
    public static var BLUE :Int = 0xff747474;
    public static var RED :Int = 0xff363636;
    public static var PURPLE :Int = 0xffB1B1B1;
    public static var BLACK :Int = 0xff111111;
    public static var WHITE :Int = 0xffDDDDDD;
}
