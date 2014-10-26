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
    static var trainingScoresMap :Map<String, Int>;

    public static function init() {
        saves.push(new FlxSave());
        Reg.save.bind("save1");
        if (Reg.save.data.trainingHighscores == null) {
            trainingScoresMap = new Map<String, Int>();
        } else {
            trainingScoresMap = Reg.save.data.trainingHighscores;
        }
        highscore = Reg.save.data.highscore;

        gameManager = new GameSessionManager(gameList);
        gameSession = new GameSession();
    }

    public static var score :Int = 0;
    public static var highscore(default, set) :Int = 0;

    public static function set_highscore(s :Int) :Int {
        highscore = s;
        Reg.save.data.highscore = s;
        Reg.save.flush();
        return s;
    }

    public static function getTrainingHighscore(gameId :String) :Null<Int> {
        return trainingScoresMap.get(gameId);
    }

    public static function setTrainingHighscore(gameId :String, s :Int) {
        trainingScoresMap.set(gameId, s);
        Reg.save.data.trainingHighscores = trainingScoresMap;
        Reg.save.flush();
    }

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

    public static var gameList :Array<Class<GameState>> = [RobotVacuumCleaner, HexChain, Jump, MultiTouch, Bounce, Overlap, CollectDots /* Lasers, */ ];
}
