package com.gestureworks.cml.utils {

import flash.display.DisplayObject;
import flash.utils.setInterval;
import flash.utils.clearInterval;

public class as3QueryFx {
	public var options:Object;
	public var elem:DisplayObject;
	public var prop:String;
	private var startTime:Number;
	private var start:Number;
	private var end:Number;
	private var unit:Number;
	private var now:Number;
	private var pos:Number;
	private var state:Number;

	
	public function as3QueryFx(_elem:DisplayObject, _options:Object, _prop:String) {
		options = _options;
		elem = _elem;
		prop = _prop;

		if ( !options.orig ) {
			options.orig = {};
		}
	}

	// Simple function for setting a style value
	public function update():void {
		if ( options.step )
			options.step.apply( elem, [ now, this ] );

		//(as3QueryFx.step[prop] || as3QueryFx.step._default)( this );
		elem[prop] = now;

		// Set display property to block for height/width animations
		if ( prop == "height" || prop == "width" )
			elem.visible = true;
	}

	// Get the current size
	public function cur(force:Boolean = false):Number {
		if ( elem.hasOwnProperty(prop) == true )
			return elem[ prop ];

		return 0;
		//var r = parseFloat(as3Query.curCSS(this.elem, this.prop, force));
		//return r && r > -10000 ? r : parseFloat(as3Query.css(this.elem, this.prop)) || 0;
	}

	// Start an animation from one number to another
	public function custom(from:Number, to:Number, unit:Number = 0):void {
		startTime = (new Date()).getTime();
		start = from;
		end = to;
		this.unit = unit || this.unit;
		now = start;
		pos = state = 0;
		update();

		var self:as3QueryFx = this;
		function t():Boolean {
			return self.step();
		}

		as3Query.timers.push(t);

		if ( as3Query.timers.length == 1 ) {
			var timer:uint = setInterval(function():void{
				var timers:Array = as3Query.timers;
				
				for ( var i:int = 0; i < timers.length; i++ )
					if ( !timers[i]() )
						timers.splice(i--, 1);

				if ( !timers.length )
					clearInterval( timer );
			}, 13);
		}
	}

	// Simple 'show' function
	public function show(...args):void {
		// Remember where we started, so that we can go back to it later
		this.options.orig[this.prop] = as3Query.attr( this.elem, this.prop );
		this.options.show = true;

		// Begin the animation
		this.custom(0, this.cur());

		// Make sure that we start at a small width/height to avoid any
		// flash of content
		if ( this.prop == "width" || this.prop == "height" )
			this.elem[this.prop] = 1;
		
		// Start by showing the element
		as3Query.create(elem).show();
	}

	// Simple 'hide' function
	public function hide(...args):void {
		// Remember where we started, so that we can go back to it later
		this.options.orig[this.prop] = as3Query.attr( this.elem, this.prop );
		this.options.hide = true;

		// Begin the animation
		this.custom(this.cur(), 0);
	}

	// Each step of an animation
	public function step():Boolean {
		var t:Number = (new Date()).getTime();

		if ( t > this.options.duration + this.startTime ) {
			this.now = this.end;
			this.pos = this.state = 1;
			this.update();

			this.options.curAnim[ this.prop ] = true;

			var done:Boolean = true;
			for ( var i:Object in this.options.curAnim )
				if ( this.options.curAnim[i] !== true )
					done = false;

			if ( done ) {
				if ( this.options.display != null ) {
					// Reset the display
					this.elem.visible = true;
				}

				// Hide the element if the "hide" operation was done
				if ( this.options.hide )
					this.elem.visible = false;

				// Reset the properties, if the item has been hidden or shown
				if ( this.options.hide || this.options.show )
					for ( var p:String in this.options.curAnim )
						as3Query.attr(this.elem, p, this.options.orig[p]);
			}

			// If a callback was provided, execute it
			if ( done && as3Query.isFunction( this.options.complete ) )
				// Execute the complete function
				this.options.complete.apply( this.elem );

			return false;
		} else {
			var n:Number = t - this.startTime;
			this.state = n / this.options.duration;

			// Perform the easing function, defaults to swing
			this.pos = as3Query.easing[this.options.easing || (as3Query.easing.swing ? "swing" : "linear")](n, 0, 1, this.options.duration);
			this.now = this.start + ((this.end - this.start) * this.pos);

			// Perform the next step of the animation
			this.update();
		}

		return true;
	}
}
}
