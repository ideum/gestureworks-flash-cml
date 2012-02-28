////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2010-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:     NodeMapViewer.as
//
//  Author:  Paul Lacey (paul(at)ideum(dot)com)		 
//
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.

////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.cml.components
{
	import flash.events.Event;
	
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.utils.*;
	
	import flash.events.Event;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.Component;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.kits.ComponentKit;	
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;
	 
	public class NodeMapViewerNew extends Component//ComponentKit
	{
		//private var itemList:Array = new Array;
		//private var nodeList:TouchSprite;
		private var node:TouchSprite;
		private var nbtn:TouchSprite;
		
		private var nodeNum:int;
		//private var holder:*; 
		private var nodes:*; 
		private var albums:*;
		private var slider:*;
		private var background:*; 
		private var text_title:*;
		private var text_desc:*; 
		
	
		public function NodeMapViewerNew()
		{
			super();
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("node viewer complete");
			//parseClass();
			initUI();
			setupUI();
		}
				
		private function parseClass():void
		{
			trace("-------", this.childList.getCSSClass("holder", 0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("background", 0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("text", 0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0));
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).id);
			
			var holder = this.childList.getCSSClass("holder", 0);
			trace("................",holder.childList.getCSSClass("background", 0).id);
			
			for (var k:int = 0; k < this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").length; k++)
			{
				
				//this.holder.nodes.node.width; 																						// reference method for objects constructed via as3 
				//this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k) 	//current reefernce reference method for objects constructed via cml engine
				
				//this.cml.holder.nodes.node.width;																						// optional reference method for objects constructed via cml engine
				//this.cml["holder.nodes.node"].width; 																					// optional reference method for objects constructed via cml engine
				
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).id); // node
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("node_point", 0).id); // node_point
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("node_title", 0).id); // title
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("node_link", 0).id); // link
			//	trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0).id); // album
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("albums", 0).childList.getCSSClass("album").getIndex(k).id); // album0
			}	
			
			//trace(this.childList.getCSSClass("holder", 0).name);
		}
		
		private function initUI():void
		{ 	
			trace("------------------------------------------", this.childList.getCSSClass("node_list_viewer", 0).id);
			trace("------------------------------------------", this.childList.getCSSClass("album_list_viewer", 0).id);
			trace("------------------------------------------", this.childList.getCSSClass("node_list_viewer", 0).childList.length);
			trace("------------------------------------------", this.childList.getCSSClass("album_list_viewer", 0).childList.getCSSClass("album").length);

			nodeNum = this.childList.getCSSClass("node_list_viewer", 0).childList.length;
			nodes = this.childList.getCSSClass("node_list_viewer", 0).childList.getCSSClass("node");
			albums = this.childList.getCSSClass("album_list_viewer", 0).childList.getCSSClass("album");
			slider = this.childList.getCSSClass("slider", 0);
			
			background = this.childList.getCSSClass("background", 0);
			text_desc = this.childList.getCSSClass("text_desc", 0)
			text_title = this.childList.getCSSClass("text_title", 0)
		}
		
		private function setupUI():void
		{ 		
			for (var k:int = 0; k < nodeNum; k++)
			{
				// add listener to albums///////// updates node links////////////////////////////////////
				//var album = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0);
				//var album:* = nodes.getIndex(k).childList.getCSSClass("album", 0);
				var album:* = albums.getIndex(k);
					album.name = k;
					album.addEventListener(DisplayEvent.CHANGE, linkDisplayHandler);
				
				// add tap listener to node points /////////////////////////////////
				//var node_point = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("node_point", 0);
				//var node_point:* = nodes.getIndex(k).childList.getCSSClass("node_point", 0);
				var node_point:* = nodes.getIndex(k).childList.getCSSClass("node_point", 0);	
					node_point.name = k;
					node_point.gestureEvents = true;
					//node_point.touchEvents = true;
					node_point.gestureList = { "tap":true,"n-drag":true };
					node_point.addEventListener(GWGestureEvent.TAP, onOpen);
					node_point.addEventListener(GWGestureEvent.DRAG, onOpen);
					node_point.addEventListener(TouchEvent.TOUCH_BEGIN, onOpen);
			}
				
			//slider//////////////////////////////////////////////
			// loop through nodes in chosen active list
			slider.addEventListener(StateEvent.CHANGE, categoryUpdate);
			
			// set node touch timer control///////////////////////
			
		}
		
		private function categoryUpdate(event:StateEvent):void 
		{
			var n:Number = Number(event.value);
			var state:int = Math.round(n);
			//trace("node category update", event.value, event.target.id, state);
			
			activateNodes(state);
			//if (state == 1) activateNodes("1869");
			//if (state == 2) activateNodes("1948");
			//if (state == 3) activateNodes ("2012");
		}
		
		private function activateNodes(state:int):void //state:String
		{
			var g:String;
			if (state == 1) g="1869";
			if (state == 2) g="1948";
			if (state == 3) g="2012";
			
			//trace("--------------node group", nodes.getIndex(ID).group);
			//trace("--------------album group",albums.getIndex(ID).group);
			
			for (var k:int = 0; k < nodeNum; k++)
			{
				// reset
				nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_on", 0).visible = false;
				nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_off", 0).visible = true; 
				//albums.getIndex(k).visible = false;
				
				if (nodes.getIndex(k).group == g) {
					//change node point icon visibilty
					nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_on", 0).visible = true;
					nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_off", 0).visible = false; 
				}
				if(albums.getIndex(k).group == g) {
					//albums.getIndex(k).visible = true;
				}
			}
			
			for (var p:int = 0; p < 3; p++)
			{
			background.getIndex(p).visible= false;
			text_desc.getIndex(p).visible = false;
			text_title.getIndex(p).visible = false;
			
				if (p==(state-1)) {
					background.getIndex(p).visible= true;
					text_desc.getIndex(p).visible = true;
					text_title.getIndex(p).visible = true;
				}
			}
		}
		
		private function onOpen(event:GWGestureEvent):void 
		{
			var ID:int = event.target.name;
			//trace("open", ID);
	
			// reset positions
			//this.album0.visible = true;
			albums.getIndex(ID).visible = true;
			nodes.getIndex(ID).childList.getCSSClass("node_link", 0).visible = true;
		}
		
		private function linkDisplayHandler(event:DisplayEvent):void 
		{
			var ID:int = event.target.name;
			//trace("album translate", ID, event.target.name, albums.getIndex(ID).x, albums.getIndex(ID).y);
			
			var album:* = albums.getIndex(ID);
			var node:*= nodes.getIndex(ID)
			var node_link:* = nodes.getIndex(ID).childList.getCSSClass("node_link", 0);
			
			node_link.width = album.x -node.x + album.width / 2;
			node_link.height = album.y - node.y;
		}
	}
}