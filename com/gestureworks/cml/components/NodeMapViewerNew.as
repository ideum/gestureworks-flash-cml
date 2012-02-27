﻿////////////////////////////////////////////////////////////////////////////////
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
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.kits.ComponentKit;	
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;
	 
	public class NodeMapViewerNew extends ComponentKit
	{
		//private var itemList:Array = new Array;
		//private var nodeList:TouchSprite;
		private var node:TouchSprite;
		private var nbtn:TouchSprite;
		
		private var nodeNum:int;
		private var holder:*; 
		private var nodes:*; 
		private var albums:*;
		private var slider:*;
		
	
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
			nodeNum = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").length;
			holder = this.childList.getCSSClass("holder", 0);
			nodes = holder.childList.getCSSClass("nodes", 0).childList.getCSSClass("node");
			albums = holder.childList.getCSSClass("albums", 0).childList.getCSSClass("album");
			
			//slider = holder.childList.getCSSClass("slider", 0);
		}
		
		private function setupUI():void
		{ 		
			for (var k:int = 0; k < nodeNum; k++)
			{
			
				// add listener to albums///////// updates node links////////////////////////////////////
	
				//var album = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0);
				//var album:* = nodes.getIndex(k).childList.getCSSClass("album", 0);
				var album:* = albums.getIndex(k);
					album.addEventListener(DisplayEvent.CHANGE, displayHandler);
				
				// add tap listener to node points /////////////////////////////////
				//var node_point = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("node_point", 0);
				var node_point:* = nodes.getIndex(k).childList.getCSSClass("node_point", 0);	
					node_point.gestureEvents = true;
					node_point.gestureList = { "tap":true,"n-drag":true };
					node_point.addEventListener(GWGestureEvent.TAP, onOpen);
					node_point.addEventListener(GWGestureEvent.DRAG, onOpen);
					node_point.addEventListener(TouchEvent.TOUCH_BEGIN, onOpen);
			}
				
			// update link drawing//////////////////////////////////
			
			//add slider control to nodes////////////////////////////
			// set slider state
			
			//slider.
			// loop through nodes in chosen active list
			// set node state
			
			
			// set node touch timer control///////////////////////
			
		}
		
		private function onOpen(event:GWGestureEvent):void 
		{
			var p:* = event.target.parent;
			trace("open", p.id, p.parent.id, p.parent.parent.id);
			var s:String = p.id;
			//var ID =  s.substr(s.length - 1)
			var array = s.split("node");
			var ID = array[1];
			trace("0000000", ID);
			

			// reset positions
			//this.album0.visible = true;
			albums.getIndex(ID).visible = true;
			
			// make visble
			//p.childList.getCSSClass("album", 0).visible = true;
			p.childList.getCSSClass("node_link", 0).visible = true;
			
			// update node link 
			//p.childList.getCSSClass("node_link", 0).width = p.childList.getCSSClass("album", 0).x + p.childList.getCSSClass("album", 0).width / 2;
			//p.childList.getCSSClass("node_link", 0).height = p.childList.getCSSClass("album", 0).y;
		}
		
		private function dTapHandler(event:GWGestureEvent):void
		{
			//trace("d tap", count);
		}
		
		private function displayHandler(event:DisplayEvent):void 
		{
			var p:* = event.target.parent;
			
			
			//trace("album translate", p.id, p.childList.getCSSClass("album", 0).childList.getCSSClass("holder", 0).id);
			
			//event.target.parent.getChildAt(2).width = event.target.album.x + event.target.x + event.target.width / 2;
			//event.target.parent.getChildAt(2).height = event.target.album.y + event.target.y;
			
			//p.childList.getCSSClass("node_link", 0).width = p.childList.getCSSClass("album", 0).childList.getCSSClass("holder", 0).x + p.childList.getCSSClass("album", 0).width / 2  + event.target.x;
			//p.childList.getCSSClass("node_link", 0).height = p.childList.getCSSClass("album", 0).childList.getCSSClass("holder", 0).y + event.target.y;
			
			//p.childList.getCSSClass("node_link", 0).width = albums.getIndex(ID).childList.getCSSClass("holder", 0).x + albums.getIndex(ID).width / 2  + event.target.x;
			//p.childList.getCSSClass("node_link", 0).height = albums.getIndex(ID).childList.getCSSClass("holder", 0).y + event.target.y;
			
		}
	}
}