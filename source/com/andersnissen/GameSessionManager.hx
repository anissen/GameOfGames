package com.andersnissen;

import flixel.FlxG;
import flixel.util.FlxSave;
import com.andersnissen.states.GameState;
import com.andersnissen.games.*;

typedef GameInfo = {
    game: GameState,
    gameName: String,
    unlockedGame: Bool,
    gameIndex :Int,
    batchSize :Int
};

class GameSessionManager
{
    var gameList :Array<Class<GameState>>;

    var gamesUnlocked :Array<Class<GameState>> = [];
    var gamesPlayed :Array<Class<GameState>> = [];
    var currentGameBatch :Array<Class<GameState>> = [];
    var batchSize :Int;
    var newGameUnlocked :Bool = false;

    public function new(list :Array<Class<GameState>>) :Void
    {
        gameList = list;

        var unlockCount :Int = (Reg.save.data.unlockCount != null ? Reg.save.data.unlockCount : 0);
        gamesUnlocked = gameList.slice(0, unlockCount);
        // trace('Unlock count: $unlockCount');
    }

    function getNextGameClass() :Class<GameState>
    {
        newGameUnlocked = false;

        // completed entire batch of games
        if (currentGameBatch.length == 0) {
            currentGameBatch = createGameBatch();

            var gamesPlayedThisSession = gamesPlayed.length;
            var hasMoreLockedGames = (gameList.length > gamesUnlocked.length);
            // Only unlock games if enough games have been played in this session
            if (hasMoreLockedGames && gamesPlayedThisSession >= gamesUnlocked.length) {
                var unlockedGame = unlockNextGame();
                currentGameBatch.unshift(unlockedGame); // Add the new game as the first in the batch
                newGameUnlocked = true;
            }

            batchSize = currentGameBatch.length;
            // var batchString = [for (g in currentGameBatch) getGameName(g)].join(", ");
            // trace('currentGameBatch: [$batchString]');
        }

        var nextGame = currentGameBatch.shift();
        gamesPlayed.push(nextGame);
        return nextGame;
    }

    function createGameBatch() :Array<Class<GameState>>
    {
        if (currentGameBatch.length > 0) throw "currentGameBatch is non-empty";

        var lastPlayedGame = gamesPlayed[gamesPlayed.length - 1];
        // trace('lastPlayedGame: ${Type.getClassName(lastPlayedGame)}');
        var gameBatch :Array<Class<GameState>> = FlxG.random.shuffleArray(gamesUnlocked.copy(), gamesUnlocked.length * 3);
        if (gameBatch.length > 0 && gameBatch[0] == lastPlayedGame) {
            gameBatch.shift();
            gameBatch.insert(FlxG.random.int(1, gameBatch.length), lastPlayedGame);
        }

        return gameBatch;
    }

    function unlockNextGame() :Class<GameState>
    {
        var unlockedGame = gameList[gamesUnlocked.length];
        gamesUnlocked.push(unlockedGame);

        Reg.save.data.unlockCount = gamesUnlocked.length;
        Reg.save.flush();
        // trace('Unlocked new game: ${getGameName(unlockedGame)}');
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

    public function getNext() :GameInfo
    {
        var nextGameClass = getNextGameClass();
        var nextGame = Type.createInstance(getNextGameClass(), []);
        return { 
            game: nextGame,
            gameName: getGameName(nextGameClass),
            gameIndex: batchSize - currentGameBatch.length,
            batchSize: batchSize,
            unlockedGame: newGameUnlocked
        };
    }

    public function getGame(index :Int) :GameState
    {
        return Type.createInstance(gameList[index], [true]);
    }

    public function getGamesPlayedList() :Array<String>
    {
        return [for (g in gamesPlayed) getGameName(g)];
    }

    public function getGamesUnlockedList() :Array<String>
    {
        return [for (g in gamesUnlocked) getGameName(g)];
    }

    public function getUnlockCount() :Int
    {
        return gamesUnlocked.length;
    }

    public function isNewGame() :Bool
    {
        return newGameUnlocked;
    }

    public function reset() :Void
    {
        gamesPlayed = [];
        currentGameBatch = [];

        Reg.save.data.unlockCount = 0;
        Reg.save.flush();
    }
}
