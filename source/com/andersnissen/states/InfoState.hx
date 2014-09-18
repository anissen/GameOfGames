package com.andersnissen.states;

import com.andersnissen.ColorScheme;
import com.andersnissen.Settings;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class InfoState extends FlxTransitionableState
{
    public var onDone :FlxSignal;
    var duration :Float;

    public function new(?duration :Float = 2) :Void
    {
        super();

        this.duration = duration;

        onDone = new FlxSignal();
    }

    override public function create() :Void
    {
        var text = new FlxText(Settings.WIDTH / 2, Settings.HEIGHT / 2, Settings.WIDTH, "Hello World");
        text.alignment = FlxTextAlign.CENTER;
        add(text);

        super.create();

        // TODO: Text should be customizable through the constructor!
        var loseScreen = new DialogBox("Game Over", 'Score: ${Reg.score}', 'Highcore: ${Reg.highscore}', ColorScheme.RED);
        add(loseScreen);
        loseScreen.open();

        new FlxTimer(duration, function(_ :FlxTimer) {
            onDone.dispatch();
        });
    }
    
    override public function destroy() :Void
    {
        super.destroy();
    }

    override public function update(elapsed :Float) :Void
    {
        super.update(elapsed);
    }
}
