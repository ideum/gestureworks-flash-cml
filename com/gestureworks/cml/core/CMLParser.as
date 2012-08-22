////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

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
	import com.gestureworks.core.GestureWorks;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.components.CMLDisplay; CMLDisplay;
	
	
	/** 
	 * The CMLParser class parses cml files for run-time object construction 
	 * and modification. It is called by the GestureWorks class when a cml file 
	 * path is specified in the constructor.
	 *
	 * @author Matthew Valverde and Charles Veasey
	 * @langversion 3.0
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * 
	 * @see com.gestureworks.cml.core.CMLObjectList
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
		public var defaultContainer:DisplayObjectContainer;
		public static const COMPLETE:String = "COMPLETE";
		public var debug:Boolean = false;
		public var cssFile:String;
		public var cmlFile:String;
		private var cmlTreeNodes:Array = [];
		public var relativePaths:Boolean = false;
		public var extensions:RegExp;			
		public var rootDirectory:String = "";		
		
		/**
		 * Initial parsing of the cml document
		 * @param 	xml
		 * @param	parent
		 * @param	properties
		 */
		public function init(cml:XML, parent:*, properties:*=null):void
		{
			extensions = /^.*\.(cml|gml|mpeg-4|mp4|m4v|3gpp|mov|flv|f4v|png|gif|jpg|mp3|swf|swc)$/i;			
			
			if (cml.@relativePaths == "true")
				relativePaths = true;
				
			// get css file
			var cssStr:String = cml.@css;			
			
			if (relativePaths)
				cssStr = relToAbsPath(rootDirectory+cssStr);
			
			CMLParser.instance.cssFile = cssStr;	
							
			if (debug)
				trace("\n\n========================== CML parser initialized ===============================");
			
			//need these settings for TLF System
			XML.ignoreWhitespace = true;
			XML.prettyPrinting = false;						
		
			
			if (debug)
				trace("\n Parsing main CML document:", cmlFile);					
			
				
			if (debug)
				trace("\n 1) Load fonts through FontManager");					

				
			var fontManager:FontManager = new FontManager;	
				
			
			if (debug)
				trace("\n 2) Create defaultContainer");					
				
			defaultContainer = parent as DisplayObjectContainer;

			
			
			
			if (debug)
				trace("\n 3) Begin traversal of first children... search for global kits");			
			
			
			
				
			if (debug)
				trace(StringUtils.printf("\n%5s%s %s", "", "3a)", "Search for LibraryKit"));
				
			if (cml.children().(name() == "LibraryKit") != undefined)
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "LibraryKit found... loading LibraryKit"));
				
				LibraryKit.instance.parseCML(cml.children().(name() == "LibraryKit"));
			}
			else 
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "No LibraryKit found... skip LibraryKit"));				
			}
			
			
			
			
			
			if (debug)
				trace(StringUtils.printf("\n%5s%s %s", "", "3b)", "Search for LayoutKit"));
						
			if (cml.children().(name() == "LayoutKit") != undefined)
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "LayoutKit found... loading LayoutKit"));				
				
				LayoutKit.instance.parseCML(cml.children().(name() == "LayoutKit"));
			}			
			else 
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "No LayoutKit found... skip LayoutKit"));				
			}			
			
			
			
			
			
			if (debug)
				trace(StringUtils.printf("\n%5s%s %s", "", "3c)", "Search for WindowKit"));
			
			if (SystemDetection.AIR && (cml.children().(name() == "WindowKit") != undefined))
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "WindowKit found... loading WindowKit"));					
				
				var ClassRef:Class = getDefinitionByName("com.gestureworks.cml.kits.WindowKit") as Class;
				ClassRef["instance"].parseCML(cml.children().(name() == "WindowKit"));
			}			
			else // window kit is not specified, use default			
			{
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "No WindowKit found... skip WindowKit... adding defaultContainer to stage"));				
					
				//DefaultStage.instance.stage.addChildAt(defaultContainer, 0);
			}			
			
			
			
			
			
			if (debug)
				trace("\n 4) Begin recursive depth traversal");	
			
			currentParent = defaultContainer;
			createElements(cml, defaultContainer);
	
			
			
			if (debug)	
			FileManager.instance.debug = true;				
			
			
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
				trace("\n 5) Begin loading non-CML external files");	
				
			FileManager.instance.addEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			FileManager.instance.startFileQueue();				
		}
		
				
		private function onLoadComplete(event:Event):void
		{
			FileManager.instance.removeEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			
			if (debug)
				trace(StringUtils.printf("\n%4s%s", "", "External file loading complete"));

			loadCSS();
		}

		private function loadCSS():void
		{		
			if (debug)
				trace("\n 6) Search for main CSS file");					
				
			if (cssFile.length > 0)
			{
				if (debug)
				{
					trace(StringUtils.printf("\n%4s%s%s", "", "CSS file found... loading: ", cssFile));				
					CSSManager.instance.debug = true;
				}
				
				CSSManager.instance.addEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
				CSSManager.instance.loadCSS(cssFile);
			}	
			else
			{
				if (debug)
					trace(StringUtils.printf("\n%4s%s", "", "No CSS file found... skipping CSS parsing"));						
					
				loadDisplay();	
			}
		}
		
		
		private function onCSSLoaded(event:FileEvent):void
		{
			CSSManager.instance.removeEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
		
			if (debug)
				trace(StringUtils.printf("%4s%s%s", "", "CSS file load complete: ", cssFile));		
			
			CSSManager.instance.parseCSS();
			loadDisplay();
		}
		
		
		private function loadDisplay():void
		{
			if (debug)
			{
				trace("\n 8) Apply CML property values\n");	
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", "cmlIndex", "type", "id", "class", "property", "value"));						
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", "--------", "----", "--", "-----", "--------", "-----"));						
			}				
				
			DisplayManager.instance.updateCMLProperties();
			
			
			if (debug)
				trace("\n 7) Call loadComplete() to awaiting objects");				
			
			DisplayManager.instance.loadComplete();	
			
			
			if (debug)
				trace("\n 9) Activate touch... apply GestureList to TouchContainers");				
			
			DisplayManager.instance.activateTouch();				
			
			
			//if (debug)
			//	trace("\n 10 update display");				
			
			//DisplayManager.instance.updateDisplay();			

			
			if (debug)
				trace("\n 10) Add child display objects to parents... make objects visible");				
			
			DisplayManager.instance.addCMLChildren();
						
			
			if (debug)
				trace("\n 8) Layout Containers... set dimensions to child");				
			
			DisplayManager.instance.layoutCML();
			
			
			if (debug)
				trace("\n 11) Call object's displayComplete() method");				
			
			DisplayManager.instance.displayComplete();		
				
			if (debug)
				trace("\n 12) Dispatch CMLParser.COMPLETE event");				
	
			dispatchEvent(new Event(CMLParser.COMPLETE, true, true));	
	
				
			if (debug)
			{
				trace("\n 13) Print CMLObjectList");
				printObjectList();				
			}
				
			
			if (debug)
				trace('\n========================== CML parser complete ===============================\n');												
		}		
		

		private var cmlFilesComplete:int = 0;
		private var cmlRenderer:XMLList;
		private var cmlRendererKitFileComplete:int = 0;
		
		private function onCMLLoadComplete(event:FileEvent):void
		{	
			cmlFilesComplete++;
			
			if (event.fileType == "cmlRenderKit")
			{
				cmlRendererKitFileComplete++;
				
				if (CMLLoader.getInstance(event.filePath).data.Renderer.@dataPath != undefined)
				{
					cmlRenderer = CMLLoader.getInstance(event.filePath).data.Renderer;
					var cmlRendererData:String = CMLLoader.getInstance(event.filePath).data.Renderer.@dataPath;
					FileManager.instance.addToQueue(cmlRendererData, "cmlRendererData");
				}
				else	
					loadRenderer(CMLLoader.getInstance(event.filePath).data, includeParentIndex[cmlRendererKitFileComplete-1]);
			}
			else if (event.fileType == "cmlRendererData")
			{
				var renderKit:XML = <RenderKit/>
				var data:XMLList = cmlRenderer + CMLLoader.getInstance(event.filePath).data.RendererData;
				renderKit.appendChild(data);				
				loadRenderer(XMLList(renderKit), includeParentIndex[cmlRendererKitFileComplete-1]);	
			}
				
			else
				createElements(CMLLoader.getInstance(event.filePath).data, includeParentIndex[cmlFilesComplete-1]);				
			
			
			if (cmlFilesComplete == FileManager.instance.cmlCount)
			{				
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
					trace(StringUtils.printf("\n%4s%s", "", "Create AS3 objects from CML elements"));				
							
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
			if (debug)
				trace("\n\nloading renderer");
				
			var rendererId:String = renderKit.Renderer.@id; 
			var rendererData:XMLList = renderKit.RendererData;
			
			for (var q:int; q < renderKit.Renderer.length(); q++)
			{
				var renderList:XMLList = rendererData.*;
				
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
					if (debug)
						trace(StringUtils.printf("%9s%s", "", "*** Include found... object creation skipped... adding CML file to queue ***"));					
					
					var attrName:String;
					
					for each (var attrValue:* in node.@*)
					{
						attrName = attrValue.name().toString();

						if ((attrName == "cml" || attrName == "src") && attrValue.toString().length > 0)
						{
							// rootDirectory allows you to change root path	
							if (relativePaths && rootDirectory 
								&& rootDirectory.length > 1){	
								if (attrValue.search(extensions) >= 0){
									attrValue = rootDirectory + attrValue;
									attrValue = relToAbsPath(attrValue);	
								}
							}	
							
														
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
					trace(StringUtils.printf("%9s%s", "", className));					
				
				
				obj = createObject(className);	
					
					
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

										
				
				// add to master object list
				CMLObjectList.instance.append(obj.id, obj);					
				
				// add to master display list
				DisplayList.object[obj.id] = obj;
				DisplayList.array.push(obj);					
				
				// unique object identifier
				obj.cmlIndex = CMLObjectList.instance.length-1;
				
				
				/*
				// add to master tree node
				
				if (parent == defaultContainer)
				{
					cmlTreeNodes[0] = new TreeNode(obj);
				}
				else
				{					
					for (var i:int = 0; i < cmlTreeNodes.length; i++) 
					{
						if (cmlTreeNodes[i].data == parent)
						{
							trace("_________________________");
							cmlTreeNodes[CMLObjectList.instance.length - 1] = new TreeNode(obj, cmlTreeNodes[i]);
						}
						
					}
				}
				*/		
				
				// run object's parse routine	
				returnedNode = obj.parseCML(XMLList(node));
				
				
				if (properties) //target render data
				{
					if (debug)
						trace("\ncomponent kit render properties of id: ", obj.id);					
					
					obj.propertyStates[0]["id"] = obj.id;				
									
					for (var key:* in obj.propertyStates[0]) 
					{						
						if (key == "rendererList") {
							includeParentIndex.push(obj);
							FileManager.instance.addToQueue(val, "cmlRenderKit");
						}
						
						
						for each (var val:* in properties.*)
						{							
							if (obj.propertyStates[0][key] == val.name().toString()){
								obj.propertyStates[0][key] = val;					
	
							}	
						}
					}						
				}				
				else
				{
					// look for rendererList keyword
					// loads an external RenderKit	
					for each (aValue in node.@*)
					{
						aName = aValue.name().toString();
						
						if (aName == "rendererList") {					
							includeParentIndex.push(obj);
							FileManager.instance.addToQueue(aValue, "cmlRenderKit");						
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
				obj = searchPackages(className, CML_CORE.CML_CORE_PACKAGES);
				
				//if search failed, try the external list
				//if (!obj)
					//obj = searchPackages(className, CML_EXTERNAL_PACKAGES);

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
				
				
				// rootDirectory allows you to change root path	
				if (relativePaths && rootDirectory && rootDirectory.length > 1)	
				{	
					if (attrValue.search(extensions) >= 0)
					{
						attrValue = rootDirectory + attrValue;
						attrValue = relToAbsPath(attrValue);	
					}
				}
				
				obj.propertyStates[0][attrName] = attrValue;				
			}
			
			attrName = null;	
			
			if (cml.*.length() > 0)
				returnNode = cml.*;
			
			return returnNode;
		}		
		
		
		public function relToAbsPath(string:String):String
		{			
			var newString:String;
			var cnt:int = 0;
			var arr:Array = string.split("/");
			
			for (var i:int = arr.length-1; i >= 0; i--) 
			{
				if (i == arr.length - 1) {
					newString = arr[i];
					continue;
				}	
				
				if (arr[i] == "..")
					cnt++;
				else if (cnt > 0) {
					cnt--;
				}	
				else 
					newString = arr[i] + "/" + newString;
			}	
						
			return newString;
		}
		

		
		/**
		 * Default updateProperties routine
		 * @param	obj
		 * @param	state
		 */
		public function updateProperties(obj:*, state:Number=0):void
		{
			var propertyValue:String;
			var objType:String;
			
			for (var propertyName:String in obj.propertyStates[state])
			{		
				obj[propertyName] = 
					filterProperty(propertyName, propertyValue, obj.propertyStates, state);	
					
				if (debug)
				{
					objType = obj.toString()
					objType = objType.replace("[object ", "");
					objType = objType.replace("]", "");
										
					if (obj.class_)
						trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", obj.cmlIndex, objType, obj.id, obj['class_'], propertyName, obj[propertyName]));
					else
						trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", obj.cmlIndex, objType, obj.id, "", propertyName, obj[propertyName]));
				}	
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
		
		
		
		public function printObjectList():void
		{			
			var cmlIndex:int;
			var id:String;
			var class_:String;
			var object:*;
			var childArray:Array = [];
			var found:Boolean = true;
			
			trace("\n*********** CMLObjectList Begin **************");
			trace("  root = no star, 'n'-child = 'n'-star");
			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{	
				cmlIndex = -1;
				id = "";
				class_ = "";
				object = null;
				found = false;
							
				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("cmlIndex"))
					cmlIndex = CMLObjectList.instance.getIndex(i).cmlIndex;
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("id"))
					id = CMLObjectList.instance.getIndex(i).id;
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("class_"))
					class_ = CMLObjectList.instance.getIndex(i).class_;
				object = CMLObjectList.instance.getIndex(i);
										
				
				for (var j:int = 0; j < childArray.length; j++) 
				{
					if (childArray[j] == cmlIndex)
						found = true;
				}					
				
				if (!found)
				{
					trace();
					trace("cmlIndex:" + cmlIndex, " id:" + id, " class:" + class_, " object:" + object);
				
					if (CMLObjectList.instance.getIndex(i).hasOwnProperty("childList")) 
						childLoop(CMLObjectList.instance.getIndex(i), 0);
				}
			}
			
			
			function childLoop(obj:*, index:int):void
			{
				var cmlIndex:int;
				var id:String;
				var class_:String;
				var object:*;
				
				for (var i:int = 0; i < obj.childList.length; i++) 
				{
			
					
					cmlIndex = -1;
					id = "";
					class_ = "";
					object = null;					
					
					if (obj.childList.getIndex(i).hasOwnProperty("cmlIndex"))
						cmlIndex = obj.childList.getIndex(i).cmlIndex;
					if (obj.childList.getIndex(i).hasOwnProperty("id"))
						id = obj.childList.getIndex(i).id;
					if (obj.childList.getIndex(i).hasOwnProperty("class_"))
						class_ = obj.childList.getIndex(i).class_;
					object = obj.childList.getIndex(i);					
					
											
					
					childArray.push(cmlIndex);
					
					var str:String = "*";
					
					for (var n:int = 0; n < index; n++)
					{
						str += "*";
					}
					
					trace(str, "cmlIndex:", cmlIndex, " id:", id, " class: ", class_, " object:", object);					
					
					if (obj.childList.getIndex(i).hasOwnProperty("childList"))
						childLoop(obj.childList.getIndex(i), index + 1); 										
				}
			
			}
							
								
			trace();	
			trace();	
			//trace(cmlTreeNodes[0].dump());
			
			trace("\n*********** CMLObjectList End **************");			
		}	
		
		
		
		
	}
}

class SingletonEnforcer{}		
