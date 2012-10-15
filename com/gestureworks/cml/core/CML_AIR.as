package com.gestureworks.cml.core 
{
	/** 
	 * The CML_AIR class is the registry file for AIR-exclusive classes that are capable of
	 * being load by the CML Parser.
	 * 
	 * <p>You can register your own AIR class for CML loading by placing your class file
	 * in either no package, or one of the following packages:</p>
	 * 
	 * <ul>
	 *	<li>com.gestureworks.buttons</li>
	 *	<li>com.gestureworks.components</li>
	 *	<li>com.gestureworks.element</li>
	 *	<li>com.gestureworks.kits</li>
	 *	<li>com.gestureworks.layouts</li>
	 *	<li>com.gestureworks.menus</li>
	 * </ul>
	 * 
	 * <p>You can then use the following import syntax to register your class:</p>
	 * <code>com.gestureworks.cml.element.CustomClass; CustomClass;</code>
	 *
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CML_CORE
	 */	 
	public class CML_AIR { }

	import com.gestureworks.cml.element.WAV; WAV;
	import com.gestureworks.cml.components.WAVPlayer; WAVPlayer;
}