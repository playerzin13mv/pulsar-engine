package mobile.objects;

import flixel.util.FlxSignal.FlxTypedSignal;

import mobile.input.MobileInputID;

interface IMobileControls
{
	public var buttonLeft:TouchButton;
	public var buttonDown:TouchButton;
	public var buttonUp:TouchButton;
	public var buttonRight:TouchButton;
	public var buttonExtra:TouchButton;
	public var onPressed:FlxTypedSignal<TouchButton->Void>;
	public var onReleased:FlxTypedSignal<TouchButton->Void>;
	public function anyPressed(buttonArray:Array<MobileInputID>):Bool;
	public function anyJustPressed(buttonArray:Array<MobileInputID>):Bool;
	public function anyReleased(buttonArray:Array<MobileInputID>):Bool;
	public function anyJustReleased(buttonArray:Array<MobileInputID>):Bool;
}