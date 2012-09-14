package com.gestureworks.cml.core 
{
	import flash.events.EventDispatcher;
	
	/** 
	 * This class is the registry file for classes that are CML-compatible.
	 * 
	 * <p>You can register you own class for CML loading by placing your class file
	 * in one of the following packages: </p>
	 * 
	 * <p> com.gestureworks.components </p>
	 * <p> com.gestureworks.element </p>
	 * <p> com.gestureworks.kits </p>
	 * <p> com.gestureworks.layouts </p>
	 * 
	 * <p>Then use the following import syntax to register your class:</p>
	 * 
	 * <p>com.gestureworks.cml.element.CustomClass; CustomClass;</p>
	 * 
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * @langversion 3.0
	 *
	 * @see com.gestureworks.cml.core.CML_AIR
	 */		
	public class CML_CORE extends EventDispatcher
	{
		// searchable packages
		protected static var CML_CORE_PACKAGES:Array = 
		[
			"",
			"com.gestureworks.cml.components.",		
			"com.gestureworks.cml.element.", 
			"com.gestureworks.cml.kits.",
			"com.gestureworks.cml.layouts."
		]		
	}
	
	import com.gestureworks.components.CMLDisplay; CMLDisplay;	
	
	/////////////////////
	//  COMPONENTS   
	/////////////////////	
	import com.gestureworks.cml.components.MediaViewer; MediaViewer;
	import com.gestureworks.cml.components.NodeListViewer; NodeListViewer;
	import com.gestureworks.cml.components.CollectionViewer; CollectionViewer;	
	import com.gestureworks.cml.components.MP3Player; MP3Player;	
	import com.gestureworks.cml.components.VideoViewer; VideoViewer;	
	import com.gestureworks.cml.components.ImageViewer; ImageViewer;
	import com.gestureworks.cml.components.AlbumViewer; AlbumViewer;
	import com.gestureworks.cml.components.NodeMapViewer; NodeMapViewer;
	import com.gestureworks.cml.components.MaskImageViewer; MaskImageViewer;
	import com.gestureworks.cml.components.PanoramicViewer; PanoramicViewer;
	import com.gestureworks.cml.components.GigaPixelViewer; GigaPixelViewer;
	import com.gestureworks.cml.components.MP3Player; MP3Player;
	import com.gestureworks.cml.components.Component; Component;	
	
	
	
	/////////////////////
	//  ELEMENTS   
	/////////////////////
	import com.gestureworks.cml.element.Include; Include;			
	import com.gestureworks.cml.element.Container; Container;
	import com.gestureworks.cml.element.Menu; Menu;		
	import com.gestureworks.cml.element.View; View;
	import com.gestureworks.cml.element.Stack; Stack;	
	import com.gestureworks.cml.element.TLF; TLF;	
	import com.gestureworks.cml.element.GestureList; GestureList;		
	import com.gestureworks.cml.element.GraphicElement; GraphicElement;	
	import com.gestureworks.cml.element.ImageElement; ImageElement;
	import com.gestureworks.cml.element.ImageSlideshow; ImageSlideshow;
	import com.gestureworks.cml.element.ImageList; ImageList;
	import com.gestureworks.cml.element.ImageSequence; ImageSequence;
	import com.gestureworks.cml.element.SWCElement; SWCElement;	
	import com.gestureworks.cml.element.SWFElement; SWFElement;
	import com.gestureworks.cml.element.TextElement; TextElement;
	import com.gestureworks.cml.element.MediaElement; MediaElement;	
	import com.gestureworks.cml.element.VideoElement; VideoElement;	
	import com.gestureworks.cml.element.TouchContainer; TouchContainer;
	import com.gestureworks.cml.element.ButtonElement; ButtonElement;		
	import com.gestureworks.cml.element.Slider; Slider;		
	import com.gestureworks.cml.element.FrameElement; FrameElement;
	import com.gestureworks.cml.element.VideoElement; VideoElement;
	import com.gestureworks.cml.element.MP3Element; MP3Element;
	import com.gestureworks.cml.element.Gesture; Gesture;
	import com.gestureworks.cml.element.Group; Group;
	import com.gestureworks.cml.element.Toggle; Toggle;
	import com.gestureworks.cml.element.RadioButtons; RadioButtons;
    import com.gestureworks.cml.element.Switch; Switch;
	import com.gestureworks.cml.element.DatePicker; DatePicker;
	import com.gestureworks.cml.element.ColorPicker; ColorPicker;
	import com.gestureworks.cml.element.TabbedContainer; TabbedContainer;
	import com.gestureworks.cml.element.TabElement; TabElement;
	import com.gestureworks.cml.element.KeyElement; KeyElement;	
	import com.gestureworks.cml.element.TouchKeyboard; TouchKeyboard;
	import com.gestureworks.cml.element.AlbumElement; AlbumElement;
	
	
	/////////////////////
	//  KITS  
	/////////////////////
	import com.gestureworks.cml.kits.LibraryKit; LibraryKit;
	import com.gestureworks.cml.kits.LayoutKit; LayoutKit;		
	import com.gestureworks.cml.kits.ComponentKit; ComponentKit;	
	import com.gestureworks.cml.kits.BackgroundKit; BackgroundKit;		
	import com.gestureworks.cml.kits.StageKit; StageKit;
	
	

	///////////////////////
	//  LAYOUTS 
	//////////////////////
	import com.gestureworks.cml.layouts.RandomLayout; RandomLayout;
	import com.gestureworks.cml.layouts.ListLayout; ListLayout;
	import com.gestureworks.cml.layouts.GridLayout; GridLayout;
	import com.gestureworks.cml.layouts.PointLayout; PointLayout;
	import com.gestureworks.cml.layouts.PileLayout; PileLayout;
	import com.gestureworks.cml.layouts.FanLayout; FanLayout;
}