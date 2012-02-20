package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.interfaces.IContainer;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.core.ObjectList;
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.core.DefaultStage;
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.managers.DisplayManager;
	import com.gestureworks.cml.managers.FileManager;	
	import com.gestureworks.cml.utils.SystemDetection;
	import flash.events.Event;
	
	import com.gestureworks.cml.kits.*;
	
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	
	/**
	 * CMLParser, Singleton
	 * CML parsing routine
	 * @authors Charles Veasey
	 */
	public class CMLParser extends CML_CORE
	{		
		public function CMLParser(enforcer:SingletonEnforcer) {}
		
		private static var _instance:CMLParser;
		public static function get instance():CMLParser 
		{ 
			if (_instance == null)
				_instance = new CMLParser(new SingletonEnforcer());			
			return _instance;	
		}
		
		private static var GXMLComponent:Class;
		private static var defaultContainer:Sprite;
		public static const COMPLETE:String = "COMPLETE";
		
		
		public var debug:Boolean = true;
		
		/**
		 * Initial parsing of the cml document
		 * @param 	xml
		 * @param	parent
		 * @param	properties
		 */
		public function init(cml:XML, parent:*, properties:*=null):void
		{
			
			if (debug)
				trace("\n\n**************** CML parser initialized ****************");
			
		
				
			if (debug)
				trace("\n\ncreate default container");					
				
			defaultContainer = new Sprite;

		
			
			if (debug)
				trace("\n\ncreate LibraryKit");				
				
			if (cml.children().(name() == "LibraryKit") != undefined)
			{
				LibraryKit.instance.parseCML(cml.children().(name() == "LibraryKit"));
			}
			
			
			
			if (debug)
				trace("\n\ncreate LayoutKit");					
						
			if (cml.children().(name() == "LayoutKit") != undefined)
			{
				LayoutKit.instance.parseCML(cml.children().(name() == "LayoutKit"));
			}			
			
			
			
			if (debug)
				trace("\n\ncreate Elements & Objects");	
							
			var name:String;
			for (var i:int=0; i<cml.children().length(); i++)
			{	
				name = cml.child(i).name().toString();	
				
				if (name != "LibraryKit" && name != "LayoutKit" && 
					name != "WindowKit" && name != "DebugKit")
					loopCML(cml.child(i), defaultContainer);					
			}		
			
			
			
			if (debug)
				trace("\n\ncreate WindowKit");
			
			if (SystemDetection.AIR && (cml.children().(name() == "WindowKit") != undefined))
			{					
				var ClassRef:Class = getDefinitionByName("com.gestureworks.cml.kits.WindowKit") as Class;
				ClassRef["instance"].parseCML(cml.children().(name() == "WindowKit"));
			}			
			else // window kit is not specified, use default			
			{
				DefaultStage.instance.stage.addChildAt(defaultContainer, 0);
			}
			
			
			
			if (debug)
				trace("\n\nload CML files");
			
			if (FileManager.instance.cmlCount > 0)
			{
				FileManager.instance.addEventListener(FileManager.CML_LOAD_COMPLETE, onCMLLoadComplete);
				FileManager.instance.startQueue();				
			}	
			else if (FileManager.instance.fileCount > 0)
			{
				loadExtFiles();
			}
			else
			{
				loadDisplay();
			}
			
				
		
			
			function onCMLLoadComplete(event:Event):void
			{
				if (debug)
					trace("\nCML file load complete");	
				
				
				if (debug)
					trace("\n\nload renderer");					
					
				DisplayManager.instance.loadRenderer();			
			

				if (FileManager.instance.fileCount > 0)
					loadExtFiles();
				else
					loadDisplay();
				
			}				
				
			
			function loadExtFiles():void
			{
				if (debug)
					trace("\nload non-cml external files");	
					
				FileManager.instance.addEventListener(FileManager.LOAD_COMPLETE, onLoadComplete);				
				FileManager.instance.startQueue();				
			}
			
					
			function onLoadComplete(event:Event):void
			{	
				if (debug)
					trace("\nload ext files complete...");						

				
				if (debug)
					trace("\call 'load complete' to awaiting objects");				
				
				DisplayManager.instance.loadComplete();
				
				loadDisplay();
			}
			
			
			
			function loadDisplay():void
			{
				if (debug)
					trace("\nload display begins...");					
				
				if (debug)
					trace("\nload cml properties");
				
				DisplayManager.instance.updateCMLProperties();
				
				if (debug)
					trace("\nlayout containers");				
				
				DisplayManager.instance.layoutCML();
				
				if (debug)
					trace("\nactivate touch");				
				
				DisplayManager.instance.activateTouch();				
				
				if (debug)
					trace("\nadd children to stage");				
				
				DisplayManager.instance.addCMLChildren();
				
				if (debug)
					trace("\ncall element's, display complete, abstract method");				
				
				DisplayManager.instance.displayComplete();		

				if (debug)
					trace("\nsend cml parser complete event");				
				
				dispatchEvent(new Event(CMLParser.COMPLETE, true, true));	
				
				trace('\n\n********************* CML Parsing Complete ************************\n\n');				
				
			}
			
		}			
		
		
		
		
		
		
		/**
		 * Recursive CML parsing
		 * @param	cml
		 * @param	parent
		 * @param	properties
		 */
		public function loopCML(cml:*, parent:*=null, properties:*=null):void
		{			
			var className:String = null;
			var obj:* = null;
			var returnedNode:XMLList = null;
			
			for each (var node:* in cml)
			{
				className = node.name();								
				
				if (debug)
					trace("\n-create", className);					
				
				obj = createObject(className);
				
				
				if (!properties)
					obj.id = node.@id;
				else //target render data
					obj.id = node.@id + "." + properties.@id;
				
					
				if (debug)
					trace("\n-add to CMLObjectList id: ", obj.id, ", object: ", obj);							
				
				CMLObjectList.instance.append(obj.id, obj);					
								

				returnedNode = obj.parseCML(XMLList(node));
			
				
				if (properties) //target render data
				{
					if (debug)
						trace("\ncomponent kit render properties of id: ", obj.id);					
					
					obj.propertyStates[0]["id"] = obj.id;				

					for (var key:* in obj.propertyStates[0]) 
					{
						if (key == "dimensionsTo")
							obj.propertyStates[0][key] = obj.propertyStates[0][key] + "." + properties.@id;
												
						for each (var val:* in properties.*)
						{
							if (obj.propertyStates[0][key] == val.name().toString())
								obj.propertyStates[0][key] = val;							
						}
					}						
				}				
				
				
				obj.postparseCML(XMLList(node));
				
				
				if (parent is (IContainer))
					parent.childToList(obj.id, obj);
								
				
				//recursion
				if (returnedNode)
					loopCML(returnedNode, obj, properties);					
			}
			
			if (parent == defaultContainer)
					defaultContainer.addChild(obj);			
		}		
		
		
		
		
		/**
		 * Creates object from class name
		 * Returns a new object of the class
		 * @param	className
		 * @return
		 */
		public function createObject(className:String):Object
		{
			//new object reference
			var obj:* = null;			
			
			//search for package syntax
			if (className.indexOf('.') != -1)
			{
				//create object
				try {
					GXMLComponent = getDefinitionByName(className) as Class;					
					obj = new GXMLComponent();
				}
				catch (e:Error){}					
			}
			
			else
			{
				//begin search in core class list
				obj = searchPackages(className, CML_CORE_PACKAGES);
				
				//if search failed, try the external list
				if (!obj)
					obj = searchPackages(className, CML_EXTERNAL_PACKAGES);

				//if search failed again, throw an error
				if (!obj)
					throw new Error(className + " failed to load");
			}
				
			return obj;
		}		
		
		
		
		
		/**
		 * Searches a class name from an array of packages
		 * Returns a new object of the class
		 * @param	className
		 * @param	packageArray
		 * @return
		 */
		private function searchPackages(className:String, packageArray:Array):Object
		{
			var obj:* = null;
			
			//search package list
			for (var i:int=0; i<packageArray.length; i++)
			{
				//create object
				try {
					GXMLComponent = getDefinitionByName(packageArray[i] + className) as Class;					
					obj = new GXMLComponent();
					break;
				}
				catch (e:Error){}	
			}
			
			return obj;
		}
		
		
		
		
		/**
		 * Default parseCML routine
		 * @param	obj
		 * @param	cml
		 * @return
		 */
		public function parseCML(obj:*, cml:XMLList):XMLList
		{
			var attrName:String;
			var returnNode:XMLList = new XMLList;
			
			for each (var attrValue:* in cml.@*)
			{
				attrName = attrValue.name().toString();
								
				obj.propertyStates[0][attrName] = attrValue;
			}
			
			attrName = null;	
			
			if (cml.*.length() > 0)
				returnNode = cml.*;
			
			return returnNode;
		}		
		
		
		
		
		/**
		 * Default updateProperties routine
		 * @param	obj
		 * @param	state
		 */
		public function updateProperties(obj:*, state:Number=0):void
		{
			var propertyValue:String;
			
			for (var propertyName:String in obj.propertyStates[state])
			{
				obj[propertyName] = 
					filterProperty(propertyName, propertyValue, obj.propertyStates, state); 
			}	
				
		}
				
		
		
		
		/**
		 * 
		 * @param	propertyName
		 * @param	propertyValue
		 * @param	propertyStates
		 * @param	state
		 * @return
		 */
		public function filterProperty(propertyName:String, propertyValue:*, propertyStates:*, state:*):*
		{
			propertyValue = propertyStates[state][propertyName].toString();
			
			// filter value for expression delimiter "{}"
			if (propertyValue.charAt(0) == "{")
			{
				if ((propertyValue.charAt(propertyValue.length - 1) == "}"))
				{
					// remove whitepsace and {} characters
					var regExp:RegExp = /[\s\r\n{}]*/gim;
					propertyValue = propertyValue.replace(regExp, '');
					
					// split properties
					var arr:Array = propertyValue.split(".");
					
					if (arr.length > 1)
					{
						// assign value from master cml list
						// get value from property states instead of object to remove time factors							
						return CMLObjectList.instance.getKey(arr[0]).propertyStates[state][arr[1]];
					}
					
					else 
						throw new Error("Malformed expression attribute. A valid id and property must be given");
				}
				
				else 
					throw new Error("Malformed expression attribute. The delimiter character: {  must be followed by the: }  character");
			}
			
			// check for boolean
			else if (propertyValue == "true")
				propertyStates[state][propertyName] = true;
			else if (propertyValue == "false")
				propertyStates[state][propertyName] = false;			
			
			// check for css keyword
			if (propertyName == "class")
				propertyName = "class_";
							
			return propertyStates[state][propertyName];			
		}
		
		
	}
}

class SingletonEnforcer{}		
