package mobile.options;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import mobile.backend.MobileData;
import mobile.objects.MobileControls;
import mobile.objects.TouchButton;

class MobileControlsSubState extends MusicBeatSubstate
{
	var options:Array<String> = [
		'HITBOX',
		'BOTTOM_ROW',
		'LEFT_FULL',
		'RIGHT_FULL',
		'CUSTOM',
	];

	var curSelected:Int = 0;
	var showingUI:Bool = true;

	var snapToGrid:Bool = false;
	var grid:FlxBackdrop;
	var cellWidth:Int = 25;
	var cellHeight:Int = 25;

	var curControl:Alphabet;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var exitButton:PsychUIButton;
	var hideButton:PsychUIButton;
	var rebindButton:PsychUIButton;
	var resetButton:PsychUIButton;
	var snapButton:PsychUIButton;

	override function create() {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF77F24E);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.6}, 0.5, {ease: FlxEase.quadOut});
		add(bg);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(cellWidth, cellHeight, FlxG.width, FlxG.height, true, 0x33FFFFFF, 0x0));
		grid.visible = false;
		add(grid);

		mobileControls = new MobileControls();
		add(mobileControls);

		curControl = new Alphabet(100, 50);
		add(curControl);

		leftArrow = new FlxSprite(curControl.x - 70, curControl.y - 5);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(curControl.x + curControl.width + 20, curControl.y - 5);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
		add(rightArrow);

		exitButton = new PsychUIButton(FlxG.width - 300, 50, Language.getPhrase('mobile_controls_save_and_exit', 'Save and Exit'), null, 250, 80);
		exitButton.normalStyle.bgColor = 0xFF00F24E;
		exitButton.text.font = Paths.font('vcr.ttf');
		exitButton.text.fieldWidth = 0;
		exitButton.text.size = 26;
		if (exitButton.text.width > exitButton.bg.width - 20) {
			exitButton.text.scale.x = exitButton.text.scale.y = exitButton.bg.width / exitButton.width;
			exitButton.text.updateHitbox();
		}
		exitButton.text.x = exitButton.bg.x + (exitButton.bg.width - exitButton.text.width) / 2;
		exitButton.text.y = exitButton.bg.y + (exitButton.bg.height - exitButton.text.height) / 2;
		add(exitButton);

		hideButton = new PsychUIButton(20, 160, Language.getPhrase('mobile_controls_hide_ui', 'Hide UI'), null, 250, 80);
		hideButton.normalStyle.bgColor = 0xFF4AA3F0;
		hideButton.text.font = Paths.font('vcr.ttf');
		hideButton.text.fieldWidth = 0;
		hideButton.text.size = 26;
		if (hideButton.text.width > hideButton.bg.width - 20) {
			hideButton.text.scale.x = hideButton.text.scale.y = hideButton.bg.width / hideButton.width;
			hideButton.text.updateHitbox();
		}
		hideButton.text.x = hideButton.bg.x + (hideButton.bg.width - hideButton.text.width) / 2;
		hideButton.text.y = hideButton.bg.y + (hideButton.bg.height - hideButton.text.height) / 2;
		add(hideButton);

		if (ClientPrefs.data.extraButton) {
			rebindButton = new PsychUIButton(exitButton.x - 300, exitButton.y, Language.getPhrase('mobile_controls_rebind', 'Rebind Extra'), null, 250, 80);
			rebindButton.normalStyle.bgColor = 0xFFAAAAAA;
			rebindButton.text.font = Paths.font('vcr.ttf');
			rebindButton.text.fieldWidth = 0;
			rebindButton.text.size = 26;
			if (rebindButton.text.width > rebindButton.bg.width - 20) {
				rebindButton.text.scale.x = rebindButton.text.scale.y = rebindButton.bg.width / rebindButton.width;
				rebindButton.text.updateHitbox();
			}
			rebindButton.text.x = rebindButton.bg.x + (rebindButton.bg.width - rebindButton.text.width) / 2;
			rebindButton.text.y = rebindButton.bg.y + (rebindButton.bg.height - rebindButton.text.height) / 2;
			add(rebindButton);
		}

		resetButton = new PsychUIButton(exitButton.x, exitButton.y + 110, Language.getPhrase('mobile_controls_reset_positions', 'Reset Positions'), null, 250, 80);
		resetButton.normalStyle.bgColor = 0xFFFF0000;
		resetButton.text.font = Paths.font('vcr.ttf');
		resetButton.text.fieldWidth = 0;
		resetButton.text.size = 26;
		if (resetButton.text.width > resetButton.bg.width - 20) {
			resetButton.text.scale.x = resetButton.text.scale.y = resetButton.bg.width / resetButton.width;
			resetButton.text.updateHitbox();
		}
		resetButton.text.x = resetButton.bg.x + (resetButton.bg.width - resetButton.text.width) / 2;
		resetButton.text.y = resetButton.bg.y + (resetButton.bg.height - resetButton.text.height) / 2;
		resetButton.update(FlxG.elapsed);
		resetButton.kill();
		add(resetButton);

		snapButton = new PsychUIButton(resetButton.x, resetButton.y + 110, Language.getPhrase('mobile_controls_snap', 'Snap to Grid'), null, 250, 80);
		snapButton.normalStyle.bgColor = 0xFFFFFF00;
		snapButton.text.font = Paths.font('vcr.ttf');
		snapButton.text.fieldWidth = 0;
		snapButton.text.size = 26;
		if (snapButton.text.width > snapButton.bg.width - 20) {
			snapButton.text.scale.x = snapButton.text.scale.y = snapButton.bg.width / snapButton.width;
			snapButton.text.updateHitbox();
		}
		snapButton.text.x = snapButton.bg.x + (snapButton.bg.width - snapButton.text.width) / 2;
		snapButton.text.y = snapButton.bg.y + (snapButton.bg.height - snapButton.text.height) / 2;
		snapButton.update(FlxG.elapsed);
		snapButton.kill();
		add(snapButton);

		curSelected = Std.int(Math.max(options.indexOf(ClientPrefs.data.controlMode.toUpperCase()), 0));
		changeControl(0, false);

		super.create();
	}

	var movingButtons:Array<Array<Dynamic>> = [];
	override function update(elapsed:Float) {
		if (showingUI) {
			if (controls.BACK || TouchUtil.overlaps(exitButton) && TouchUtil.justPressed) {
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
				ClientPrefs.data.controlMode = options[curSelected];
				ClientPrefs.saveSettings();
				if (options[curSelected] == 'CUSTOM') {
					MobileData.saveCustomPad(mobileControls.virtualPad);
				}
				close();
			}

			if (rebindButton != null && TouchUtil.overlaps(rebindButton) && TouchUtil.justPressed) {
				openSubState(new RebindSubstate());
			}

			if (options[curSelected] == 'CUSTOM') {
				if (TouchUtil.overlaps(resetButton) && TouchUtil.justPressed) {
					MobileData.resetCustomPad();
					for (i => button in [mobileControls.virtualPad.buttonLeft, mobileControls.virtualPad.buttonDown, mobileControls.virtualPad.buttonUp, mobileControls.virtualPad.buttonRight, mobileControls.virtualPad.buttonExtra]) {
						button.x = MobileData.save.data.customPad[i][0];
						button.y = MobileData.save.data.customPad[i][1];
					}
				}
				if (TouchUtil.overlaps(snapButton) && TouchUtil.justPressed) {
					snapToGrid = grid.visible = !grid.visible;
				}
			}

			if (TouchUtil.overlaps(leftArrow) && TouchUtil.pressed) {
				leftArrow.animation.play('press');
				if (TouchUtil.justPressed) changeControl(-1);
			}
			else {
				leftArrow.animation.play('idle');
			}

			if (TouchUtil.overlaps(rightArrow) && TouchUtil.pressed) {
				rightArrow.animation.play('press');
				if (TouchUtil.justPressed) changeControl(1);
			}
			else {
				rightArrow.animation.play('idle');
			}

			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeControl(controls.UI_LEFT_P ? -1 : 1);
			}
		}

		if (TouchUtil.overlaps(hideButton) && TouchUtil.justPressed) {
			hideUI(showingUI);
		}

		if (options[curSelected] == 'CUSTOM') {
			for (button in [mobileControls.virtualPad.buttonLeft, mobileControls.virtualPad.buttonDown, mobileControls.virtualPad.buttonUp, mobileControls.virtualPad.buttonRight, mobileControls.virtualPad.buttonExtra]) {
				if (!ClientPrefs.data.extraButton && button == mobileControls.virtualPad.buttonExtra) continue;

				for (i => touch in TouchUtil.inputs.list) {
					if (TouchUtil.initiallyOverlapped([button], null, null, [touch]) && touch.pressed && movingButtons[i] == null) {
						movingButtons[i] = [];
						movingButtons[i][0] = button;
						movingButtons[i][1] = [button.x, button.y];
					}
					else if (touch.justReleased && movingButtons[i] != null) {
						movingButtons[i] = null;
					}
				}
			}
			for (i => touch in TouchUtil.inputs.list) {
				if (movingButtons[i] != null) {
					if (snapToGrid) {
						movingButtons[i][1][0] += touch.deltaX;
						movingButtons[i][1][1] += touch.deltaY;
						movingButtons[i][0].x = Math.round(movingButtons[i][1][0] / cellWidth) * cellWidth;
						movingButtons[i][0].y = Math.round(movingButtons[i][1][1] / cellHeight) * cellHeight;
					}
					else {
						movingButtons[i][0].x += touch.deltaX;
						movingButtons[i][0].y += touch.deltaY;
					}
				}
			}
		}

		super.update(elapsed);
	}

	function changeControl(change:Int = 0, playSound:Bool = true) {
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		curControl.text = options[curSelected];
		rightArrow.x = curControl.x + curControl.width + 20;
		mobileControls.changeControl(MobileData.controlModes.get(options[curSelected]), ClientPrefs.data.hitboxStyle);
		MobileData.setControlColor(mobileControls.currentMode);

		if (mobileControls.isVirtualPad) mobileControls.virtualPad.allowSwiping = false;

		if (options[curSelected] == 'CUSTOM') {
			resetButton.revive();
			snapButton.revive();
		}
		else {
			if (resetButton.alive) resetButton.kill();
			if (snapButton.alive) snapButton.kill();
			if (snapToGrid) snapToGrid = grid.visible = false;
		}
	}

	function hideUI(hide:Bool = false) {
		showingUI = !hide;
		for (button in [curControl, leftArrow, rightArrow, exitButton, resetButton, hideButton, rebindButton]) {
			if (button == null) continue;

			if (button == hideButton) {
				var b:PsychUIButton = cast button;
				b.normalStyle.bgAlpha = b.hoverStyle.bgAlpha = b.clickStyle.bgAlpha = hide ? 0.15 : 1;
			}
			if (hide && button != hideButton) button.active = false;
			else if (!hide && button.alive) button.active = true;
			FlxTween.cancelTweensOf(button);
			FlxTween.tween(button, { alpha: (hide && button == hideButton) ? 0.15 : hide ? 0 : 1 }, 0.15);
		}
	}
}

class RebindSubstate extends MusicBeatSubstate
{
	override function create() {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		add(bg);

		var rebindingTxt:Alphabet = new Alphabet(FlxG.width / 2, 160, 'Rebinding EXTRA key\nCurrent bind: ' + ClientPrefs.data.hitboxExtraKeybind, true);
		rebindingTxt.alignment = CENTERED;
		add(rebindingTxt);

		FlxTween.tween(bg, { alpha: 0.6 }, 0.25);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		FlxG.stage.window.textInputEnabled = true;

		super.create();
	}

	override function update(elapsed:Float) {
		if (TouchUtil.justPressed || !FlxG.stage.window.textInputEnabled) close();
	}

	override function destroy() {
		FlxG.stage.window.textInputEnabled = false;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		ClientPrefs.saveSettings();
		super.destroy();
	}

	function onKeyDown(e:KeyboardEvent) {
		ClientPrefs.data.hitboxExtraKeybind = cast(e.keyCode, FlxKey).toString();
		close();
	}
}