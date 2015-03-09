package com.gestureworks.cml.core 
{
	/** 
	 * The CMLAir class is the registry file for AIR-exclusive classes that are capable of
	 * being loaded by the CML Parser.
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
	 * <code>com.gestureworks.cml.elements.CustomClass; CustomClass;</code>
	 *
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CMLCore
	 */	 
	public class CMLAir {}

	import com.gestureworks.cml.elements.HTML; HTML;
	import com.gestureworks.cml.components.HTMLViewer; HTMLViewer;
	import com.gestureworks.cml.elements.Window; Window;	
	import com.gestureworks.cml.base.media.WAVFactory;WAVFactory	
}