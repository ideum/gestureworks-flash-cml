package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
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
		public var defaultContainer:Container;
		public static const COMPLETE:String = "COMPLETE";
		public var debug:Boolean = true;
		
		public var cssFile:String;
		
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
				
			defaultContainer = new Container;

		
			
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
			
			
			currentParent = defaultContainer;
			createElements(cml, defaultContainer);
	

			
			if (debug)
				trace("\n\nload CML files");
			
			if (FileManager.instance.cmlCount > 0)
			{
				FileManager.instance.removeEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);												
				FileManager.instance.addEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);
				FileManager.instance.startCMLQueue();				
			}	
			else if (FileManager.instance.fileCount > 0)
			{
				FileManager.instance.removeEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);								
				loadExtFiles();
			}
			else
			{
				FileManager.instance.removeEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);												
				loadCSS();
			}
			
		}			
		
		
		
		
		private function loadExtFiles():void
		{
			if (debug)
				trace("\nload non-cml external files");	
				
			FileManager.instance.addEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			FileManager.instance.startFileQueue();				
		}
		
				
		private function onLoadComplete(event:Event):void
		{
			FileManager.instance.removeEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			
			if (debug)
				trace("\nload ext files complete...");						

			
			if (debug)
				trace("\call 'load complete' to awaiting objects");				
			
			DisplayManager.instance.loadComplete();

			loadCSS();
		}

		private function loadCSS():void
		{
			if (debug)
				trace("\nload css data...");						
				
			if (cssFile.length > 0)
			{
				CSSManager.instance.addEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
				CSSManager.instance.loadCSS(cssFile);
			}	
			else
				loadDisplay();
		}
		
		
		private function onCSSLoaded(event:FileEvent):void
		{
			CSSManager.instance.removeEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
			
			if (debug)
				trace("\parse css data...");
			
			CSSManager.instance.parseCSS();
			loadDisplay();
		}
		
		
		private function loadDisplay():void
		{
			if (debug)
				trace("\nload display begins...");					

			if (debug)
				trace("\apply cml properties");
			
			DisplayManager.instance.updateCMLProperties();
			
			if (debug)
				trace("\nlayout containers");				
			
			DisplayManager.instance.layoutCML();
			
			if (debug)
				trace("\nactivate touch");				
			
			DisplayManager.instance.activateTouch();				
			
			if (debug)
				trace("\nupdate display");				
			
			DisplayManager.instance.updateDisplay();			

			
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
		

		private var cmlFilesComplete:int = 0;
	

		private function onCMLLoadComplete(event:FileEvent):void
		{
			if (debug)
				trace("\nCML file load complete");	
			
			cmlFilesComplete++;
			
			if (event.fileType == "cmlRenderKit")
				loadRenderer(CML.getInstance(event.filePath).data, includeParentIndex[cmlFilesComplete-1]);				
			else
				createElements(CML.getInstance(event.filePath).data, includeParentIndex[cmlFilesComplete-1]);				
			
			
			if (cmlFilesComplete == FileManager.instance.cmlCount)
			{
				
				if (debug)
					trace("\n\nload renderer");					
						
			
				
				if (FileManager.instance.fileCount > 0)
					loadExtFiles();
				else
					loadCSS();				
			}
			
			else
			{
				FileManager.instance.resumeCMLQueue();
			}
			
		}			
		
		private var currentParent:*;
		
		public function createElements(cml:*, parent:*=null):void
		{
			
			if (debug)
				trace("\n\ncreate Elements & Objects");	
							
			var name:String;
			for (var i:int=0; i<cml.children().length(); i++)
			{
				
				name = cml.child(i).name().toString();	
				
				if (name != "LibraryKit" && name != "LayoutKit" && 
					name != "WindowKit" && name != "DebugKit") 
					loopCML(cml.child(i), parent);				
	
			}
					
		}
		
		
		
		
		
		
		public function loadRenderer(renderKit:*, parent:*):void
		{	
			
			var rendererId:String = renderKit.Renderer.@id; 
			var rendererData:String = renderKit.Renderer.@data;
			
			var renderedItemId:String;
			
			for (var q:int; q < renderKit.Renderer.length(); q++)
			{								
				var renderList:XMLList = renderKit[rendererData].children();				
						
				for (var i:int=0; i<renderList.length(); i++)
				{
					var cmlRenderer:XMLList = new XMLList(renderKit.Renderer[q].*);
					
					for each (var node:XML in cmlRenderer) 
					{
						var properties:XMLList = XMLList(renderList[i]);						
						CMLParser.instance.loopCML(node, parent, properties);
					}
					
				}
				
			}
		
		}			

		
		
		private var index:int = 0;
		
		private var includeParentIndex:Array = [];
		
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
			var classNameKeyword:Boolean = false;
			
			for each (var node:* in cml)
			{
				className = node.name();								
				classNameKeyword = false;
				
				// nested cml loader
				if (className == "Include")
				{
					var attrName:String;
					
					for each (var attrValue:* in node.@*)
					{
						attrName = attrValue.name().toString();

						if (attrName == "cml" && attrValue.toString().length > 0)
						{							
							includeParentIndex.push(parent);
							FileManager.instance.addToQueue(attrValue, "cml");			
						}
					}
					
					continue;
				}
				
				
				// look for className keyword
				// this changes the class type of the loaded object	
				for each (var aValue:* in node.@*)
				{
					var aName:String = aValue.name().toString();
					if (aName == "className")					
						className = aValue;
				}
										
				
				if (debug)
					trace("\n-create", className);					
				
				obj = createObject(className);	
				
				
				
				// look for rendererList keyword
				// loads an external RenderKit	
				for each (aValue in node.@*)
				{
					aName = aValue.name().toString();
					
					if (aName == "rendererList") {					
						includeParentIndex.push(parent);
						FileManager.instance.addToQueue(aValue, "cmlRenderKit");
					}		
				}				
				
		
				
				
				// assign id and class values
				if (node.@id != undefined)
				{
					obj.id = node.@id;
					if (node.@['class'] != undefined)
						obj.class_ = node.@['class'];
				}
				else if (node.@['class'] != undefined)
				{
					obj.class_ = node.@['class'];
					obj.id = node.@['class'];
				}
				else
					obj.id = className;

				
					
				if (debug)
					trace("\n-add to CMLObjectList id: ", obj.id, ", object: ", obj);							
				
				CMLObjectList.instance.append(obj.id, obj);					
				
				
				//unique object identifier
				obj.cmlIndex = CMLObjectList.instance.length-1;

				
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
				{
					parent.childToList(obj.id, obj);
				}				
				
				//recursion
				if (returnedNode)
					loopCML(returnedNode, obj, properties);					
			}
			
			if (parent == defaultContainer && obj is DisplayObject)
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

				// check for css keyword
				if (attrName == "class")
					attrName = "class_";				
				
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
									
					// split last period 					
					var arr:Array = propertyValue.split(".");			
					
					if (arr.length > 1)
					{				
						var str1:String = "";
						var str2:String = "";
					
						for (var i:int = 0; i < arr.length; i++) 
						{
							if (i < arr.length-1)
								str1 += "." + arr[i];
							else
								str2 = arr[i];
						}
						
						if (str1.charAt(0) == ".")
							str1 = str1.slice(1);					

						//trace(str1, state, str2, CMLObjectList.instance.getKey(str1).propertyStates[state][str2]);	
						
						
						var last:int = -1;
						for (var j:int = 0; j < CMLObjectList.instance.length; j++) 
						{	
							if (CMLObjectList.instance.getIndex(j).propertyStates[state][str2])
								return CMLObjectList.instance.getIndex(j).propertyStates[state][str2];
							
						}
											
						throw new Error("Malformed expression attribute. A valid id and property must be given");	

						
						// assign value from master cml list
						// get value from property states instead of object to remove time factors							
						return CMLObjectList.instance.getKey(str1).propertyStates[state][str2];
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
			
							
			return propertyStates[state][propertyName];			
		}
		
		
	}
}

class SingletonEnforcer{}		
