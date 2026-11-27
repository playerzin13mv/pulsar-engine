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

	// ---- Estilo BOTTOM_ROW (setas em fileira embaixo, como o FNF da Play Store) ----
	// Índices dos botões: 0 esquerda, 1 baixo, 2 cima, 3 direita, 4 botão extra

	public static function bottomRowButtons(virtualPad:VirtualPad):Array<TouchButton> {
		return [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight, virtualPad.buttonExtra];
	}

	// Tamanho salvo (1 = 100%). Limitado entre 50% e 200%.
	public static function getBottomRowScale():Float {
		var scale:Null<Float> = save.data.bottomRowScale;
		if (scale == null || Math.isNaN(scale)) return 1;
		return FlxMath.bound(scale, 0.5, 2);
	}

	// Posição padrão: 4 setas em fileira embaixo; o botão extra fica acima da seta da direita.
	// Para mudar o espaçamento padrão, ajuste "margin" (distância das bordas).
	public static function getBottomRowDefaultPosition(index:Int, scale:Float = 1):Array<Float> {
		var w:Float = 132 * scale;
		var h:Float = 127 * scale;
		if (index == 4) return [FlxG.width - w - 20, FlxG.height - h * 2 - 40];
		var margin:Float = 40;
		var step:Float = (FlxG.width - margin * 2 - w) / 3;
		return [margin + step * index, FlxG.height - h - 20];
	}

	// Aplica tamanho e posição (salvos, ou os padrões se não houver nada salvo).
	public static function applyBottomRow(virtualPad:VirtualPad, scale:Float = -1) {
		if (scale < 0) scale = getBottomRowScale();
		var saved:Array<Dynamic> = save.data.bottomRowPad;
		for (i => button in bottomRowButtons(virtualPad)) {
			if (i == 4 && !ClientPrefs.data.extraButton) continue;
			button.scale.set(scale, scale);
			button.updateHitbox();
			var pos:Array<Float> = getBottomRowDefaultPosition(i, scale);
			if (saved != null && saved[i] != null && saved[i].length > 1) pos = saved[i];
			button.x = pos[0];
			button.y = pos[1];
		}
	}

	public static function saveBottomRow(virtualPad:VirtualPad, scale:Float) {
		var old:Array<Dynamic> = save.data.bottomRowPad;
		var result:Array<Dynamic> = [];
		for (i => button in bottomRowButtons(virtualPad)) {
			// Sem o botão extra ativo, mantém a posição antiga dele em vez de salvar (0, 0)
			if (i == 4 && !ClientPrefs.data.extraButton) result.push(old != null ? old[4] : null);
			else result.push([button.x, button.y]);
		}
		save.data.bottomRowPad = result;
		save.data.bottomRowScale = scale;
		save.flush();
	}

	public static function resetBottomRow() {
		Reflect.deleteField(save.data, 'bottomRowPad');
		save.data.bottomRowScale = 1.0;
		save.flush();
	}
}
