package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	
	import flash.display.Sprite;
	import flash.text.engine.*;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditingMode;
	import flashx.textLayout.edit.SelectionFormat;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.events.StatusChangeEvent;

	/**
	 * The TLF element provides access to AS3's TLF system within CML. The input is in the form of XML,
	 * and prefixed with AS3's namespace. Use the native flashx.textLayout.elements.TextFlow and 
	 * flashx.textLayout.formats.TextLayoutFormat classes when developing in AS3.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * <TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>
	 *		<p>Paragraph1</p>
	 *		<p>Paragraph2</p>
	 *		<p>Paragraph3</p>
	 *	</TextFlow>
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see flashx.textLayout.elements.TextFlow;
	 */	
	
	public class TLF extends ElementFactory
	{	
		private var textFormat:TextLayoutFormat;
		private var configuration:Configuration;
		private var textFlow:TextFlow;
		private var container:ContainerController;
		private var initialized:Boolean=false;
		
		/**
		 * Constructor
		 */
		public function TLF()
		{
			super();		
			textFormat = new TextLayoutFormat;
			configuration = new Configuration;
			configuration.textFlowInitialFormat = textFormat;
			textFlow = new TextFlow;
		}	
		
		/**
		 * Initialisation method
		 */
		public function init():void
		{
			
		}
	
		
		private function onChange(e:StatusChangeEvent):void {			
			textFlow.flowComposer.updateAllControllers();	
		}
		
		/**
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		override public function parseCML(cml:XMLList):XMLList
		{
			XML.ignoreWhitespace = true;			
			input(cml.children());
			var returnNode:XMLList = new XMLList;
			var attrName:String;
			
			for each (var attrValue:* in cml.@*)
			{
				attrName = attrValue.name().toString();
				propertyStates[0][attrName] = attrValue;
			}
			
			attrName = null;			
			
			return returnNode;
		}
		
		
		private var _width:Number = 500;
		/**
		 * container width
		 */				
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			if (initialized) updateContainer();
		}
		

		private var _height:Number = 500;
		/**
		 * container height 
		 */				
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			if (initialized) updateContainer();
		}	
		
		private var _font:String = "OpenSansRegular";
		/**
		* font name, use CFF embeded fonts 
		*/	
		public function get font():String { return _font; }
		public function set font(v:String):void 
		{ 
			_font = v; 
			textFlow.fontFamily = font;
			if (initialized) updateContainer();
		}
		
		private var _backgroundAlpha:Number;
		/**
		 * sets the background alpha
		 */
		public function get backgroundAlpha():Number { return _backgroundAlpha; }
		public function set backgroundAlpha(value:Number):void {
			_backgroundAlpha = value;
			textFlow.backgroundAlpha = _backgroundAlpha;
			if (initialized) updateContainer();
		}
		
		private var _backgroundColor:uint;
		/**
		 * sets the background color
		 */
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
			textFlow.backgroundColor = _backgroundColor;
			if (initialized) updateContainer();
		}
		
		/**
		 * Input must be prefixed with AS3's namespace:
		 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		 * <TextFlow xmlns='http://ns.adobe.com/textLayout/2008' color='0xFF2233'>
		 *		<p>Paragraph1</p>
		 *		<p>Paragraph2</p>
		 *		<p>Paragraph3</p>
		 *	</TextFlow>
		 * </codeblock>
		 * @param input string
		 */
		public function input(value:String):void
		{				
			configuration.textFlowInitialFormat = textFormat;
			textFlow = TextConverter.importToFlow(value, TextConverter.TEXT_LAYOUT_FORMAT, configuration);
			textFlow.fontLookup = FontLookup.EMBEDDED_CFF;
			textFlow.fontFamily = font;	
			textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, onChange);
			updateContainer();
			initialized=true;
		}
		
		private function updateContainer():void
		{			
			if (initialized) 
			{
				container.setCompositionSize( width, height );			
				textFlow.flowComposer.updateAllControllers();	
			}
			else 
			{
				container = new ContainerController(this, width, height);
				textFlow.flowComposer.addController(container);		
				textFlow.flowComposer.updateAllControllers();	
			}
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			textFormat = null;
            configuration = null;
            textFlow = null;
            container = null;
		}
		
	}
}