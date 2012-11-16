package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.TextFactory;
	import com.gestureworks.cml.utils.CloneUtils;

	/**
	 * The Text element displays a text fields. It has most of the functionality
	 * the the TextField and TexrFormat AS3 classes combined
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  			
		var txt:Text = new Text();
		txt.x = 200;
		txt.y = 200;
		txt.font = "OpenSansBold";
		txt.fontSize = 30;			
		txt.color = 0xFF0000;		
		addChild(txt);
		
	 * </codeblock>
	 * 
	 * @inheritDoc TextFactory
	 * @author Ideum
	 * @see SWF
	 */	
	public class Text extends TextFactory
	{				
		public function Text()
		{						
			super();
			updateTextFormat();
		}
		
		public function displayComplete():void
		{
			if (width == 0) 
				width = 100;
			if (height == 0) 
				height = 100;
			updateTextFormat();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		/**
		 * Returns clone of self
		 */
		override public function clone():* 
		{ 
			var clone:Text = CloneUtils.clone(this, this.parent);
			clone.updateTextFormat();
			return clone;
		}
		
		
		public var paddingLeft:Number = 0;
		public var paddingRight:Number = 0;
		public var paddingTop:Number = 0;
		public var paddingBottom:Number = 0;
		
	}
}