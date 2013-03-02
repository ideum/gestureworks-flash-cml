package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.core.CMLDisplay; CMLDisplay;	
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;	
	
	/** 
	 * The CMLParser class parses cml files for run-time object construction 
	 * and modification. It is called by the GestureWorks class when a cml file 
	 * path is specified in the Constructor.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CMLObjectList
	 * @see com.gestureworks.cml.core.CMLDisplay
	 */		
	public class CMLParser extends CML_CORE
	{	
		// private variables
		private static var cmlFilesComplete:int = 0;
		private static var cmlRenderer:XMLList;
		private static var cmlRendererKitFileComplete:int = 0;		
		private static var GXMLComponent:Class;
		private static var currentParent:*;			
		private static var index:int = 0;
		private static var includeParentIndex:Array = [];
		private static var pausedCML:Array = [];
		private static var pausedCML2:Array = [];
		private static var includeFound:Boolean = false;		
		private static var extFilesLoaded:Boolean = false;
		
		//public variables
		public static const COMPLETE:String = "COMPLETE";
		public static var extensions:RegExp = /^.*\.(cml|gml|xml|mpeg-4|mp4|m4v|3gpp|mov|flv|f4v|png|gif|jpg|mp3|swf|swc)$/i;		
		public static var debug:Boolean = false;			
		public static var relativePaths:Boolean = false;			
		public static var rootDirectory:String = "";	
		public static var defaultContainer:DisplayObjectContainer;
		public static var cssFile:String;
		public static var cmlFile:String;
		
		public function CMLParser() {}
		
		// legacy support, when CMLParser was a singleton instead of a static class
		private static var _instance:*;
		public static function get instance():* { 
			return CMLParser;	
		}
		
		
		/**
		 * Initial parsing of the cml document
		 * @param 	xml
		 * @param	parent
		 * @param	properties
		 */
		public static function init(cml:XML, parent:*, properties:*=null):void
		{
			//need these settings for TLF System
			XML.ignoreWhitespace = true;
			XML.prettyPrinting = false;
			
			if (cml.@relativePaths == "true")
				relativePaths = true;
			
			if (cml.@rootDirectory != undefined && !relativePaths)
				rootDirectory = cml.@rootDirectory;
			else if (cml.@rootDirectory != undefined && relativePaths)
				rootDirectory = relToAbsPath(rootDirectory.concat(cml.@rootDirectory));	
				
			// get css file
			var cssStr:String = "";
			if (cml.@css != undefined)
				cssStr = cml.@css;			
			if (cssStr.length > 0){
				if (relativePaths)
					cssStr = relToAbsPath(rootDirectory.concat(cssStr));
				else if (rootDirectory.length > 0)
					cssStr = rootDirectory.concat(cssStr);					
			}
			CMLParser.instance.cssFile = cssStr;	
			
			if (debug)
				trace("\n\n========================== CML parser initialized ===============================");						
		
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
				
			if (cml.children().(name() == "LibraryKit") != undefined) {
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "LibraryKit found... loading LibraryKit"));
				
				LibraryKit.instance.parseCML(cml.children().(name() == "LibraryKit"));	
				delete cml["LibraryKit"];
			}
			else {
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "No LibraryKit found... skip LibraryKit"));				
			}

			if (debug)
				trace(StringUtils.printf("\n%5s%s %s", "", "3b)", "Search for LayoutKit"));
						
			if (cml.children().(name() == "LayoutKit") != undefined) {
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "LayoutKit found... loading LayoutKit"));				
				
				LayoutKit.instance.parseCML(cml.children().(name() == "LayoutKit"));
				delete cml["LayoutKit"];
			}			
			else {
				if (debug)
					trace(StringUtils.printf("%9s%s", "", "No LayoutKit found... skip LayoutKit"));				
			}						
			
			// TODO: Implement WindowKit
			/* 
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
			*/
			
			if (debug)	
				FileManager.instance.debug = true;	
				
			if (debug)
				trace("\n 4) Begin recursive depth traversal");	
			
			currentParent = defaultContainer;
			
			var xmllist:XMLList = XMLList(cml.*);
			loopCML(xmllist, defaultContainer);
			if (!renderKitFound)
				evaluate();
		}			
				
		private static var extFilesLoading:Boolean = false;
		private static function loadExtFiles():void
		{	
			if (debug)
				trace("\n 5) Begin loading non-CML external files");	
			
			extFilesLoading = true;	
			FileManager.instance.addEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			FileManager.instance.startFileQueue();
		}
		
		
		private static function onLoadComplete(event:Event):void
		{			
			FileManager.instance.removeEventListener(FileEvent.FILES_LOADED, onLoadComplete);				
			
			if (debug)
				trace(StringUtils.printf("\n%4s%s", "", "External file loading complete"));
			
			extFilesLoading = false;	
			extFilesLoaded = true;	
			loadCSS();
		}

		private static function loadCSS():void
		{		
			if (debug)
				trace("\n 6) Search for main CSS file");					
				
			if (cssFile.length > 0) {
				if (debug) {
					trace(StringUtils.printf("\n%4s%s%s", "", "CSS file found... loading: ", cssFile));				
					CSSManager.instance.debug = true;
				}
				CSSManager.instance.addEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
				CSSManager.instance.loadCSS(cssFile);
			}	
			else {
				if (debug)
					trace(StringUtils.printf("\n%4s%s", "", "No CSS file found... skipping CSS parsing"));						
				loadDisplay();	
			}
		}
		
		
		private static function onCSSLoaded(event:FileEvent):void
		{
			CSSManager.instance.removeEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
		
			if (debug)
				trace(StringUtils.printf("%4s%s%s", "", "CSS file load complete: ", cssFile));		
			
			CSSManager.instance.parseCSS();
			loadDisplay();
		}

		
		private static function onCMLLoadComplete(event:FileEvent):void
		{	
			cmlFilesComplete++;
			
			if (event.fileType == "cmlRenderKit") {
				cmlRendererKitFileComplete++;
				
				if (CMLLoader.getInstance(event.filePath).data.Renderer.@dataPath != undefined) {
					cmlRenderer = CMLLoader.getInstance(event.filePath).data.Renderer;
					var cmlRendererData:String = CMLLoader.getInstance(event.filePath).data.Renderer.@dataPath;
					FileManager.instance.addToQueue(cmlRendererData, "cmlRendererData");
				}
				else	
					loadRenderer(CMLLoader.getInstance(event.filePath).data, includeParentIndex[cmlRendererKitFileComplete-1]);
			}
			else if (event.fileType == "cmlRendererData") {
				var renderKit:XML = <RenderKit/>
				var data:XMLList = cmlRenderer + CMLLoader.getInstance(event.filePath).data.RenderKit.RendererData;
				renderKit.appendChild(data);
				loadRenderer(XMLList(renderKit), includeParentIndex[includeParentIndex.length-1]);	
			}
			else {
				var xml:XML = XML(CMLLoader.getInstance(event.filePath).data);
				var xmllist:XMLList = XMLList((xml.*).toXMLString());
				includeFound = false;
				loopCML(xmllist, includeParentIndex[includeParentIndex.length - 1]);
				evaluate();
			}
		}			
		
		
		
		public static function loadRenderer(renderKit:*, parent:*):void
		{
			if (debug)
				trace("\n\nloading renderer");
		
			var rendererData:XMLList = renderKit.RendererData;
			var renderList:XMLList;	
			var cmlRenderer:XMLList;
			var dataRootTag:String;
			
			for (var q:int; q < renderKit.Renderer.length(); q++) {

				if (renderKit.Renderer.@dataRootTag == undefined)
					renderList = rendererData.*;
				else {
					dataRootTag = renderKit.Renderer.@dataRootTag;
					renderList = rendererData.*.(name() == dataRootTag);
					trace(renderList.toString());
				}				
				for (var i:int = 0; i < renderList.length(); i++) {
					cmlRenderer = new XMLList(renderKit.Renderer[q].*);
					
					for each (var node:XML in cmlRenderer) {						
						var properties:XMLList = XMLList(renderList[i]);	
						loopCML(XMLList(node), parent, properties);
					}
				}
			}
			
			renderKitFound = false;
			evaluate();			
		}			

					
		private static var renderKitFound:Boolean = false;
		
		/**
		 * Recursive CML parsing
		 * @param	cml
		 * @param	parent
		 * @param	properties
		 */
		public static function loopCML(cml:XMLList, parent:*= null, properties:*= null):void
		{
			if (includeFound) {
				pausedCML2.push(new Array(cml, parent, properties));
				return;
			}		
			
			var className:String = null;
			var attrName:String;
			var obj:* = null;
			var returnedNode:XMLList = null;
			var i:int = 0;
			var index:int = -1;
			var node:XML;
			
			for each (node in cml) {
				index++;
				
				if (includeFound) {
					var tmp:XMLList = cml.copy();
					for (var j:int = index-1; j >= 0; j--) {
						delete tmp[j];
					}
					pausedCML2.push(new Array(tmp, parent, properties));					
					break;
					return;
				}
				
				className = node.name();
				
				
				// skip over tags which aren't in the correct place
				if (className == "LibraryKit" || className == "Library" || className == "LayoutKit" || 
					className == "WindowKit" || className == "DebugKit") {
					continue;
				}
				// nested RenderKit
				else if (className == "RenderKit") {
					if (node.Renderer != undefined) {
						if (node.Renderer.@dataPath != undefined) {
							cmlRenderer = node.Renderer;
							includeParentIndex.push(parent);
							pausedCML.push(cml.copy());
							for (var j:int = i; j >= 0; j--) {
								delete pausedCML[pausedCML.length - 1][j];
							}
							renderKitFound = true;
							FileManager.instance.addToQueue(String(node.Renderer.@dataPath), "cmlRendererData");
							FileManager.instance.addEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);
							if (FileManager.instance.cmlCount == 1)
								FileManager.instance.startCMLQueue();
							else
								FileManager.instance.resumeCMLQueue();
						}
						else if (node.RendererData != undefined)			
							loadRenderer(XMLList(node), parent);
					}
					return;
				}	
				// nested cml loader
				else if (className == "Include") {
					if (debug)
						trace(StringUtils.printf("%9s%s", "", "*** Include found... object creation skipped... adding CML file to queue ***"));					
					
					for each (var attrValue:* in node.@*) {
						attrName = attrValue.name().toString();

						if ((attrName == "cml" || attrName == "src") && attrValue.toString().length > 0) {
							if (attrValue.search(extensions) >= 0){
								// rootDirectory allows you to change root path	
								if (relativePaths && rootDirectory.length > 0){	
									attrValue = rootDirectory.concat(attrValue);
									attrValue = relToAbsPath(attrValue);
								}
								else if (rootDirectory.length > 0) {
									attrValue = rootDirectory.concat(attrValue);
								}
							}	
														
							includeParentIndex.push(parent);
							FileManager.instance.addToQueue(attrValue, "cml");								
							pausedCML.push(cml.copy());
														
							for (var j:int = i; j >= 0; j--) {
								delete pausedCML[pausedCML.length - 1][j];
							}
														
							FileManager.instance.addEventListener(FileEvent.CML_LOADED, onCMLLoadComplete);
							
							if (FileManager.instance.cmlCount == 1)
								FileManager.instance.startCMLQueue();
							else 
								FileManager.instance.resumeCMLQueue();
							
							includeFound = true;
							return;
						}
					}
					continue;
				}
			
				// look for className keyword
				// this changes the class type of the loaded object	
				var aName:String;
				var aValue:*;
				for each (aValue in node.@*) {
					aName = aValue.name().toString();
					if (aName == "className")
						className = aValue;
				}
										
				if (debug)
					trace(StringUtils.printf("%9s%s", "", className));					
								
				obj = createObject(className);	
	
				// assign id and class values
				if (node.@id != undefined) {
					obj.id = node.@id;
					if (node.@['class'] != undefined)
						obj.class_ = node.@['class'];
				}
				else if (node.@['class'] != undefined) {
					obj.class_ = node.@['class'];
					obj.id = node.@['class'];
				}
				else
					obj.id = className;
						
				// add to master object list
				CMLObjectList.instance.append(obj.id, obj);				
				
				// unique object identifier
				obj.cmlIndex = CMLObjectList.instance.length-1;	
				
				// run object's parse routine	
				returnedNode = obj.parseCML(XMLList(node));
				
				 //target render data
				if (properties){
					if (debug)
						trace("\ncomponent kit render properties of id: ", obj.id);					
					
					obj.propertyStates[0]["id"] = obj.id;				
									
					for (var key:* in obj.propertyStates[0]) {						
						if (key == "rendererList") {
							includeParentIndex.push(obj);
							FileManager.instance.addToQueue(val, "cmlRenderKit");
						}
						
						for each (var val:* in properties.*) {
							var str:String = obj.propertyStates[0][key];
							var eval:Boolean = false;
							
							// filter value for expression delimiter "{}"
							if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {				
								// remove whitepsace and {} characters
								var regExp:RegExp = /[\s\r\n{}]*/gim;
								str = str.replace(regExp, '');
								eval = true;
							}	
							
							if (str == val.name().toString()) {
								eval = false;
								obj.propertyStates[0][key] = val;
							}							
						}
					}						
				}				
				else {
					// look for rendererList keyword
					// loads an external RenderKit	
					for each (aValue in node.@*) {
						aName = aValue.name().toString();
						
						if (aName == "rendererList") {					
							includeParentIndex.push(obj);
							FileManager.instance.addToQueue(aValue, "cmlRenderKit");						
						}		
					}
				}
				
				obj.postparseCML(XMLList(node));
				
				if (parent is (IContainer))
					parent.childToList(obj.id, obj);				
				else if (parent == defaultContainer && obj is DisplayObject)
					defaultContainer.addChild(obj);					
				
				//recursion
				if (returnedNode.length() > 0)
					loopCML(returnedNode, obj, properties);
					
				i++;	
			}
		}		
		
	
		
		
		/**
		 * Creates object from class name
		 * Returns a new object of the class
		 * @param	className
		 * @return
		 */
		public static function createObject(className:String):Object
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

				//if search failed, throw an error
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
		private static function searchPackages(className:String, packageArray:Array):Object
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
		public static function parseCML(obj:*, cml:XMLList):XMLList
		{
			var returnNode:XMLList = new XMLList;
			
			attrLoop(obj, cml);
			
			if (cml.*.length() > 0)
				returnNode = cml.*;
			
			return returnNode;
		}		
		
		
		public static function attrLoop(obj:*, cml:XMLList):void
		{
			var attrName:String;
			
			for each (var attrValue:* in cml.@*)
			{
				attrName = attrValue.name().toString();

				// check for css keyword
				if (attrName == "class")
					attrName = "class_";				
				
				if (attrValue.search(extensions) >= 0 && String(attrValue.charAt(0) != "{") )
				{
					// rootDirectory allows you to change root path	
					if (relativePaths && rootDirectory.length > 1)	
					{	
						attrValue = rootDirectory.concat(attrValue);
						attrValue = relToAbsPath(attrValue);	
					}
					else if (rootDirectory.length > 0)	
					{	
						attrValue = rootDirectory.concat(attrValue);
					}					
				}
					
				obj.propertyStates[0][attrName] = attrValue;
			}
					
			attrName = null;			
		}
		
		
		/**
		 * Converts relative to absolute path
		 * @param	string
		 * @return
		 */
		public static function relToAbsPath(string:String):String
		{			
			var newString:String;
			var cnt:int = 0;
			var arr:Array = string.split("/");
			
			for (var i:int = arr.length-1; i >= 0; i--) {
				if (i == arr.length - 1) {
					newString = arr[i];
					continue;
				}	
				
				if (arr[i] == "..")
					cnt++;
				else if (cnt > 0)
					cnt--;
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
		public static function updateProperties(obj:*, state:Number=0):void
		{
			var propertyValue:String;
			var objType:String;
			
			var newValue:*;
			
			for (var propertyName:String in obj.propertyStates[state]) {				
				newValue = obj.propertyStates[state][propertyName];
					
				if (newValue == "true")
					newValue = true;
				else if (newValue == "false")
					newValue = false
					
				if (obj[propertyName] != newValue && String(newValue).charAt(0) != "{") {
					obj[propertyName] = newValue;
				}
				
				if (debug) {
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
		 * Filters properties amd resolves expression attributes
		 * @param	propertyName
		 * @param	propertyValue
		 * @param	propertyStates
		 * @param	state
		 * @return
		 */
		public static function filterProperty(propertyName:String, propertyValue:*, propertyStates:*, state:*):*
		{				
			propertyValue = propertyStates[state][propertyName].toString();			
			
			// filter value for expression delimiter "{}"
			if (propertyValue.charAt(0) == "{") {				
				if ((propertyValue.charAt(propertyValue.length - 1) == "}")) {
					// remove whitepsace and {} characters
					var regExp:RegExp = /[\s\r\n{}]*/gim;
					propertyValue = propertyValue.replace(regExp, '');
									
					// split last period 					
					var arr:Array = propertyValue.split(".");			
					
					if (arr.length > 1) {				
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
						for (var j:int = 0; j < CMLObjectList.instance.length; j++) {	
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
							
			return propertyStates[state][propertyName];			
		}
		
		
		/**
		 * Evaluates whether or not to exit recursive parsing loop
		 */
		private static function evaluate():void
		{
			if ( (cmlFilesComplete != FileManager.instance.cmlCount) || renderKitFound || extFilesLoading)
				return;
			else if (pausedCML.length > 0) {
				loopCML(pausedCML.pop(), includeParentIndex.pop());
				evaluate();
			}
			else if (pausedCML2.length > 0) {
				var arr:Array = pausedCML2.pop();				
				loopCML(XMLList(arr[0]),arr[1],arr[2]);
				evaluate();				
			}
			else if (FileManager.instance.fileCount > 0 && !extFilesLoaded)
				loadExtFiles();
			else
				loadCSS();
		}
		
		
		/**
		 * The final parsing control function
		 */
		private static function loadDisplay():void
		{
			if (debug) {
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
					
			if (debug) {
				trace("\n 13) Print CMLObjectList");
				printObjectList();				
			}
				
			if (debug)
				trace('\n========================== CML parser complete ===============================\n');												
		}			
		
		
		/**
		 * Prints CMLObjectList hierarchy (for debugging purposes)
		 */
		private static function printObjectList():void
		{			
			var cmlIndex:int;
			var id:String;
			var class_:String;
			var object:*;
			var childArray:Array = [];
			var found:Boolean = true;
			
			trace("\n*********** CMLObjectList Begin **************");
			trace("  root = no star, 'n'-child = 'n'-star");
			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) {	
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
										
				for (var j:int = 0; j < childArray.length; j++) {
					if (childArray[j] == cmlIndex)
						found = true;
				}					
				
				if (!found) {
					trace();
					trace("cmlIndex:" + cmlIndex, " id:" + id, " class:" + class_, " object:" + object);
				
					if (CMLObjectList.instance.getIndex(i).hasOwnProperty("childList")) 
						childLoop(CMLObjectList.instance.getIndex(i), 0);
				}
			}
			
			function childLoop(obj:*, index:int):void {
				var cmlIndex:int;
				var id:String;
				var class_:String;
				var object:*;
				
				for (var i:int = 0; i < obj.childList.length; i++) {
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
					
					for (var n:int = 0; n < index; n++) {
						str += "*";
					}
					
					trace(str, "cmlIndex:", cmlIndex, " id:", id, " class: ", class_, " object:", object);					
					
					if (obj.childList.getIndex(i).hasOwnProperty("childList"))
						childLoop(obj.childList.getIndex(i), index + 1); 										
				}
			
			}
										
			trace("\n*********** CMLObjectList End **************");			
		}	
		
		
		// IEventDispatcher
        private static var _dispatcher:EventDispatcher = new EventDispatcher();
        public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
            _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public static function dispatchEvent(event:Event):Boolean {
            return _dispatcher.dispatchEvent(event);
        }
        public static function hasEventListener(type:String):Boolean {
            return _dispatcher.hasEventListener(type);
        }
        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
        public static function willTrigger(type:String):Boolean {
            return _dispatcher.willTrigger(type);
        }	
		
	}
}
