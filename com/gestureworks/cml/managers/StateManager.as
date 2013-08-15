package com.gestureworks.cml.managers 
{
	import flash.utils.Dictionary;
	/**
	 * Manages the storage and loading of object states through the RenderKit. Passing a state to the StateManager, is done by assigning a stateId to 
	 * a RenderData object. To load the object state, pass the stateId to the StateManager through the loadState function (StateManager.loadState("first state")).
	 * @author shaun
	 */
	public class StateManager 
	{		
		private static var renderStates:Array;
		private static var attributes:Array;
		private static var placeholder:int = -1;
		private static var _states:Array = [];
		private static var lookUp:Dictionary = new Dictionary;
		
		private static var id = 0;
		
		public static function get states():Array { return _states;}
		private static function get nextId():String { return "state_" + id++; };
		
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
							renderStates.push(new Dictionary());
						if (!renderStates[attr.placeholder][stateId])
							renderStates[attr.placeholder][stateId] = new Dictionary();	
						if (!renderStates[attr.placeholder][stateId][attr.property])
							renderStates[attr.placeholder][stateId][attr.property] = new Dictionary();
							
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
				storeRenderAttributes(obj.*);				
			}
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
								
			for (var stateId:* in renderStates[0]) {				
				renderStates[0][stateId]["stateId"] = stateId;
				registerObject(object, renderStates[0][stateId]);
				object.stateId = stateId;
			}
			
			renderStates.shift();
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
			var attr:Dictionary;
			var stateTag:Boolean = false;
			
			
			for each (var node:XML in cml.*) {
				if (node.name() == "State") {
					
					stateTag = true;
					
					if (node.@stateId == undefined)
						node.@stateId = nextId;
						
					for each (val in node.@ * ) {
						if(!attr)
							attr = new Dictionary();
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
			
			//register initial state if parent contains state nodes
			if (stateTag) {
				registerObject(object, object.state[0]);
				object.state.pop();
				object.stateId = object.state[0].stateId;
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
		public static function registerObject(object:*, attr:Dictionary):void {
			
			if (!("state" in object)) return;
			
			var stateId:String = attr["stateId"];
			if (!stateId) {
				stateId = nextId;
				attr["stateId"] = stateId;
			}			
			
			if (!lookUp[stateId])
				lookUp[stateId] = new Array();
			lookUp[stateId].push(object);
			
			_states.push(attr);
			object.state.push(_states[_states.length - 1]);			
		}
		
		/**
		 * Loads applicable objects with provided states by state id.
		 * @param	stateId
		 */
		public static function loadState(stateId:*): void {
			var obj:*;
			for each(obj in lookUp[stateId])
				obj.loadStateById(stateId);
		}
		
		/**
		 * Returns all objects with states associated with the provided state id
		 * @param	stateId
		 * @return An array of objects
		 */
		public static function stateIdObjects(stateId:String):Array {
			return lookUp[stateId];
		}
		
		/**
		 * Returns registered state ids of the provided object
		 * @param	object The registered object
		 * @return An array of state ids
		 */
		public static function stateIds(object:*):Array {
			var ids:Array = [];
			for (var id:String in lookUp) {
				if (stateIdObjects[id].indexOf(object) >= 0)
					ids.push(id);
			}
			return ids;
		}
	}

}