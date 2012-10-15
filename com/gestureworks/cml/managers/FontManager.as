package com.gestureworks.cml.managers
{
	import flash.text.*
	import flash.text.engine.*
	
	/**
	 * The FontManager loads embedded fonts. 
	 * 
	 * <p>By default it loads a basics set of OpenSans fonts: OpenSansRegularTLF, 
	 * OpenSansBoldTLF, and OpenSansItalicTLF</p>
	 * 
	 * <p>The fonts loaded here are for use with the TLF textfield, embedAsCFF="true"</p>
	 * 
	 * <p>The non-TLF versions of these fonts, embedAsCFF="false", are loaded through 
	 * the GML core library: OpenSansRegular, OpenSansBold, and OpenSansItalic</p>
	 * 
	 * @author Charles
	 * @see com.gestureworks.cml.element.TLF
	 * @see com.gestureworks.text.DefaultFonts
	 */
	public class FontManager
	{
		// Keep the default fonts to a miminum. OpenSans is the chosen font for Open Exhibits.
		// For custom projects embed fonts directly into the project, not here.
		
		// Open Sans TLF (embedAsCFF='true')
		[Embed(source = '../../../../../lib/fonts/OpenSansRegular.ttf', 
			fontName = 'OpenSansRegularTLF', 
			fontFamily = 'OpenSans', 
			fontWeight = 'normal', 
			fontStyle = 'normal', 
			mimeType = 'application/x-font-truetype', 
			advancedAntiAliasing = 'true', 
			embedAsCFF = 'true',
			unicodeRange='U+0020-007E')]
		/**
		 * Specifies the OpenSansRegularTLF font name
		 */
		public static var OpenSansRegularTLF:Class;
		Font.registerFont(OpenSansRegularTLF);	
		
		
		[Embed(source = '../../../../../lib/fonts/OpenSansItalic.ttf', 
			fontName = 'OpenSansItalicTLF', 
			fontFamily = 'OpenSans', 
			fontStyle = 'italic', 
			mimeType = 'application/x-font-truetype', 
			advancedAntiAliasing = 'true', 
			embedAsCFF = 'true',
			unicodeRange='U+0020-007E')]
		/**
		 * Specifies the OpenSansItalicTLF font name
		 */
		public static var OpenSansItalicTLF:Class;
		Font.registerFont(OpenSansItalicTLF);
		
		
		[Embed(source = "../../../../../lib/fonts/OpenSansBold.ttf", 
			fontName = 'OpenSansBoldTLF', 
			fontFamily = 'OpenSans', 
			fontStyle = 'bold', 
			mimeType = 'application/x-font-truetype', 
			advancedAntiAliasing = 'true', 
			embedAsCFF = 'true',
			unicodeRange='U+0020-007E')]
		/**
		 *  Specifies the OpenSansBoldTLF font name
		 */
		public static var OpenSansBoldTLF:Class;
		Font.registerFont(OpenSansBoldTLF);
		
	}
}