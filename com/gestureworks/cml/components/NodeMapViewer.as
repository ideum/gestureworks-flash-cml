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
	 
	public class NodeMapViewer extends ComponentKit
	{
		private var itemList:Array = new Array;

		private var holder:TouchSprite;
		private var background_holder:Sprite;
		private var text_holder:Sprite;
		private var slider_holder:TouchSprite;
		private var node_holder:TouchSprite;
		
		private var nodeList:TouchSprite;
		private var node:TouchSprite;
		private var nbtn:TouchSprite;
		
		
	
		public function NodeMapViewer()
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
			//initUI();
			parseClass();
			setupUI();
		}
		
		/*
		private function childListParse():void
		{ 
			trace(this.childList.length);
				for (var i:int=0; i<this.childList.length; i++)
					{
						trace(this.childList.getIndex(i),this.childList.getIndex(i).id)
						if ((childList.getIndex(i) is TouchContainer))

						{
						trace("touch container", this.childList[i].id)
						itemList.push(childList.getIndex(i))
						}
					}
				n = itemList.length;
		}
		*/
		
		private function parseIndex():void
		{
			trace("node viewer child parse");
			
			
			for (var j:int = 0; j < this.childList.length; j++)
					{	
						trace("inside 1---------------- ",this.childList.getIndex(j), this.childList.getIndex(j).id)
					
						for (var i:int = 0; i < this.childList.getIndex(j).childList.length; i++)
					{
						trace("inside 2-----------------------------------",this.childList.getIndex(j).childList.getIndex(i), this.childList.getIndex(j).childList.getIndex(i).id);
						
							if ( this.childList.getIndex(j).childList.getIndex(i) is TouchContainer) {
								
								//trace("length",this.childList.getIndex(j).childList.getIndex(i).childList.length)
								for (var k:int = 0; k < this.childList.getIndex(j).childList.getIndex(i).childList.length; k++)
								{
									trace("inside 3--------------------------------------------------", this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k),this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k).id);	
									var item = this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k);
									
									
									
									if (item is AlbumViewerNew) {
										
										
										
										//trace("compoenent kit", item, item.id)
										//trace("compoenent kit", item.childList.getIndex(0), item.childList.getIndex(0).id);
										
										childList.getIndex(j).childList.getIndex(i).childList.getIndex(k).addEventListener(DisplayEvent.CHANGE, displayHandler);
										
										//if (item.childList) {
											//trace(item.childList.length, item.childList.getIndex(0), item.childList.getIndex(0).id);
											//item.childList.getIndex(0).addEventListener(DisplayEvent.CHANGE, displayHandler);
										//}
									}
								}
							}
					}
				}
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
				trace("-------//-------",this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0).id); // album
			}	
		}
		
		private function setupUI():void
		{ 	
			var nodeNum:int = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").length;
			var holder:* = this.childList.getCSSClass("holder", 0);
			var nodes:* = holder.childList.getCSSClass("nodes", 0).childList.getCSSClass("node");
			
			for (var k:int = 0; k < nodeNum; k++)
			{
			
				// add listener to albums///////// updates node links////////////////////////////////////
	
				//var album = this.childList.getCSSClass("holder", 0).childList.getCSSClass("nodes", 0).childList.getCSSClass("node").getIndex(k).childList.getCSSClass("album", 0);
				var album:* = nodes.getIndex(k).childList.getCSSClass("album", 0);
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
			// loop through nodes in chosen active list
			// set node state
			
			
			// set node touch timer control///////////////////////
			
		}
		
		private function onOpen(event:GWGestureEvent):void 
		{
			var p:* = event.target.parent;
			//trace("open", p.id);

			// reset positions
			
			
			// make visble
			p.childList.getCSSClass("album", 0).visible = true;
			p.childList.getCSSClass("node_link", 0).visible = true;
			
			// update node link 
			p.childList.getCSSClass("node_link", 0).width = p.childList.getCSSClass("album", 0).x + p.childList.getCSSClass("album", 0).width / 2;
			p.childList.getCSSClass("node_link", 0).height = p.childList.getCSSClass("album", 0).y;
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
			
			p.childList.getCSSClass("node_link", 0).width = p.childList.getCSSClass("album", 0).childList.getCSSClass("holder", 0).x + p.childList.getCSSClass("album", 0).width / 2  + event.target.x;
			p.childList.getCSSClass("node_link", 0).height = p.childList.getCSSClass("album", 0).childList.getCSSClass("holder", 0).y + event.target.y;
			
		}
	}
}