package com.gestureworks.cml.managers
{
	import flash.text.*
	import flash.text.engine.*
	
	
	public class FontManager
	{
		// Keep the default fonts to a miminum. OpenSans is the chosen font for Open Exhibits.
		// For custom projects embed fonts into the directly project, not here.
		
		// Open Sans (embedAsCFF='false')
		[Embed(source="../../../../../lib/defaultFonts/OpenSansRegular.ttf",fontName='OpenSansRegular',fontFamily='OpenSans',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansRegular:Class;
		Font.registerFont(OpenSansRegular);	
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansItalic.ttf",fontName='OpenSansItalic',fontFamily='OpenSans', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansItalic:Class;
		Font.registerFont(OpenSansItalic);
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansBold.ttf",fontName='OpenSansBold',fontFamily='OpenSans', fontStyle='bold',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansBold:Class;
		Font.registerFont(OpenSansBold);
		
		
		// Open Sans TLF (embedAsCFF='true')
		[Embed(source="../../../../../lib/defaultFonts/OpenSansRegular.ttf",fontName='OpenSansRegularTLF',fontFamily='OpenSans',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansRegularTLF:Class;
		Font.registerFont(OpenSansRegularTLF);	
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansItalic.ttf",fontName='OpenSansItalicTLF',fontFamily='OpenSans', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansItalicTLF:Class;
		Font.registerFont(OpenSansItalicTLF);
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansBold.ttf",fontName='OpenSansBoldTLF',fontFamily='OpenSans', fontStyle='bold',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		public static var OpenSansBoldTLF:Class;
		Font.registerFont(OpenSansBoldTLF);
		
	}
}