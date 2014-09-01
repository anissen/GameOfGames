package com.andersnissen;

import com.andersnissen.Settings;
import com.andersnissen.states.MenuState;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.addons.transition.TransitionData;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;

@:font("assets/fonts/kenvector_future.ttf") private class DefaultFont extends openfl.text.Font {}

class Main extends Sprite 
{
	var gameWidth :Int = Settings.WIDTH; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight :Int = Settings.HEIGHT; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState :Class<FlxState> = MenuState; // The FlxState the game starts with.
	var zoom :Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate :Int = 60; // How many frames per second the game should run at.
	var skipSplash :Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen :Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		setupGame();
	}
	
	private function setupGame():Void
	{
		var stageWidth :Int = Lib.current.stage.stageWidth;
		var stageHeight :Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX :Float = stageWidth / gameWidth;
			var ratioY :Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

        FlxG.stage.quality = flash.display.StageQuality.BEST;

        openfl.text.Font.registerFont(DefaultFont);
        flixel.system.FlxAssets.FONT_DEFAULT = new DefaultFont().fontName;

        FlxTransitionableState.defaultTransIn = new TransitionData();
        FlxTransitionableState.defaultTransOut = new TransitionData();
        FlxTransitionableState.defaultTransIn.type = TransitionType.TILES;
        FlxTransitionableState.defaultTransIn.color = com.andersnissen.ColorScheme.random();
        FlxTransitionableState.defaultTransOut.type = TransitionType.TILES;
        FlxTransitionableState.defaultTransOut.color = com.andersnissen.ColorScheme.random();
        FlxTransitionableState.defaultTransIn.tileData = { asset:GraphicTransTileDiamond, width:32, height:32 };
        FlxTransitionableState.defaultTransOut.tileData = { asset:GraphicTransTileDiamond, width:32, height:32 };

        Reg.gameManager = new GameSessionManager(Reg.gameList);
        Reg.networkManager = new NetworkManager();
        Reg.gameSession = new GameSession();
        Reg.networkManager.connect();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
	}
}
