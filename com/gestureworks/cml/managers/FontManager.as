package com.gestureworks.cml.managers
{
	import flash.text.*
	import flash.text.engine.*
	
	/**
	 * font manager class manages the font information
	 */
	public class FontManager
	{
		// Keep the default fonts to a miminum. OpenSans is the chosen font for Open Exhibits.
		// For custom projects embed fonts into the directly project, not here.
		
		// Open Sans TLF (embedAsCFF='true')
		[Embed(source="../../../../../lib/defaultFonts/OpenSansRegular.ttf",fontName='OpenSansRegularTLF',fontFamily='OpenSans',fontWeight='normal',fontStyle='normal',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		/**
		 * specifies the OpenSansRegularTLF font name
		 */
		public static var OpenSansRegularTLF:Class;
		Font.registerFont(OpenSansRegularTLF);	
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansItalic.ttf",fontName='OpenSansItalicTLF',fontFamily='OpenSans', fontStyle='italic',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		/**
		 * specifies the OpenSansItalicTLF font name
		 */public static var OpenSansItalicTLF:Class;
		Font.registerFont(OpenSansItalicTLF);
		
		[Embed(source="../../../../../lib/defaultFonts/OpenSansBold.ttf",fontName='OpenSansBoldTLF',fontFamily='OpenSans', fontStyle='bold',mimeType='application/x-font-truetype',advancedAntiAliasing='true',embedAsCFF='true')]
		/**
		 *  specifies the OpenSansBoldTLF font name
		 */
		public static var OpenSansBoldTLF:Class;
		Font.registerFont(OpenSansBoldTLF);
		
	}
}