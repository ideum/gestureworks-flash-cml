////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File: MP3FactoryNew.as
//  Authors: Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.base.media 
{		
	import com.gestureworks.cml.managers.FileManager;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.MP3Loader;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	/** 
	 * The MP3Factory is the base class for all MP3 audio elements. 
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 */	
	public class MP3Factory extends AudioFactory
	{	
		private var soundLoader:MP3Loader;	
		
		//waveform attributes
		private var bytes:ByteArray;		
		private var cnt:int;
		
		/**
		 * Constructor
		 */
		public function MP3Factory() {
			super();
			bytes = new ByteArray();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function load():void {
			super.load();			
			soundLoader = new MP3Loader(_src, {onProgress:loadProgress, onComplete:soundLoaded});		
			soundLoader.load();					
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function loadProgress(event:Event = null):void {
			_percentLoaded = event.target.progress;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function soundLoaded(event:Event = null):void {
			if (soundLoader){
				soundLoader.vars.onComplete = null; 
				_soundData = soundLoader.content;
				soundLoader.pauseSound();
			}
			else {					
				_soundData = (FileManager.media.getContent(src)) as Sound;			
			}
			
			//duration
			_duration = _soundData.length;
			
			//metadata
			_metadata = _soundData.id3;
			_title = _metadata.songName;
			_artist = _metadata.artist;
			_album = _metadata.artist;
			_date = _metadata.year;
			_comment = _metadata.comment;
			
			if (autoplay){ 
				play();		
			}	
			super.soundLoaded(event);			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function soundComplete(event:Event = null):void {
			super.soundComplete(event);
			if (loop) {
				play();
			}				
		}				
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			super.close();
			listenComplete = false;		
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function play():void {
			if (!isPlaying) {	
				_channel = _soundData.play(_position, 0, _soundTransform);
				listenComplete = true;
			}			
			super.play();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function resume():void {
			if (!isPlaying) {				
				_channel = _soundData.play(_position, 0, _soundTransform);
				listenComplete = true;
			}			
			super.resume();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void {
			_position = _channel.position;				
			_channel.stop();
			listenComplete = false;
			super.pause();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			_channel.stop();
			listenComplete = false;
			super.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function seek(pos:Number):void {
			pause();
			_position = pos; 
			super.seek(pos);			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get position():Number { return _channel ? _channel.position : _position; }	
		
		/**
		 * Register/unregister sound complete event
		 */
		private function set listenComplete(value:Boolean):void {
			if (value) {
				_channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			}
			else {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function visualize(value:Waveform):void {
			bytes.position = 0;
			soundData.extract(bytes, 2048, position * 44.1);
			bytes.position = 0;
			
			cnt = 0;
			var average:Number;
			while (bytes.bytesAvailable > 0) {
				average = bytes.readFloat() + bytes.readFloat() * .5;
				
				if (cnt % 8 == 0) {
					value.averageGain[cnt] = average;
					value.draw();
				}
				cnt++;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			soundLoader = null;	
			bytes = null;				
		}
	}
}