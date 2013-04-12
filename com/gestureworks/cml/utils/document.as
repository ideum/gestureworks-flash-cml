package com.gestureworks.cml.utils {

import com.gestureworks.cml.core.CMLObjectList;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.utils.getQualifiedClassName;
import flash.utils.Dictionary;

	public class document 
	{
		static public function firstChild( node:DisplayObject):DisplayObject 
		{
			if ( node is DisplayObjectContainer ) {
				var c:DisplayObjectContainer = DisplayObjectContainer(node);
				return c.numChildren ? c.getChildAt(0) : null;
			}

			return null;
		}

		static public function lastChild( node:DisplayObject):DisplayObject 
		{
			if ( node is DisplayObjectContainer ) {
				var c:DisplayObjectContainer = DisplayObjectContainer(node);
				return c.numChildren ? c.getChildAt(c.numChildren - 1) : null;
			}

			return null;
		}

		static public function previousSibling( node:DisplayObject ):DisplayObject 
		{
			var parent:DisplayObjectContainer = node.parent;
			var index:int = parent.getChildIndex(node);
			return index == 0 ? null : parent.getChildAt(index - 1);
		}

		static public function nextSibling( node:DisplayObject ):DisplayObject 
		{
			var parent:DisplayObjectContainer = node.parent;
			var index:int = parent.getChildIndex(node);
			return index == parent.numChildren - 1 ? null : parent.getChildAt(index + 1);
		}

		static internal function getProperty( node:DisplayObject, prop:String ):Object 
		{
			return /firstChild|nextSibling|previousSibling/.test(prop) ? document[prop]( node ) :
				node.hasOwnProperty(prop) ? node[prop] : null;
		}

		static public function nodeName( node:DisplayObject ):String 
		{
			return getQualifiedClassName( node ).replace(/.*::/, "");
		}

		static public function nodeNameCmp( node:DisplayObject, nodeName:String ):Boolean 
		{
			return document.nodeName( node ).toUpperCase() == nodeName.toUpperCase();
		}
		
		static public function getElementById( id:String, elem:DisplayObject = null ):* 
		{	
			return CMLObjectList.instance.getId(id);
		}
		
		static public function getElementsByTagName( tagName:String, parent:DisplayObject = null, arr:Array = null ):Array 
		{
			parent = parent || DefaultStage.instance.stage;
			arr = arr || [];

			if ( parent is DisplayObjectContainer ) {
				var p:DisplayObjectContainer = DisplayObjectContainer(parent);
				for ( var i:int = 0, al:int = p.numChildren; i < al; i++) {
					var n:DisplayObject = p.getChildAt( i );

					if ( tagName == "*" || nodeNameCmp( n, tagName ) )
						arr.push( n );
					if ( n is DisplayObjectContainer)
						getElementsByTagName( tagName, DisplayObjectContainer(n), arr );
				}
			}

			return arr;
		}

		static public function getElementsByClassName( className:String ):Array 
		{
			if (CMLObjectList.instance.getCSSClass(className))
				return CMLObjectList.instance.getCSSClass(className).getValueArray();
			return null;
		}
		
		
		static public function querySelector( selector:String ):* 
		{
			return $(selector)[0];
		}		

		
		static public function querySelectorAll( selector:* ):Array 
		{
			var ret:Array;
			
			if (selector is String && selector.indexOf("#") == 0 ) {
				selector = selector.substring(1);
				var tmp:Array = CMLObjectList.instance.getValueArray();
				ret = [];
				for (var i:int = 0; i < tmp.length; i++) {
					
					if (tmp[i]["id"] == selector)
						ret.push(tmp[i]);
				}
			}
			
			if (ret) return ret;
			var t:* = $(selector);			
			if ( t && t.length ) return t.getArray();
			return null
		}	
		

		/*
		static private var idList:Dictionary = new Dictionary( false );

		static internal function registerId( id:String, obj:DisplayObject ):void {
			idList[ id ] = obj;
		}

		static internal function unregisterId( id:String ):void {
			if( idList.hasOwnProperty( id ))
				delete idList[ id ];
		}
		
		
		static public function getElementById( id:String, elem:DisplayObject = null ):* 
		{	
			
			
			var ret:DisplayObject = idList[ id ];
			if ( !elem ) 
				return ret;
			else if( elem is DisplayObjectContainer 
				&& DisplayObjectContainer(elem).contains(ret) )
					return ret;
			else
				return null;
		}	
		*/
		
	}	
}
