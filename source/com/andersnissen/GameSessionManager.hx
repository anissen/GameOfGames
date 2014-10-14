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

typedef GameClass = Class<GameState>

class GameSessionManager
{
    var gameList :Array<GameClass>;

    var unlockCount :Int;
    var batchSize :Int;
    var newGameUnlocked :Bool = false;

    var batch :GameBatch;

    public function new(list :Array<GameClass>) :Void
    {
        gameList = list;

        unlockCount = 0; //(Reg.save.data.unlockCount != null ? Reg.save.data.unlockCount : 0);
        batch = new GameBatch(gameList.slice(0, unlockCount));
    }

    function getNextGameClass() :GameClass
    {
        newGameUnlocked = false;

        // completed entire batch of games
        if (batch.empty()) {
            if (unlockCount < gameList.length) {
                newGameUnlocked = true;
                batch.newBatch(gameList[unlockCount++]);
                Reg.save.data.unlockCount = unlockCount;
                Reg.save.flush();
            } else {
                batch.newBatch();
            }

            batchSize = batch.length();
            // var batchString = [for (g in currentGameBatch) getGameName(g)].join(", ");
            // trace('currentGameBatch: [$batchString]');
        }

        return batch.pickRandom();
    }

    function getGameName(cls :GameClass) :String 
    {
        var qualifiedName = Type.getClassName(cls);
        var lastDotPos = qualifiedName.lastIndexOf(".");
        if (lastDotPos < 0) return qualifiedName;
        return qualifiedName.substr(lastDotPos + 1);
    }

    public function getNext() :GameInfo
    {
        var nextGameClass = getNextGameClass();
        var nextGame = Type.createInstance(nextGameClass, []);
        trace('getNext: batchSize: $batchSize, batch.length(): ${batch.length()}');
        return { 
            game: nextGame,
            gameName: getGameName(nextGameClass),
            gameIndex: batchSize - batch.length(),
            batchSize: batchSize,
            unlockedGame: newGameUnlocked
        };
    }

    public function getGame(index :Int) :GameState
    {
        return Type.createInstance(gameList[index], [true]);
    }

    public function getGamesUnlockedList() :Array<String>
    {
        return [for (i in 0...unlockCount) getGameName(gameList[i])];
    }

    public function getUnlockCount() :Int
    {
        return unlockCount;
    }

    public function isNewGame() :Bool
    {
        return newGameUnlocked;
    }

    public function reset() :Void
    {
        batch.reset();
        batchSize = 0;
        newGameUnlocked = false;
    }
}

class GameBatch {
    var games :Array<GameClass>;
    var batch :Array<GameClass>;
    var lastGame :GameClass;

    public function new(unlockedGames :Array<GameClass>) {
        // trace('Created batch with ${unlockedGames.length} unlocked games');
        games = unlockedGames;
        newBatch();
    }

    public function newBatch(?unlockedGame :GameClass) {
        // trace('new batch with ${games.length} games and unlocked game: ${unlockedGame != null}');
        batch = games.copy();
        batch = FlxG.random.shuffleArray(batch, batch.length * 3);
        if (unlockedGame != null) {
            batch.unshift(unlockedGame);
            games.push(unlockedGame);
        } else {
            if (batch.length > 0 && lastGame != null && batch[0] == lastGame) {
                batch.push(batch.shift());
            }
        }
    }

    public function pickRandom() :GameClass {
        // trace('pick random from ${batch.length} games');
        var game = batch.shift();
        lastGame = game;
        return game;
    }

    public function reset() {
        // trace('reset batch');
        batch = games.copy();
        lastGame = null;
    }

    public function length() :Int {
        return batch.length;
    }

    public function empty() :Bool {
        return batch.length == 0;
    }
}
