package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.elements.State;
	import com.gestureworks.cml.elements.TLF;
	import com.gestureworks.cml.utils.StringUtils;
	import flash.utils.Dictionary;
	/**
	 * Manages the storage and loading of object states through the RenderKit or the State tag. Through the RenderKit, passing a state to the StateManager is done by assigning a stateId to 
	 * a RenderData object. To register a state through a "State" tag, nest the tag inside the CML object node and assign attributes. If a stateId is not defined on a state tag, one is automatically 
	 * generated. To load the object state, pass the stateId to the StateManager through the loadState function (StateManager.loadState("first state")).
	 * @author shaun
	 */
	public class StateManager 
	{		
		private static var renderStates:Array;
		private static var attributes:Array;
		private static var placeholder:int = -1;
		private static var _states:Array = [];
		private static var lookUp:State = new State;
		
		private static var id:int = 0;
		
		public static function get states():Array { return _states; }
		
		private static function get nextId():String { 
			while (lookUp["state_" + id])
				id++;
			return "state_" + id; 
		};
		
		////////////////////////////////////////////////
		//////	RENDER KIT
		///////////////////////////////////////////////
		/*<RenderKit>

			<Renderer max="1" dataRootNode="Item">
				<Container id="c1" x="{x}" y="{y}">
					<Graphic id="g" color="{color}" shape="{shape}" radius="{r}" width="{width}" height="{height}"/>
				</Container>
			</Renderer>

			<RendererData>
				<Item stateId="circle_1">
					<x>500</x>
					<y>0</y>
					<shape>circle</shape>			
					<color>0x000000</color>
					<r>100</r>
				</Item>
				<Item stateId="rectangle_1"> 
					<x>500</x>
					<y>200</y>
					<shape>rectangle</shape>
					<color>0xFF0000</color>			
					<width>200</width>					
					<height>100</height>
				</Item>
				<Item stateId="rectangle_2"> 
					<x>500</x>
					<y>400</y>
					<shape>rectangle</shape>
					<color>0x00FF00</color>			
					<width>200</width>					
					<height>400</height>
				</Item>
				<Item stateId="circle_2"> 
					<x>500</x>
					<y>600</y>
					<shape>circle</shape>		
					<r>150</r>
				</Item>
			</RendererData>	

		</RenderKit>*/
		
		/**
		 * Generates a nested dictionary of state data with the following structure: object placeholder-->state id-->property-->value.
		 * The placeholder will be replaced by the resulting CML object after instantiaton.
		 * @param	stateData
		 * @param	objects
		 */
		public static function saveRenderState(stateData:XML, cmlObjects:XMLList):void {
			var stateAttr:XML;
			var attr:*;
			var stateId:String = stateData.@stateId;
						
			if (!attributes) {
				attributes = new Array();
				storeRenderAttributes(cmlObjects);
			}
			
			if (!renderStates)
				renderStates = new Array();	
			
			for each(stateAttr in stateData.*){

				for each(attr in attributes) {
					
					//populate states with state attributes matching renderer object attributes
					if (stateAttr.name() == attr.value) {
						
						if (!renderStates[attr.placeholder])
							renderStates[attr.placeholder] = new State();
						if (!renderStates[attr.placeholder][stateId])
							renderStates[attr.placeholder][stateId] = new State();	
						if (!renderStates[attr.placeholder][stateId][attr.property])
							renderStates[attr.placeholder][stateId][attr.property] = new State();
							
						renderStates[attr.placeholder][stateId][attr.property] = stateAttr.toString();
					}
				}
			}			
		}
		
		/**
		 * Parse renderer objects to identify which attributes to to update when loading states. These attributes
		 * are indicated with values between two curly braces (e.g "{x}"). Also flag the renderer object node with
		 * saveState attribute to later (after instantiation) identify the AS3 object for placeholder replacement.
		 * @param	objects
		 */
		private static function storeRenderAttributes(objects:XMLList):void {
			var str:String;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			var p:XML;
			
			for each(var obj:* in objects) {
				placeholder++;
				
				for each(var attr:* in obj.@ * ) {
					str = attr.toString();
					if (str.charAt(0) == "{" && str.charAt(str.length -1) == "}") {
						obj.@saveState = "true";
						str = str.replace(regExp, '');
						attributes.push({placeholder:placeholder, property:attr.name().toString(), value:str == "true" ? true : str == "false" ? false : str});
					}
				}
				
				if (obj.name() == "TLF") {
					if (storeTLFAttributes(formatTLF(obj.*))){
						obj.@saveState = "true";
					}
					continue;
				}
					
				storeRenderAttributes(obj.*);
			}
		}
		
		/**
		 * Remove non-TextFlow child nodes
		 * @param	value
		 * @return
		 */
		private static function formatTLF(value:XMLList):XMLList {
			var tmp:XMLList = value.copy();
			for (var i:int = 0; i < value.length(); i++) {
				if (value[i].localName() != "TextFlow") 	
					delete tmp[i];
			}
			return tmp;
		}		
		
		/**
		 * Store attributes of TLF child nodes. TLF nodes need to be treated differently because they can have child nodes that are not AS3 objects. 
		 * @param	obj
		 * @return
		 */
		private static function storeTLFAttributes(obj:XMLList):Boolean {
			var save:Boolean = false;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			var str:String;

			if (obj.nodeKind() == "text") {
				str = obj.toString();
				if ( (str.charAt(0) == "{") && (str.charAt(str.length - 1) == "}") ) {	
					str = str.replace(regExp, '');
					attributes.push( { placeholder:placeholder, property:obj.nodeKind(), value:str == "true" ? true : str == "false" ? false : str } );
					save = true;
				}	
				return save;
			}
			else {
				for each(var attr:* in obj.@ * ) {
					str = attr.toString();
					if (str.charAt(0) == "{" && str.charAt(str.length -1) == "}") {
						str = str.replace(regExp, '');
						attributes.push( { placeholder:placeholder, property:attr.name().toString(), value:str == "true" ? true : str == "false" ? false : str } );
						save = true;
					}
					
				}
			}
			
			return storeTLFAttributes(obj.*) || save; 
			
		}
		
		/**
		 * Sequentially replace the placeholder integers with objects. Intended for post RenderKit object
		 * instantiation.
		 * @param	object
		 * @private
		 */
		public static function registerRenderObject(object:*): void {
			placeholder = -1;
			attributes = null;		
			var firstObj:State = firstObject();
			
			for (var stateId:* in firstObj) {				
				firstObj[stateId]["stateId"] = stateId;
				registerObject(object, firstObj[stateId]);
				object.stateId = stateId;
			}
			
			renderStates.splice(renderStates.indexOf(firstObj), 1);
		}
		
		/**
		 * Loops through the renderStates sparse array until it finds the first element.
		 */
		private static function firstObject():State {
			var obj:State;
			for each(obj in renderStates) {
				return obj;
			}
			return obj;
		}
		
		////////////////////////////////////////////////
		//////	STATE TAG 
		///////////////////////////////////////////////
		/*<Graphic x="10" y="100" shape="rectangle" width="100" height="100" color="0xcccccc" lineStroke="0">
			<State x="20" y="300" shape="circle" color="0xff1223" radius="50"/>	
			<State stateId="test" x="20" y="300" shape="rectangle" width="300" height="50" color="0xccf2cd" lineStroke="0"/>	
		</Graphic>*/
		
		/**
		 * Register object attributes in State tag
		 * @param	object
		 * @param	cml
		 */
		public static function registerStateTag(object:*, cml:XMLList):void {
			
			if (!("state" in object)) return;
		
			var name:String;
			var val:*;	
			var attr:State;
			var initial:Boolean = false;
			
			//register initial state if parent contains state nodes
			function registerInitialState():void {
				if (!initial) {
					initial = true;
					registerObject(object, object.state[0]);					
					object.stateId = object.state[0].stateId;
				}
			}	
			
			for each (var node:XML in cml.*) {
				if (node.name() == "State") {
					
					registerInitialState();
					
					if (node.@stateId == undefined)
						node.@stateId = nextId;
						
					for each (val in node.@ * ) {
						if(!attr)
							attr = new State();
						name = val.name();	
						if (val == "true") val = true;
						if (val == "false") val = false;	
						attr[name] = val.toString();
					}	
					
					if (attr)
						registerObject(object, attr);
					attr = null;
				}	
			}					
		}
		
		////////////////////////////////////////////////
		//////	AS3
		///////////////////////////////////////////////
		
		/**
		 * Registers object attributes for state management
		 * @param	object The object to register
		 * @param	attr Property to value Dictionary
		 */
		public static function registerObject(object:*, attr:State):void {
			
			if (!("state" in object)) return;
			
			var stateId:String = attr["stateId"];
			if (!stateId) {
				stateId = nextId;
			}			
			
			//allow comma delimited state ids to associate a single state with multiple ids
			var stateIds:Array = stateId.split(",");
			var attrCopy:State;
			
			for each(stateId in stateIds) {
				stateId = StringUtils.trim(stateId); 
				attrCopy = copyAttributes(attr);
				if (!lookUp[stateId])
					lookUp[stateId] = new Array();
				if(lookUp[stateId].indexOf(object) == -1)
					lookUp[stateId].push(object);
				
				attrCopy["stateId"] = stateId;
				
				// TODO
				_states.push(attrCopy);
				object.state[stateId] = _states[_states.length - 1];			
			}
		}
		
		/**
		 * Loads applicable objects with provided states by state id.
		 * @param	stateId
		 */
		public static function loadState(stateId:*): void {
			var obj:*;
			for each(obj in lookUp[stateId])
				obj.loadState(stateId);
		}
		
		/**
		 * Saves applicable objects with provided states by state id.
		 * @param	stateId
		 */
		public static function saveState(stateId:*): void {
			var obj:*;
			for each(obj in lookUp[stateId])
				obj.saveState(stateId);
		}		
		
		/**
		 * Returns all objects with states associated with the provided state id
		 * @param	stateId
		 * @return An array of objects
		 */
		public static function stateIdObjects(stateId:String):Array {
			if (lookUp[stateId])
				return lookUp[stateId];
			return null;
		}
		
		/**
		 * Returns registered state ids of the provided object
		 * @param	object The registered object
		 * @return An array of state ids
		 */
		public static function stateIds(object:*):Array {
			var ids:Array;
			for (var id:String in lookUp) {
				if (lookUp[id] && lookUp[id].indexOf(object) >= 0) {
					if (!ids) ids = [];
					ids.push(id);
				}
			}
			return ids;
		}
		
		/**
		 * Returns shallow copy of attribute dictionary
		 * @param source The source dictionary
		 * @return The dictionary copy
		 */
		private static function copyAttributes(source:State):State {
			var copy:State = new State();			
			for (var key:String in source)
				copy[key] = source[key];
			return copy;
		}
	}

}