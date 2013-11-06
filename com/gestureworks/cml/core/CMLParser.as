package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.core.CMLDisplay; CMLDisplay;	
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.layouts.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.core.LoaderCore;
	import com.greensock.loading.LoaderMax;
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
	public class CMLParser extends CMLCore
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
		public static var rootHeader:String = "";
		public static var relativePaths:Boolean = false;
		
		public static var cssFile:String;
		public static var cmlFile:String;
		public static var cmlData:XML;
		
		public static var cmlDisplay:Container;
		
		
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
			
			FileManager.init();
			
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
			else
				rootDirectory = "";
				
			rootDirectory = combinePaths(rootHeader, rootDirectory);			
			
			// set css file
			var cssStr:String = "";
			if (cml.@css != undefined)
				cssStr = cml.@css;			
			if (cssStr.length) {
				CMLParser.cssFile = updatePath(cssStr);
			}

			// set parent display
			cmlDisplay = parent as Container;
			
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
					if ( cml[i].toString().search(FileManager.cmlType) > -1 )
						ppInclude(cml[i], cml[i].toString());					
					else if ( cml[i].toString().search(FileManager.mediaPreloadTypes) > -1 )
						ppMedia(cml[i], cml[i].toString());
					continue;
				}
				
				if (debug && tag == "cml") trace("");
				if (debug) trace(dash(XMLList(cml[i])) + tag + "");
				
				if (tag == "Preloader")
					ppPreloaderKit(cml[i]);
				else if (tag == "Include")
					ppInclude(cml[i]);				
				else if (tag == "RenderKit")
					ppRenderKit(cml[i]);
				else if (tag == "LibraryKit" || tag == "Library")
					ppLibraryKit(cml[i]);
				else if (tag == "LayoutKit" || tag == "Layout")
					ppLayoutKit(cml[i]);	
				else if (tag == "Stage")
					cml[i].setName("StageKit");
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
					var loader:LoaderCore = FileManager.append(p[i]);
					loader.addEventListener(LoaderEvent.COMPLETE, fileLoaded);
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
			if (state == "Include") {
				FileManager.cml.addEventListener(LoaderEvent.COMPLETE, filesLoaded);
				FileManager.cml.load();
			}
			else if (state == "Library") {
				FileManager.swf.addEventListener(LoaderEvent.COMPLETE, filesLoaded);
				FileManager.swf.load();				
			}
			else if (state == "Media") {
				FileManager.media.addEventListener(LoaderEvent.COMPLETE, filesLoaded);
				FileManager.media.load();				
			}			
		}
		
		
		private static function fileLoaded(e:LoaderEvent):void
		{
			LoaderCore(e.target).removeEventListener(LoaderEvent.COMPLETE, fileLoaded);
			if (debug) trace("0:" + fileCnt.toString(), "File loaded:", LoaderCore(e.target).name, LoaderCore(e.target).content);
			if (state == "Include") 
			data.push(LoaderCore(e.target).content);
			fileCnt++;
		}
		
		
		private static function filesLoaded(e:LoaderEvent):void
		{
			LoaderMax(e.target).removeEventListener(LoaderEvent.COMPLETE, filesLoaded); 
			if (debug) trace("0:*", "Files loaded");			
			
			if (state == "Include") {
				for (var i:int = 0; i < data.length; i++) {
					preprocessLoop(XMLList(data[i]));
				}
				data = [];
			}
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
		
		private static function ppPreloaderKit(cml:XML):void 
		{	
			if (cml.Preloader != undefined) {
				var obj:Object = createObject(cml.name());
				obj.parseCML();
				obj.init();
			}
		}
		
		private static function ppInclude(cml:XML, str:String=""):void 
		{			
			var path:String;
			
			if (str.length)
				path = str;		
				
			else {
				if (cml.@src != undefined)
					path = cml.@src;
				else throw new Error("Include statement must contain the 'src' attribute");
			}	
			
			if (!FileManager.isCML(path)) 
				return;
			
			path = updatePath(path);
			
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
				
				path = updatePath(path);	
				
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
			if (debug) trace("0:  Layout found: " + cml.@ref);	// deprecate classRef								
		}	
		
		private static function ppMedia(cml:XML, str:String=""):void 
		{	
			var path:String; 
			
			if (str.length)
				path = str;
			else
				path = cml.@src;
			
			path = updatePath(path);	
				
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
			if (relativePaths && rootDirectory.length){	
				path = rootDirectory.concat(path);
				path = relToAbsPath(path);
			}
			else if (rootDirectory.length)
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
		public static function loopCML(cml:XMLList, parent:*= null):void
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
					var path:String;
					if (node.@src != undefined) {
						path = updatePath(node.@src);
					}
					else if (node.@cml != undefined) { // Deprecated
						path = updatePath(node.@cml);
					}
					
					if (FileManager.hasFile(path)) {
						node = XML(FileManager.cml.getLoader(path).content);
					
						tag = node.name();
						loopCML(node.*, parent);
					}
					continue;

				}
				else if (tag == "RenderKit") {
					loopCML(pRenderKit(XML(node)), parent);
					continue;
				}
				
				else if (tag == "DebugKit" || tag == "RendererData" || tag == "Filter" || tag == "Gesture" 
					|| tag == "GestureList" || tag == "LibraryKit" || tag == "Library" || tag == "LayoutKit" 
					|| tag == "Layout" || tag == "State" || tag == "Sound")
					continue;
							
				
				obj = createObject(tag);	
				
				//save render kit object states
				if (node.@saveState != undefined) {
					StateManager.registerRenderObject(obj);
					delete node.@["saveState"];
				}					
				
				// assign id
				if (node.@id != undefined)
					obj.id = node.@id;
				// id defaults to name
				else 
					obj.id = obj.name; 
				
				// assign class values
				if (node.@['class'] != undefined)
					obj.className = node.@['class'];
									
				
				// run object's parse routine	
				returned = obj.parseCML(XMLList(node));
				
				returned = parseFilter(obj, returned);
				returned = parseGesture(obj, returned);
				
				obj.postparseCML(XMLList(node));				
				
				//target state tag
				StateManager.registerStateTag(obj, XMLList(node));
				
				//target sound tag
				SoundUtils.parseCML(obj, XMLList(node));
					
				if ("childToList" in parent)
					parent.childToList(obj.id, obj);
				
				if (parent == cmlDisplay && obj is DisplayObject)
					cmlDisplay.addChild(obj);					
					
				//recursion
				if (returned && returned.length())
					loopCML(returned, obj);
			}
		}		
		
		
		private static function pRenderKit(renderKit:XML):XMLList
		{						
			if (debug) trace("\n\n++ Loading RenderKit ++");
			var regExp:RegExp = /[\s\r\n{}]*/gim;		
			var rendererData:XMLList = new XMLList;
			var renderList:XMLList;	
			var cmlRenderer:XMLList;
			var dataRootTag:String;
			var dataPathExp:String;
			var tmp:XMLList;
			var ret:XMLList = new XMLList;
			var max:int = int.MAX_VALUE;
			var repeat:int = 1;
			var j:int;
			var i:int;
			var q:int;
			var nest:int;
			
			for (q = 0; q < renderKit.Renderer.length(); q++) {
				
				if (renderKit.Renderer.@dataPath == undefined)
					rendererData = renderKit.RendererData;
				else {
					rendererData = XMLList(FileManager.fileList.getKey(String(renderKit.Renderer.@dataPath)).content)
					if (rendererData.RenderKit == undefined) // makes RenderKit and Renderer optional on dataPath files
						rendererData = XMLList(<cml><RenderKit><RendererData>{rendererData.*}</RendererData></RenderKit></cml>);					
					rendererData = rendererData.RenderKit.RendererData;
				}
				
				if (rendererData.Include != undefined) {
					tmp = XMLList(<RendererData />);
					
					for each (var node:* in rendererData.*) {
						if (node.name() == "Include")
							tmp.appendChild( XMLList(FileManager.fileList.getKey(String(node.@src)).content.children() ));
						else
							tmp.appendChild(node);
					}
					rendererData = tmp;
				}

				if (renderKit.Renderer.@max != undefined)
					max = renderKit.Renderer.@max;	
					
				if (renderKit.Renderer.@repeat != undefined)
					repeat = renderKit.Renderer.@repeat;						
				
				if (renderKit.Renderer.@dataRootTag == undefined) {
					renderList = rendererData.*;
				}
				else {
					dataRootTag = renderKit.Renderer.@dataRootTag;
					renderList = rendererData.*.(name() == dataRootTag);
				}	
				
				var len:int = (max < renderList.length()) ? max : renderList.length();
				
				processStates(renderList, XMLList(renderKit.Renderer[q].*));
								
				for (i = 0; i < repeat; i++) {
					for (j = 0; j < len; j++) {
						cmlRenderer = XMLList(renderKit.Renderer[q].*).copy();
						loopRenderer(XMLList(renderList[j]), cmlRenderer);
						ret += XMLList(cmlRenderer);
					}
				}
			}			
			return ret;
		}
		
		private static function loopRenderer(renderList:XMLList, cmlRenderer:XMLList):void
		{			
			var str:String;
			var val:*;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			var level:int;
			var i:int;
			
			for (i = 0; i < cmlRenderer.length(); i++) {
				if (cmlRenderer[i].name() == "Include") {
					cmlRenderer[i] = XMLList(FileManager.fileList.getKey(String(cmlRenderer[i].@src))).copy();
					cmlRenderer[i] = XMLList(cmlRenderer[i].children());
				}
			}
		
			for each (var node:* in cmlRenderer) {
				if (node.name()) {
					//if (node.name() == "RenderKit") continue;
					str = node.name().toString();
				}
				
				for each (val in renderList.*) {										
					if (node.nodeKind() == "text" ) { 
						str = node.toString();
					
						// filter value for expression delimiter "{}"
						if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {				
							// remove whitespace and {} characters
							str = str.replace(regExp, '');
						}	
												
						if (str == val.name().toString()) {									
							var p : XML = node.parent(); 
							var childIndex : int = node.childIndex(); 
							p.children()[childIndex] = String(val.*);
						}					
					}					
					
					for each (var attrVal:* in node.@*) {
						var attr:* = attrVal.name();							
						str = String(attrVal);
						
						// filter value for expression delimiter "{}"
						if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {				
							// remove whitepsace and {} characters
							str = str.replace(regExp, '');
						}	
						
						if ( str == String(val.name()) ) {									
							node.@[attr] = val;
						}					
					}
				
				}	
								
				if (node.*.length())
					loopRenderer(renderList, node.*);
			}			
		}
		
		/**
		 * Save states of all nodes with stateId attribute.
		 * @param	renderList  render data objects
		 * @param	cmlRenderer  renderer objects
		 */
		private static function processStates(renderList:XMLList, cmlRenderer:XMLList):void {
			for each(var node:XML in renderList) {
				if (node.@stateId != undefined)
					StateManager.saveRenderState(node, cmlRenderer);
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
			
			if (filterArray.length)
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
				
			if (cssFile && cssFile.length) {
				if (debug) {
					trace("CSS file found... loading: ", cssFile);;				
					CSSManager.instance.debug = false;
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
			
			CSSManager.instance.parseCSS(event.data);
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

				obj = searchPackages(tag, CMLCore.packages);
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
		public static function searchPackages(tag:String, packageArray:Array):Object
		{
			var obj:* = null;
			var as3class:Class;
			
			//search package list
			for (var i:int=0; i<packageArray.length; i++) {
			
				try {
					// auto-append period to package names, if not provided
					if ( packageArray[i].length > 0) {
						if ( packageArray[i].substr(packageArray[i].length - 1, packageArray[i].length) != "." ) {
							packageArray[i] = packageArray[i] + ".";
							trace( packageArray[i] );
						}					
					}
					//create object
					as3class = getDefinitionByName(packageArray[i] + tag) as Class;					
					obj = new as3class();
					break;
				}
				catch (e:Error) {}	
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
			addToObjectList(obj);
			var returnNode:XMLList = new XMLList;
			
			attrLoop(obj, cml);
			
			if (cml.*.length() > 0)
				returnNode = cml.*;
			
			return returnNode;
		}
		
		/**
		 * Assigns cml index to object and adds object to global CMLObjectList
		 * @param	obj
		 */
		public static function addToObjectList(obj:*):void {
			// unique object identifier
			obj.cmlIndex = CMLObjectList.instance.length;	
			
			// add to master object list
			CMLObjectList.instance.append(obj.id, obj);				
		}		
		
		public static function attrLoop(obj:*, cml:XMLList):void
		{
			var attr:String;
			var stateId:String;
			
			for each (var attrValue:* in cml.@*) {
				attr = attrValue.name().toString();

				// check for css keyword
				if (attr == "class")
					attr = "className";				
				
				if (attrValue.search(FileManager.fileTypes) >= 0 && String(attrValue.charAt(0) != "{") ) {
					// rootDirectory allows you to change root path	
					if (relativePaths && rootDirectory.length > 1) {	
						attrValue = rootDirectory.concat(attrValue);
						attrValue = relToAbsPath(attrValue);	
					}
					else if (rootDirectory.length) {	
						attrValue = rootDirectory.concat(attrValue);
					}					
				}
				
				if (attr == "stateId") {
					stateId = attrValue;
				}
				
				obj.state[0][attr] = attrValue;
			}
			
			if (stateId) {
				obj.state[stateId] = obj.state[0];
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
		
		public static function combinePaths(absPath:String, relPath:String):String {
			
			if (absPath == "") {
				return relPath;
			}
			
			if (relPath == "") {
				return absPath;
			}
			
			var absArray:Array = absPath.split("/");
			var relArray:Array = relPath.split("/");
			
			var relCountToDelete:int = 0;
			for (var i:int = 0; i < relArray.length; ++i) {
				
				var relPart:String = relArray[i];
				
				switch(relPart) {
					case ".":
						relCountToDelete++;
						break;
					
					case "..":
						relCountToDelete++;
						if (absArray.length > 0) {
							var popped:String = absArray.pop();
							while (popped == "" && absArray.length > 0) {
								popped = absArray.pop();
								trace("popped " + popped);
							}
						}
						break;
						
					default:
						break;
				}
			}
			
			if(relCountToDelete > 0) {
				relArray.splice(0, relCountToDelete);
			}
			
			var finalPath:String = absArray.join("\\") + "\\" + relArray.join("\\");
			
			return finalPath;
		}
		
		/**
		 * Default updateProperties routine
		 * @param	obj
		 * @param	state
		 */
		public static function updateProperties(obj:*, state:*=0):void
		{
			var propertyValue:String;
			var objType:String;
			
			var newValue:*;
			var isExpression:Boolean;
			
			for (var propertyName:String in obj.state[state]) {				
				newValue = obj.state[state][propertyName];
					
				if (newValue == "true")
					newValue = true;
				else if (newValue == "false")
					newValue = false
									
				if (propertyName == "width" && String(newValue).charAt(	String(newValue).length - 1 ) == "%") {
					newValue = String(newValue).replace("%", "");
					propertyName = "widthPercent";
				}
				else if (propertyName == "height" && String(newValue).charAt(	String(newValue).length - 1 ) == "%") {
					newValue = String(newValue).replace("%", "");
					propertyName = "heightPercent";
				}	
				else if (propertyName == "widthPercent" || propertyName == "heightPercent") {
					if ( String(newValue).charAt(String(newValue).length - 1 ) == "%") {
						String(newValue).replace("%", "");
					}
				}			
				
				isExpression = obj is Key && (propertyName == "text" || propertyName == "shiftText") ? false : String(newValue).charAt(0) == "{"; 
				
				if (!isExpression) {
					obj[propertyName] = newValue;
				}
				
				if (debug) {
					objType = obj.toString()
					objType = objType.replace("[object ", "");
					objType = objType.replace("]", "");
										
					if (obj.className)
						trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", obj.cmlIndex, objType, obj.id, obj['className'], propertyName, obj[propertyName]));
					else
						trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s %-20s %-20s", "", obj.cmlIndex, objType, obj.id, "", propertyName, obj[propertyName]));
				}	
			}	
		}
				
				
		/**
		 * Resolves expression attributes
		 */
		public static function resolveAttrs(obj:Object):void
		{
			if (!("state" in obj)) return;
			
			var i:int;
			var prop:String;
			var val:String;
			var st:Dictionary;
			var selector:String;
			var pp:String;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			var isExpression:Boolean;
			
			for each (st in obj.state) {
				for  (prop in st) {					
					val = st[prop]; 
					
					//bypass non expressions
					isExpression = obj is Key && (prop == "text" || prop == "shiftText") ? false : val.charAt(0) == "{"; 					
					if (!isExpression) continue;
					
					// remove whitepsace and {} characters
					val = val.replace(regExp, '');
									
					// split last period 					
					var arr:Array = val.split(".");			
					
					if (arr.length > 1) {				
						 selector = "";
						 pp = "";
					
						for (i = 0; i < arr.length; i++) {
							if (i < arr.length-1)
								selector += "." + arr[i];
							else
								pp = arr[i];
						}
						
						if (selector.charAt(0) == ".")
							selector = selector.slice(1);					

						if ( (pp.charAt(pp.length -1) == ")" ) &&
							 (pp.charAt(pp.length -2) == "(") ) {
								 
								obj[prop] = document.querySelector(selector)[pp.slice(0, pp.length-2)]();
						}
							
						else if (pp in obj) {
							if (("searchChildren" in obj) && (obj.searchChildren(val)))
								obj[prop] = obj.searchChildren(selector)[pp];
							else
								obj[prop] = document.querySelector(selector)[pp];
						}

					}	
					
					else {
						if (("searchChildren" in obj) && (obj.searchChildren(val)))
							obj[prop] = obj.searchChildren(val);
						else if ( document.querySelector(val) )
							obj[prop] = document.querySelector(val);
					}
				}
			}
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
		
			
			if (debug) {
				trace("\n\n Resolve Expression Attributes\n");					
			}			
			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) {				
				resolveAttrs(CMLObjectList.instance.getIndex(i));
			}			
			
			
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
				trace("\n\n++ Call object's init() method ++");				
			
			DisplayManager.instance.init();	
			
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
			var className:String;
			var object:*;
			var childArray:Array = [];
			var found:Boolean = true;
			
			trace("\n*********** CMLObjectList Begin **************");
			trace("  root = no star, 'n'-child = 'n'-star");
			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) {	
				cmlIndex = -1;
				id = "";
				className = "";
				object = null;
				found = false;
							
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("cmlIndex"))
					cmlIndex = CMLObjectList.instance.getIndex(i).cmlIndex;
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("id"))
					id = CMLObjectList.instance.getIndex(i).id;
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("className"))
					className = CMLObjectList.instance.getIndex(i).className;
				object = CMLObjectList.instance.getIndex(i);
										
				for (var j:int = 0; j < childArray.length; j++) {
					if (childArray[j] == cmlIndex)
						found = true;
				}					
				
				if (!found) {
					trace();
					trace("cmlIndex:" + cmlIndex, " id:" + id, " class:" + className, " object:" + object);
				
					if (CMLObjectList.instance.getIndex(i).hasOwnProperty("childList")) 
						childLoop(CMLObjectList.instance.getIndex(i), 0);
				}
			}
			
			function childLoop(obj:*, index:int):void {
				var cmlIndex:int;
				var id:String;
				var className:String;
				var object:*;
				
				for (var i:int = 0; i < obj.childList.length; i++) {
					cmlIndex = -1;
					id = "";
					className = "";
					object = null;					
					
					if (obj.childList.getIndex(i).hasOwnProperty("cmlIndex"))
						cmlIndex = obj.childList.getIndex(i).cmlIndex;
					if (obj.childList.getIndex(i).hasOwnProperty("id"))
						id = obj.childList.getIndex(i).id;
					if (obj.childList.getIndex(i).hasOwnProperty("className"))
						className = obj.childList.getIndex(i).className;
					object = obj.childList.getIndex(i);					
					
					childArray.push(cmlIndex);
					var str:String = "*";
					
					for (var n:int = 0; n < index; n++) {
						str += "*";
					}
					
					if (debug) trace(str, "cmlIndex:", cmlIndex, " id:", id, " class: ", className, " object:", object);					
					
					if (obj.childList.getIndex(i).hasOwnProperty("childList"))
						childLoop(obj.childList.getIndex(i), index + 1); 										
				}
			
			}
										
			trace("\n*********** CMLObjectList End **************");			
		}	
		
		public static function clear():void {
			
			if (!cmlDisplay) {
				return;
			}
			
			while(CMLObjectList.instance.length > 0)  {
				CMLObjectList.instance.removeIndex(0);
			}
			
			var childrenToIgnore:int = 0;
			
			while (cmlDisplay.numChildren > childrenToIgnore) {
				
				var child:* = cmlDisplay.getChildAt(childrenToIgnore);
				
				if (child is GestureWorks) {
					childrenToIgnore++;
					continue;
				}
				
				if (child is DisplayObject) {
					cmlDisplay.removeChild(child);
					child.dispose();
					child = 0;
				}
			}
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
