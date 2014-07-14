package com.andersnissen;

import flixel.util.FlxRandom;
import flixel.util.FlxSave;
import com.andersnissen.states.GameState;
import com.andersnissen.games.*;

// import GameState;

// typedef Array<Class<states.GameState>> GameList

class GameManager
{
    var gameList :Array<Class<GameState>> = [];
    var gamesUnlocked :Array<Class<GameState>> = [];
    var gamesPlayed :Array<Class<GameState>> = [];
    var currentGameBatch :Array<Class<GameState>> = [];

    var _gameSave :FlxSave;

    // public var onGameUnlocked :flixel.util.FlxSignal;

    public function new() :Void
    {
        _gameSave = new FlxSave();
        _gameSave.bind("GamesUnlocked");

        gameList = [Jump, CollectDots, Bounce, Lasers, Overlap];

        var unlockCount :Int = (_gameSave.data.unlockCount != null ? _gameSave.data.unlockCount : 0);
        gamesUnlocked = gameList.slice(0, unlockCount);
        trace('Unlock count: $unlockCount');
        // onGameUnlocked = new flixel.util.FlxSignal();
    }

    function getNextGameClass() :Class<GameState>
    {
        // completed entire batch of games
        if (currentGameBatch.length == 0) {
            currentGameBatch = createGameBatch();

            var gamesPlayedThisSession = gamesPlayed.length;
            var hasMoreLockedGames = (gameList.length > gamesUnlocked.length);
            // Only unlock games if enough games have been played in this session
            if (hasMoreLockedGames && gamesPlayedThisSession >= gamesUnlocked.length) {
                var unlockedGame = unlockNextGame();
                currentGameBatch.unshift(unlockedGame); // Add the new game as the first in the batch
            }

            var batchString = [for (g in currentGameBatch) getGameName(g)].join(", ");
            trace('currentGameBatch: [$batchString]');
        }

        var nextGame = currentGameBatch.shift();
        gamesPlayed.push(nextGame);
        return nextGame;
    }

    function createGameBatch() :Array<Class<GameState>>
    {
        if (currentGameBatch.length > 0) throw "currentGameBatch is non-empty";

        var lastPlayedGame = gamesPlayed[gamesPlayed.length - 1];
        trace('lastPlayedGame: ${Type.getClassName(lastPlayedGame)}');
        var gameBatch :Array<Class<GameState>> = FlxRandom.shuffleArray(gamesUnlocked.copy(), gamesUnlocked.length * 3);
        if (gameBatch.length > 0 && gameBatch[0] == lastPlayedGame) {
            gameBatch.shift();
            gameBatch.insert(FlxRandom.intRanged(1, gameBatch.length), lastPlayedGame);
        }

        return gameBatch;
    }

    function unlockNextGame() :Class<GameState>
    {
        var unlockedGame = gameList[gamesUnlocked.length];
        gamesUnlocked.push(unlockedGame);

        _gameSave.data.unlockCount = gamesUnlocked.length;
        _gameSave.flush();
        trace('Unlocked new game: ${getGameName(unlockedGame)}');
        // onGameUnlocked.dispatch();

        return unlockedGame;
    }

    function getGameName(cls :Class<GameState>) :String 
    {
        var qualifiedName = Type.getClassName(cls);
        var lastDotPos = qualifiedName.lastIndexOf(".");
        if (lastDotPos < 0) return qualifiedName;
        return qualifiedName.substr(lastDotPos + 1);
    }

    public function getNextGame() :GameState
    {
        return Type.createInstance(getNextGameClass(), []);
    }

    public function getGamesPlayedList() :Array<String>
    {
        return [for (g in gamesPlayed) getGameName(g)];
    }

    public function reset() :Void
    {
        gamesPlayed = [];
        currentGameBatch = [];

        _gameSave.data.unlockCount = 0;
        _gameSave.flush();
    }
}
