import SaveData;

var warningScreen:FunkinSprite;

var dreamState:Bool;

var fadeTmr:FlxTimer;

var isFading = false;

function create()
{
    SaveData.load();

    dreamState = SaveData.getBool('firstDreamState');

    warningScreen = new FunkinSprite(268, 278, Paths.image('warning'));
    add(warningScreen);

    fadeTmr = new FlxTimer().start(2, function(){ 
        fade();
    });
}

function update(elapsed:Float)
{
    if (!isFading && (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed))
    {
        fadeTmr?.cancel();
        fade();
    }
}

function fade()
{
    if (isFading)
        return;

    isFading = true;

    FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
    {
        if (FlxG.random.int(1, 10000) == 1)
        {
            FlxG.switchState(new ModState("SecretState", {img: 1, goToMenu: true}));
            return;
        }

        if (dreamState)
            FlxG.switchState(new ModState("DreamState", {dream: 1}));
        else
            FlxG.switchState(new ModState("TitleStateFNAF"));
    });
}