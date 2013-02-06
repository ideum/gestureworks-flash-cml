package com.gestureworks.cml.utils 
{
	/**
	 * The ChildList utility is a data structure that creates an ordered
	 * map that can store duplicate keys. It has a built-in two-way iterator, 
	 * and contains many options for storing and retrieving values.
	 * 
	 * <p>The structure is comprised of:
	 * <ul>
	 * 	<li>index - the index number (must be an integer)</li>
	 * 	<li>key - the reference key (ussually a string, but can be anything)</li>
	 * 	<li>value - the stored value (can be anything)</li>
	 * </ul></p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		var cl:ChildList = new ChildList();
		cl.append("s1", new Sprite());
		cl.append("s2", new TouchSprite());
		
		cl.reset();0
		trace(cl.next());
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see LinkedMap
	 */
	public class ChildList extends LinkedMap 
	{
		
		public function ChildList(weakKeys:Boolean=false)
		{				
			super();
		}
		
		/**
		 * Returns a LinkedMap of objects that are of the 
		 * specified CSS class if no second argument is given.
		 * Returns the nth object of the retuned LinkedMap
		 * if the second argument is present. 
		 * @param	value
		 * @param	index
		 * @return
		 */
		public function getCSSClass(value:String, index:int=-1):*
		{
			var tmp:LinkedMap = new LinkedMap(true);
			
			for (var i:int = 0; i < this.length; i++) 
			{
				if (!this.getIndex(i)) continue; // Make sure index is defined; causing error when cloning the ScrollPane.
				
				if (this.getIndex(i).hasOwnProperty("class_"))
				{
					if (this.getIndex(i).class_ == value)
						tmp.append(this.getIndex(i).id, this.getIndex(i));
				}
			}
						
			if (index > -1)
				return tmp.getIndex(index);
			else
				return tmp;
		}
		
		
		/**
		 * Returns a LinkedMap of objects that are of the 
		 * specified AS3 class if no second argument is given.
		 * Returns the nth object of the returned LinkedMap
		 * if the second argument is present.
		 * @param	value
		 * @param	index
		 * @return
		 */
		public function getClass(value:Class, index:int=-1):*
		{
			var tmp:LinkedMap = new LinkedMap(true);
			
			for (var i:int = 0; i < this.length; i++) 
			{
				if (this.getIndex(i) is value)
					tmp.append(this.getIndex(i).id, this.getIndex(i));
			}	
			
			if (index > -1)
				return tmp.getIndex(index);
			else
				return tmp;				
		}			
		
	}

}