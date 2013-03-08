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
		
		//preprocess
		private static var state:String;
		private static var paths:Dictionary;
		private static var data:Array = [];
		private static var fileCnt:int;
		
		private static var GXMLComponent:Class;
		private static var currentParent:*;			
		private static var index:int = 0;

		
		//public variables
		public static const COMPLETE:String = "COMPLETE";
		
		public static var debug:Boolean = false;			
		
		public static var rootDirectory:String = "";	
		public static var relativePaths:Boolean = false;					
		
		public static var cssFile:String;
		public static var cmlFile:String;
		public static var cmlData:XML;
		
		public static var cmlDisplay:DisplayObjectContainer;
		
		
		public function CMLParser() {}
		
		// legacy support, when CMLParser was a singleton 
		private static var _instance:*;
		public static function get instance():* {return CMLParser;}
		
		
		/**
		 * Initial parsing of the cml document
		 * @param 	xml
		 * @param	parent
		 * @param	properties
		 */
		public static function init(cml:XML, parent:*, properties:*=null):void
		{
			if (debug) trace('\n========================== CML Parser Initialized ===============================\n');				
			
			// required for TLF
			XML.ignoreWhitespace = true;
			XML.prettyPrinting = false;
		
			cmlData = cml;			
			
			// set paths relative to main cml document
			if (cml.@relativePaths == "true")
				relativePaths = true;
			
			// set root directory of file paths
			if (cml.@rootDirectory != undefined && !relativePaths)
				rootDirectory = cml.@rootDirectory;
			else if (cml.@rootDirectory != undefined && relativePaths)
				rootDirectory = relToAbsPath(rootDirectory.concat(cml.@rootDirectory));	
				
			// set css file
			var cssStr:String = "";
			if (cml.@css != undefined)
				cssStr = cml.@css;			
			if (cssStr.length > 0)
				CMLParser.cssFile = updatePath(cssStr);
			
			
			// set parent display
			cmlDisplay = parent as DisplayObjectContainer;
			

			// preprocess
			preprocess(XMLList(cml));
		}			
		
		

		

		// ************************************************** //		
		// *************** preprocess stages **************** //
		// ************************************************** //		
		
		private static function preprocess(cml:XMLList):void
		{
			if (debug) trace("\n\n++ Preprocess Begin ++");	

			paths = new Dictionary;
			paths["Include"] = [];
			paths["Library"] = [];
			paths["Media"] = [];
			
			preprocessLoop(cml);
			state = "Include";			
			processPaths(paths[state]);
		}		
		
		private static function ppComplete():void
		{
			if (debug) trace("\n\n++ Preprocess Complete ++");	

			// process
			process(XMLList(cmlData));			
		}
		
		private static function preprocessLoop(cml:XMLList):void
		{
			var tag:String;
			var i:int;
			var j:int;
		
			for (i = 0; i < cml.length(); i++) {
				tag = cml[i].name();
				
				if (!tag) {
					// TODO: Replace -match against RendererData attribute values to more reliably resolve paths
					//if (cml.parent() && 
					//	cml.parent().parent().parent().name() == "RendererData") {			
						if ( cml[i].toString().search(FileManager.cmlType) > -1 )
							ppInclude(cml[i], cml[i].toString());					
						else if ( cml[i].toString().search(FileManager.mediaPreloadTypes) > -1 )
							ppMedia(cml[i], cml[i].toString());
					//}	
					continue;
				}
				
				if (debug && tag == "cml") trace("");
				if (debug) trace(dash(XMLList(cml[i])) + tag + "");
				
				if (tag == "Include")
					ppInclude(cml[i]);				
				else if (tag == "RenderKit")
					ppRenderKit(cml[i]);
				else if (tag == "LibraryKit" || tag == "Library")
					ppLibraryKit(cml[i]);
				else if (tag == "LayoutKit" || tag == "Layout")
					ppLayoutKit(cml[i]);					
				else if (cml[i].@src != undefined)
					ppMedia(cml[i]);					
				
				if (cml[i].*.length() > 0)
					preprocessLoop(cml[i].*);
			}
			
		}							
		
		
		private static function processPaths(p:Array):void
		{
			var cnt:int = 0;
			
			for (var i:int = 0; i < p.length; i++) {
				if (!FileManager.hasFile(p[i])) {
					FileManager.addToQueue(p[i]);
					cnt++;
				}	
			}
			paths[state] = [];
			
			if (cnt)
				startQueue();
			else
				ppEval();
		}

		
		private static function startQueue():void 
		{
			FileManager.addEventListener(FileEvent.FILE_LOADED, fileLoaded);
			FileManager.addEventListener(FileEvent.FILES_LOADED, filesLoaded);
			FileManager.startQueue();			
		}
		
		private static function stopQueue():void 
		{
			FileManager.removeEventListener(FileEvent.FILE_LOADED, fileLoaded);
			FileManager.removeEventListener(FileEvent.FILES_LOADED, filesLoaded);
			FileManager.stopQueue();			
		}		
		
		private static function fileLoaded(e:FileEvent):void
		{
			if (debug) trace("0:" + fileCnt.toString(), "File loaded:", e.path, e.data);
			data.push(e.data);
			fileCnt++;
		}
		
		private static function filesLoaded(e:FileEvent):void
		{
			if (debug) trace("0:*", "Files loaded");			
			for (var i:int = 0; i < data.length; i++) {
				preprocessLoop(XMLList(data[i]));
			}
			data = [];
			processPaths(paths[state]);			
		}		
		
		
		private static function ppEval():void
		{			
			if (paths[state].length == 0) {
				if (state == "Include") {
					state = "Library";
					processPaths(paths[state]);
					return;
				}
				else if (state == "Library") {
					state = "Media";
					processPaths(paths[state]);
					return;
				}					
				else if (state == "Media"){
					ppComplete();
					return;
				}
			}
			processPaths(paths[state]);			
		}
		
		private static function ppInclude(cml:XML, str:String=""):void 
		{			
			var path:String;
			
			if (str.length > 0)
				path = str;			
			else {
				if (cml.@src != undefined)
					path = cml.@src;
				else if (cml.@cml != undefined) // deprecate
					path = cml.@cml;
				else throw new Error("Include statement must contain the 'src' attribute");
			}	
			
			if (!FileManager.isCML(path)) return;
			
			if (paths["Include"].indexOf(path) == -1)
				paths["Include"].push(path);
			if (debug) trace("0:  Include found: " + path);
		}
		
		private static function ppRenderKit(cml:XML):void 
		{
			if (debug) trace("0:  RenderKit found" );
			var path:String;
			if (cml.Renderer != undefined  && cml.Renderer.@dataPath != undefined) {
				path = cml.Renderer.@dataPath;
				
				if (!FileManager.isCML(path)) return;
				
				if (paths["Include"].indexOf(path) == -1)
					paths["Include"].push(path);
				if (debug) trace("0:  Renderer dataPath found: " + path);
			}					
		}		
		
		private static function ppLibraryKit(cml:XML):void 
		{
			if (cml.name() != "Library") return;
			if (cml.parent().name() != "LibraryKit") return; 
			
			var path:String = cml.@src;
			if (!FileManager.isLibrary(path)) return;

			if (paths["Library"].indexOf(path) == -1)
				paths["Library"].push(path);	
			if (debug) trace("0:  Library found: " + path);						
		}				
		
		private static function ppLayoutKit(cml:XML):void 
		{
			if (cml.name() != "Layout") return;
			if (cml.parent().name() != "LayoutKit") return; 
			
			LayoutKit.instance.parseCML(XMLList(cml));
			if (debug) trace("0:  Layout found: " + cml.@ref + cml.@classRef);	// deprecate classRef								
		}	
		
		private static function ppMedia(cml:XML, str:String=""):void 
		{	
			var path:String; 
			
			if (str.length > 0)
				path = str;
			else
				path = cml.@src;
			
			if (!FileManager.isPreloadMedia(path)) return;				
				
			if (paths["Media"].indexOf(path) == -1)
				paths["Media"].push(path);
			if (debug) trace("0:   Media found: " + path);				
		}		 
		
		private static function dash(cml:XMLList):String
		{
			var str:String="-";
			while (cml.parent()) {
				str += "-"
				cml = XMLList(cml.parent());
			}
			return str;
		}
		

		
		private static function updatePath(path:String):String 
		{
			if (relativePaths && rootDirectory.length > 0){	
				path = rootDirectory.concat(path);
				path = relToAbsPath(path);
			}
			else if (rootDirectory.length > 0)
				path = rootDirectory.concat(path);
				
			return path;
		}
		
		
			
		
		
		
		
		// ************************************************** //		
		// ***************** processing stages ***************** //
		// ************************************************** //		
		
		
		
		
		
		
		
		
		
		private static function process(cml:XMLList):void
		{
			if (debug) trace("\n\n++ Process Begin ++");	
			if (debug) trace("\n" + dash(XMLList(cml)) + "cml");	
			
			loopCML(cml.children(), cmlDisplay);
			loadCSS();			
		}
		
	
		
	
							
		/**
		 * Recursive CML parsing
		 * @param	cml
		 * @param	parent
		 * @param	properties
		 */
		public static function loopCML(cml:XMLList, parent:*= null, properties:*= null):void
		{
			var node:XML;			
			var tag:String;
			var attr:String;
			var obj:*;
			var returned:XMLList=null;

			
			
			for each (node in cml) {
				tag = node.name();	
				if (debug) trace(dash(XMLList(node)) + tag + "");
				

				
				if (tag == "Include") {
					if (FileManager.hasFile(node.@src)) {
						if (node.@src != undefined)
							node = XML(FileManager.fileList.getKey(String(node.@src)));
						else if (node.@cml != undefined) //deprecate
							node = XML(FileManager.fileList.getKey(String(node.@src)));
					
						tag = node.name();
						loopCML(node.*, parent);
					}
					continue;

				}
				else if (tag == "RenderKit") {
					if (properties) {
						var tmp:XML = expRenderer(node, parent, properties);
						if (tmp) node = tmp;
					}
					loadRenderer(node, parent);	
					continue;
				}
				else if (tag == "DebugKit" || tag == "RendererData" || tag == "Filter" || tag == "Gesture" || tag == "GestureList"
					|| tag == "LibraryKit" || tag == "Library" || tag == "LayoutKit" || tag == "Layout" )
					continue;
				

			
				
				obj = createObject(tag);	
	
				
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
				else obj.id = tag;
				
				

				// unique object identifier
				obj.cmlIndex = CMLObjectList.instance.length;	
				
				
				
				// run object's parse routine	
				returned = obj.parseCML(XMLList(node));
				
				returned = parseFilter(obj, returned);
				returned = parseGesture(obj, returned);
				
				obj.postparseCML(XMLList(node));
				
				
				 //target render data
				if (properties) {
					if (obj) { //normal
						for (var key:* in obj.propertyStates[0]) {		
							for each (var val:* in properties.*) {
								var str:String = obj.propertyStates[0][key];
								
								// filter value for expression delimiter "{}"
								if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {				
									// remove whitepsace and {} characters
									var regExp:RegExp = /[\s\r\n{}]*/gim;
									str = str.replace(regExp, '');
								}	
								
								if (str == val.name().toString()) {
									if (key == "id")
										obj.id = val;									
									obj.propertyStates[0][key] = val;
								}							
							}
						}
					}
				}	
				
				
				// add to master object list
				CMLObjectList.instance.append(obj.id, obj);	
		
					
				if (parent is (IContainer))
					parent.childToList(obj.id, obj);
				
				else if (parent == cmlDisplay && obj is DisplayObject)
					cmlDisplay.addChild(obj);					

					
				//recursion
				if (returned && returned.length())
					loopCML(returned, obj, properties);
					
			}
		}		
		
		
		
		public static function expRenderer(node:*, parent:*, properties:*):XML
		{
			var returned:XML = XML(node);
			
			var tmp:*;
			var renderer:XMLList = node.*;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			
			for (var i:int = 0; i < renderer.length(); i++) {
				tmp = renderer[i];
			
				for each (var atr:XML in tmp.@*) {		
					for each (var val:* in properties.*) {
						var str:String = atr;
						
						// filter value for expression delimiter "{}"
						if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {				
							// remove whitepsace and {} characters
							str = str.replace(regExp, '');
						}	
						
						if (str == "panel-path")
							trace(str, atr, atr.name() );
							
						
						if (str == val.name().toString()) {	
							tmp.@[String(atr.name())] = val;							
							returned = <RenderKit />;
							returned.appendChild(XML(tmp));
							return returned;
						}							
					}
				}							
			}
			
			return returned;
		}
		

		
		public static function loadRenderer(renderKit:*, parent:*):void
		{
			if (debug) trace("\n\n++ Loading RenderKit ++");
		
			var rendererData:XMLList = new XMLList;
			var renderList:XMLList;	
			var cmlRenderer:XMLList;
			var dataRootTag:String;
			var dataPathExp:String;
			var tmp:XMLList;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
				
			for (var q:int; q < renderKit.Renderer.length(); q++) {
				
				if (renderKit.Renderer.@dataPath == undefined)
					rendererData = renderKit.RendererData;
				else {
					rendererData = XMLList(FileManager.fileList.getKey(String(renderKit.Renderer.@dataPath)))
					if (rendererData.RenderKit == undefined) // makes RenderKit and Renderer optional on dataPath files
						rendererData = XMLList(<cml><RenderKit><RendererData>{rendererData.*}</RendererData></RenderKit></cml>);					
					rendererData = rendererData.RenderKit.RendererData;
				}
				
				if (rendererData.Include != undefined) {
					var j:int;
					var src:String;
					tmp = XMLList(<RendererData />);
					
					for each (var node:* in rendererData.*) {
						if (node.name() == "Include")
							tmp.appendChild( XMLList(FileManager.fileList.getKey(String(node.@src)).children() ));
						else
							tmp.appendChild(node);
					}
					rendererData = tmp;
				}

				
				
				if (renderKit.Renderer.@dataRootTag == undefined) {
					renderList = rendererData.*;
				}
				else {
					dataRootTag = renderKit.Renderer.@dataRootTag;
					renderList = rendererData.*.(name() == dataRootTag);
				}	
				
				
				for (var i:int = 0; i < renderList.length(); i++) {
					cmlRenderer = new XMLList(renderKit.Renderer[q].*);
					
					for each (var node:* in cmlRenderer) {
						
						if (node.name() == "Include") {
							node = XML(FileManager.fileList.getKey(String(node.@src)));
							node = XMLList(node.children());
						}
	
						var properties:XMLList = XMLList(renderList[i]);	
						loopCML(XMLList(node), parent, properties);
					}
				}
			}
				
		}			
		
		
		
		
		
		
		
		
		private static function parseFilter(obj:*, node:XMLList):XMLList
		{
			var attrName:String;
			var attrValue:*;
			var filter:*;
			var filterArray:Array = [];
			
			for each (var item:XML in node) {
				if (item.name() == "Filter") {
					
					filter = createObject(item.@ref);					
										
					//apply attributes
					for each (attrValue in item.@*) {											
						attrName = attrValue.name().toString();						
						if (attrValue == "true")
							attrValue = true;
						if (attrValue == "false")
							attrValue = false;
						if (attrName != "ref")
							filter[attrName] = attrValue;
					}					
					
					filterArray.push(filter.getFilter());					
				}
			}			
			
			if (filterArray.length > 0)
				obj.filters = filterArray;
			
			return node;
		}
		
		
		
		
		private static function parseGesture(obj:*, node:XMLList):XMLList
		{
			if (!(obj is TouchSprite)) return node;
		
			var tmp:XMLList;
			
			if ( node.(name() == "GestureList").length() )
				tmp = node;
				
			else if ( node.(name() == "Gesture").length() ) {
				tmp = XMLList(<GestureList />);
				tmp.appendChild(XMLList(node.(name() == "Gesture")));
			}
			
			if (tmp && tmp.length)
				obj.makeGestureList(tmp);
			
			return node;
		}		
		
		
		
		
		private static function loadCSS():void
		{		
			if (debug) trace("\n\n++ Search for main CSS file ++");					
				
			if (cssFile && cssFile.length > 0) {
				if (debug) {
					trace("CSS file found... loading: ", cssFile);;				
					CSSManager.instance.debug = true;
				}
				CSSManager.instance.addEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
				CSSManager.instance.loadCSS(cssFile);
			}	
			else {
				if (debug) trace("No CSS file found... skipping CSS parsing");
				loadDisplay();	
			}
		}

		private static function onCSSLoaded(event:FileEvent):void
		{
			CSSManager.instance.removeEventListener(FileEvent.CSS_LOADED, onCSSLoaded)					
		
			if (debug) trace("CSS file load complete: ", cssFile);		
			
			CSSManager.instance.parseCSS();
			loadDisplay();
		}
		
		
		
		/**
		 * Creates object from class name
		 * Returns a new object of the class
		 * @param	tag
		 * @return
		 */
		public static function createObject(tag:String):Object
		{
			//new object reference
			var obj:* = null;			
			var as3class:Class;
			
			//search for package syntax
			if (tag.indexOf('.') != -1)
			{
				//create object
				try {
					as3class = getDefinitionByName(tag) as Class;					
					obj = new as3class();
				}
				catch (e:Error){}					
			}
			
			else
			{
				//begin search in core class list
				obj = searchPackages(tag, CML_CORE.CML_CORE_PACKAGES);

				//if search failed, throw an error
				if (!obj) throw new Error(tag + " failed to load");
			}
				
			return obj;
		}		
		
		
		
		
		/**
		 * Searches a class name from an array of packages
		 * Returns a new object of the class
		 * @param	tag
		 * @param	packageArray
		 * @return
		 */
		private static function searchPackages(tag:String, packageArray:Array):Object
		{
			var obj:* = null;
			var as3class:Class;
			
			//search package list
			for (var i:int=0; i<packageArray.length; i++)
			{
				//create object
				try {
					as3class = getDefinitionByName(packageArray[i] + tag) as Class;					
					obj = new as3class();
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
			var attr:String;
			
			for each (var attrValue:* in cml.@*) {
				attr = attrValue.name().toString();

				// check for css keyword
				if (attr == "class")
					attr = "class_";				
				
				if (attrValue.search(FileManager.fileTypes) >= 0 && String(attrValue.charAt(0) != "{") ) {
					// rootDirectory allows you to change root path	
					if (relativePaths && rootDirectory.length > 1) {	
						attrValue = rootDirectory.concat(attrValue);
						attrValue = relToAbsPath(attrValue);	
					}
					else if (rootDirectory.length > 0) {	
						attrValue = rootDirectory.concat(attrValue);
					}					
				}
					
				obj.propertyStates[0][attr] = attrValue;
			}
					
			attr = null;			
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
		 * The final parsing control function
		 */
		private static function loadDisplay():void
		{
			if (debug) {
				trace("\n\n Apply CML property values\n");	
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", "cmlIndex", "type", "id", "class", "property", "value"));						
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", "--------", "----", "--", "-----", "--------", "-----"));						
			}				
				
			DisplayManager.instance.updateCMLProperties();
			
			if (debug)
				trace("\n\n++ Call loadComplete() to awaiting objects ++");				
			
			DisplayManager.instance.loadComplete();	
			
			if (debug)
				trace("\n\n++ Activate touch... apply GestureList to TouchContainers ++");				
			
			DisplayManager.instance.activateTouch();				
			
			if (debug)
				trace("\n\n++ Add child display objects to parents... make objects visible ++");				
			
			DisplayManager.instance.addCMLChildren();
						
			if (debug)
				trace("\n\n++ Layout Containers... set dimensions to child ++");				
			
			DisplayManager.instance.layoutCML();
			
			if (debug)
				trace("\n\n++ Call object's displayComplete() method ++");				
			
			DisplayManager.instance.displayComplete();	
			
			if (debug) trace("\n\n++ Process Complete ++");
	
			if (debug) {
				trace("\n\n++ Print CMLObjectList ++");
				printObjectList();				
			}			
			
			if (debug) trace("\n\n++ Dispatch CMLParser.COMPLETE event ++");				
			dispatchEvent(new Event(CMLParser.COMPLETE, true, true));	
					
			if (debug)
				trace('\n\n========================== CML parser complete ===============================\n');					
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
					
					if (debug) trace(str, "cmlIndex:", cmlIndex, " id:", id, " class: ", class_, " object:", object);					
					
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
