package com.gestureworks.cml.core 
{
	
	public class CML_CORE extends CML_EXTERNAL 
	{
		// searchable packages
		protected static var CML_CORE_PACKAGES:Array = 
		[
			"com.gestureworks.cml.components.",		
			"com.gestureworks.cml.element.", 
			"com.gestureworks.cml.kits.",
			"com.gestureworks.cml.layouts."
		]		
	}
	
	
	//////////////////
	//  COMPONENTS  // 
	//////////////////

	import com.gestureworks.cml.components.TmpViewer; TmpViewer;			
	
	import com.gestureworks.cml.components.ImageViewer; ImageViewer;
	
	
	import com.gestureworks.cml.components.AlbumViewer; AlbumViewer;
	import com.gestureworks.cml.components.AlbumListViewer; AlbumListViewer;
	import com.gestureworks.cml.components.AlbumViewerNew; AlbumViewerNew;
	import com.gestureworks.cml.components.ListViewer; ListViewer;
	import com.gestureworks.cml.components.NodeViewer; NodeViewer;
	import com.gestureworks.cml.components.NodeMapViewer; NodeMapViewer;
	import com.gestureworks.cml.components.NodeMapViewerNew; NodeMapViewerNew;
	import com.gestureworks.cml.components.GoogleMapsViewer; GoogleMapsViewer;
	import com.gestureworks.cml.components.ModestMapsViewer; ModestMapsViewer;
	//import com.gestureworks.cml.components.PanoramicViewer; PanoramicViewer
	
	import com.gestureworks.cml.components.MaskImageViewer; MaskImageViewer;
	//import com.gestureworks.cml.components.TimelineViewer; TimelineViewer;
	//import com.gestureworks.cml.components.MediaViewer; MediaViewer;
	

	
	
	////////////////
	//  ELEMENTS  // 
	////////////////

	//checked	
	import com.gestureworks.cml.element.Include; Include;			
	import com.gestureworks.cml.element.Component; Component;	
	import com.gestureworks.cml.element.Container; Container;
	import com.gestureworks.cml.element.Menu; Menu;		
	import com.gestureworks.cml.element.View; View;
	import com.gestureworks.cml.element.Stack; Stack;	
	import com.gestureworks.cml.element.TLF; TLF;	
	import com.gestureworks.cml.element.GestureList; GestureList;		
	import com.gestureworks.cml.element.GraphicElement; GraphicElement;	
	import com.gestureworks.cml.element.ImageElement; ImageElement;
	import com.gestureworks.cml.element.SWCElement; SWCElement;	
	import com.gestureworks.cml.element.SWFElement; SWFElement;
	import com.gestureworks.cml.element.TextElement; TextElement;
	import com.gestureworks.cml.element.MediaElement; MediaElement;	
	import com.gestureworks.cml.element.VideoElement; VideoElement;	
	import com.gestureworks.cml.element.TouchContainer; TouchContainer;
	import com.gestureworks.cml.element.ButtonElement; ButtonElement;		
	import com.gestureworks.cml.element.SliderElement; SliderElement;		
	
	
	
	//??
	import com.gestureworks.cml.element.Gesture; Gesture;
	import com.gestureworks.cml.element.Group; Group;		
	import com.gestureworks.cml.element.PreloaderElement; PreloaderElement;
	import com.gestureworks.cml.element.LabelElement; LabelElement;
	
	
	
	/////////////////////
	//  KITS  
	////////////////////
	
	
	//checked
	import com.gestureworks.cml.kits.LibraryKit; LibraryKit;
	import com.gestureworks.cml.kits.ViewKit; ViewKit;
	import com.gestureworks.cml.kits.LayoutKit; LayoutKit;		
	import com.gestureworks.cml.kits.ComponentKit; ComponentKit;		

	
	//??
	import com.gestureworks.cml.kits.BackgroundKit; BackgroundKit;		
	import com.gestureworks.cml.kits.StageKit; StageKit;
	import com.gestureworks.cml.kits.SplashKit; SplashKit;	
	
	

	///////////////////////
	//  LAYOUTS 
	//////////////////////
	
	
	//checked
	import com.gestureworks.cml.layouts.RandomLayout; RandomLayout;
	import com.gestureworks.cml.layouts.ListLayout; ListLayout;
	import com.gestureworks.cml.layouts.StackLayout; StackLayout;
	import com.gestureworks.cml.layouts.GridLayout; GridLayout;

	
}

