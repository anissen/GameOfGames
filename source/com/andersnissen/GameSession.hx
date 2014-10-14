package com.andersnissen;

import com.andersnissen.ColorScheme;
import com.andersnissen.GameSessionManager.GameInfo;
import com.andersnissen.states.TrainingState;
import flixel.FlxG;
import com.andersnissen.states.GameState;
import com.andersnissen.states.MenuState;
import flixel.util.FlxTimer;

class GameSession
{
    var gameManager :GameSessionManager;
    var speed :Float;
    var score :Int;
    var training :Bool;
    var newHighscore :Bool;
    var newGamesUnlocked :Int;

    public function new()
    {

    }

    public function start(manager :GameSessionManager, ?isTraining :Bool = false) :Void
    {
        gameManager = manager;
        training = isTraining;
        speed = 1.0;
        score = 0;
        newHighscore = false;
        newGamesUnlocked = 0;

        startGame(gameManager.getNext());
    }

    function startGame(gameInfo :GameInfo) :Void
    {
        if (gameInfo.unlockedGame)
            newGamesUnlocked++;

        var game = gameInfo.game;
        game.speed = speed;
        game.score = score;
        game.gameIndex = gameInfo.gameIndex;
        game.gameBatchSize = gameInfo.batchSize;
        game.onWin.addOnce(wonGame);
        game.onLose.addOnce(lostGame);

        FlxG.switchState(game);
    }

    function wonGame() :Void
    {
        score++;
        speed += 0.1;

        startGame(gameManager.getNext());
    }

    function lostGame() :Void
    {
        if (training) {
            var gameName = gameManager.getGamesUnlockedList()[0]; // HACK
            var highscore :Null<Int> = Reg.getTrainingHighscore(gameName);
            if (highscore == null || score > highscore) {
                Reg.setTrainingHighscore(gameName, score);
            }
        } else {
            if (score > Reg.highscore) {
                newHighscore = true;
                Reg.highscore = score;
            }
            Reg.score = score;
        }

        // TODO: Pass text, score, highscore to InfoState
        // var infoState = new InfoState(1);
        // infoState.bgColor = ColorScheme.RED;
        // infoState.onDone.addOnce(function() {
            if (training) {
                FlxG.switchState(new TrainingState());
            } else {
                FlxG.switchState(new MenuState(newHighscore, newGamesUnlocked));
            }
        // });
        // FlxG.switchState(infoState);
    }
}
