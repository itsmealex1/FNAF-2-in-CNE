
// this state is REALLY eyeballed.

import SaveData;
import funkin.menus.ModSwitchMenu;
import flixel.text.FlxTextBorderStyle;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.RatioScaleMode;

var staticSprite:FunkinSprite;
var camLine1:FunkinSprite;
var animatronics:FunkinSprite;
var cameraBlip:FunkinSprite;
var title:FunkinSprite;
var version:FunkinSprite;
var versionTxt:FunkinText;
var copyright:FunkinSprite;
var copyrightTxt:FunkinText;
var resetData:FunkinSprite;

var night:FunkinSprite;
var nightNumberSprite:FunkinSprite;
var nightText:FunkinText;

var firstStar:FunkinSprite;
var secondStar:FunkinSprite;
var thirdStar:FunkinSprite;

var news:FunkinSprite;
var arrow:FunkinSprite;

var randomTmr:FlxTimer;
var alphaTmr:FlxTimer;
var twitchTmr:FlxTimer;
var transitionTmr:FlxTimer;

var nightNumber:Int;
var sixthNightUnlocked:Bool;
var customNightUnlocked:Bool;

var buttons:Array<MenuButton> = [];
var mainButtons:Array<MenuButton> = [];
var optionsButtons:Array<Dynamic> = [];
var unlocksButtons:Array<MenuButton> = [];
var allButtons:Array<MenuButton> = [];

var lastHovered:Dynamic = null;
var currentMenu:String = 'main';

var canSelect:Bool = true;
var canSkip:Bool = false;
var selectedNewGame:Bool = false;
var transitioning:Bool = false;
var canFlicker:Bool = true;

var deleteFrames:Int;

var camButtons:FlxCamera;

var perspShader:CustomShader = new CustomShader('perspective');

function create()
{
    SaveData.load();
    SaveData.loadMobile();

    nightNumber = SaveData.getInt('night', 1);
    sixthNightUnlocked = SaveData.getBool('sixthNightUnlocked');
    customNightUnlocked = SaveData.getBool('customNightUnlocked');

    FlxG.sound.playMusic(Paths.music('title$mobilePrefix'), 1, true);
    FlxG.sound.play(Paths.sound('static2'), 1, false);

    camButtons = new FlxCamera();
    camButtons.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(camButtons, false);

    animatronics = new FunkinSprite(0, 0, Paths.image('title/title'));
    animatronics.antialiasing = true;
    animatronics.animation.addByPrefix('normal', 'normal', 8, false);
    animatronics.animation.addByPrefix('bonnie', 'bonnie', 8, false);
    animatronics.animation.addByPrefix('chica', 'chica', 8, false);
    animatronics.animation.addByPrefix('freddy', 'freddy', 8, false);

    if (canSelect)
    {
        animatronics.animation.finishCallback = function(name:String)
        {
            if (name != 'normal')
                animatronics.animation.play('normal');
        };

        alphaTmr = new FlxTimer().start(0.3, function(timer:FlxTimer)
        {
            animatronics.alpha = FlxG.random.float(0.1, 1);
            timer.reset(0.3);
        });

        twitchTmr = new FlxTimer().start(0.1, function(timer:FlxTimer)
        {
            if (FlxG.random.int(1, 50) == 1)
                playRandomTitleAnimation();

            timer.reset(0.1);
        });

        randomTmr = new FlxTimer().start(FlxG.random.float(0.3, 0.5), function(timer:FlxTimer)
        {
            playBlip();
            cameraBlip.visible = FlxG.random.bool(50);
            timer.reset(FlxG.random.float(0.3, 0.5));
        });
    }

    add(animatronics);

    staticSprite = new FunkinSprite();
    staticSprite.frames = Paths.getSparrowAtlas('ui/static');
    staticSprite.alpha = isMobile ? 0.9 : 0.5;
    staticSprite.blend = 0;
    staticSprite.antialiasing = true;
    staticSprite.animation.addByPrefix('static', 'frame', 60, true);
    staticSprite.animation.play('static');
    add(staticSprite);

    camLine1 = new FunkinSprite(0, -35, Paths.image('ui/camLine1'));
    camLine1.scale.y -= 0.5;
    camLine1.blend = 0;
    camLine1.alpha = 0.2;
    add(camLine1);

    cameraBlip = new FunkinSprite();
    cameraBlip.frames = Paths.getSparrowAtlas('camBlip');
    cameraBlip.animation.addByPrefix('blip', 'frame', 5, false);
    cameraBlip.blend = 0;
    cameraBlip.alpha = 0.2;
    add(cameraBlip);
    playBlip();

    title = new FunkinSprite(96, 39, Paths.image('title/fnaf2'));
    title.antialiasing = true;
    add(title);

    firstStar = new FunkinSprite(94, 341, Paths.image('title/star'));
    firstStar.antialiasing = true;
    firstStar.visible = SaveData.getBool('night5done');
    add(firstStar);

    secondStar = new FunkinSprite(171, 341, Paths.image('title/star'));
    secondStar.antialiasing = true;
    secondStar.visible = SaveData.getBool('night6done');
    add(secondStar);

    thirdStar = new FunkinSprite(246, 341, Paths.image('title/star'));
    thirdStar.antialiasing = true;
    thirdStar.visible = SaveData.getBool('goldenFreddyDone');
    add(thirdStar);

    if (isMobile)
        for (itm in [title, firstStar, secondStar, thirdStar])
            itm.x -= 25;

    mainButtons = [
        new MenuButton('newGame', !isMobile ? 86 : 66, 437, 'title/newgame', true),
        new MenuButton('continue', !isMobile ? 86 : 66, !isMobile ? 507 : 517, 'title/continue', true),
        new MenuButton('sixthNight', !isMobile ? 90 : 66, !isMobile ? 582 : 602, 'title/sixnight', sixthNightUnlocked),
        new MenuButton('customNight', !isMobile ? 89 : 66, !isMobile ? 650 : 680, 'title/customnight', customNightUnlocked)
    ];

    if (isMobile)
    {
        mainButtons.push(new MenuButton('options', 770, 582, 'title/options', true));
        mainButtons.push(new MenuButton('unlocks', 770, 662, 'title/unlocks', true));
    }

    optionsButtons = [
        new OptionButton('displayMode', 'Display Mode', 'display', 200, 50, SaveData.getMobileBool('displayMode', true), 20, null, -30),
        new OptionButton('perspectiveEffect', 'Perspective Effect', 'switch', 200, 200, SaveData.getMobileBool('perspectiveEffect', true)),
        new MenuButton('back', 860, 662, 'title/back', true),
    ];
    unlocksButtons = [
        new MenuButton('back', 860, 662, 'title/back', true),
    ];

    allButtons = mainButtons.concat(unlocksButtons);

    for (button in allButtons)
    {
        button.sprite.camera = camButtons;
        add(button.sprite);
        button.sprite.visible = false;
    }

    for (button in optionsButtons)
    {
        button.sprite.camera = camButtons;
        add(button.sprite);
        button.sprite.visible = false;

        if (button.type == 'option')
        {
            button.title.camera = camButtons;
            add(button.title);
            button.title.visible = false;
        }
    }

    if (!isMobile)
    {
        version = new FunkinSprite(26, 738, Paths.image('title/version'));
        add(version);
    }
    else
    {
        versionTxt = new FunkinText(16, 728, FlxG.width, 'v 2.0.7');
        versionTxt.setFormat(Paths.font('Roboto Regular.ttf'), 24);
        versionTxt.alpha = 0.5;
        add(versionTxt);
    }

    if (!isMobile)
    {
        resetData = new FunkinSprite(335, 736, Paths.image('title/resetData'));
        add(resetData);
    }

    if (!isMobile)
    {
        copyright = new FunkinSprite(790, 735, Paths.image('title/copyright'));
        add(copyright);
    }
    else
    {
        copyrightTxt = new FunkinText(645, 725, FlxG.width, '© 2014-2025 Scott Cawthon');
        copyrightTxt.setFormat(Paths.font('Roboto Regular.ttf'), 25);
        copyrightTxt.alpha = 0.5;
        add(copyrightTxt);
    }

    arrow = new FunkinSprite(33, 439, Paths.image('title/arrow'));
    arrow.visible = false;
    arrow.antialiasing = true;
    arrow.camera = camButtons;
    add(arrow);

    if (!isMobile)
    {
        night = new FunkinSprite(97, 549, Paths.image('title/nights'));
        night.visible = false;
        add(night);

        nightNumberSprite = new FunkinSprite(171, 550, Paths.image('title/number/' + nightNumber));
        nightNumberSprite.visible = false;
        add(nightNumberSprite);
    }
    else
    {
        nightText = new FunkinText(70, 552, FlxG.width, 'Night $nightNumber', 22);
        nightText.setFormat(Paths.font('Roboto Regular.ttf'), 24, FlxColor.WHITE, 'left', FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT);
        nightText.antialiasing = true;
        add(nightText);
    }

    news = new FunkinSprite(0, 0, Paths.image('news$mobilePrefix'));
    news.antialiasing = true;
    news.alpha = 0;
    news.camera = camButtons;
    add(news);

    showMenu('main');
}

function showMenu(menu:String)
{
    currentMenu = menu;

    for (button in allButtons)
        button.sprite.visible = false;

    for (button in optionsButtons)
    {
        button.sprite.visible = false;

        if (button.type == 'option')
            button.title.visible = false;
    }

    switch (currentMenu)
    {
        case 'main':
            buttons = mainButtons;

        case 'options':
            buttons = [];

            for (button in optionsButtons)
            {
                if (button.type == 'menu')
                    buttons.push(button);
                else
                {
                    button.sprite.visible = true;
                    button.title.visible = true;
                }
            }

        case 'unlocks':
            buttons = unlocksButtons;

        default:
            buttons = mainButtons;
            currentMenu = 'main';
    }

    for (button in buttons)
        button.sprite.visible = button.unlocked;

    if (isMobile)
    {
        for (mainObj in [nightText, title, firstStar, secondStar, thirdStar, versionTxt, copyrightTxt])
            mainObj.visible = currentMenu == 'main';
    }

    arrow.visible = false;
    lastHovered = null;
}

function playBlip()
{
    cameraBlip.visible = true;
    cameraBlip.animation.play('blip');

    cameraBlip.animation.finishCallback = function(name:String)
    {
        if (name == 'blip')
            cameraBlip.visible = false;
    };
}

function playRandomTitleAnimation()
{
    var animations:Array<String> = [
        'freddy',
        'bonnie',
        'chica',
        'normal'
    ];

    var randomAnimation:String = FlxG.random.getObject(animations);
    animatronics.animation.play(randomAnimation);
}

function update(elapsed:Float)
{
    if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && selectedNewGame && canSkip)
    {
        transitionTmr?.cancel();

        camButtons.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.sound.music.stop();
            FlxG.switchState(new ModState("NightState"));
        });
    }

    if (!canSelect)
        return;

    if (controls.SWITCHMOD)
    {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    if (!isMobile)
    {
        if (FlxG.keys.pressed.DELETE)
            deleteFrames++;

        if (FlxG.keys.justReleased.DELETE)
            deleteFrames = 0;

        if (deleteFrames >= 100)
        {
            SaveData.reset();
            FlxG.resetState();
        }
    }

    camLine1.y += 0.6;

    if (camLine1.y > FlxG.height + 35)
        camLine1.y = -35;

    var hovered:Dynamic = null;

    for (button in buttons)
    {
        if (button.isHovered())
            hovered = button;
    }

    if (currentMenu == 'options' && hovered == null)
    {
        for (button in optionsButtons)
        {
            if (button.type == 'option' && button.isHovered())
                hovered = button;
        }   
    }

    if (hovered != lastHovered)
    {
        if (hovered != null)
        {
            if (!isMobile && currentMenu == 'main')
            {
                night.visible = hovered.name == 'continue';
                nightNumberSprite.visible = hovered.name == 'continue';
            }

            FlxG.sound.play(Paths.sound('blip3'));

            arrow.y = hovered.sprite.y + (hovered.sprite.height - arrow.height) / 2;
            arrow.x = hovered.sprite.x - arrow.width - 10;
        }

        arrow.visible = hovered != null;
        lastHovered = hovered;
    }

    if (FlxG.mouse.justPressed && hovered != null)
    {
        switch (hovered.name)
        {
            case 'newGame':
                canSelect = false;
                selectedNewGame = true;
                transition();

            case 'continue':
                FlxG.sound.music.stop();
                FlxG.switchState(new ModState("NightState", {night: SaveData.getInt('night', 1)}));

            case 'sixthNight':
                FlxG.sound.music.stop();
                FlxG.switchState(new ModState("NightState", {night: 6, sixthNight: true}));

            case 'customNight':
                FlxG.switchState(new ModState("CustomNightState"));

            case 'options':
                if (SaveData.getMobileBool('perspectiveEffect', true) == true)
                    camera.addShader(perspShader);
                showMenu('options');

            case 'unlocks':
                showMenu('unlocks');

            case 'back':
                camera.filters = [];
                showMenu('main');
        }
    }

    if (FlxG.mouse.justPressed && currentMenu == 'options')
    {
        for (button in optionsButtons)
        {
            if (button.type == 'option' && button.isHovered())
            {
                button.toggle();

                switch (button.name)
                {
                    case 'perspectiveEffect':
                        SaveData.setMobileBool('perspectiveEffect', button.enabled);
                        SaveData.saveMobile();
                        camera.addShader(button.enabled ? new CustomShader('perspective') : null);
                    case 'displayMode':
                        SaveData.setMobileBool('displayMode', button.enabled);
                        SaveData.saveMobile();

                        FlxG.scaleMode = button.enabled ? new FillScaleMode() : new RatioScaleMode();
                }
            }
        }
    }
}

function transition()
{
    SaveData.setInt('night', 1);
    SaveData.save();

    alphaTmr.cancel();
    twitchTmr.cancel();
    randomTmr.cancel();

    staticSprite.animation.pause();
    cameraBlip.animation.pause();

    FlxTween.tween(news, {alpha: 1}, 2, {
        onComplete: function(_)
        {
            canSkip = true;
        }
    });

    transitionTmr = new FlxTimer().start(6, function()
    {
        camButtons.fade(FlxColor.BLACK, 1, false, function()
        {
            canSkip = false;

            FlxG.sound.music.stop();
            FlxG.switchState(new ModState("NightState"));
        });
    });
}

class MenuButton
{
    public var sprite:FunkinSprite;
    public var name:String;
    public var unlocked:Bool;
    public var type:String = 'menu';

    public function new(name:String, x:Float, y:Float, graphic:String, unlocked:Bool = true)
    {
        this.name = name;
        this.unlocked = unlocked;

        sprite = new FunkinSprite(x, y, Paths.image(graphic));
        sprite.antialiasing = true;
        sprite.visible = unlocked;
    }

    public function isHovered():Bool
    {
        if (!unlocked || !sprite.visible)
            return false;

        return sprite.overlapsPoint(FlxG.mouse.getWorldPosition(FlxG.camera));
    }
}

class OptionButton
{
    public var title:FunkinText;
    public var sprite:FunkinSprite;

    public var name:String;
    public var enabled:Bool;
    public var type:String = 'option';

    public function new(name:String, text:String, spriteImg:String, x:Float, y:Float, enabled:Bool = false, textX:Float = 0, textY:Float = 0, spriteX:Float = 0, spriteY:Float = 0)
    {
        this.name = name;
        this.enabled = enabled;

        title = new FunkinText(x + textX, y + textY, 0, text, 24);
        title.setFormat(Paths.font('Roboto Regular.ttf'), 24, FlxColor.WHITE, 'center');
        title.antialiasing = true;

        sprite = new FunkinSprite(x + 60 + spriteX, y + 40 + spriteY);
        sprite.frames = Paths.getSparrowAtlas('title/$spriteImg');
        sprite.animation.addByPrefix('off', 'off', 24, false);
        sprite.animation.addByPrefix('on', 'on', 24, false);
        sprite.antialiasing = true;

        updateSprite();
    }

    public function isHovered():Bool
        return CoolUtil.mouseOverlaps(sprite, camButtons);

    public function update()
    {
        if (FlxG.mouse.justPressed && isHovered())
            toggle();
    }

    public function toggle()
    {
        enabled = !enabled;
        updateSprite();
    }

    public function updateSprite()
    {
        sprite.animation.play(enabled ? 'on' : 'off', true);
        if (sprite.animation.name == 'on')
            sprite.offset.x = -15;
        else 
            sprite.offset.x = 0;
    }
}