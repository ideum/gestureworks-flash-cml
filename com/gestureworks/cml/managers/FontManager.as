package com.gestureworks.cml.managers
{
	import flash.text.Font;
	
	public class FontManager
	{
		// DroidSerif-Regular as TLF
		[Embed(source="../../../../../projects/UPRR/lib/DroidSerifRegular.ttf",fontName='DroidSerifRegularTLF',fontFamily='font',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true',unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E')]
		public static var DroidSerifRegularTLF:Class;
		Font.registerFont(DroidSerifRegularTLF);

	}
}