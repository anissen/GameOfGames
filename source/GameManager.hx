package;

import flixel.util.FlxRandom;
import flixel.util.FlxSave;

// import states.GameState;

// typedef Array<Class<states.GameState>> GameList

class GameManager
{
    var gameList :Array<Class<states.GameState>> = [];
    var gamesUnlocked :Array<Class<states.GameState>> = [];
    var gamesPlayed :Array<Class<states.GameState>> = [];
    var currentGameBatch :Array<Class<states.GameState>> = [];

    // public var onGameUnlocked :flixel.util.FlxSignal;

    public function new() :Void
    {
        gameList = [games.Jump, games.CollectDots, games.Bounce, games.Lasers];
        // gamesUnlocked = [games.Jump, games.CollectDots, games.Bounce];
        // onGameUnlocked = new flixel.util.FlxSignal();
    }

    function getNextGameClass() :Class<states.GameState>
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

            var batchString = [for (g in currentGameBatch) Type.getClassName(g)].join(", ");
            trace('currentGameBatch: [$batchString]');
        }

        var nextGame = currentGameBatch.shift();
        gamesPlayed.push(nextGame);
        return nextGame;
    }

    function createGameBatch() :Array<Class<states.GameState>>
    {
        if (currentGameBatch.length > 0) throw "currentGameBatch is non-empty";

        var lastPlayedGame = gamesPlayed[gamesPlayed.length];
        var gameBatch :Array<Class<states.GameState>> = FlxRandom.shuffleArray(gamesUnlocked.copy(), gamesUnlocked.length * 3);
        if (gameBatch.length > 0 && gameBatch[0] == lastPlayedGame) {
            gameBatch.shift();
            gameBatch.insert(FlxRandom.intRanged(1, gameBatch.length), lastPlayedGame);
        }

        return gameBatch;
    }

    function unlockNextGame() :Class<states.GameState>
    {
        var unlockedGame = gameList[gamesUnlocked.length];
        gamesUnlocked.push(unlockedGame);
        trace('Unlocked new game: ${Type.getClassName(unlockedGame)}');
        // onGameUnlocked.dispatch();

        return unlockedGame;
    }

    public function getNextGame() :states.GameState
    {
        return Type.createInstance(getNextGameClass(), []);
    }

    public function reset() :Void
    {
        gamesPlayed = [];
        currentGameBatch = [];
    }
}
