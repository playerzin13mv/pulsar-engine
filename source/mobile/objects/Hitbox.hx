package mobile.objects;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.GradientType;

import objects.StrumNote;

import mobile.backend.MobileData;
import mobile.input.MobileInputID;
import mobile.input.MobileInputManager;
import mobile.objects.TouchButton;

class Hitbox extends MobileInputManager implements IMobileControls
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_RIGHT]);
	public var buttonExtra:TouchButton = new TouchButton(0, 0, [MobileInputID.EXTRA]);

	public function new(style:String = 'Normal', extra:Bool = false) {
		super();

		#if !mobile return; #end

		var storedKeys:Map<String, Array<MobileInputID>> = [];
		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) storedKeys.set(button, spr.IDs);
		}

		if (extra && ClientPrefs.data.extraButton) addHitbox(style, EXTRA);
		else addHitbox(style, NORMAL);

		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) spr.IDs = storedKeys.get(button);
		}
		updateTrackedButtons();
	}

	public function addHitbox(style:String = 'Normal', hitbox:HitboxLayout) {
		var buttonWidth:Int = Std.int(FlxG.width / 4);
		switch(hitbox) {
			case NORMAL:
				add(buttonLeft = createHitbox(0, 0, buttonWidth, FlxG.height, style));
				add(buttonDown = createHitbox(buttonWidth, 0, buttonWidth, FlxG.height, style));
				add(buttonUp = createHitbox(buttonWidth * 2, 0, buttonWidth, FlxG.height, style));
				add(buttonRight = createHitbox(buttonWidth * 3, 0, buttonWidth, FlxG.height, style));
			case EXTRA:
				var extraPos:String = ClientPrefs.data.hitboxExtraPosition.toLowerCase();
				switch (extraPos) {
					case 'bottom', 'top':
						var buttonHeight:Int = Std.int(FlxG.height / 4);
						var buttonY:Float = extraPos == 'top' ? buttonHeight : 0;
						add(buttonLeft = createHitbox(0, buttonY, buttonWidth, buttonHeight * 3, style));
						add(buttonDown = createHitbox(buttonWidth, buttonY, buttonWidth, buttonHeight * 3, style));
						add(buttonUp = createHitbox(buttonWidth * 2, buttonY, buttonWidth, buttonHeight * 3, style));
						add(buttonRight = createHitbox(buttonWidth * 3, buttonY, buttonWidth, buttonHeight * 3, style));
						add(buttonExtra = createHitbox(0, extraPos == 'top' ? 0 : buttonHeight * 3, FlxG.width, buttonHeight, style));
					case 'middle':
						buttonWidth = Std.int(FlxG.width / 5);
						add(buttonLeft = createHitbox(0, 0, buttonWidth, FlxG.height, style));
						add(buttonDown = createHitbox(buttonWidth, 0, buttonWidth, FlxG.height, style));
						add(buttonExtra = createHitbox(buttonWidth * 2, 0, buttonWidth, FlxG.height, style));
						add(buttonUp = createHitbox(buttonWidth * 3, 0, buttonWidth, FlxG.height, style));
						add(buttonRight = createHitbox(buttonWidth * 4, 0, buttonWidth, FlxG.height, style));
				}
		}
	}

	function createHitbox(x:Float = 0, y:Float = 0, width:Int = 1, height:Int = 1, style:String = 'Normal'):TouchButton {
		var button = new TouchButton(x, y);
		button.loadGraphic(createHitboxGraphic(style, width, height));
		button.alpha = 0.0001;
		button.label = new FlxSprite();
		button.label.makeGraphic(1, 1, 0);
		if (ClientPrefs.data.hitboxHints) {
			button.label.loadGraphic(createHitboxGraphic('Hint', width, height));
		}
		button.label.alpha = ClientPrefs.data.controlAlpha;
		button.changeLabelAlpha = false;

		button.onDown.callback = function() {
			onPressed.dispatch(button);
			FlxTween.cancelTweensOf(button, ['alpha']);
			FlxTween.cancelTweensOf(button.label, ['alpha']);
			FlxTween.tween(button, { alpha: ClientPrefs.data.controlAlpha }, ClientPrefs.data.controlAlpha / 100, { ease: FlxEase.circInOut });
			FlxTween.tween(button.label, { alpha: 0.0001 }, ClientPrefs.data.controlAlpha / 10, { ease: FlxEase.circInOut });
		}

		button.onOut.callback = button.onUp.callback = function() {
			onReleased.dispatch(button);
			FlxTween.cancelTweensOf(button, ['alpha']);
			FlxTween.cancelTweensOf(button.label, ['alpha']);
			FlxTween.tween(button, { alpha: 0.0001 }, ClientPrefs.data.controlAlpha / 10, { ease: FlxEase.circInOut });
			FlxTween.tween(button.label, { alpha: ClientPrefs.data.controlAlpha }, ClientPrefs.data.controlAlpha / 100, { ease: FlxEase.circInOut });
		}

		return button;
	}

	function createHitboxGraphic(style:String, width:Int, height:Int) {
		if (style.toLowerCase() == 'hidden') {
			var bitmap:BitmapData = new BitmapData(width, height, true, 0);
			return FlxG.bitmap.add(bitmap);
		}
		else {
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFFFFFF);
			shape.graphics.lineStyle(3, 0xFFFFFF, 1);
			shape.graphics.drawRect(0, 0, width, height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, width - 6, height - 6);
			shape.graphics.endFill();
			if (style.toLowerCase() == 'gradient') shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
			else if (style.toLowerCase() == 'hint') shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [0, 0], [0, 255], null, null, null, 0.5);
			else shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [0.3, 0], [0, 255], null, null, null, 0.75);
			shape.graphics.drawRect(3, 3, width - 6, height - 6);
			shape.graphics.endFill();
			var bitmap:BitmapData = new BitmapData(width, height, true, 0);
			bitmap.draw(shape);
			return FlxG.bitmap.add(bitmap);
		}
	}
}

// now imagine extra keys support :durr:
enum HitboxLayout
{
	NORMAL;
	EXTRA;
}