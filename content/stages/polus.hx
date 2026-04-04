import flixel.FlxSprite;

import openfl.filters.ShaderFilter;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;

import funkin.objects.SnowEmitter;
import funkin.objects.shader.OverlayShader;
import funkin.data.ClientPrefs;
import funkin.utils.CameraUtil;
import funkin.objects.BGSprite;

var snowAlpha = 0;
var ext:String = 'stage/polus/'; // Edit polus to your stage name.
var vignette:FlxSprite;
var snow:FlxSprite;
var rose:FlxSprite;
var boomBox:BGSprite;
var blackSprite:FlxSprite;
var blkBg:FlxSprite;
var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
var evilCam = FlxCamera;
var anotherCam = FlxCamera;
var bfVoters:FlxTypedGroup;
var redVoters:FlxTypedGroup;

var everyoneLook:String = ''; // Set this to -peep WHEN THEY START YAPPING
var p = 0;
/*
	0 - BF
	1 - RED
	2 - GREEN
	3 - DETECTIVE
	4 - LIME
	5 - PURPLE
	6 - CYAN
	7 - ROSE
 */
var rv:Int = 0;
var bv:Int = 0;
var roseTable:FlxSprite = null;
var greenTable:FlxSprite = null;

// character zIndex's are 12

function onLoad()
{
	// base bg ---------------------------------------
	
	var bg = new BGSprite(null, -832, -974).loadFromSheet(ext + 'sky', 'sky', 0);
	bg.scale.set(2, 2);
	bg.updateHitbox();
	bg.scrollFactor.set(0.3, 0.3);
	bg.zIndex = 0;
	
	stars = new BGSprite(null, -1205, -1600).loadFromSheet(ext + 'sky', 'stars', 0);
	stars.scale.set(2, 2);
	stars.updateHitbox();
	stars.scrollFactor.set(1.1, 1.1);
	stars.zIndex = 0;
	
	global.set('base_bg', bg);
	global.set('base_stars', stars);
	
	
	mountains = new BGSprite(null, -1569, -185).loadFromSheet(ext + 'bg2', 'bgBack', 0);
	mountains.scrollFactor.set(0.8, 0.8);
	mountains.zIndex = 2;
	
	mountains2 = new BGSprite(null, -1467, -25).loadFromSheet(ext + 'bg2', 'bgFront', 0);
	mountains2.scrollFactor.set(0.9, 0.9);
	mountains2.zIndex = 2;
	
	floor = new BGSprite(null, -1410, -139).loadFromSheet(ext + 'bg2', 'groundnew', 0);
	floor.zIndex = 2;
	
	snowEmitter = new SnowEmitter(floor.x, floor.y - 200, floor.width);
	snowEmitter.start(false, ClientPrefs.lowQuality ? 0.1 : 0.05);
	snowEmitter.scrollFactor.x.set(1, 1.5);
	snowEmitter.scrollFactor.y.set(1, 1.5);
	add(snowEmitter);
	snowEmitter.alpha.active = false;
	snowEmitter.onEmit.add((particle) -> particle.alpha = snowAlpha);
	snowEmitter.zIndex = 13;
	
	global.set('snowEmitter', snowEmitter);
	
	var thingy = new BGSprite(null, 2458, -115).loadSparrowFrames(ext + "guylmao");
	thingy.animation.addByPrefix('idle', 'REACTOR_THING', 24, true);
	thingy.animation.play('idle');
	thingy.zIndex = 3;
	
	var thingy2 = new BGSprite(ext + "thing front", 2467, 269);
	thingy2.zIndex = 4;
	
	// misc stuff ---------------------------------------
	
	if (ClientPrefs.shaders)
	{
		var overlayShader:OverlayShader = new OverlayShader();
		overlayShader.setBitmapOverlay(Paths.image(ext + 'overlay', 'impostor').bitmap);
		game.camGame.filters = [new ShaderFilter(overlayShader)];
	}
	
	vignette = new BGSprite(ext + "polusvignette");
	vignette.cameras = [game.camOther];
	vignette.alpha = 0.8;
	add(vignette);
	
	// i put it back for now
	blackSprite = new FlxSprite(0, 0).makeScaledGraphic(1280, 720, 0xff000000);
	blackSprite.cameras = [game.camOther];
	add(blackSprite);
	blackSprite.alpha = 0;
	global.set('blackSprite', blackSprite);


	//very bandaid fix but it works for now.. that sabo custcene rly fucked shit up ig lmao
	blkBg = new FlxSprite(0, 0).makeScaledGraphic(1280, 720, 0xff000000);
	blkBg.cameras = [game.camOther];
	add(blkBg);
	blkBg.alpha = 0;
	global.set('blkBg', blkBg);
	
	for (i in [bg, stars, mountains, mountains2, floor, thingy, thingy2])
	{
		add(i);
	}
	
	// meltdown stuff ---------------------------------------
	
	if (songName == 'Meltdown')
	{
		buildMeltdownBG();
	}
}

function onCreatePost()
{
	dadGroup.zIndex = 12;
	gfGroup.zIndex = 12;
	boyfriendGroup.zIndex = 12;
	
	// ^ temp
	if (PlayState.SONG.song.toLowerCase() == 'sussus moogus')
	{
		game.isCameraOnForcedPos = true;
		game.snapCamFollowToPos(1025, -800);
		game.camHUD.alpha = 0;
		FlxG.camera.zoom = 0.4;
		blkBg.alpha = 1;
	}
	
	if (PlayState.SONG.song.toLowerCase() == 'meltdown')
	{
		game.isCameraOnForcedPos = true;
		game.snapCamFollowToPos(1025, 500);
		FlxG.camera.zoom = 0.5;
		gf.y += 1000;
		gf.alpha = 0;
		gfDead.alpha = 1;
		boomBox.alpha = 1;
		cyan.alpha = 1;
		rose.alpha = 1;
	}
	
	snowAlpha = (songName == 'Sussus Moogus' ? 0 : 1);
	
	// sususs
	if (!ClientPrefs.lowQuality)
	{
		evilGreen = new BGSprite(null, -550, 725).loadSparrowFrames(ext + "green");
		evilGreen.animation.addByPrefix('cutscene', 'scene instance 1', 24, false);
		evilGreen.scale.set(2.3, 2.3);
		evilGreen.scrollFactor(1.2, 1.2);
		evilGreen.alpha = 0;
		add(evilGreen);
		
		evilCam = CameraUtil.quickCreateCam(false);
		FlxG.cameras.insert(evilCam, FlxG.cameras.list.indexOf(game.camPause), false);
		
		evilGreen.cameras = [evilCam];
	}
	
	anotherCam = CameraUtil.quickCreateCam(false);
	FlxG.cameras.insert(anotherCam, FlxG.cameras.list.indexOf(game.camPause), false);
	
	// loggo is a nigger
	
	vignette2 = new BGSprite(ext + "vignette2", 0, 0);
	vignette2.cameras = [anotherCam];
	vignette2.alpha = 0;
	add(vignette2);
	
	refreshZ();
}

function onUpdate(elapsed)
{
	// Making them move!
	/*
		p+=1; // IDK IF THIS IS TIED TO THE FPS I HAVENT TRIED IT

		redVoters.forEach(function(spr:FlxSprite){
			spr.scale.x = 1+(Math.sin((p+(50*spr.ID))/5 / (FlxG.updateFramerate / 60)) * 0.05);
			spr.scale.y = 1+(Math.sin((p+(50*spr.ID))/5 / (FlxG.updateFramerate / 60)) * 0.05);
		});
		bfVoters.forEach(function(spr:FlxSprite){
			spr.scale.x = 1+(Math.sin((p+(50*spr.ID))/5 / (FlxG.updateFramerate / 60)) * 0.05);
			spr.scale.y = 1+(Math.sin((p+(50*spr.ID))/5 / (FlxG.updateFramerate / 60)) * 0.05);
		});

		This is to make them move around, which looks kind of cool but in reality it's actually kind of dumb and gay.
	 */
	anotherCam.zoom = game.camHUD.zoom;
	if (!ClientPrefs.lowQuality)
	{
		evilCam.zoom = game.camGame.zoom;
		evilCam.scroll.x = FlxG.camera.scroll.x;
		evilCam.scroll.y = FlxG.camera.scroll.y;
	}
}

function revealVoters()
{
	// Scrapped (BUT IT LOOKS SO FUN)
	redVoters.forEach(function(spr:FlxSprite) {
		FlxTween.tween(spr.scale, {x: 0}, 0.25,
			{
				ease: FlxEase.quadIn,
				onComplete: function(tween:FlxTween) {
					FlxTween.tween(spr.scale, {x: 1}, 0.25, {ease: FlxEase.quadOut});
					spr.animation.curAnim.curFrame = 1;
				}
			});
	});
	bfVoters.forEach(function(spr:FlxSprite) {
		FlxTween.tween(spr.scale, {x: 0}, 0.25,
			{
				ease: FlxEase.quadIn,
				onComplete: function(tween:FlxTween) {
					FlxTween.tween(spr.scale, {x: 1}, 0.25, {ease: FlxEase.quadOut});
					spr.animation.curAnim.curFrame = 1;
				}
			});
	});
}

function refreshVoters()
{
	// trace(rv + ' ' + bv);
	redVoters.forEach(function(spr:FlxSprite) {
		if (spr.ID == rv) FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.backOut});
		FlxTween.tween(spr, {x: dad.x + 100 + (((spr.ID - 1) * 100) - (redVoters.length * (75 / 2)))}, (spr.ID == rv ? 0.1 : 0.5), {ease: FlxEase.quadInOut});
	});
	bfVoters.forEach(function(spr:FlxSprite) {
		if (spr.ID == bv) FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.25, {ease: FlxEase.backOut});
		FlxTween.tween(spr, {x: boyfriend.x + (((spr.ID - 1) * 100) - (bfVoters.length * (75 / 2)))}, (spr.ID == bv ? 0.1 : 0.5), {ease: FlxEase.quadInOut});
	});
}

function onBeatHit()
{
	if (game.curBeat % 2 == 0)
	{
		if (boomBox != null && boomBox.animation.curAnim.name == 'sus') boomBox.animation.play('sus', true);
		if (roseTable != null && roseTable.animation.curAnim.name == 'idle') roseTable.animation.play('idle' + everyoneLook);
		if (greenTable != null && greenTable.animation.curAnim.name == 'idle') greenTable.animation.play('idle' + everyoneLook);
		if (roseTable != null && roseTable.animation.curAnim.name == 'idle-peep') roseTable.animation.play('idle-peep' + everyoneLook);
		if (greenTable != null && greenTable.animation.curAnim.name == 'idle-peep') greenTable.animation.play('idle-peep' + everyoneLook);
	}
}

function onSongStart()
{
	// blackSprite.alpha = 0;
	blkBg.alpha = 0;
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case '':
			switch (value1)
			{
				case 'speedUp':
					snowEmitter.speed.set(1400, 1700);
					snowEmitter.frequency = 0.04;
			}
		case 'orange':
			var orange = global.get('sussus_orange');
			var green = global.get('sussus_green');
			
			if (ClientPrefs.lowQuality
				&& (value1 == 'walk' || value1 == 'die' || value1 == 'idle' || value2 == 'walk' || value2 == 'kill' || value2 == 'carry')) return;
				
			switch (value1)
			{
				case 'walk':
					orange.alpha = 1;
					FlxTween.tween(orange, {x: 60}, 3.5,
						{
							onComplete: function() {
								orange.animation.play('idle');
								orange.y += 30;
							}
						});
				case 'die':
					orange.animation.play('die');
				case 'wave':
					orange.animation.play('wave');
					orange.y -= 100;
				// super unorganized, but here's my camera tweens. it's done shittily i know but it was faster. sum1 else can touch it up if needed
				case 'camMiddle':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1, {ease: FlxEase.linear});
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.smootherStepInOut});
					game.defaultCamZoom = 0.5;
				case 'camMiddleSlow':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1.5, {ease: FlxEase.linear});
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 2, {ease: FlxEase.linear});
					game.defaultCamZoom = 0.5;
				case 'camMiddleTuah':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1, {ease: FlxEase.linear});
					FlxTween.tween(FlxG.camera, {zoom: 0.55}, 1, {ease: FlxEase.smootherStepInOut});
					game.defaultCamZoom = 0.55;
				case 'camNormal':
					game.isCameraOnForcedPos = false;
				case 'camRight':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1600, y: 525}, 5, {ease: FlxEase.smootherStepInOut});
					game.defaultCamZoom = 0.5;
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.smootherStepInOut});
				case 'evilgreen':
					if (ClientPrefs.lowQuality) return;
					
					game.playFields.cameras = [anotherCam];
					game.notes.cameras = [anotherCam];
					game.grpNoteSplashes.cameras = [anotherCam];
					flashSprite.scale.set(5, 5);
					flashSprite.cameras = [evilCam];
					evilGreen.alpha = 1;
					FlxTween.tween(vignette2, {alpha: 0.6}, 3, {ease: FlxEase.linear});
					evilGreen.animation.play('cutscene');
					FlxTween.tween(vignette2, {alpha: 0}, 2, {ease: FlxEase.linear, startDelay: 9});
					FlxTween.tween(vignette2, {alpha: 0}, 2,
						{
							ease: FlxEase.linear,
							startDelay: 9,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(2, function(tmr:FlxTimer) {
									game.playFields.cameras = [game.camHUD];
									game.notes.cameras = [game.camHUD];
									game.grpNoteSplashes.cameras = [game.camHUD];
									flashSprite.scale.set(1, 1);
									flashSprite.cameras = [game.camOther];
									remove(evilGreen);
								});
							}
						});
				case 'idle':
					orange.animation.play('idle');
					orange.y += 100;
				case 'intro':
					FlxTween.num(snowAlpha, 1, 2, {startDelay: 7.5}, (f) -> {
						snowAlpha = f;
					});
					
					FlxTween.tween(game.camHUD, {alpha: 1}, 2.5, {ease: FlxEase.linear, startDelay: 9.5});
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 12, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(game.camFollow, {y: 500}, 12,
						{
							ease: FlxEase.smootherStepInOut,
							startDelay: 0,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0.2, function(tmr:FlxTimer) {
									game.isCameraOnForcedPos = false;
								});
							}
						});
				case 'star':
					game.isCameraOnForcedPos = true;
					
					FlxTween.num(snowAlpha, 0, 2, {startDelay: 1.5}, (f) -> {
						snowAlpha = f;
					});
					
					FlxTween.tween(global.get('redStar'), {alpha: 0.9}, 5, {ease: FlxEase.linear});
					FlxTween.tween(global.get('bfStar'), {alpha: 0.9}, 3, {ease: FlxEase.linear, startDelay: 5});
					
					FlxTween.tween(FlxG.camera, {zoom: 0.4}, 5, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(game, {defaultCamZoom: 0.4}, 5, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(game.camFollow, {x: 1025, y: -800}, 5,
						{
							ease: FlxEase.smootherStepInOut,
							startDelay: 0,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.4;
								});
							}
						});
				case 'down':
					FlxTween.tween(global.get('redStar'), {alpha: 0}, 1, {ease: FlxEase.linear});
					// FlxTween.tween(snow, {alpha: 0.7}, 0.5, {ease: FlxEase.linear, startDelay: 1});
					FlxTween.num(snowAlpha, 1, 0.5, {startDelay: 1}, (f) -> {
						snowAlpha = f;
					});
					FlxTween.tween(global.get('bfStar'), {alpha: 0}, 1, {ease: FlxEase.linear});
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(game, {defaultCamZoom: 0.5}, 1, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(game.camFollow, {x: 800, y: 500}, 1,
						{
							ease: FlxEase.smootherStepInOut,
							startDelay: 0,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.5;
									game.isCameraOnForcedPos = false;
								});
							}
						});
			}
			switch (value2)
			{
				case 'walk':
					green.alpha = 1;
					FlxTween.tween(green, {x: -200,}, 3.5,
						{
							onComplete: function() {
								green.animation.play('idle');
							}
						});
				case 'kill':
					green.animation.play('kill');
				case 'carry':
					orange.alpha = 0;
					green.animation.play('carry');
					FlxTween.tween(green, {x: -1000,}, 5);
			}
		case 'dialogue':
			switch (value1)
			{
				case 'red':
					redtalk.alpha = 1;
					switch (value2)
					{
						case '1':
							redtalk.animation.play('1');
							redtalk.animation.finishCallback = function() {
								redtalk.alpha = 0;
							};
						case '2':
							redtalk.animation.play('2');
							redtalk.animation.finishCallback = function() {
								redtalk.alpha = 0;
							};
						case '3':
							redtalk.x = 80;
							redtalk.y = 195;
							redtalk.animation.play('3');
							redtalk.animation.finishCallback = function() {
								redtalk.alpha = 0;
								remove(redtalk);
							};
					}
				case 'bf':
					bftalk.alpha = 1;
					switch (value2)
					{
						case '1':
							bftalk.x = 1025;
							bftalk.y = 140;
							bftalk.animation.play('1');
							bftalk.animation.finishCallback = function() {
								bftalk.alpha = 0;
							};
						case '2':
							bftalk.x = 1030;
							bftalk.y = 200;
							bftalk.animation.play('2');
							bftalk.animation.finishCallback = function() {
								bftalk.alpha = 0;
							};
						case '3':
							bftalk.x = 1050;
							bftalk.y = 185;
							bftalk.animation.play('3');
							bftalk.animation.finishCallback = function() {
								bftalk.alpha = 0;
								remove(bftalk);
							};
					}
			}
		case 'sabotage':
			var detectData = global.get('detectiveUI');
			switch (value1)
			{
				case 'noOpp':
					FlxTween.tween(global.get('sabo_detective'), {alpha: 1}, 3, {ease: FlxEase.linear});
					FlxTween.tween(game.opponentStrums, {alpha: 0}, 7, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.healthBar, {alpha: 0}, 7, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.iconP1, {alpha: 0}, 7, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.iconP2, {alpha: 0}, 7, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.scoreTxt, {alpha: 0}, 7, {ease: FlxEase.linear});
					healthLoss = 0;
				case 'drop':
					var boomBoxS:BGSprite = global.get('boomBoxS');
					
					boomBoxS.alpha = 1;
					boomBoxS.animation.play('anim');
					boomBoxS.setPosition(gf.x + 240, gf.y + 50);
					stage.insert(stage.members.indexOf(gfGroup) + 1, boomBoxS);
				case 'oppReturn':
					healthLoss = 1;
					FlxTween.tween(game.opponentStrums, {alpha: 1}, 5, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.healthBar, {alpha: 1}, 5, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.iconP1, {alpha: 1}, 5, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.iconP2, {alpha: 1}, 5, {ease: FlxEase.linear});
					FlxTween.tween(game.playHUD.scoreTxt, {alpha: 1}, 5, {ease: FlxEase.linear});
					
					FlxTween.tween(detectData.investigationText, {y: 1000}, 0.7, {ease: FlxEase.expoIn});
					FlxTween.tween(detectData.detectiveUI, {y: 1000}, 0.7, {ease: FlxEase.expoIn});
					FlxTween.tween(detectData.detectiveIcon, {y: 1000}, 0.7, {ease: FlxEase.expoIn});
					
					FlxTween.tween(detectData.flxBar, {y: 1000}, 0.7, {ease: FlxEase.expoIn});
					FlxTween.tween(detectData.detectiveUI2, {y: 1000}, 0.7,
						{
							ease: FlxEase.expoIn,
							onComplete: function(tween:FlxTween) {
								FlxTimer.wait(0, () -> {
									detectData.detectiveUI.visible = detectData.detectiveUI.active = false;
									detectData.detectiveUI2.visible = detectData.detectiveUI2.active = false;
									detectData.flxBar.visible = detectData.flxBar.active = false;
								});
							}
						});
				case 'detective alt idle':
					var detective:Character = global.get('sabo_detective');
					detective.idleSuffix = '-alt';
					detective.recalculateDanceIdle();
				case 'obiturary':
					var detective:Character = global.get('sabo_detective');
					detective.playAnim('turn', true);
					detective.specialAnim = true;
					detective.idleSuffix = '';
					detective.recalculateDanceIdle();
				case 'saltyDKFunkin':
					FlxTween.tween(global.get('sabo_spotlight'), {alpha: 0.7}, 3, {ease: FlxEase.linear, startDelay: 0});
				case 'jammy':
					FlxTween.tween(global.get('sabo_spotlight'), {alpha: 0}, 3, {ease: FlxEase.linear});
				case 'ending':
					camGame.visible = camHUD.visible = false;
					inCutscene = true;
				case 'slideUp':
					startCountdown();
					
					global.get('startInvestigationCountdown')(35);
					
					FlxTween.tween(detectData.detectiveIcon, {y: 540}, 0.4, {ease: FlxEase.expoOut});
					FlxTween.tween(detectData.investigationText, {y: 618}, 0.4, {ease: FlxEase.expoOut});
					FlxTween.tween(detectData.detectiveUI, {y: 415}, 0.4, {ease: FlxEase.expoOut});
					FlxTween.tween(detectData.detectiveUI2, {y: 415}, 0.4,
						{
							ease: FlxEase.expoOut,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									detectData.flxBar.alpha = 1;
									FlxTween.tween(detectData.flxBar, {value: 60}, 35, {ease: FlxEase.linear});
								});
							}
						});
			}
			
		case 'speechbubble':
			switch (value1)
			{
				case 'red':
					speechBubbleBlue.alpha = 1;
					switch (value2)
					{
						case 'intro':
							speechBubbleBlue.x = 0;
							speechBubbleBlue.y = 200;
							speechBubbleBlue.x += -70; // Adjust x offset for intro animation
							speechBubbleBlue.y += -100; // Adjust y offset for intro animation
							speechBubbleBlue.animation.play('intro', false);
							speechBubbleBlue.animation.finishCallback = function() {
								speechBubbleBlue.animation.play('idle', true);
								speechBubbleBlue.x += 70;
								speechBubbleBlue.y += 100;
							};
						case 'exit':
							speechBubbleRed.x = 1000;
							speechBubbleRed.y = 175;
							speechBubbleBlue.x += -20; // Adjust x offset for exit animation
							speechBubbleBlue.y += -40; // Adjust y offset for exit animation
							speechBubbleBlue.animation.play('exit', false);
							speechBubbleBlue.animation.finishCallback = function() {
								speechBubbleBlue.alpha = 0;
							};
					}
				case 'blue':
					speechBubbleRed.alpha = 1;
					switch (value2)
					{
						case 'intro':
							speechBubbleRed.x = 1000;
							speechBubbleRed.y = 175;
							speechBubbleRed.x += -65; // Adjust x offset for intro animation
							speechBubbleRed.y += -100; // Adjust y offset for intro animation
							speechBubbleRed.animation.play('intro', false);
							speechBubbleRed.animation.finishCallback = function() {
								speechBubbleRed.animation.play('idle', true);
								speechBubbleRed.x += 65; // Adjust x offset for exit animation
								speechBubbleRed.y += 100;
							};
						case 'exit':
							speechBubbleRed.x = 1000;
							speechBubbleRed.y = 175;
							speechBubbleRed.x += -65; // Adjust x offset for intro animation
							speechBubbleRed.y += -100; // Adjust y offset for exit animation
							speechBubbleRed.animation.play('exit', false);
							speechBubbleRed.animation.finishCallback = function() {
								speechBubbleRed.alpha = 0;
							};
					}
			}
		case 'meltdown':
			switch (value1)
			{
				case 'boombox':
					boomBox.x = 1135;
					boomBox.y = 525;
					boomBox.animation.play('alert');
					boomBox.animation.finishCallback = function() {
						boomBox.x = 1140;
						boomBox.y = 680;
						boomBox.animation.play('sus');
					};
					
				case 'redVote':
					var v = Std.parseInt(value2);
					rv += 1;
					var voter:FlxSprite = new FlxSprite(dad.x + 100, dad.y - 100).loadGraphic(Paths.image(ext + 'meltdown/votingIcons'), true, 150, 150);
					voter.animation.add('yy', [8, v], 0, false);
					voter.animation.play('yy');
					voter.origin.set(75, 75);
					voter.animation.curAnim.curFrame = 1;
					voter.ID = rv;
					voter.scale.set(0, 0);
					voter.antialiasing = ClientPrefs.globalAntialiasing;
					redVoters.add(voter);
					refreshVoters();
				case 'bfVote':
					var v = Std.parseInt(value2);
					bv += 1;
					var voter:FlxSprite = new FlxSprite(boyfriend.x, boyfriend.y - 100).loadGraphic(Paths.image(ext + 'meltdown/votingIcons'), true, 150, 150);
					voter.animation.add('yy', [8, v], 0, false);
					voter.animation.play('yy');
					voter.scale.set(0, 0);
					voter.animation.curAnim.curFrame = 1;
					voter.origin.set(75, 75);
					voter.ID = bv;
					voter.antialiasing = ClientPrefs.globalAntialiasing;
					bfVoters.add(voter);
					refreshVoters();
				case 'meeting':
					stars.alpha = 0;
					FlxTween.tween(floor, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(mountains, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(mountains2, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					
					FlxTween.tween(greenTable, {x: -100, y: 500}, 0.2, {ease: FlxEase.linear});
					FlxTween.tween(limeTable, {x: 2050, y: 400}, 0.4, {ease: FlxEase.linear});
					FlxTween.tween(roseTable, {x: 1700, y: 320}, 0.8, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(cyanTable, {x: -550, y: 650}, 0.8, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(purpleTable, {x: 725, y: 970}, 1, {ease: FlxEase.smootherStepInOut});
					
					emergency.alpha = 1;
					emergency.animation.play('idle');
					meltdownBGLeft.alpha = 1;
					meltdownBGRight.alpha = 1;
					meltdownTable.alpha = 1;
					lime.alpha = 0;
					purple.alpha = 0;
					rose.alpha = 0;
					cyan.alpha = 0;
					
					// meltdownBGBack.zIndex = 0;
					// snowEmitter.zIndex = 1;
					// refreshZ();
					snowEmitter.scrollFactor.x.set(0.8, 1);
					snowEmitter.scrollFactor.y.set(0.8, 1);
					stage.remove(snowEmitter);
					stage.insert(stage.members.indexOf(meltdownBGBack) + 1, snowEmitter);
					
					FlxTween.tween(meltdownBGBack, {x: 50, y: 335}, 0.4, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(meltdownBGLeft, {x: -1100}, 0.2, {ease: FlxEase.linear});
					FlxTween.tween(meltdownBGRight, {x: (1 * meltdownBGLeft.width) - 1100}, 0.2, {ease: FlxEase.linear});
					FlxTween.tween(gf, {alpha: 1}, 0.6,
						{
							ease: FlxEase.linear,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									FlxTween.tween(emergency, {alpha: 0}, 1, {ease: FlxEase.linear, startDelay: 1});
								});
							}
						});
					FlxTween.tween(gf, {y: 480}, 0.8, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(meltdownTable, {y: 650}, 0.3, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(gfDead, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(boomBox, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					
					// FlxTween.tween(snow2, {alpha: 1}, 0.5, {ease: FlxEase.linear});
					
					// FlxTween.tween(overlay, {alpha: 0}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(vignette, {alpha: 0}, 0.5, {ease: FlxEase.linear});
				case 'facepalm':
					greenTable.animation.play('facepalm', false);
					greenTable.animation.finishCallback = function() {
						greenTable.animation.play('loop', true);
					};
				case 'watch':
					greenTable.animation.play('idle-peep');
					limeTable.animation.play('idle-peep');
					roseTable.animation.play('idle-peep');
					cyanTable.animation.play('idle-peep');
					purpleTable.animation.play('idle-peep');
				case 'bop':
					limeTable.animation.play('idle');
					roseTable.animation.play('idle');
					cyanTable.animation.play('idle');
					purpleTable.animation.play('idle');
					
				case 'camMiddle':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1,
						{
							ease: FlxEase.smootherStepInOut,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.5;
								});
							}
						});
				case 'camMiddleMeeting':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1, {ease: FlxEase.linear});
					FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1,
						{
							ease: FlxEase.linear,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.65;
								});
							}
						});
						
				case 'camMiddleAyo':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1,
						{
							ease: FlxEase.smootherStepInOut,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									FlxTween.tween(FlxG.camera, {zoom: 0.8}, 0.8,
										{
											ease: FlxEase.smootherStepInOut,
											startDelay: 2,
											onComplete: function(tween:FlxTween) {
												new FlxTimer().start(0, function(tmr:FlxTimer) {
													game.defaultCamZoom = 0.8;
												});
											}
										});
								});
							}
						});
						
				case 'camMiddle6':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1,
						{
							ease: FlxEase.smootherStepInOut,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.6;
								});
							}
						});
				case 'camNormal':
					game.isCameraOnForcedPos = false;
				case 'camMiddleSlow':
					game.isCameraOnForcedPos = true;
					FlxTween.tween(game.camFollow, {x: 1025, y: 500}, 1.5, {ease: FlxEase.smootherStepInOut});
					FlxTween.tween(FlxG.camera, {zoom: 0.65}, 1.5,
						{
							ease: FlxEase.linear,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									game.defaultCamZoom = 0.5;
								});
							}
						});
				case 'meetingZoom':
					game.isCameraOnForcedPos = true;
			}
			switch (value2)
			{
				case 'idle':
					green.animation.play('idle');
					green.y += 100;
				case 'cyan':
					FlxTween.tween(cyan, {x: -25}, 6,
						{
							ease: FlxEase.linear,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									cyan.animation.play('idle');
									cyan.y += 20;
								});
							}
						});
				case 'purple':
					FlxTween.tween(purple, {x: 2050}, 5,
						{
							ease: FlxEase.linea,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									purple.animation.play('idle');
								});
							}
						});
				case 'rose':
					FlxTween.tween(rose, {x: 1800}, 5,
						{
							ease: FlxEase.linear,
							onComplete: function(tween:FlxTween) {
								new FlxTimer().start(0, function(tmr:FlxTimer) {
									rose.animation.play('idle');
								});
							}
						});
				case 'lime':
					FlxTween.tween(lime, {x: -300}, 5, {ease: FlxEase.smootherStepInOut});
			}
	}
}

function buildMeltdownBG()
{
	meltdownBGBack = new BGSprite(ext + "meltdown/buildingsbg", 50, 4000);
	meltdownBGBack.scrollFactor.set(0.85, 0.85);
	add(meltdownBGBack);
	meltdownBGBack.zIndex = 5;
	
	meltdownBGLeft = new BGSprite(ext + "meltdown/wallBGLeft", -4000, -300);
	meltdownBGLeft.alpha = 0;
	add(meltdownBGLeft);
	meltdownBGLeft.zIndex = 5;
	
	cyan = new BGSprite(null, -2000, 475).loadSparrowFrames(ext + "meltdown/crewOutside");
	cyan.animation.addByPrefix('walk', 'CYAN WALK', 24, true);
	cyan.animation.addByPrefix('idle', 'IDLE CYAN', 24, true);
	cyan.animation.play('walk');
	add(cyan);
	cyan.zIndex = 5;
	
	rose = new BGSprite(null, 3000, 305).loadSparrowFrames(ext + 'meltdown/crewOutside');
	rose.animation.addByIndices('walk', 'ROSE', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], "", 24, true);
	rose.animation.addByIndices('idle', 'ROSE', [16, 17, 18, 19], "", 24, true);
	rose.animation.play('walk');
	add(rose);
	rose.zIndex = 5;
	
	meltdownBGRight = new BGSprite(ext + "meltdown/wallBGRight", ((meltdownBGLeft.width) + meltdownBGLeft.x) + 4000, meltdownBGLeft.y);
	add(meltdownBGRight);
	meltdownBGRight.alpha = 0;
	meltdownBGRight.zIndex = 6;
	
	speechBubbleBlue = new BGSprite(null, 100, 250).loadSparrowFrames(ext + "meltdown/textbox");
	speechBubbleBlue.animation.addByPrefix('idle', 'RedBubbleBoil', 24, true);
	speechBubbleBlue.animation.addByPrefix('intro', 'RedBubblePop', 24, false);
	speechBubbleBlue.animation.addByPrefix('exit', 'RedBubbleOut', 24, false);
	speechBubbleBlue.scale.set(0.9, 0.9);
	add(speechBubbleBlue);
	speechBubbleBlue.alpha = 0;
	speechBubbleBlue.zIndex = 6;
	
	speechBubbleRed = new BGSprite(null, 1000, 175).loadSparrowFrames(ext + "meltdown/textbox");
	speechBubbleRed.animation.addByPrefix('idle', 'BlueBubbleBoil', 24, true);
	speechBubbleRed.animation.addByPrefix('intro', 'BlueBubblePop', 24, false);
	speechBubbleRed.animation.addByPrefix('exit', 'BlueBubbleOut', 24, false);
	speechBubbleRed.scale.set(0.9, 0.9);
	add(speechBubbleRed);
	speechBubbleRed.alpha = 0;
	speechBubbleRed.zIndex = 6;
	
	redtalk = new BGSprite(null, 80, 230).loadSparrowFrames(ext + "meltdown/RedSpeech1");
	redtalk.animation.addByPrefix('1', 'red1', 24, false);
	redtalk.animation.addByPrefix('2', 'red2', 24, false);
	redtalk.animation.addByPrefix('3', 'red3', 24, false);
	redtalk.scale.set(0.85, 0.72);
	redtalk.alpha = 0;
	redtalk.zIndex = 6;
	add(redtalk);
	
	bftalk = new BGSprite(null, 1025, 140).loadSparrowFrames(ext + "meltdown/BFSpeech1");
	bftalk.animation.addByPrefix('1', 'bf1', 24, false);
	bftalk.animation.addByPrefix('2', 'bf2', 24, false);
	bftalk.animation.addByPrefix('3', 'bf3', 24, false);
	bftalk.scale.set(0.85, 0.72);
	bftalk.alpha = 0;
	bftalk.zIndex = 6;
	add(bftalk);
	
	gfDead = new BGSprite(null, 920, 580).loadSparrowFrames(ext + "meltdown/gfDead");
	gfDead.animation.addByPrefix('idle', 'gf DEAD', 24, true);
	gfDead.alpha = 0;
	gfDead.scale.set(1.1, 1.1);
	add(gfDead);
	gfDead.animation.play('idle');
	gfDead.zIndex = 6;
	
	boomBox = new BGSprite(null, 1175, 780).loadSparrowFrames(ext + "meltdown/boombox");
	boomBox.animation.addByPrefix('idle', 'floor boombox', 24, true);
	boomBox.animation.addByPrefix('alert', 'boombox alert', 24, false);
	boomBox.animation.addByPrefix('sus', 'boombox anim', 24, false);
	boomBox.alpha = 0;
	boomBox.scale.set(1.1, 1.1);
	add(boomBox);
	boomBox.animation.play('idle');
	boomBox.zIndex = 6;


	emergency = new BGSprite(null, 0, 50).loadSparrowFrames(ext + "meltdown/meeting");
	emergency.cameras = [game.camHUD];
	emergency.animation.addByPrefix('idle', 'meeting', 24, false);
	emergency.alpha = 0;
	add(emergency);
	emergency.animation.play('idle');
	emergency.zIndex = 6;
	
	greenTable = new BGSprite(null, -1000, 570).loadSparrowFrames(ext + "meltdown/crewInside");
	greenTable.animation.addByPrefix('idle', 'GREEN LOOP', 24, false);
	greenTable.animation.addByPrefix('idle-peep', 'GRELOOKATRED', 24, false);
	greenTable.animation.addByPrefix('facepalm', 'GREEN FACEPALM', 24, false);
	greenTable.animation.addByPrefix('loop', 'GREEN ANGER LOOP', 24, true);
	greenTable.animation.play('idle');
	greenTable.scale.set(0.9, 0.9);
	
	greenTable.zIndex = 14;
	
	investigationText = new FlxText(180, 1000, 480, "Investigation ends in 0", true);
	investigationText.setFormat(Paths.font("bahn.ttf"), 24, 0xFFFFFF, "center");
	investigationText.cameras = [game.camHUD];
	investigationText.alpha = 1;
	investigationText.antialiasing = ClientPrefs.globalAntialiasing;
	game.add(investigationText);
	
	roseTable = new BGSprite(null, 3000, 370).loadSparrowFrames(ext + "meltdown/crewInside");
	roseTable.animation.addByPrefix('idle', 'METING ROSE', 24, false);
	roseTable.animation.addByPrefix('idle-peep', 'LOOKING ROSE', 24, false);
	roseTable.animation.play('idle');
	roseTable.alpha = 1;
	roseTable.scale.set(0.9, 0.9);
	roseTable.zIndex = 14;
	
	add(greenTable);
	
	add(roseTable);
	
	redVoters = new FlxTypedGroup();
	redVoters.zIndex = 14;
	add(redVoters);

	global.set('redVoters',redVoters);
	
	bfVoters = new FlxTypedGroup();
	bfVoters.zIndex = 14;
	add(bfVoters);
	global.set('bfVoters',bfVoters);

	
	purple = new BGSprite(null, 3000, 650).loadSparrowFrames(ext + "meltdown/crewOutside");
	purple.animation.addByIndices('walk', 'PURPLE', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, true);
	purple.animation.addByIndices('idle', 'PURPLE', [4, 5, 6, 7], "", 24, true);
	purple.animation.play('walk');
	purple.alpha = 0;
	if (PlayState.SONG.song.toLowerCase() == 'meltdown')
	{
		purple.alpha = 1;
	}
	purple.scrollFactor.set(1.2, 1.2);
	purple.scale.set(1.1, 1.1);
	add(purple);
	
	purple.zIndex = 15;
	
	lime = new BGSprite(null, -2500, 375).loadSparrowFrames(ext + "meltdown/crewOutside");
	lime.animation.addByPrefix('idle', 'LIME', 24, true);
	lime.animation.play('idle');
	lime.scale.set(1.1, 1.1);
	lime.scrollFactor.set(1.2, 1.2);
	add(lime);
	lime.zIndex = 15;
	
	meltdownTable = new BGSprite(ext + "meltdown/Table", 0, 4000);
	meltdownTable.alpha = 0;
	add(meltdownTable);
	
	meltdownTable.zIndex = 15;
	
	cyanTable = new BGSprite(null, -1600, 650).loadSparrowFrames(ext + "meltdown/crewInside");
	cyanTable.animation.addByPrefix('idle', 'MEETING CYAN', 24, true);
	cyanTable.animation.addByPrefix('idle-peep', 'CYAN PEEP', 24, true);
	cyanTable.animation.play('idle');
	cyanTable.scrollFactor.set(1.1, 1.1);
	cyanTable.scale.set(1.1, 1.1);
	add(cyanTable);
	
	cyanTable.zIndex = 15;
	
	purpleTable = new BGSprite(null, 900, 2000).loadSparrowFrames(ext + "meltdown/crewInside");
	purpleTable.animation.addByPrefix('idle', 'PURPLE MEETING', 24, true);
	purpleTable.animation.play('idle');
	purpleTable.scrollFactor.set(1.2, 1.2);
	purpleTable.scale.set(1.3, 1.3);
	add(purpleTable);
	
	purpleTable.zIndex = 15;
	
	limeTable = new BGSprite(null, 3000, 400).loadSparrowFrames(ext + "meltdown/crewInside");
	limeTable.animation.addByPrefix('idle', 'LIME MEETING', 24, true);
	limeTable.animation.addByPrefix('idle-peep', 'LIMELOOK', 24, true);
	limeTable.animation.play('idle');
	limeTable.scrollFactor.set(1.1, 1.1);
	limeTable.scale.set(1.3, 1.3);
	add(limeTable);
	
	limeTable.zIndex = 15;
}
