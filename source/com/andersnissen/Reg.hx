package com.andersnissen;

import com.andersnissen.states.GameState;
import com.andersnissen.games.*;
import flixel.effects.postprocess.PostProcess;
import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
    public static function init() {
        saves.push(new FlxSave());
        Reg.save.bind("save1");
        highscore = Reg.save.data.highscore;

        gameManager = new GameSessionManager(gameList);
        // networkManager = new NetworkManager();
        gameSession = new GameSession();
        // networkManager.connect();

    }

	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels :Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level :Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores :Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
    public static var score :Int = 0;
    public static var highscore(default, set) :Int = 0;

    public static function set_highscore(s :Int) :Int {
        trace('highscore: $s');
        highscore = s;
        Reg.save.data.highscore = s;
        Reg.save.flush();
        return s;
    }

    public static var speed :Float = 0;
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	private static var saves :Array<FlxSave> = [];

    public static var save(get, null) :FlxSave;

    public static function get_save() {
        return saves[0];
    }

    public static var gameManager :GameSessionManager;
    public static var networkManager :NetworkManager;
    public static var gameSession :GameSession;

    public static var gameList :Array<Class<GameState>> = [HexChain, Jump, MultiTouch, Bounce, Overlap, CollectDots, Lasers];

    // public static var vignette :PostProcess;

    public static function setPostprocessingAmount(amount :Float) {
        // placeholder
        // amount = Math.clamp(amount, 0.0, 1.0));
        // vignette.setUniform("amount", Settings.VIGNETTE_DEFAULT + (Settings.VIGNETTE_MAX - Settings.VIGNETTE_DEFAULT) * amount);
    }
}
