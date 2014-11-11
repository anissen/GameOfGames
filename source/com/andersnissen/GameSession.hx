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
    var trainingPage :Int;
    var newHighscore :Bool;
    var newGamesUnlocked :Int;

    public function new() {

    }

    public function start(manager :GameSessionManager, ?isTraining :Bool = false, ?trainingPage :Int = 0) :Void
    {
        gameManager = manager;
        training = isTraining;
        this.trainingPage = trainingPage;
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
        game.className = gameInfo.gameName;
        game.training = training;
        game.onWin.addOnce(wonGame);
        game.onLose.addOnce(lostGame);

        FlxG.switchState(game);
    }

    function wonGame() :Void
    {
        score++;
        speed += 0.08;

        startGame(gameManager.getNext());
    }

    function lostGame() :Void
    {
        if (training) {
            var game = gameManager.getNext();
            var gameName = game.gameName;
            var highscore :Null<Int> = Reg.getTrainingHighscore(gameName);
            if (highscore == null || score > highscore) {
                Reg.setTrainingHighscore(gameName, score);
            }
        } else {
            if (score > Reg.highscore) {
                newHighscore = true;
                Reg.highscore = score;
            } else {
                // no new highscore
            }
            Reg.score = score;
        }

        if (training) {
            FlxG.switchState(new TrainingState(trainingPage));
        } else {
            FlxG.switchState(MenuState.Create(newHighscore, newGamesUnlocked));
        }
    }
}
