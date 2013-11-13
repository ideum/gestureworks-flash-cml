package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.Waveform;
	import com.adobe.xmp.core.XMPConst;
	import com.adobe.xmp.core.XMPMeta;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.net.URLLoaderDataFormat;
	
	/**
	 * The WAV element is an AIR required element that loads in a .WAV file and plays it, with the options to pause, stop, and resume play. The WAV element will automatically load any XMP data
	 * if it is present. The WAV element also provides the option of a graphical waveform by setting the display property to "waveform", otherwise "none". The waveform's color can be set.
	 * 
	 * <p>To use the WavElement, it absolutely MUST be compiled in an AIR project.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var wavElement:WavElement = new WavElement();
		wavElement.open("FDR-Infamy.wav");
		wavElement.autoplay = true;
		wavElement.display = "waveform";
		wavElement.volume = 0.5;
		addChild(wavElement);	
		wavElement.init();		
		
	 *
	 * </codeblock>
	 * @author Ideum
	 */
	public class WAV extends TouchContainer
	{
		private var urlLoader:URLLoader;
		private var waveSound:flash.media.Sound;
		private var channel:SoundChannel;
		private var soundTrans:SoundTransform;
		private var Position:uint;		
		private var loading:Boolean = false;
		private var waveForm:Waveform;
		private var _loaded:Boolean;
		
		private var bgGraphic:Sprite;

		private var bytes:ByteArray;
		
		private var _invalidError:Error;
		
		// update timer
		private var _timerFormated:String = "00:00";
		public static var TIME:String = "Time";
		public var timer:Timer;
		
		/**
		 * Cue start byte position
		 * @default null
		 */			
		private var _cueStreamStart:Number;
		
		/**
		 * Constructor
		 */
		public function WAV() 
		{
			super();
			mouseChildren = true;
			//propertyDefaults();
			_averageGain = new Array();
		}
		
		private var _channels:uint = 0;
		/**
		 * Number of audio channels
		 * @default 0
		 */
		public function get channels():uint { return _channels; }
		
		private var _printData:Boolean;		
		/**
		 * print data
		 */
		public function get printData():Boolean { return _printData; }
		public function set printData(val:Boolean):void { _printData = val; }
		
			
		private var _cueStart:Number = 0;
		/**
		 * Cue start point in milliseconds
		 * @default 0 
		 */	
		public function get cueStart():Number { return _cueStart; }
		public function set cueStart(val:Number):void { _cueStart = val; }
		
			
		private var _byteRate:uint = 0;
		/**
		 * Audio byte rate (bytes per second)
		 * @default 0 
		 */	
		public function get byteRate():uint { return _byteRate; }
		
			
		private var _bufferSize:uint = 2048;	
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
		
		private var _backgroundColor:uint = 0x333333;
		/**
		 * Sets the background color
		 * @default 0x333333
		 */			
		public function get backgroundColor():uint {return _backgroundColor;}
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		
		private var _backgroundAlpha:Number = 1.0;
		/**
		 * Sets the background alpha
		 * @default 1.0
		 */			
		public function get backgroundAlpha():Number{ return _backgroundAlpha;}
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
		}		
		
		private var _waveColor:uint = 0xFFFFFF;	
		/**
		 * Sets the color of the waveform
		 * @default 0xFFFFFF
		 */			
		public function get waveColor():uint{ return _waveColor;}
		public function set waveColor(value:uint):void
		{
			_waveColor = value;
		}
		
		private var _autoLoad:Boolean = true;
		[Deprecated(replacement = "preload")] 	
		/**
		 * Indicates whether the wav file is autoloaded 
		 */
		public function get autoLoad():Boolean { return _preload; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_preload = value;
		}
	
	
		private var _preload:Boolean = false;
		/**
		 * Indicates whether the wav file is preloaded by the cml parser
		 * @default true
		 */			
		public function get preload():Boolean { return _preload; }
		public function set preload(value:Boolean):void 
		{ 
			_preload = value;
		}
		
		
		private var _autoplay:Boolean = false;
		/**
		 * Indicates whether the wav file plays upon load
		 * @default true
		 */			
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}

			
		private var _loop:Boolean = false;
		/**
		 * Specifies wether the wav file will to loop to the beginning and continue playing upon completion
		 * @default false
		 */			
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		
		private var _src:String;
		/**
		 * Sets the wav file path
		 * @default
		 */			
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
		}		
		
	
		private var _volume:Number = 1;
		/**
		 * Sets the volume 
		 * @default 1
		 */				
		public function get volume():Number {return _volume;}		
		public function set volume(value:Number):void
		{
			if (value < 0.0) _volume = 0.0; 
			else if (value > 1.0) _volume = 1.0;
			else _volume = value;
		}
		
	
		private var _pan:Number = 0;
		/**
		 * Sets the audio pannning ( -1 = left, 0 = center, 1 = right )
		 * @default 0
		 */				
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void
		{
			if (value < -1.0) _pan = -1.0; 
			else if (value > 1.0) _pan = 1.0;
			else _pan = value;
		}		
				
		
		private var _display:String = "waveform";
		/**
		 * Visualization display type, choose waveform or none
		 * @default waveform
		 */			
		public function get display():String {return _display;}				
		public function set display(value:String):void
		{
			_display = value;
			
			//if (preload)
				//load();
		}
		
		// READ ONLY // 
		
		private var _bitDepth:uint;
		/**
		 * depth of wav file
		 */
		public function get bitDepth():uint { return _bitDepth; }
		
		private var _wavLength:uint;
		/**
		 * length of wav file
		 */
		public function get wavLength():uint { return _wavLength; }
		
		private var _duration:Number = 0;
		/**
		 * Total duration
		 * @default 0
		 */			
		public function get duration():Number { return _duration; }
		
	
		private var _percentLoaded:Number = 0;
		/**
		 * Percent of file loaded 
		 * @default 0
		 */			
		public function get percentLoaded():Number { return _percentLoaded; }
		
	
		private var _playhead:Number = 0;
		/**
		 * Playhead position in ms
		 * @default 0
		 */			
		public function get playhead():Number { return _playhead; }
		
		private var _isPlaying:Boolean = false;
		/**
		 * Sets video playing status
		 * @default false
		 */
		public function get isPlaying():Boolean { return _isPlaying; }
		
		private var _paused:Boolean = false;
		/**
		 * specifies whether the wav file is paused or not
		 * @default false
		 */
		public function get paused():Boolean { return _paused; }
		
		/**
		 * Array of average gain values
		 * @default null
		 */	
		private var _averageGain:Array;
		public function get averageGain():Array { return _averageGain; }
		
		private var _sampleRate:uint = 0;
		public function get sampleRate():uint { return _sampleRate; }
		
		// PROTECTED //
		
		/**
		 * Byte position in file stream which indicates the beginning of audio data
		 * @default 0
		 */		
		protected var _audioStreamStart:Number = 0;
		
		/**
		 * Byte position in file stream which indicates the beginning of audio data
		 * default = 0 
		 */		
		protected var _audioStreamEnd:Number = 0;
		
		/**
		 * Current audio data byte position in the file stream
		 * @default 0 
		 */						
		protected var _audioStreamPosition:Number = 0;		
		
		/**
		 * Number of audio data bytes available in file stream
		 * @default 0 
		 */				
		protected var _audioStreamAvailable:Number = 0;
		
		/**
		 * Total size in bytes of audio data in file stream
		 * default = 0 
		 */			
		protected var _audioStreamSize:Number = 0;	
		
		/**
		 * Byte rate in milliseconds
		 * default = 0 
		 */		
		protected var _msByteRate:uint = 0;
		
		protected var _stream:FileStream;
		
		private var _file:File;
		
		// XMP DATA //
		
		/**
		 * XMP metadata object
		 * @default null 
		 */		
		private var _xmp:XMPMeta;
		public function get xmp():XMPMeta { return _xmp; }

		/**
		 * XMP (dublin core) title metadata
		 * @default null
		 */			
		private var _title:String;
		public function get title():String { return _title; }			

		/**
		 * XMP artist metadata
		 * @default null
		 */		
		private var _artist:String;
		public function get artist():String { return _artist; }		
		
		/**
		 * XMP album metadata
		 * @default null
		 */		
		private var _album:String;
		public function get album():String { return _album; }

		/**
		 * XMP album metadata
		 * @default null
		 */		
		private var _date:String;
		public function get date():String { return _date; }
		
		/**
		 * XMP album metadata
		 * @default null
		 */		
		private var _publisher:String;
		public function get publisher():String { return _publisher; }				
		
		/**
		 * XMP comment metadata
		 * @default null
		 */		
		private var _comment:String;
		public function get comment():String { return _comment; }
		
		/**
		 * Variable audio buffer size (might be smaller than audio buffer size near the end of file) 
		 * @default null
		 */			
		private var _varBufferSize:Number;	
		
		/**
		 * Audio block align (bytes per sample)
		 * @default 0 
		 */		
		private var _blockAlign:uint = 0;
		public function get blockAlign():uint { return _blockAlign; }
		
		private var _fileSize:uint;
		public function get fileSize():uint { return _fileSize; }
		
		// PUBLIC METHODS //
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			load();
		}
		
		/**
		 * Sets the src property from the argument and loads the wav file
		 * @param file Full path and file name of wav file
		 */		
		public function open(file:String):void
		{
			src = file;
			load();
		}
		
		/**
		 * closes wav file
		 */
		public function close():void 
		{
			channel.stop();
			waveSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
			_isPlaying = false;
			_paused = false;
			visible = false;
			timer.stop();
		}
		
		/**
		 * plays wav file
		 */
		public function play():void {
			
			if (_isPlaying == false) {
				
				//if not paused, start from defined cue
				if(!_paused) {
				
					//skip to audio data + cue start point
					_cueStreamStart = _cueStart * byteRate / 1000 + _audioStreamStart;
					
					//make sure number is equally divisible by the block align
					var err:Number = _cueStreamStart % blockAlign;
					_cueStreamStart = _cueStreamStart - err;
										
					//set stream position
					_stream.position = _cueStreamStart;
					
				}
								
				//add SampleDataEvent listener (runs at the audio rate, currently flash only supports 44.1 Hz)
				waveSound.addEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
				
				timer.start();
				
				//play the sound file through sound object, leave cue and loop properties at zero (handled differently)
				waveSound.play();
				_isPlaying = true;	
			}
		}
		
		/**
		 * pauses the wav file
		 */			
		public function pause():void {
			//stop playback and set pause to true
			waveSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
			timer.stop();
			_isPlaying = false;
			_paused = true;
		}
		
		/**
		 * seek method
		 * @param	pos
		 */
		public function seek(pos:Number):void
		{
			pause();
			
			//set stream position
			_stream.position = pos;
			play();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "Position" , _stream.position));
		}
		
		/**
		 * stops wav file
		 */
		public function stop():void {
			//stop playback 
			waveSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
			timer.stop();
			_isPlaying = false;
		}
		
		// PRIVATE //
		
		//load
		private function load():void
		{
			loading = true;;
			
			waveSound = new flash.media.Sound();
			channel = new SoundChannel();
			soundTrans = new SoundTransform();
			//sound.addEventListener(Event.COMPLETE, soundLoaded);
			
			if (display == "waveform") 
			{
				bgGraphic = new Sprite;
				bgGraphic.graphics.beginFill(backgroundColor, backgroundAlpha);
				bgGraphic.graphics.drawRect(0, 0, width, height);
				bgGraphic.graphics.endFill();
				addChild(bgGraphic);
				
				waveForm = new Waveform();
				waveForm.waveColor = _waveColor;
				waveForm.waveWidth = width;
				waveForm.waveHeight = height;
				addChild(waveForm);
			}
			
			
			
			//update timer
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			//sound
			soundTrans.volume = _volume;
			soundTrans.pan = _pan;
			_isPlaying = false;
			Position = 0;
			
			//audio
			_file = File.applicationDirectory.resolvePath(_src);
			_stream = new FileStream();
			_stream.open(_file, FileMode.READ);
			_fileSize = _stream.bytesAvailable;
			
			traverseFile();
		}
		
		/**
		 * Reads through the audio data at the audio rate; Event handler for SampleDataEvent
		 * @param SampleDataEvent
		 * @return none 
		 */	
		private function readAudioData(e:SampleDataEvent):void {
						
			var j:uint = 0;
			
			//read through the data at the audio rate
			for (var i:int=0; i<_varBufferSize; i++) {

				var leftAmp:Number = _stream.readShort() / 32767 * _volume * (1 - _pan * .5);
				e.data.writeFloat(leftAmp);
				
				if (channels == 2) {
					var rightAmp:Number = _stream.readShort() / 32767 * _volume * (1 + _pan * .5);
					e.data.writeFloat(rightAmp);
				}
				//update audio stream position
				_audioStreamPosition = _stream.position - _audioStreamStart;
				
								
				//compute the amount of audio data remaining
				_audioStreamAvailable = _audioStreamSize - _audioStreamPosition;
				
				//if there is less than one sample per channel, loop
				if ((_audioStreamAvailable < blockAlign) && (_loop)) {
					
					_varBufferSize = bufferSize;
					_stream.position = _cueStreamStart;
					
				}
				
				//currently use to create graphical waveform
				_averageGain[j] = leftAmp + rightAmp * .5;
				
				j++
			}
			
			//if smaller than current buffer size, compute the new buffer size
			if (_audioStreamAvailable < _varBufferSize * blockAlign)
				_varBufferSize = _audioStreamAvailable / blockAlign;
			
			//if end of audio data reached, reset buffer size and stop playback
			if (_audioStreamAvailable == 0) {
				_varBufferSize = _bufferSize;
				stop();
			}		
		}
		
		//timer methods
		private function updateDisplay(event:TimerEvent):void
		{
			var string:String=formatTime(channel.position);
			sendUpdate(string);
			
			if (display == "waveform") 	{
				waveForm.averageGain = _averageGain;
				waveForm.draw();
			}	
				
		}
		
		private function sendUpdate(string:String):void
		{
			_timerFormated = string;
		}
		
		private function formatTime(t:int):String
		{
			var s:int=Math.round(t/1000);
			var m:int=0;
			if (s>0)
			{
				while (s > 59)
				{
					m++;
					s-=60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			}
			else return "00:00";
		}
		
		private function traverseFile():void {
			
			//reset byte position
			_stream.position = 0;
			
			//loop index
			var i:int;
			
			/* RIFF chunk */
			//read chunk id (4 bytes)
			_stream.endian = Endian.BIG_ENDIAN;
			var chunkId:String = _stream.readUTFBytes(4);
			if (_printData)
				trace ('Chunk Id = ' + chunkId);
			if (chunkId != 'RIFF')
				throw _invalidError;
			
			//read chunk size (4 bytes - little endian)
			_stream.endian = Endian.LITTLE_ENDIAN;
			var chunkSize:uint;
			for (i=0; i<4; i++)
				chunkSize += _stream.readUnsignedByte() * int(Math.pow(256,i));
			if (_printData)
				trace ('Chunk Size = ' + chunkSize + ' bytes');
			
			//read format (4 bytes - big endian)
			_stream.endian = Endian.BIG_ENDIAN;
			var format:String = _stream.readUTFBytes(4)
			if (_printData)
				trace ('Format = ' + format);
			if (format != 'WAVE')
				throw _invalidError;
			
			/*  subchunk1 (fmt) */
			//read subchunk1 id (4 bytes - big endian)
			var subchunk1Id:String = _stream.readUTFBytes(4)
			if (_printData)
				trace ('Subchunk1 Id = ' + subchunk1Id);
			if (subchunk1Id != 'fmt ')
				throw _invalidError;
			
			//read subchunk1 size (4 bytes - little endian)
			_stream.endian = Endian.LITTLE_ENDIAN;
			var fmtChunkSize:uint;
			for (i=0; i<4; i++)
				fmtChunkSize += _stream.readUnsignedByte() * int(Math.pow(256,i));
			if (_printData)
				trace ('Subchunk1 Size = ' + fmtChunkSize + ' bytes');
			
			//record start position of fmt chunk data
			var fmtChunkStart:uint = _stream.position;
			
			//read audio format (2 bytes - little endian)
			var audioFormat:uint = _stream.readUnsignedByte();			
			_stream.readUnsignedByte();
			if (_printData)	
				trace('Audio Format = uncompressed PCM');
			if (audioFormat != 1)
				throw _invalidError;
			
			//read number of channels (2 bytes - little endian)
			_channels = _stream.readUnsignedByte();
			_stream.readUnsignedByte();
			if (_printData)
				trace('Channels = ' + channels);
			if (channels > 2)
				throw new Error("More than two channels are not supported");
			
			//read sample rate (4 bytes - little endian)
			for (i=0; i<4; i++) 
				_sampleRate += _stream.readUnsignedByte() * int(Math.pow(256,i));
			if (_printData)	
				trace("Sample Rate = " + sampleRate);
			if (_sampleRate != 44100)
				throw new Error("Sample rate not supported; 44100 Hz required");
			
			//read byte rate (4 bytes - little endian)
			for (i=0; i<4; i++) 
				_byteRate += _stream.readUnsignedByte() * int(Math.pow(256,i));
			_msByteRate = _byteRate / 1000;
			if (_printData)
				trace("Byte Rate = " + byteRate);		
			
			//read block align (2 bytes - little endian)
			for (i=0; i<2; i++) 
				_blockAlign += _stream.readUnsignedByte() * int(Math.pow(256,i));
			if (_printData)
				trace("Block Align = " + _blockAlign);
			
			//read bits per sample (2 bytes - little endian)
			_bitDepth = _stream.readUnsignedByte();
			_stream.readUnsignedByte();
			if (_printData)
				trace("Bit Depth = " + bitDepth);
			if (bitDepth != 16)
				throw new Error("Bit depth is not supported; Must be 16 bits"); 
			
			//read compression parameter (2 bytes - little endian) - doesn't exist if PCM
			if (audioFormat != 1)
				_stream.position +=2;
			
			//read any extra paramerters
			var fmtPosition:uint = _stream.position - fmtChunkStart;
			while (fmtPosition != fmtChunkSize) 
				_stream.position++;
			
			//traverse subchunks
			parseSubChunk();
			
			//read sub chunk (look for audio 'DATA' chunk and '_PMX' xmp metadata chunk)
			function parseSubChunk():void {
				
				//read subchunk id (4 bytes - big endian)
				_stream.endian = Endian.BIG_ENDIAN;
				var subChunkId:String = _stream.readUTFBytes(4);
				if (_printData)
					trace ('Subchunk Id = ' + subChunkId);
				
				//read subchunk size (4 bytes - little endian)
				_stream.endian = Endian.LITTLE_ENDIAN;
				var subChunkSize:uint = 0;
				for (i=0; i<4; i++)
					subChunkSize += _stream.readUnsignedByte() * int(Math.pow(256,i));
				if (_printData)
					trace ('Subchunk Size = ' + subChunkSize)	
				
				//read xmp metadata
				if (subChunkId == '_PMX') {
					//read xmp data as a string
					var str:String = _stream.readUTFBytes(subChunkSize);
					
					//create xmp objects
					_xmp = new XMPMeta(str);
					var xmpDM:Namespace = XMPConst.xmpDM; 
					var dc:Namespace = XMPConst.dc;
					
					//assign targeted data
					if (_xmp.dc::title)
						_title = xmp.dc::title[1]
					if (_xmp.xmpDM::artist)
						_artist = xmp.xmpDM::artist;		
					if (_xmp.xmpDM::album)
						_album = xmp.xmpDM::album;
					if (_xmp.xmpDM::shotDay)
						_date = xmp.xmpDM::shotDay;
					if (_xmp.dc::publisher)
						_publisher = xmp.dc::publisher[1]
					if (_xmp.xmpDM::comment)
						_comment= xmp.xmpDM::comment;
					
					if (_printData)
						trace('XMP = ' + str);
											
					//free memory
					str = null;
				}	
					
				else {
					//if audio data chunk, mark location, size, and length
					if (subChunkId == 'data') {
						_audioStreamSize = subChunkSize;
						_audioStreamStart = _stream.position;
						_audioStreamEnd = _audioStreamStart + _audioStreamSize;
						_wavLength = _audioStreamSize / byteRate * 1000;
					}	
					
					_stream.position += subChunkSize;
				}
				
				//if end of file, exit recursive function
				if (_stream.bytesAvailable == 0)
					fileTraversalComplete();
				//else, read another sub chunk	
				else 
					parseSubChunk();				
			}	
		
		}
		
		private function fileTraversalComplete():void {
			if (_printData)
				trace('File traversal complete');

			_loaded = true;
			_varBufferSize = bufferSize;
			
			//Dispatch event, file is loaded, ready to play.
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "loaded", _loaded));
			
			if (_autoplay)
				play();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();			
			_averageGain = null;
			_xmp = null;
			_file = null;
			_stream = null;
			_invalidError = null;
			waveForm = null;
			soundTrans = null;
			urlLoader = null;
			bgGraphic = null;
			bytes = null;
			
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, updateDisplay);
				timer = null;
			}
			
			if (channel) 
			{
				channel.stop();
				channel = null;
			}
			
			if (waveSound) {
				waveSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, readAudioData);
				waveSound = null;
			}
		}
	}

}