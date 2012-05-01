package com.gestureworks.cml.managers
{
	import flash.text.*
	import flash.text.engine.*
	
	public class FontManager
	{
		// DroidSerif-Regular as TLF
		//[Embed(source="../../../../../projects/UPRR/lib/DroidSerifRegular.ttf",fontName='DroidSerifRegularTLF',fontFamily='font',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true',unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E')]
		[Embed(source="../../../../../lib//defaultFonts/DroidSerifRegular.ttf",fontName='DroidSerifRegularTLF',fontFamily='font',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true',unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E')]
		public static var DroidSerifRegularTLF:Class;
		Font.registerFont(DroidSerifRegularTLF);
		
		
		[Embed(source="../../../../../lib//defaultFonts/OpenSansRegular.ttf",fontName='OpenSansRegularTLF',fontFamily='OpenSans',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansRegularTLF:Class;
		Font.registerFont(OpenSansRegularTLF);	
		
		
		[Embed(source="../../../../../lib//defaultFonts/OpenSansItalic.ttf",fontName='OpenSansItalicTLF',fontFamily='OpenSans', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansItalicTLF:Class;
		Font.registerFont(OpenSansRegularTLF);
		
		
		[Embed(source = "../../../../../projects/CollectionViewerMaxwell/lib/MyriadPro/MyriadPro-Regular.otf", fontName='MyriadProRegularTLF',fontFamily='MyriadPro', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var MyriadProRegularTLF:Class;
		Font.registerFont(MyriadProRegularTLF);			
		
		
		[Embed(source = "../../../../../projects/CollectionViewerMaxwell/lib/MyriadPro/MyriadPro-It.otf", fontName='MyriadProItalicTLF',fontFamily='MyriadPro', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var MyriadProItalicTLF:Class;
		Font.registerFont(MyriadProItalicTLF);			
		
	}
}