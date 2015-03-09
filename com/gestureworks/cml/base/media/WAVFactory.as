////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File: WAVFactory.as
//  Authors: Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.base.media 
{	
	import com.adobe.xmp.core.XMPConst;
	import com.adobe.xmp.core.XMPMeta;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/** 
	 * The WAVFactory is the AIR-exclusive base class for all .wav audio files.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.elements.MP3
	 * @see com.gestureworks.cml.elements.WAV
	 */	
	public class WAVFactory extends AudioFactory
	{		
		private var bytes:ByteArray;		
		private var invalidError:Error;	
		
		private var cueStreamStart:Number;
		private var averageGain:Array;		
		
		private var _byteRate:uint = 0;		
		private var _bufferSize:uint = 2048;	
		private var _bitDepth:uint;		
		private var _sampleRate:uint = 0;			
		private var _channels:uint = 0;		
		
		//byte position in file stream which indicates the beginning of audio data
		private var audioStreamStart:Number = 0;
		//byte position in file stream which indicates the beginning of audio data
		private var audioStreamEnd:Number = 0;
		//current audio data byte position in the file stream
		private var audioStreamPosition:Number = 0;			
		//umber of audio data bytes available in file stream
		private var audioStreamAvailable:Number = 0;
		//total size in bytes of audio data in file stream
		private var audioStreamSize:Number = 0;	
		//byte rate in milliseconds
		private var msByteRate:uint = 0;
		
		private var stream:FileStream;	
		private var file:File;
		private var blockAlign:uint = 0;		
		private var fileSize:uint;	
		private var varBufferSize:Number;				
		private var xmp:XMPMeta;
		
		/**
		 * Constructor
		 */
		public function WAVFactory() {
			super();
			averageGain = [];
		}		
		
		/**
		 * @inheritDoc
		 */
		override protected function load():void {
			super.load();
			file = File.applicationDirectory.resolvePath(_src);
			stream = new FileStream();
			stream.open(file, FileMode.READ);
			fileSize = stream.bytesAvailable;
			soundLoaded();			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function soundLoaded(event:Event = null):void {
			traverseFile();						
			super.soundLoaded(event);			
		}

		/**
		 * Parse .wav file
		 */
		private function traverseFile():void {
			
			//reset byte position
			stream.position = 0;
			
			//loop index
			var i:int;
			
			/* RIFF chunk */
			//read chunk id (4 bytes)
			stream.endian = Endian.BIG_ENDIAN;
			var chunkId:String = stream.readUTFBytes(4);
			if (chunkId != 'RIFF')
				throw invalidError;
			
			//read chunk size (4 bytes - little endian)
			stream.endian = Endian.LITTLE_ENDIAN;
			var chunkSize:uint;
			for (i=0; i<4; i++)
				chunkSize += stream.readUnsignedByte() * int(Math.pow(256,i));
			
			//read format (4 bytes - big endian)
			stream.endian = Endian.BIG_ENDIAN;
			var format:String = stream.readUTFBytes(4)
			if (format != 'WAVE')
				throw invalidError;
			
			/*  subchunk1 (fmt) */
			//read subchunk1 id (4 bytes - big endian)
			var subchunk1Id:String = stream.readUTFBytes(4)
			if (subchunk1Id != 'fmt ')
				throw invalidError;
			
			//read subchunk1 size (4 bytes - little endian)
			stream.endian = Endian.LITTLE_ENDIAN;
			var fmtChunkSize:uint;
			for (i=0; i<4; i++)
				fmtChunkSize += stream.readUnsignedByte() * int(Math.pow(256,i));
			
			//record start position of fmt chunk data
			var fmtChunkStart:uint = stream.position;
			
			//read audio format (2 bytes - little endian)
			var audioFormat:uint = stream.readUnsignedByte();			
			stream.readUnsignedByte();
			if (audioFormat != 1)
				throw invalidError;
			
			//read number of channels (2 bytes - little endian)
			_channels = stream.readUnsignedByte();
			stream.readUnsignedByte();
			if (channels > 2)
				throw new Error("More than two channels are not supported");
			
			//read sample rate (4 bytes - little endian)
			for (i=0; i<4; i++) 
				_sampleRate += stream.readUnsignedByte() * int(Math.pow(256,i));
			if (_sampleRate != 44100)
				throw new Error("Sample rate not supported; 44100 Hz required");
			
			//read byte rate (4 bytes - little endian)
			for (i=0; i<4; i++) 
				_byteRate += stream.readUnsignedByte() * int(Math.pow(256,i));
			msByteRate = _byteRate / 1000;	
			
			//read block align (2 bytes - little endian)
			for (i=0; i<2; i++) 
				blockAlign += stream.readUnsignedByte() * int(Math.pow(256,i));
			
			//read bits per sample (2 bytes - little endian)
			_bitDepth = stream.readUnsignedByte();
			stream.readUnsignedByte();
			if (bitDepth != 16)
				throw new Error("Bit depth is not supported; Must be 16 bits"); 
			
			//read compression parameter (2 bytes - little endian) - doesn't exist if PCM
			if (audioFormat != 1)
				stream.position +=2;
			
			//read any extra paramerters
			var fmtPosition:uint = stream.position - fmtChunkStart;
			while (fmtPosition != fmtChunkSize) 
				stream.position++;
			
			//traverse subchunks
			parseSubChunk();
			
			//read sub chunk (look for audio 'DATA' chunk and '_PMX' xmp metadata chunk)
			function parseSubChunk():void {
				
				//read subchunk id (4 bytes - big endian)
				stream.endian = Endian.BIG_ENDIAN;
				var subChunkId:String = stream.readUTFBytes(4);
				
				//read subchunk size (4 bytes - little endian)
				stream.endian = Endian.LITTLE_ENDIAN;
				var subChunkSize:uint = 0;
				for (i=0; i<4; i++)
					subChunkSize += stream.readUnsignedByte() * int(Math.pow(256,i));
				
				//read xmp metadata
				if (subChunkId == '_PMX') {
					//read xmp data as a string
					var str:String = stream.readUTFBytes(subChunkSize);
					
					//create xmp objects
					xmp = new XMPMeta(str);
					var xmpDM:Namespace = XMPConst.xmpDM; 
					var dc:Namespace = XMPConst.dc;
					
					//assign targeted data
					if (xmp.dc::title)
						_title = xmp.dc::title[1]
					if (xmp.xmpDM::artist)
						_artist = xmp.xmpDM::artist;		
					if (xmp.xmpDM::album)
						_album = xmp.xmpDM::album;
					if (xmp.xmpDM::shotDay)
						_date = xmp.xmpDM::shotDay;
					if (xmp.dc::publisher)
						_publisher = xmp.dc::publisher[1]
					if (xmp.xmpDM::comment)
						_comment= xmp.xmpDM::comment;
											
					//free memory
					str = null;
					_metadata = xmp;
				}	
					
				else {
					//if audio data chunk, mark location, size, and length
					if (subChunkId == 'data') {
						audioStreamSize = subChunkSize;
						audioStreamStart = stream.position;
						audioStreamEnd = audioStreamStart + audioStreamSize;
						_duration = audioStreamSize / byteRate * 1000;
					}	
					
					stream.position += subChunkSize;
				}
				
				//if end of file, exit recursive function
				if (stream.bytesAvailable == 0)
					fileTraversalComplete();
				//else, read another sub chunk	
				else 
					parseSubChunk();				
			}	
		
		}		
		
		/**
		 * Reads through the audio data at the audio rate (currently flash only supports 44.1 Hz).
		 * @param SampleDataEvent		
		 */	
		private function readAudioData(e:SampleDataEvent):void {
						
			var j:uint = 0;
			
			//read through the data at the audio rate
			for (var i:int=0; i<varBufferSize; i++) {

				var leftAmp:Number = stream.readShort() / 32767 * _volume * (1 - _pan * .5);
				e.data.writeFloat(leftAmp);
				
				if (channels == 2) {
					var rightAmp:Number = stream.readShort() / 32767 * _volume * (1 + _pan * .5);
					e.data.writeFloat(rightAmp);
				}
				//update audio stream position
				audioStreamPosition = stream.position - audioStreamStart;
				
				
								
				//compute the amount of audio data remaining
				audioStreamAvailable = audioStreamSize - audioStreamPosition;
				
				//if there is less than one sample per channel, loop
				if ((audioStreamAvailable < blockAlign) && (_loop)) {
					varBufferSize = bufferSize;
					stream.position = cueStreamStart;
					
					_isComplete = true; 
					publishStatus(MediaStatus.PLAYBACK_COMPLETE, isComplete);
					
					_isComplete = false; 
					publishStatus(MediaStatus.PLAYBACK_COMPLETE, isComplete);
				}
				
				//currently use to create graphical waveform
				averageGain[j] = leftAmp + rightAmp * .5;	
				j++
			}
			
			//if smaller than current buffer size, compute the new buffer size
			if (audioStreamAvailable < varBufferSize * blockAlign)
				varBufferSize = audioStreamAvailable / blockAlign;
			
			//if end of audio data reached, reset buffer size and stop playback
			if (audioStreamAvailable == 0) {
				soundComplete();
			}		
		}				
		
		/**
		 * Parse complete
		 */
		private function fileTraversalComplete():void {
			varBufferSize = bufferSize;			
			if (autoplay){
				play();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function soundComplete(event:Event = null):void {
			varBufferSize = _bufferSize;
			super.soundComplete(event);
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			super.close();
			stop();
			
			if(stream){
				stream.close();
				stream = null;
			}

			bytes = null;	
			cueStreamStart = 0;
			averageGain.length = 0;		
			_byteRate = 0;		
			_bitDepth = 0;		
			_sampleRate = 0;			
			
			audioStreamStart = 0;
			audioStreamEnd = 0;
			audioStreamPosition = 0;			
			audioStreamAvailable = 0;
			audioStreamSize = 0;	
			msByteRate = 0;
			
			blockAlign = 0;		
			fileSize = 0;	
			varBufferSize = 0;				
			xmp = null;		
		}		
		
		/**
		 * Enable/disable audio data reading
		 */
		private function set readData(value:Boolean):void {
			if (value) {
				_soundData.addEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
			}
			else {
				_soundData.removeEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function play():void {
			if (!isPlaying) {
				
				//if not paused, start from defined cue
				if(!isPaused) {
				
					//skip to audio data + cue start point
					cueStreamStart = _position * byteRate / 1000 + audioStreamStart;
					
					//make sure number is equally divisible by the block align
					var err:Number = cueStreamStart % blockAlign;
					cueStreamStart = cueStreamStart - err;
										
					//set stream position
					stream.position = cueStreamStart;
					
				}												
				readData = true; 				
				_channel = _soundData.play();
			}
			super.play();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function resume():void {
			if (!isPlaying) {	
				play();
			}				
			super.resume();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void {
			readData = false; 
			super.pause();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void {
			if(stream){
				stream.position = 0;
				readData = false; 			
			}
			_channel.stop();			
			super.stop();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function seek(pos:Number):void {
			_position = pos;
			if(stream){
				pause();
				stream.position = _position;
				play();		
			}
			super.seek(pos);			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get position():Number { return duration*progress; }
		
		/**
		 * @inheritDoc
		 */
		override public function get progress():Number { return audioStreamPosition / audioStreamSize; }
		
		/**
		 * Number of audio channels
		 * @default 0
		 */
		public function get channels():Number { return _channels; }
		

		/**
		 * Audio byte rate (bytes per second)
		 * @default 0 
		 */	
		public function get byteRate():uint { return _byteRate; }

		/**
		 * Audio buffer size
		 * @default 2048
		 */
		public function get bufferSize():uint { return _bufferSize; }
		public function set bufferSize(val:uint):void { 		
			if (val == 2048 || val == 4096 || val == 8192)
				_bufferSize = val; 
			else
				throw new Error("Buffer size must be a power of two. (Use: 2048, 4096, or 8192)"); 
		}						
		
		/**
		 * Number of bits of information in each sample
		 */
		public function get bitDepth():uint { return _bitDepth; }					
		
		/**
		 * Number of samples of the sound taken per second to represent the event digitally
		 */
		public function get sampleRate():uint { return _sampleRate; }		

		/**
		 * @inheritDoc
		 */
		override public function visualize(value:Waveform):void {
			value.averageGain = averageGain;
			value.draw();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			bytes = null;		
			invalidError = null;	
			averageGain = null;			
			stream = null;	
			file = null;			
			xmp = null;			
		}
	}
}