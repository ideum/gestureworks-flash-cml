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
	
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
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
	 
	public class NodeMapViewer extends Component//ComponentKit
	{
		private var nodeNum:int;
		private var nodes:*; 
		private var album_holder:*;
		private var albums:*;
		private var slider:*;
		private var background:*; 
		private var text_title:*;
		private var text_desc:*; 
	
		public function NodeMapViewer()
		{
			super();
		}

		override public function dispose():void
		{
			super.dispose();
			
			nodes = null;
			album_holder = null;
			albums = null;
			background = null;
			text_title = null;
			text_desc = null;
			
			if (slider)
			{
				slider.removeEventListener(StateEvent.CHANGE, categoryUpdate);
				slider = null;
			}
			
		}
		
		override public function displayComplete():void
		{			
			//trace("node viewer complete");
			initUI();
			setupUI();
		}
		
		private function initUI():void
		{ 	
			//trace("------------------------------------------", this.childList.getCSSClass("node_list_viewer", 0).id);
			//trace("------------------------------------------", this.childList.getCSSClass("album_list_viewer", 0).id);
			//trace("------------------------------------------", this.childList.getCSSClass("node_list_viewer", 0).childList.length);
			//trace("------------------------------------------", this.childList.getCSSClass("album_list_viewer", 0).childList.getCSSClass("album").length);

			nodeNum = this.childList.getCSSClass("node_list_viewer", 0).childList.length;
			nodes = this.childList.getCSSClass("node_list_viewer", 0).childList.getCSSClass("node");
			album_holder = this.childList.getCSSClass("album_list_viewer", 0);
			albums = this.childList.getCSSClass("album_list_viewer", 0).childList.getCSSClass("album");
			slider = this.childList.getCSSClass("slider", 0);
			background = this.childList.getCSSClass("background", 0);
		}
		
		private function setupUI():void
		{ 		
			trace("node num",nodeNum)
			
			for (var k:int = 0; k < nodeNum; k++)
			{
				// add listener to albums///////// updates node links////////////////////////////////////
				//var album = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0);
				//var album:* = nodes.getIndex(k).childList.getCSSClass("album", 0);
				var album:TouchContainer = albums.getIndex(k);
					album.name = String(k);
					album.addEventListener(DisplayEvent.CHANGE, updateHandler);
				
				//reposition albums that open out of sight
				if (album.y>(1080-album.height)) album.y -= (album.height +50);
				
				// add tap listener to nodes /////////////////////////////////
				var node:TouchContainer = nodes.getIndex(k);
				
				var node_point:TouchContainer = new TouchContainer();	
				//var node_point:* = nodes.getIndex(k).childList.getCSSClass("node_point", 0);
					//node_point.id = k;
					node_point.name = String(k);
					//node_point.gestureEvents = true;
					node_point.gestureList = { "tap":true};//"n-drag":true 
					node_point.addEventListener(GWGestureEvent.TAP, onOpen);
				node.addChild(node_point)
				
				// sub in node_point content
				var cml_node_point:* = nodes.getIndex(k).childList.getCSSClass("node_point", 0);
				node_point.addChild(cml_node_point);
				
				// node group
				trace(node.group);
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
			trace("node category update", event.value, event.target.id, state);
			
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
			
			//trace("--------------node group", g);
			//trace("--------------album group",albums.getIndex(ID).group);
			//trace("node vis", nodes.getIndex(0).group, g);
				
			for (var k:int = 0; k < nodeNum; k++)
			{
				// reset
				nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_on", 0).visible = false;
				nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_off", 0).visible = true; 
				//albums.getIndex(k).visible = false;
				
				var s:String = nodes.getIndex(k).group;
				var sn:Array = s.split(", ");
				//var sa:Array = albums.getIndex(k).group;
				
				for (var f:int = 0; f < sn.length; f++)
				{
					//trace("--------",sn[f], g)
					if (sn[f] == g) {
						//change node point icon visibilty
						//trace("node vis");
						nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_on", 0).visible = true;
						nodes.getIndex(k).childList.getCSSClass("node_point", 0).childList.getCSSClass("icon_a_off", 0).visible = false; 
					}
					//if(sa[f] == g) {
						//albums.getIndex(k).visible = true;
					//}
				}
			}
			
			for (var p:int = 0; p < 3; p++)
			{
				background.getIndex(p).visible= false;
				if (p==(state-1)) background.getIndex(p).visible= true;
			}
		}
		
		private function onOpen(event:GWGestureEvent):void 
		{
			var ID:int = event.target.name;
			var album:* = albums.getIndex(ID);
			var node_link:* = nodes.getIndex(ID).childList.getCSSClass("node_link", 0);
			
			trace("open", ID,event.target.id);
	
			// reset positions
			album.visible = true;
			node_link.visible = true;
			albumPop(album);
		}
		
		private function albumPop(album:*):void 
		{
			album_holder.removeChild(album);
			album_holder.addChild(album);
		}
		
		private function updateHandler(event:DisplayEvent):void 
		{
			
			albumPop(event.target)
			linkDisplayHandler(event);
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
			
			// when closed make invisible
			if (!album.visible) node_link.visible = false;
		}
	}
}