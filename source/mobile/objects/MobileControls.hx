package mobile.objects;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import mobile.backend.MobileData;
import mobile.objects.Hitbox;
import mobile.objects.VirtualPad;
import mobile.input.MobileInputManager;

class MobileControls extends FlxTypedSpriteGroup<MobileInputManager>
{
	public var currentMode(get, never):IMobileControls;
	public var controlMode(get, set):String;
	public var isHitbox(get, never):Bool;
	public var isVirtualPad(get, never):Bool;
	public var virtualPad:VirtualPad;
	public var hitbox:Hitbox;

	private var _controlMode:ControlMode;

	public function new(controlMode:ControlMode = HITBOX, hitboxStyle:String = 'Normal', extra:Bool = true) {
		super();
		changeControl(controlMode, hitboxStyle, extra);
		alpha = ClientPrefs.data.controlAlpha;
	}

	public function changeControl(?controlMode:ControlMode, hitboxStyle:String = 'Normal', extra:Bool = true) {
		controlMode ??= HITBOX;
		if (virtualPad != null) {
			remove(virtualPad);
			virtualPad.destroy();
		}
		if (hitbox != null) {
			remove(hitbox);
			hitbox.destroy();
		}
		_controlMode = controlMode;
		switch(controlMode) {
			case HITBOX:
				hitbox = new Hitbox(hitboxStyle, extra);
				add(hitbox);
			case LEFT_FULL:
				virtualPad = new VirtualPad(LEFT_FULL, NONE, extra);
				add(virtualPad);
			case RIGHT_FULL:
				virtualPad = new VirtualPad(RIGHT_FULL, NONE, extra);
				add(virtualPad);
			case CUSTOM:
				virtualPad = new VirtualPad(CUSTOM, NONE, extra);
				add(virtualPad);
		}
	}

	function get_isHitbox():Bool {
		return controlMode == 'HITBOX';
	}

	function get_isVirtualPad():Bool {
		return (controlMode == 'LEFT_FULL' || controlMode == 'RIGHT_FULL' || controlMode == 'CUSTOM');
	}

	// May need to cast if you want the class specific stuff
	function get_currentMode():IMobileControls {
		if (controlMode == 'HITBOX') return hitbox;
		else if (controlMode != 'NONE') return virtualPad;
		return null;
	}

	function get_controlMode():String {
		return _controlMode == null ? 'NONE' : Std.string(_controlMode);
	}

	function set_controlMode(value:String):String {
		_controlMode = MobileData.controlModes.get(value.toUpperCase()) ?? HITBOX;
		return value.toUpperCase();
	}
}