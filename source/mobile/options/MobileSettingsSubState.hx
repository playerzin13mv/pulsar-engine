package mobile.options;

import options.*;

import mobile.backend.MobileData;

class MobileSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('mobile_menu', 'Mobile Settings');
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Virtual Pad Alpha',
			'How transparent should the virtual pad in menus be?',
			'padAlpha',
			FLOAT);
		option.defaultValue = 0.6;
		option.changeValue = 0.1;
		option.minValue = 0;
		option.maxValue = 1;
		option.scrollSpeed = 1;
		option.onChange = onChangePadAlpha;
		addOption(option);

		var option:Option = new Option('Control Alpha',
			'How transparent should the mobile controls be?',
			'controlAlpha',
			FLOAT);
		option.defaultValue = 0.6;
		option.changeValue = 0.1;
		option.minValue = 0;
		option.maxValue = 1;
		option.scrollSpeed = 1;
		addOption(option);

		var option:Option = new Option('Extra Button',
			'Adds an extra button that can be used for mechanics, etc.\nDefaults to SPACE but can be rebinded in the mobile controls menu!',
			'extraButton',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hitbox Style',
			'Which hitbox style should be used?',
			'hitboxStyle',
			STRING,
			MobileData.hitboxStyles);
		addOption(option);

		var option:Option = new Option('Show Hitbox Hints',
			'Shows the hitbox borders at all times.',
			'hitboxHints',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hitbox Extra Position',
			'Where should the extra hitbox be positioned?',
			'hitboxExtraPosition',
			STRING,
			['BOTTOM', 'MIDDLE', 'TOP']);
		addOption(option);

		super();
	}

	function onChangePadAlpha() {
		virtualPad.alpha = ClientPrefs.data.padAlpha;
	}
}