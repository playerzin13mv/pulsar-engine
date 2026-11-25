package mobile.backend;

import flixel.util.FlxSave;

import mobile.objects.TouchButton;
import mobile.objects.VirtualPad;

enum ControlMode {
	HITBOX;
	LEFT_FULL;
	RIGHT_FULL;
	BOTTOM_ROW;
	CUSTOM;
}

class MobileData
{
	public static var buildVersion:String = '1.1.0';
	public static var controlModes:Map<String, ControlMode> = [];
	public static var hitboxStyles:Array<String> = ['Normal', 'Gradient', 'Hidden'];
	public static var save:FlxSave;

	public static function load() {
		save = new FlxSave();
		save.bind('MobileData', CoolUtil.getSavePath());

		for (mode in ControlMode.createAll()) {
			controlModes.set(Std.string(mode), mode);
		}
	}

	public static function setControlColor(control:Dynamic, ?colors:Array<Array<FlxColor>>) {
		colors ??= PlayState.isPixelStage ? ClientPrefs.data.arrowRGBPixel : ClientPrefs.data.arrowRGB;
		for (i => button in [control.buttonLeft, control.buttonDown, control.buttonUp, control.buttonRight, control.buttonExtra]) {
			var color:FlxColor;
			if (button == control.buttonExtra) color = 0xFFAAAAAA;
			else color = colors[i][0];
			button.color = color;
			button.updateColorTransform();
			if (button.label != null) {
				button.label.color = color;
				button.label.updateColorTransform();
			}
		}
	}

	public static function saveCustomPad(virtualPad:VirtualPad) {
		save.data.customPad = [];
		for (button in [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight, virtualPad.buttonExtra]) {
			save.data.customPad.push([button.x, button.y]);
		}
		save.flush();
	}

	public static function loadCustomPad(virtualPad:VirtualPad) {
		if (save.data.customPad == null) resetCustomPad();

		for (i => button in [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight, virtualPad.buttonExtra]) {
			if (save.data.customPad[i] == null || save.data.customPad[i].length < 1) {
				save.data.customPad[i] = getDefaultPadPosition(i);
				save.flush();
			}
			button.x = save.data.customPad[i][0];
			if (save.data.customPad[i][1] != null) button.y = save.data.customPad[i][1];
		}
	}

	public static function resetCustomPad() {
		// LEFT_FULL + EXTRA default position
		save.data.customPad = [for (i in 0...5) getDefaultPadPosition(i)];
		save.flush();
	}

	public static function getDefaultPadPosition(index:Int):Array<Float> {
		return switch(index) {
			case 0: [0, FlxG.height - 220];
			case 1: [98, FlxG.height - 124];
			case 2: [98, FlxG.height - 315];
			case 3: [196, FlxG.height - 220];
			case 4: [FlxG.width - 225, FlxG.height - 215];
			default: [0, 0];
		}
	}

	// Estilo "Play Store": 4 setas em fileira na parte de baixo da tela.
	// Para mudar o espaçamento, ajuste "margin" (distância das bordas).
	public static function applyBottomRow(virtualPad:VirtualPad) {
		var buttons = [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight];
		var margin:Float = 40;
		var step:Float = (FlxG.width - margin * 2 - buttons[0].width) / 3;
		for (i => button in buttons) {
			button.x = margin + step * i;
			button.y = FlxG.height - button.height - 20;
		}
		if (virtualPad.buttonExtra != null) {
			virtualPad.buttonExtra.x = FlxG.width - virtualPad.buttonExtra.width - 20;
			virtualPad.buttonExtra.y = buttons[0].y - virtualPad.buttonExtra.height - 20;
		}
	}
}
