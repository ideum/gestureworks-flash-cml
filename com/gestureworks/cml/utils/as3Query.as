package com.gestureworks.cml.utils {

import flash.events.Event;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.net.registerClassAlias;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.flash_proxy;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.Proxy;

/*
as3Query ActionScript port Copyright (c) 2008 nitoyon, http://tech.nitoyon.com/about.html
jQuery Copyright (c) 2007 John Resig, http://jquery.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
public class as3Query extends Proxy {

	//--------------------------------------------------------------------------
	//
	// core
	//
	//--------------------------------------------------------------------------

	private static var quickExpr:RegExp = /^[^<]*(<(.|\s)+>)[^>]*$|^#(\w+)$/;

	public function as3Query(array:Array) {
		setArray( array );
	}

	// stage is an AS3 specific implementation
	private static var _stage:Stage = DefaultStage.instance.stage;
	static internal function set stage(value:Stage):void {
		stage = value;
	}
	static internal function get stage():Stage {
		return DefaultStage.instance.stage;
	}

	static public function create(... args):as3Query {
		var a:Object = args[0] || DefaultStage.instance.stage;
		var c:Object = args[1];

		if(a is String) {
			var m:Array = quickExpr.exec(String(a));
			if(m && (m[1] || !c)) {
				// HANDLE $(html) -> $(array)
				if( m[ 1 ] ) {
					a = as3Query.clean( [ m[1] ] );
				// HANDLE: $("#id")
				} else {
					var tmp:DisplayObject = document.getElementById( m[3] );
					if ( tmp ){
						return new as3Query( [ tmp ] );
					}
					else
						a = [];
				}
			// HANDLE: $(expr)
			} else {				
				return create( c ).find(a);
			}
		// HANDLE: $(function)
		// Shortcut for ???
		} else if( as3Query.isFunction(a) ) {
			throw new Error();
		// HANDLE: $(XML)
		} else if( a is XML || a is XMLList ) {
			a = as3Query.clean( [ a ]);
		// HANDLE: $(Class)
		} else if( a is Class ) {
			a = new a();
		}

		if ( a is Stage && !DefaultStage.instance.stage)
			as3Query.stage = a as Stage;

		return new as3Query(
			// HANDLE: $(array)
			a is Array ? a as Array :

			// HANDLE: $(arraylike)
			a.hasOwnProperty("length") && a.hasOwnProperty(0) ? as3Query.makeArray(a) :

			// HANDLE: $(*)
			[a]);
	}

	flash_proxy override function getProperty(name:*):* {
		if(name.match(/^[0-9]+$/))
			return _array[name];
		return null;
	}

	flash_proxy override function hasProperty(name:*):Boolean {
		return flash_proxy::getProperty(name) != null;
	}

	flash_proxy override function callProperty(name:*, ...rest):* {
		return null;
	}

  		
		
	public function toString():String {
		return "[as3Query " + _array.toString() + "]";
	}

	public const aquery:String = "1.2";

	public function size():int {
		return length;
	}

	public function get length():int {
		return _array.length;
	}

	private var _array:Array = [];

	public function get( num:int = -1 ):Object {
		return num == -1 ? 

			getArray() :

			// Return just the object
			this[num];
	}

	public function getArray():Array {
		// Return a 'clean' array
		return as3Query.makeArray( this );
	}

	
	
	private var prevObject:as3Query = null;
	private function pushStack( a:Object ):as3Query {
		var ret:as3Query = as3Query.create(a);
		ret.prevObject = this;
		return ret;
	}

	private function setArray(a:Array):as3Query {
		_array.push.apply(_array, a);
		return this;
	}

	public function each(fn:Function, args:Object = null):as3Query {
		return as3Query.each( this, fn, args ) as as3Query;
	}

	public function index( obj:Object ):int {
		return _array.indexOf( obj );
	}

	public function attr(key:Object, value:Object = null, type:String = null):Object {
		var obj:Object = key;

		// Look for the case where we're accessing a style value
		if ( key is String )
			if ( value == null )
				return length && as3Query[type || "attr"](this[0], key) || undefined;
			else {
				obj = {};
				obj[key] = value;
			}

		// Check to see if we're setting style values
		return each(function(index:int, val:Object):void{
			// Set all the styles
			for ( var prop:String in obj )
				as3Query[type || "attr"](
					this,
					prop, as3Query.prop(this, obj[prop], type, index, prop)
				);
		});
	}

	public function css( key:String, value:Object = null ):Object {
		return attr( key, value, "css" );
	}

	public function text(e:Object = null):Object {
		if(e != null) {
			return each(function(index:int, val:Object):void{
				if( this.hasOwnProperty("text") ) {
					this["text"] = e.toString();
				}
			});
		}

		var t:String = "";
		as3Query.each( e || this, function(index:int, val:Object):void {
			if( this.hasOwnProperty("text") ) {
				t += this["text"].toString();
			}
		});
		return t;
	}

	public function wrapAll(html:String):as3Query {
		if ( this[0] )
			// The elements to wrap the target around
			as3Query.create(html, this[0].stage)
				.clone()
				.insertBefore(this[0])
				.map(function(...args):DisplayObject{
					var elem:DisplayObject = this;
					while ( document.firstChild(elem) )
						elem = document.firstChild(elem);
					return elem;
				})
				.append(this);

		return this;
	}

	public function wrapInner(html:String):as3Query {
		return each(function(...args):void{
			as3Query.create(this).contents().wrapAll(html);
		});
	}

	public function wrap(html:String):as3Query {
		return each(function(...args):void{
			as3Query.create(this).wrapAll(html);
		});
	}

	static private const props:Object = {
		"for": "htmlFor",
		"class": "className",
		"float": "styleFloat",
		cssFloat: "styleFloat",
		styleFloat: "styleFloat",
		innerHTML: "innerHTML",
		className: "className",
		value: "value",
		disabled: "disabled",
		checked: "checked",
		readonly: "readOnly",
		selected: "selected",
		maxlength: "maxLength"
	};

	public function parent( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):DisplayObject {
			return a.parent;
		});
	}

	public function parents( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):Array {
			return as3Query.dir(a, 'parent');
		});
	}

	public function next( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):DisplayObject {
			return as3Query.nth(a, 2, 'nextSibling');
		});
	}

	public function prev( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):DisplayObject {
			return as3Query.nth(a, 2, 'previousSibling');
		});
	}

	public function nextAll( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):Array {
			return as3Query.dir(a, 'nextSibling');
		});
	}

	public function prevAll( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):Array {
			return as3Query.dir(a, 'previousSibling');
		});
	}

	public function siblings( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):Array {
			return as3Query.sibling(a.parent.getChildAt(0), a);
		});
	}

	public function children( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):Array {
			return as3Query.sibling(document.firstChild(a));
		});
	}

	public function contents( filter:String = null ):as3Query {
		return mapAndPush(filter, function(a:DisplayObject, ...args):DisplayObject {
			return a.root;
		});
	}

	private function mapAndPush( a:String, fn:Function ):as3Query {
		var ret:Array = as3Query.map( this, fn );
		if ( a )
			ret = as3Query.multiFilter(a, ret.getArray());
		return pushStack(as3Query.unique(ret));
	}

	public function append(... args):as3Query {
		return documentManip(args, true, 1, function(a:DisplayObject):void{
			this.addChild( a );
		});
	}

	public function prepend(... args):as3Query {
		return documentManip(args, true, -1, function(a:DisplayObject):void{
			this.addChildAt( a, 0 );
		});
	}
	
	public function before(... args):as3Query {
		return this.documentManip(args, false, 1, function(a:DisplayObject):void{
			this.parent.addChildAt( a, this.parent.getChildIndex( this ) );
		});
	}

	public function after(... args):as3Query {
		return this.documentManip(args, false, -1, function(a:DisplayObject):void{
			this.parent.addChildAt( a, this.parent.getChildIndex( this ) + 1 );
		});
	}

	public function end():as3Query {
		return prevObject || as3Query.create([]);
	}

	public function find(t:*):as3Query {
		var data:Array = as3Query.map(this, function(a:DisplayObject, ...args):Array{ return as3Query.find(t,a); });
		return pushStack( /[^+>] [^+>]/.test( t ) || t.indexOf("..") > -1 ?
			as3Query.unique( data ) : data );
	}

	public function clone(events:Boolean = false):as3Query {
		// Do the clone
		var ret:as3Query = map(function(...args):DisplayObject{
			return as3Query.cloneObject(this) as DisplayObject;
		});
		
		if (events === true) {
			var clone:as3Query = ret.find("*").andSelf();

			find("*").andSelf().each(function(i:int, ...args):void {
				var events:Object = as3Query.data(this, "events");
				for ( var type:String in events )
					for ( var handler:Object in events[type] )
						as3QueryEvent.add(clone[i], type, events[type][handler], events[type][handler].data);
			});
		}

		// Return the cloned set
		return ret;
	}

	public function filter(t:Object):as3Query {
		return pushStack(
			as3Query.isFunction( t ) &&
			as3Query.grep(this, function(el:Object, index:int):Object{
				return t.apply(el, [index]);
			}) ||

			as3Query.multiFilter(t.toString(),_array) );
	}

	public function not(t:Object):as3Query {
		return pushStack(
			t is String &&
			as3Query.multiFilter(t as String, _array, true) ||

			as3Query.grep(this, function(a:Object):Boolean {
				return ( t is Array ? as3Query.inArray( a, t as Array ) < 0 : 
				         t is as3Query ? as3Query.inArray( a, t._array ) < 0 : a != t);
			})
		);
	}

	public function add(t:Object):as3Query {
		return pushStack( as3Query.merge(
			get() as Array,
			t is String ?
				as3Query(t).get() as Array :
				t is Array ? t as Array : 
				t is as3Query ? t.get() as Array : [t] )
		);
	}

	public function _is(expr:String):Boolean {
		return expr ? as3Query.multiFilter(expr, _array).length > 0 : false;
	}

	public function hasClass(expr:String):Boolean {
		return _is("." + expr);
	}
	
/*	val: function( val ) {
		if ( val == undefined ) {
			if ( this.length ) {
				var elem = this[0];
			
				// We need to handle select boxes special
				if ( as3Query.nodeName(elem, "select") ) {
					var index = elem.selectedIndex,
						a = [],
						options = elem.options,
						one = elem.type == "select-one";
					
					// Nothing was selected
					if ( index < 0 )
						return null;

					// Loop through all the selected options
					for ( var i = one ? index : 0, max = one ? index + 1 : options.length; i < max; i++ ) {
						var option = options[i];
						if ( option.selected ) {
							// Get the specifc value for the option
							var val = as3Query.browser.msie && !option.attributes["value"].specified ? option.text : option.value;
							
							// We don't need an array for one selects
							if ( one )
								return val;
							
							// Multi-Selects return an array
							a.push(val);
						}
					}
					
					return a;
					
				// Everything else, we just grab the value
				} else
					return this[0].value.replace(/\r/g, "");
			}
		} else
			return this.each(function(){
				if ( val.constructor == Array && /radio|checkbox/.test(this.type) )
					this.checked = (as3Query.inArray(this.value, val) >= 0 ||
						as3Query.inArray(this.name, val) >= 0);
				else if ( as3Query.nodeName(this, "select") ) {
					var tmp = val.constructor == Array ? val : [val];

					as3Query("option", this).each(function(){
						this.selected = (as3Query.inArray(this.value, tmp) >= 0 ||
						as3Query.inArray(this.text, tmp) >= 0);
					});

					if ( !tmp.length )
						this.selectedIndex = -1;
				} else
					this.value = val;
			});
	},
*/
	public function html( val:Object = null ):Object {
		return val == null ?
			( this.length && this[0].hasOwnProperty("htmlText") ? this[0].htmlText : null ) :
			each(function(index:int, val:Object):void{
				if( this.hasOwnProperty("htmlText") ) {
					this["htmlText"] = String(val);
				}
			});
	}

	public function replaceWith( val:Object ):as3Query {
		return after( val ).remove();
	}

	public function slice(...args):as3Query {
		return pushStack( _array.slice.apply( this, args ) );
	}

	public function map(fn:Function):as3Query {
		return pushStack(as3Query.map( this, function(elem:Object,i:int):Object{
			return fn.call( elem, i, elem );
		}));
	}

	public function andSelf():as3Query {
		return add( prevObject );
	}

	public function documentManip(args:Array, table:Boolean, dir:int, fn:Function):as3Query {
		var clone:Boolean = length > 1, a:Array; 

		return each(function():void{
			if ( !a ) {
				a = as3Query.clean(args);
				if ( dir < 0 )
					a.reverse();
			}

			var obj:as3Query = this;

			as3Query.each( a, function():void{
				fn.apply( obj, [ clone ? as3Query.cloneObject(this) : this ] );
			});
		}) as as3Query;
	}

	static private function cloneObject(source:Object):Object {
		var cls:Class = getDefinitionByName(getQualifiedClassName(source)) as Class;
		if(cls) {
			try {
				return new cls();
			}
			catch(e:*) {
			}
		}
		return null;
	}

	public function extend( ...args ):Object {
		return as3Query.extend.apply( null, args );
	}

	public static function extend( ...args ):Object {
		// copy reference to target object
		var target:Object = args[0], a:int = 1, al:int = args.length, deep:Boolean = false;

		// Handle a deep copy situation
		if ( target is Boolean ) {
			deep = Boolean(target);
			target = args[1] || {};
		}

		var prop:Object;

		for ( ; a < al; a++ )
			// Only deal with non-null/undefined values
			if ( (prop = args[a]) != null )
				// Extend the base object
				for ( var i:Object in prop ) {
					// Prevent never-ending loop
					if ( target == prop[i] )
						continue;

					// Recurse if we're merging object values
					if ( deep && prop[i] is Object && target[i] )
						as3Query.extend( target[i], prop[i] );

					// Don't bring in undefined values
					else if ( prop[i] != undefined )
						target[i] = prop[i];
				}

		// Return the modified object
		return target;
	}

	private static var expando:String = "as3Query" + (new Date()).getTime();

	static public function isFunction(fn:Object):Boolean
	{
		return fn is Function;
	}

	// check if an element is in a XML document
	static public function isXMLDoc(elem:Object):Boolean
	{
		return elem is XML;
	}

	static public function nodeName( elem:DisplayObject, name:String ):Boolean {
		return document.nodeNameCmp( elem, name );
	}

	static private var cache:Dictionary = new Dictionary( false );

	static internal function data( elem:Object, name:String = "", data:Object = null ):Object {
		// Only generate the data cache if we're
		// trying to access or manipulate it
		if ( name != "" && !cache[ elem ] )
			cache[ elem ] = {};
		
		// Prevent overriding the named cache with undefined values
		if ( data != null )
			as3Query.cache[ elem ][ name ] = data;
		
		// Return the named cache data
		return cache[ elem ][ name ];
	}

	static internal function removeData( elem:Object, name:String = "" ):void {
		// If we want to remove a specific section of the element's data
		if ( name != "" ) {
			if ( as3Query.cache[ elem ] ) {
				// Remove the section of cache data
				delete as3Query.cache[ elem ][ name ];

				// If we've removed all the data, remove the element's cache
				name = "";
				for ( name in as3Query.cache[ elem ] ) break;
				if ( name != "" )
					as3Query.removeData( elem );
			}

		// Otherwise, we want to remove all of the element's data
		} else {
			// Clean up the element expando
			delete as3Query.cache[ elem ];
		}
	}

	// args is for internal usage only
	static public function each( obj:Object, fn:Function, args:Object = null ):Object {
		var i:int, ol:int;
		if ( args ) {
			if( !obj.hasOwnProperty("length") )
				for ( var id:* in obj )
					fn.apply(obj[id], args);
			else
				for ( i = 0, ol = obj.length; i < ol; i++ )
					if(fn.apply(obj[i], args) === false) break;

		// A special, fast, case for the most common use of each
		} else {
			if ( !obj.hasOwnProperty("length") )
				for(id in obj)
					fn.call(obj[id], id, obj[id]);
			else {
				var val:Object;
				for ( i = 0, ol = obj.length, val = obj[0]; 
					i < ol && fn.call(val,i,val) !== false; val = obj[++i]){}
			}
		}

		return obj;
	}
	
	static public function prop(elem:Object, value:Object, type:Object, index:int, prop:Object):Object {
		// Handle executable functions
		if(as3Query.isFunction(value))
			value = value.call(elem, [index]);

		// Handle passing in a number to a CSS property
		return value;
	}

/*	className: {
		// internal only, use addClass("class")
		add: function( elem, c ){
			as3Query.each( (c || "").split(/\s+/), function(i, cur){
				if ( !as3Query.className.has( elem.className, cur ) )
					elem.className += ( elem.className ? " " : "" ) + cur;
			});
		},

		// internal only, use removeClass("class")
		remove: function( elem, c ){
			elem.className = c != undefined ?
				as3Query.grep( elem.className.split(/\s+/), function(cur){
					return !as3Query.className.has( c, cur );	
				}).join(" ") : "";
		},

		// internal only, use is(".class")
		has: function( t, c ) {
			return as3Query.inArray( c, (t.className || t).toString().split(/\s+/) ) > -1;
		}
	},

	swap: function(e,o,f) {
		for ( var i in o ) {
			e.style["old"+i] = e.style[i];
			e.style[i] = o[i];
		}
		f.apply( e, [] );
		for ( var i in o )
			e.style[i] = e.style["old"+i];
	},*/

	static public function css(e:DisplayObject, p:String, value:Object = null):Object {
		if ( value != null ) {
			if ( e is TextField ) {
				var tf:TextField = TextField(e);
				tf.styleSheet = tf.styleSheet || new StyleSheet();
				if(value is String)
					tf.styleSheet.parseCSS(value.toString());
				else
					tf.styleSheet.setStyle( p, as3Query.extend(as3Query.curCSS( e, p) || {}, value) );
			}
		}

		return as3Query.curCSS( e, p );
	}

	static private function curCSS(elem:DisplayObject, prop:String, force:Boolean = false):Object {
		if (elem is TextField) {
			var tf:TextField = TextField(elem);
			return tf.styleSheet ? tf.styleSheet.getStyle(prop) : null;
		}
		return null;
	}

	static public function clean(a:Object):Array {
		var r:Array = [];

		as3Query.each( a, function(i:int,arg:Object):void{
			if ( !arg ) return;

			if ( arg is Number )
				arg = arg.toString();
			
			// Convert html string into XMLList
			if ( arg is String ) {
				try {
					arg  = XMLList(arg.toString());
				} catch (e:*) {
					throw new Error("XML Parse error!!!");
				}
			}

			// Convert XML into DisplayObjects
			if ( arg is XML || arg is XMLList ) {
				var fn:Function = function(xml:XML):DisplayObject {
					try {
						var cls:Class = getDefinitionByName( xml.localName() ) as Class;
						var ret:DisplayObject = new cls() as DisplayObject;

						if ( ret ) {
							var obj:Object = {};
							for each ( var attr:XML in xml.attributes() ) {
								obj[attr.localName()] = attr.toString();
							}
							$(ret).attr( obj );
						}

						if ( ret is DisplayObjectContainer ) {
							var parent:DisplayObjectContainer = ret as DisplayObjectContainer;
							for each(var child:XML in xml.children()) {
								var d:DisplayObject = arguments.callee(child);
								if ( d )
									parent.addChild( d );
							}
						}

						return ret;
					} catch( e:* ) {
						trace(e.toString());
					}
					return null;
				};

				var list:XMLList = arg is XML ? XMLList(arg) : arg as XMLList;
				arg = [];
				for each(var x:XML in list) {
					var d:DisplayObject = fn(x);
					if ( d ) {
						arg.push( d );
					}
				}
			}

			if ( arg )
				if( !(arg is Array) )
					r.push( arg );
				else
					r = as3Query.merge( r, as3Query.makeArray( arg ) );
		});

		return r;
	}

	static public function attr( elem:Object, name:String, value:Object = null ):Object {
		// special case "id"
		if( elem is DisplayObject && name == "id" )
			if( value != null && value is String ) {
				//document.registerId( value.toString(), DisplayObject(elem) );
				as3Query.data( elem, "id", value );
				return value;
			}
			else
				return as3Query.data( elem, "id" );

		if( !elem.hasOwnProperty( name ) )
			return null;

		if( value != null )
			elem[name] = value;

		return elem[name];
	}

	static public function trim(t:String):String {
		return t.replace(/^\s+|\s+$/g, "");
	}

	static public function makeArray( a:Object ):Array {
		var r:Array = [];

		// Need to use typeof to fight Safari childNodes crashes
		if( a is Array )
			r = (a as Array).slice();
		else
			for ( var i:int = 0, al:int = a.length; i < al; i++ )
				r.push( a[i] );

		return r;
	}

	static public function inArray( b:Object, a:Array ):int {
		for ( var i:int = 0, al:int = a.length; i < al; i++ )
			if ( a[i] == b )
				return i;
		return -1;
	}

	static public function merge(first:Array, second:Array):Array {
		first.push.apply(first, second);
		return first;
	}

	static public function unique(first:Array):Array {
		var r:Array = [], done:Dictionary = new Dictionary();

		for ( var i:int = 0, fl:int = first.length; i < fl; i++ ) {
			if ( !done[first[i]] ) {
				done[first[i]] = true;
				r.push(first[i]);
			}
		}

		return r;
	}

	static public function grep(elems:Object, fn:Function, inv:Boolean = false):Array {
		var result:Array = [];

		// Go through the array, only saving the items
		// that pass the validator function
		for ( var i:int = 0, el:int = elems.length; i < el; i++ )
			if ( !inv && fn(elems[i],i) || inv && !fn(elems[i],i) )
				result.push( elems[i] );

		return result;
	}

	static public function map(elems:Object, fn:Function):Array {
		var result:Array = [];

		// Go through the array, translating each of the items to their
		// new value (or values).
		for ( var i:int = 0, el:int = elems.length; i < el; i++ ) {
			var val:Object = fn(elems[i],i);

			if ( val !== null  ) {
				if ( !(val is Array) ) val = [val];
				result = result.concat( val as Array );
			}
		}

		return result;
	}

	public function appendTo(... args):as3Query {
		return argCall("append", args);
	}

	public function prependTo(... args):as3Query {
		return argCall("prepend", args);
	}

	public function insertBefore(... args):as3Query {
		return argCall("before", args);
	}

	public function insertAfter(... args):as3Query {
		return argCall("after", args);
	}

	public function replaceAll(... args):as3Query {
		return argCall("replaceWith", args);
	}

	private function argCall(n:String, args:Array):as3Query
	{
		return each(function():void{
			for ( var i:int = 0, al:int = args.length; i < al; i++)
				(as3Query.create(args[i]))[n]( this );
		});
	}

	public function removeAttr( key:String ):as3Query {
		return each( function( a:Object, v:Object = null ):void {
			delete this[ key ];
		});
	}

	/* !!! AS has no class
	addClass: function(c){
		jQuery.className.add(this,c);
	},
	removeClass: function(c){
		jQuery.className.remove(this,c);
	},
	toggleClass: function( c ){
		jQuery.className[ jQuery.className.has(this,c) ? "remove" : "add" ](this, c);
	},*/

	public function remove( a:String = null ):as3Query {
		return each( function( ...args ):void {
			if ( !a || as3Query.filter( a, [this] ).r.length ) {
				as3Query.removeData( this );
				this.parent.removeChild( this );
			}
		});
	}

	public function empty():as3Query {
		return each( function( ...args ):void {
			// Clean up the cache
			as3Query.create("*", this).each(function(...args):void{ as3Query.removeData(this); });

			var c:DisplayObjectContainer = this as DisplayObjectContainer;
			while ( c && c.numChildren )
				c.removeChildAt(0);
		});
	}

	//--------------------------------------------------------------------------
	//
	// selector
	//
	//--------------------------------------------------------------------------

	static private const chars:String = "(?:[\\w*_-]|\\\\.)";
	static private const quickChild:RegExp = new RegExp("^>\\s*(" + chars + "+)");
	static private const quickID:RegExp = new RegExp("^(" + chars + "+)(#)(" + chars + "+)");
	static private const quickClass:RegExp = new RegExp("^([#.]?)(" + chars + "*)");

	static private const expr:Object = {
		"":  function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return m[2]=='*'||document.nodeNameCmp(a,m[2])},
		"#": function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return as3Query.data(a, "id")==m[2]},
		":": {
			// Position Checks
			lt:    function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i<m[3]-0},
			gt:    function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i>m[3]-0},
			nth:   function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return m[3]-0==i},
			eq:    function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return m[3]-0==i},
			first: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i==0},
			last:  function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i==r.length-1},
			even:  function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i%2==0},
			odd:   function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return i%2==1},

			// Child Checks
			"first-child": function(a:DisplayObject, ...args):Boolean{return document.firstChild(a.parent)==a},
			"last-child":  function(a:DisplayObject, ...args):Boolean{return document.lastChild(a.parent)==a},
			"only-child":  function(a:DisplayObject, ...args):Boolean{return a.parent.numChildren == 1},

			// Parent Checks
			parent: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return !!document.firstChild(a)},
			empty:  function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return !document.firstChild(a)},
			root:   function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return !a.parent},

			// Text Check
			contains: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return a.hasOwnProperty("text") && a["text"].toString().indexOf(m[3])>=0},

			// Visibility
			visible: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return a.visible},
			hidden:  function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return !a.visible},

/*			// Form attributes
			enabled: function(a:DisplayObject,i:int){return !a.disabled},
			disabled: function(a:DisplayObject,i:int){return a.disabled},
			checked: function(a:DisplayObject,i:int){return a.checked},
			selected: function(a:DisplayObject,i:int){return a.selected||as3Query.attr(a,'selected')},
*/
			// Form elements
			text: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return document.nodeNameCmp(a, "TextField")},
/*			radio: function(a:DisplayObject,i:int){return 'radio'==a.type},
			checkbox: function(a:DisplayObject,i:int){return 'checkbox'==a.type},
			file: function(a:DisplayObject,i:int){return 'file'==a.type},
			password: function(a:DisplayObject,i:int){return 'password'==a.type},
			submit: function(a:DisplayObject,i:int){return 'submit'==a.type},
			image: function(a:DisplayObject,i:int){return 'image'==a.type},
			reset: function(a:DisplayObject,i:int){return 'reset'==a.type},
			button: '"button"==a.type||as3Query.nodeName(a,"button")',
			input: function(a:DisplayObject,i:int){return (/input|select|textarea|button/i).test(a.nodeName)},
*/
			// :has()
			has: function(a:DisplayObject,i:int, m:Array, r:Array):Boolean{return as3Query.find(m[3],a).length != 0},

			// :header
			header: function(...args):Boolean{return false}

			// :animated
			//animated: function(a:DisplayObject,...args):Boolean{return as3Query.grep(as3Query.timers,function(fn,...args){return a==fn.elem;}).length}*/
		}
	};
	
	// The regular expressions that power the parsing engine
	static private const parse:Array = [
		// Match: [@value='test'], [@foo]
		/^(\[) *@?([\w-]+) *([!*$^~=]*) *('?"?)(.*?)\4 *\]/,

		// Match: :contains('foo')
		/^(:)([\w-]+)\("?'?(.*?(\(.*?\))?[^(]*?)"?'?\)/,

		// Match: :even, :last-chlid, #id, .class
		new RegExp("^([:.#]*)(" + chars + "+)")
	];

	static private function multiFilter( expr:String, elems:Array, not:Boolean = false ):Array {
		var old:Object, cur:Array = [];

		while ( expr && expr != old ) {
			old = expr;
			var f:Object = as3Query.filter( expr, elems, not );
			expr = f.t.replace(/^\s*,\s*/, "" );
			cur = not ? elems = f.r : as3Query.merge( cur, f.r );
		}

		return cur;
	}

	static public function find( t:String, context:DisplayObject = null ):Array {
		// Set the correct context (if none is provided)
		context = context || DefaultStage.instance.stage;

		// Initialize the search
		var ret:Array = [context], done:Array = [], last:String;

		// Continue while a selector expression exists, and while
		// we're no longer looping upon ourselves
		while ( t && last != t ) {
			var r:Array = [];
			last = t;

			t = as3Query.trim(t);

			var foundToken:Boolean = false;

			// An attempt at speeding up child selectors that
			// point to a specific element tag
			var re:RegExp = quickChild;
			var m:Array = re.exec(t);

			if ( m ) {
				var nodeName:String = m[1].toUpperCase();

				// Perform our own iteration and filter
				for ( var i:int = 0; ret[i]; i++ )
					for ( var c:DisplayObject = document.firstChild(ret[i]); c; c = document.nextSibling(c) )
						if ( nodeName == "*" || document.nodeNameCmp(c, nodeName) )
							r.push( c );

				ret = r;
				t = t.replace( re, "" );
				if ( t.indexOf(" ") == 0 ) continue;
				foundToken = true;
			} else {
				re = /^([>+~])\s*(\w*)/i;

				if ( (m = re.exec(t)) != null ) {
					r = [];
					nodeName = m[2];

					var merge:Dictionary = new Dictionary();
					var m1:String = m[1];

					for ( var j:int = 0, rl:int = ret.length; j < rl; j++ ) {
						var n:DisplayObject = m1 == "~" || m1 == "+" ? document.nextSibling(ret[j]) : document.firstChild(ret[j]);
						for ( ; n; n = document.nextSibling(n) ){
							if ( m1 == "~" && merge[n] ) break;

							if (!nodeName || document.nodeNameCmp(n, nodeName) ) {
								if ( m1 == "~" ) merge[n] = true;
								r.push( n );
							}

							if ( m1 == "+" ) break;
						}
					}

					ret = r;

					// And remove the token
					t = as3Query.trim( t.replace( re, "" ) );
					foundToken = true;
				}
			}

			// See if there's still an expression, and that we haven't already
			// matched a token
			if ( t && !foundToken ) {
				// Handle multiple expressions
				if ( !t.indexOf(",") ) {
					// Clean the result set
					if ( context == ret[0] ) ret.shift();

					// Merge the result sets
					done = as3Query.merge( done, ret );

					// Reset the context
					r = ret = [context];

					// Touch up the selector string
					t = " " + t.substr(1,t.length);

				} else {
					// Optimize for the case nodeName#idName
					var re2:RegExp = quickID;
					m = re2.exec(t);
					
					// Re-organize the results, so that they're consistent
					if ( m ) {
					   m = [ 0, m[2], m[3], m[1] ];

					} else {
						// Otherwise, do a traditional filter check for
						// ID, class, and element selectors
						re2 = quickClass;
						m = re2.exec(t);
					}

					m[2] = m[2].replace(/\\/g, "");

					var elem:DisplayObject = ret[ret.length-1];

					// Try to do a global search by ID, where we can
					if ( m[1] == "#" ) {//&& elem && elem.getElementById && !as3Query.isXMLDoc(elem) ) {
						// Optimization for HTML document case
						var oid:DisplayObject = document.getElementById(m[2], elem);
						
						// Do a quick check for node name (where applicable) so
						// that div#foo searches will be really fast
						ret = r = oid && (!m[3] || document.nodeNameCmp(oid, m[3])) ? [oid] : [];
					} else {
						// We need to find all descendant elements
						for ( i = 0; ret[i]; i++ ) {
							// Grab the tag name being searched for
							var tag:String = m[1] == "#" && m[3] ? m[3] : m[1] != "" || m[0] == "" ? "*" : m[2];

							r = as3Query.merge( r, document.getElementsByTagName( tag, ret[i] ));
						}

						// It's faster to filter by class and be done with it
						if ( m[1] == "." )
							r = as3Query.classFilter( r, m[2] );

						// Same with ID filtering
						if ( m[1] == "#" ) {
							var tmp:Array = [];

							// Try to find the element with the ID
							for ( i = 0; r[i]; i++ )
								if ( r[i].getAttribute("id") == m[2] ) {
									tmp = [ r[i] ];
									break;
								}

							r = tmp;
						}

						ret = r;
					}

					t = t.replace( re2, "" );
				}

			}

			// If a selector string still exists
			if ( t ) {
				// Attempt to filter it
				var val:Object = as3Query.filter(t,r);
				ret = r = val.r;
				t = as3Query.trim(val.t);
			}
		}

		// An error occurred with the selector;
		// just return an empty set instead
		if ( t )
			ret = [];

		// Remove the root context
		if ( ret && context == ret[0] )
			ret.shift();

		// And combine the results
		done = as3Query.merge( done, ret );

		return done;
	}

	static public function classFilter(r:Array,m:String,not:Boolean = false):Array {
		m = " " + m + " ";
		var tmp:Array = [];
		for ( var i:int = 0; r[i]; i++ ) {
			if ( !r[i].hasOwnProperty("className") )
				continue;

			var pass:Boolean = (" " + r[i].className + " ").indexOf( m ) >= 0;
			if ( !not && pass || not && !pass )
				tmp.push( r[i] );
		}
		return tmp;
	}

	static public function filter(t:String,r:Array,not:Boolean = false):Object {
		var last:Object;

		// Look for common filter expressions
		while ( t  && t != last ) {
			last = t;

			var p:Object = as3Query.parse, m:Array;

			for ( var i:int = 0; p[i]; i++ ) {
				m = p[i].exec( t );

				if ( m ) {
					// Remove what we just matched
					t = t.substring( m[0].length );

					m[2] = m[2].replace(/\\/g, "");
					break;
				}
			}

			if ( !m )
				break;

			// :not() is a special case that can be optimized by
			// keeping it out of the expression list
			if ( m[1] == ":" && m[2] == "not" )
				r = as3Query.filter(m[3], r, true).r;

			// We can get a big speed boost by filtering by class here
			else if ( m[1] == "." )
				r = as3Query.classFilter(r, m[2], not);

			else if ( m[1] == "[" ) {
				var tmp:Array = [], type:String = m[3];
				
				var rl:int;
				for ( i = 0, rl = r.length; i < rl; i++ ) {
					var a:Object = r[i], z:Object = a.hasOwnProperty( m[2] ) ? a[ m[2] ] : null;
					
					if ( z == null || /href|src|selected/.test(m[2]) )
						z = as3Query.attr(a,m[2]) || '';

					if ( int(type == "" && !!z ||
						 type == "=" && z == m[5] ||
						 type == "!=" && z != m[5] ||
						 type == "^=" && z && !z.indexOf(m[5]) ||
						 type == "$=" && z.substr(z.length - m[5].length) == m[5] ||
						 (type == "*=" || type == "~=") && z.indexOf(m[5]) >= 0) ^ int(not) )
							tmp.push( a );
				}
				
				r = tmp;

			// We can get a speed boost by handling nth-child here
			} else if ( m[1] == ":" && m[2] == "nth-child" ) {
				var merge:Dictionary = new Dictionary(), 
					test:Array = /(\d*)n\+?(\d*)/.exec(
						m[3] == "even" ? "2n" : m[3] == "odd" ? "2n+1" :
						!(/\D/).test(m[3]) ? "n+" + m[3] : m[3]),
					first:int = (test[1] || 1) - 0, _last:int = test[2] - 0;
				tmp = [];

				var nodeIndex:Dictionary = new Dictionary();
				for ( i = 0, rl = r.length; i < rl; i++ ) {
					var node:DisplayObject = r[i], parentNode:DisplayObjectContainer = node.parent;

					if ( !merge[parentNode] ) {
						var c:int = 1;

						for ( var ii:int = 0; ii < parentNode.numChildren; ii++) {
							var n:DisplayObject = parentNode.getChildAt(ii);
							nodeIndex[n] = c++;
						}

						merge[parentNode] = true;
					}

					var add:Boolean = false;

					if ( first == 1 ) {
						if ( _last == 0 || nodeIndex[node] == _last )
							add = true;
					} else if ( (nodeIndex[node] + _last) % first == 0 )
						add = true;

					if ( int(add) ^ int(not) )
						tmp.push( node );
				}

				r = tmp;

			// Otherwise, find the expression to execute
			} else {
				var f:Object = as3Query.expr[m[1]];
				if ( f is Object )
					f = as3Query.expr[m[1]][m[2]];

				if(f is Function) {
					// Build a custom macro to enclose it
					var ff:Function = function(a:DisplayObject, i:int):Boolean{return (f as Function)(a, i, m, r)};

					// Execute it against the current filter
					r = as3Query.grep( r, ff, not );
				}
			}
		}

		// Return an array of filtered elements (r)
		// and the modified expression string (t)
		return { r: r, t: t };
	}

	static public function dir( elem:DisplayObject, dir:String ):Array {
		var matched:Array = [];
		var cur:DisplayObject = document.getProperty(elem, dir) as DisplayObject;
		while ( cur && !(cur is Stage) ) {
			matched.push( cur );
			cur = document.getProperty(cur, dir) as DisplayObject;
		}
		return matched;
	}

	static public function nth( cur:DisplayObject, result:Number, dir:String, elem:DisplayObject = null):DisplayObject {
		result = result || 1;
		var num:int = 0;

		for ( ; cur && !(cur is Stage); cur = document.getProperty(cur, dir) as DisplayObject)
			if ( ++num == result )
				break;

		return cur;
	}

	static public function sibling( n:DisplayObject, elem:DisplayObject = null ):Array {
		var r:Array = [];

		for ( ; n; n = document.nextSibling(n) ) {
			if ( !elem || n != elem )
				r.push( n );
		}

		return r;
	}

	//--------------------------------------------------------------------------
	//
	// events
	//
	//--------------------------------------------------------------------------

	public function bind( type:String, data:Object, fn:Object = null ):as3Query {
		return each(function(... args):void{
			as3QueryEvent.add( this, type, (fn || data) as Function, fn && data );
		});
	}

	public function one( type:String, data:Object, fn:Object = null ):as3Query {
		return each(function(... args):void {
			as3QueryEvent.add( this, type, function(event:Event):Object {
				(as3Query.create(this)).unbind(type, arguments.callee);
				return ((fn || data) as Function).apply( this, arguments);
			}, fn && data);
		});
	}

	public function unbind( type:Object = null, fn:Function = null ):as3Query {
		return each(function(... args):void {
			as3QueryEvent.remove( this, type, fn );
		});
	}

	public function trigger( type:String, data:Array = null ):as3Query {
		return this.each(function(...args):void {
			as3QueryEvent.trigger( type, data, this );
		});
	}

	public function triggerHandler( type:String, data:Array = null, fn:Function = null ):Object {
		if ( this[0] )
			return as3QueryEvent.trigger( type, data, this[0], false, fn );
		return null;
	}

/*	toggle: function() {
		// Save reference to arguments for access in closure
		var a = arguments;

		return this.click(function(e) {
			// Figure out which function to execute
			this.lastToggle = 0 == this.lastToggle ? 1 : 0;
			
			// Make sure that clicks stop
			e.preventDefault();
			
			// and execute the function
			return a[this.lastToggle].apply( this, [e] ) || false;
		});
	},
*/

	public function hover(f:Function, g:Function):as3Query {

		// A private function for handling mouse 'hovering'
		function handleHover(e:Event):Object {
			// Execute the right function
			return (e.type == "rollOver" ? f : g).apply(this, [e]);
		}

		// Bind the function to the two event listeners
		return this.bind("rollOver", handleHover).bind("rollOut", handleHover);
	}

	public function focusOut    ( f:Function = null):as3Query { return eventImpl("focusOut", f);}
	public function focusIn     ( f:Function = null):as3Query { return eventImpl("focusIn", f);}
	public function resize      ( f:Function = null):as3Query { return eventImpl("resize", f);}
	public function scroll      ( f:Function = null):as3Query { return eventImpl("scroll", f);}
	public function click       ( f:Function = null):as3Query { return eventImpl("click", f);}
	public function doubleClick ( f:Function = null):as3Query { return eventImpl("doubleClick", f);}
	public function mouseDown   ( f:Function = null):as3Query { return eventImpl("mouseDown", f);}
	public function mouseUp     ( f:Function = null):as3Query { return eventImpl("mouseUp", f);}
	public function mouseMove   ( f:Function = null):as3Query { return eventImpl("mouseMove", f);}
	public function mouseOver   ( f:Function = null):as3Query { return eventImpl("mouseOver", f);}
	public function mouseOut    ( f:Function = null):as3Query { return eventImpl("mouseOut", f);}
	public function keyDown     ( f:Function = null):as3Query { return eventImpl("keyDown", f);}
	public function keyUp       ( f:Function = null):as3Query { return eventImpl("keyUp", f);}
	public function enterFrame  ( f:Function = null):as3Query { return eventImpl("enterFrame", f);}

	// jQuery compatible methods
	public function focus    ( f:Function = null):as3Query { return focusIn(f);}
	public function blur     ( f:Function = null):as3Query { return focusOut(f);}
	public function dblclick ( f:Function = null):as3Query { return doubleClick(f);}
	public function mousedown( f:Function = null):as3Query { return mouseDown(f);}
	public function mouseup  ( f:Function = null):as3Query { return mouseUp(f);}
	public function mousemove( f:Function = null):as3Query { return mouseMove(f);}
	public function mouseover( f:Function = null):as3Query { return mouseOver(f);}
	public function mouseout ( f:Function = null):as3Query { return mouseOut(f);}
	public function keydown  ( f:Function = null):as3Query { return keyDown(f);}
	public function keyup    ( f:Function = null):as3Query { return keyUp(f);}

	private function eventImpl( type:String, f:Function = null):as3Query {
		return f != null ? bind(type, f) : trigger(type);
	}

	//--------------------------------------------------------------------------
	//
	// effects
	//
	//--------------------------------------------------------------------------

	public function addTween(obj:Object):as3Query {
		var tweener:Class = getDefinitionByName("caurina.transitions.Tweener") as Class;
		if(tweener && tweener.addTween is Function) {
			tweener.addTween.call(null, getArray(), obj);
		}
		return this;
	}

	public function show(speed:Number = 0, callback:Function = null):as3Query {
		return speed ?
			animate({
				height: "show", width: "show", alpha: "show"
			}, speed, callback) :
			filter(":hidden").each(function(...args):void{
				this.visible = true;
			}).end();
	}
	
	public function hide(speed:Number = 0, callback:Function = null):as3Query {
		return speed ?
			animate({
				height: "hide", width: "hide", alpha: "hide"
			}, speed, callback) :
			filter(":visible").each(function(...args):void{
				this.visible = false;
			}).end();
	}

	public function toggle( fn:Object = null, fn2:Object = null ):as3Query {
		//return //as3Query.isFunction(fn) && as3Query.isFunction(fn2) ?
			//_toggle( fn, fn2 ) :
		return fn != null ?
				animate({
					height: "toggle", width: "toggle", alpha: "toggle"
				}, fn, fn2) :
			each(function(...args):void{
				as3Query.create(this)[ as3Query.create(this)._is(":hidden") ? "show" : "hide" ]();
			});
	}
	
	public function slideDown(speed:Object,callback:Object = null):as3Query {
		return animate({height: "show"}, speed, callback);
	}
	
	public function slideUp(speed:Object,callback:Object = null):as3Query {
		return animate({height: "hide"}, speed, callback);
	}

	public function slideToggle(speed:Object, callback:Object = null):as3Query {
		return animate({height: "toggle"}, speed, callback);
	}
	
	public function fadeIn(speed:Object, callback:Object = null):as3Query {
		return animate({alpha: "show"}, speed, callback);
	}
	
	public function fadeOut(speed:Object, callback:Object = null):as3Query {
		return animate({alpha: "hide"}, speed, callback);
	}
	
	public function fadeTo(speed:Object, to:Number, callback:Object = null):as3Query {
		return animate({alpha: to}, speed, callback);
	}

	public function animate( prop:Object, speed:Object, easing:Object, callback:Function = null ):as3Query {
		var opt:Object = as3Query.speed(speed, easing, callback);

		return this[ opt.queue === false ? "each" : "queue" ](function(... args):Object {
			opt = as3Query.extend({}, opt);
			var hidden:Boolean = as3Query.create(this)._is(":hidden"), self:DisplayObject = this;
			
			for ( var p:String in prop ) {
				if ( prop[p] == "hide" && hidden || prop[p] == "show" && !hidden )
					return as3Query.isFunction(opt.complete) && opt.complete.apply(this);

				if ( p == "height" || p == "width" ) {
					// Store display property
					opt.display = this.visible;
				}
			}

			opt.curAnim = as3Query.extend({}, prop);
			
			as3Query.each( prop, function(name:String, val:Object):void {
				var e:as3QueryFx = new as3QueryFx( self, opt, name );

				if ( /toggle|show|hide/.test( val.toString() ) )
					e[ val == "toggle" ? hidden ? "show" : "hide" : val ]( prop );
				else {
					var parts:Array = val.toString().match(/^([+-]?)([\d.]+)(.*)$/),
						start:Object = e.cur(true) || 0;

					if ( parts ) {
						var end:Number = parseFloat(parts[2]),
							unit:String = parts[3] || "px";

						// We need to compute starting value
						if ( unit != "px" ) {
							self.style[ name ] = end + unit;
							start = (end / e.cur(true)) * start;
							self.style[ name ] = start + unit;
						}

						// If a +/- token was provided, we're doing a relative animation
						if ( parts[1] )
							end = ((parts[1] == "-" ? -1 : 1) * end) + start;

						e.custom( start, end, unit );
					} else
						e.custom( start, val is Number ? Number(val) : parseFloat(val.toString()), "" );
				}
			});

			// For JS strict compliance
			return true;
		});
	}

	private function queue(type:Object, fn:Object = null):as3Query {
		if ( !fn ) {
			fn = type;
			type = "fx";
		}

		return each(function(... args):void {
			if ( fn is Array )
				as3Query.queue(this, type.toString(), fn as Array);
			else {
				as3Query.queue(this, type.toString()).push( fn );
			
				if ( as3Query.queue(this, type.toString()).length == 1 )
					fn.apply(this);
			}
		});
	}

	public function stop():as3Query {
		var timers:Array = as3Query.timers;

		return each(function(...args):void {
			for ( var i:int = 0; i < timers.length; i++ )
				if ( timers[i].elem == this )
					timers.splice(i--, 1);
		}).dequeue();
	}

	static private function queue( elem:DisplayObject, type:String, array:Array = null ):Array {
		if ( !elem )
			return [];

		var q:Array = as3Query.data( elem, type + "queue" ) as Array;

		if ( !q || array )
			q = as3Query.data( elem, type + "queue", 
				array ? as3Query.makeArray(array) : [] ) as Array;

		return q;
	}

	public function dequeue(type:String = null):as3Query {
		type = type || "fx";

		return each(function(... args):void{
			var q:Array = as3Query.queue(this, type);

			q.shift();

			if ( q.length )
				q[0].apply( this );
		});
	}

	static private function speed(speed:Object, easing:Object, fn:Function):Object {
		var opt:Object = speed && getQualifiedClassName(speed) == "Object" ? speed : {
			complete: fn || fn != null && easing || 
				as3Query.isFunction( speed ) && speed,
			duration: speed,
			easing: fn && easing || easing && !(easing is Function) && easing
		};
		opt.duration = (opt.duration && opt.duration is Number ? 
			opt.duration : 
			{ slow: 600, fast: 200 }[opt.duration]) || 400;

		// Queueing
		opt.old = opt.complete;
		opt.complete = function():void{
			as3Query.create(this).dequeue();
			if ( as3Query.isFunction( opt.old ) )
				opt.old.apply( this );
		};

		return opt;
	}

	static internal const easing:Object = {
		linear: function( p:Number, firstNum:Number, diff:Number, d:Number ):Number {
			return firstNum + diff * p / d;
		},
		swing: function( p:Number, firstNum:Number, diff:Number, d:Number ):Number {
			return ((-Math.cos(p/d*Math.PI)/2) + 0.5) * diff + firstNum;
		},
		easeInSine: function(t:Number, b:Number, c:Number, d:Number):Number {
			return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
		},
		easeOutSine: function(t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sin(t/d * (Math.PI/2)) + b;
		}
	}

	static internal const timers:Array = [];
}
}
