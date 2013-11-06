package com.gestureworks.cml.managers
{
	import flash.text.*
	import flash.text.engine.*
	import fonts.OpenSansBoldTLF;
	import fonts.OpenSansItalicTLF;
	import fonts.OpenSansRegularTLF;
	
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
	 * @see com.gestureworks.cml.elements.TLF
	 * @see com.gestureworks.text.DefaultFonts
	 */
	public class FontManager
	{
		// Keep the default fonts to a miminum. OpenSans is the chosen font for Open Exhibits.
		// For custom projects embed fonts directly into the project, not here.

		Font.registerFont(OpenSansRegularTLF);	
		
		Font.registerFont(OpenSansItalicTLF); 
		
		Font.registerFont(OpenSansBoldTLF); 
		
	}
}