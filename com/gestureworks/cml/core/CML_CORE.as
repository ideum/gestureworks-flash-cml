package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.managers.FontManager;
	/** 
	 * The CML_CORE class is the registry file for classes that are capable of
	 * being load by the CML Parser.
	 * 
	 * <p>You can register your own class for CML loading by placing your class file
	 * in either no package, or one of the following packages: </p>
	 * 
	 * <ul>
	 *	<li>com.gestureworks.buttons</li>
	 *	<li>com.gestureworks.components</li>
	 *	<li>com.gestureworks.element</li>
	 *	<li>com.gestureworks.kits</li>
	 *	<li>com.gestureworks.layouts</li>
	 *	<li>com.gestureworks.menus</li>
	 * </ul>
	 * 
	 * <p>You can then use the following import syntax to register your class:</p>
	 * <code>com.gestureworks.cml.element.CustomClass; CustomClass;</code>
	 *
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CML_AIR
	 */		
	public class CML_CORE
	{
		// searchable packages
		protected static var CML_CORE_PACKAGES:Array = 
		[
			"",
			"com.gestureworks.cml.buttons.",			
			"com.gestureworks.cml.components.",		
			"com.gestureworks.cml.element.",
			"com.gestureworks.cml.filters.",
			"com.gestureworks.cml.kits.",
			"com.gestureworks.cml.layouts.",
			"com.gestureworks.cml.menus.",
			"com.gestureworks.cml.away3d.elements."
		];
		
		// loads default open sans TLF fonts
		public var fontManager:FontManager = new FontManager;
	}
	
	
	/////////////////////
	//  COMPONENTS   
	/////////////////////	
	import com.gestureworks.cml.components.MediaViewer; MediaViewer;
	import com.gestureworks.cml.components.CollectionViewer; CollectionViewer;	
	import com.gestureworks.cml.components.MP3Player; MP3Player;	
	import com.gestureworks.cml.components.VideoViewer; VideoViewer;	
	import com.gestureworks.cml.components.ImageViewer; ImageViewer;
	import com.gestureworks.cml.components.AlbumViewer; AlbumViewer;
	import com.gestureworks.cml.components.PaintViewer; PaintViewer;
	import com.gestureworks.cml.components.MaskImageViewer; MaskImageViewer;
	import com.gestureworks.cml.components.YouTubeViewer; YouTubeViewer;
	import com.gestureworks.cml.components.Component; Component;	
	import com.gestureworks.cml.components.FlickrViewer; FlickrViewer;
	import com.gestureworks.cml.components.ModestMapViewer; ModestMapViewer;
	//import com.gestureworks.cml.components.GigapixelViewer; GigapixelViewer;
	import com.gestureworks.cml.components.LiveVideoViewer; LiveVideoViewer;
	import com.gestureworks.cml.components.SlideshowViewer; SlideshowViewer;
	import com.gestureworks.cml.components.FlipBookViewer; FlipBookViewer;
	
	
	
	/////////////////////
	//  ELEMENTS   
	/////////////////////
	import com.gestureworks.cml.element.Include; Include;			
	import com.gestureworks.cml.element.Container; Container;
	import com.gestureworks.cml.element.View; View;
	import com.gestureworks.cml.element.Stack; Stack;	
	import com.gestureworks.cml.element.TLF; TLF;	
	import com.gestureworks.cml.element.GestureList; GestureList;		
	import com.gestureworks.cml.element.TouchContainer; TouchContainer;
	import com.gestureworks.cml.element.Slider; Slider;		
	import com.gestureworks.cml.element.RadialSlider; RadialSlider;
	import com.gestureworks.cml.element.Gesture; Gesture;
	import com.gestureworks.cml.element.Toggle; Toggle;
    import com.gestureworks.cml.element.Switch; Switch;
	import com.gestureworks.cml.element.DatePicker; DatePicker;
	import com.gestureworks.cml.element.YouTube; YouTube;
	import com.gestureworks.cml.element.Slideshow; Slideshow;
	import com.gestureworks.cml.element.ColorPicker; ColorPicker;
	import com.gestureworks.cml.element.MaskContainer; MaskContainer;
	import com.gestureworks.cml.element.TabbedContainer; TabbedContainer;
	import com.gestureworks.cml.element.TouchKeyboard; TouchKeyboard;
	import com.gestureworks.cml.element.Dial; Dial;
	import com.gestureworks.cml.element.ScrollBar; ScrollBar;
	import com.gestureworks.cml.element.ScrollPane; ScrollPane;
	import com.gestureworks.cml.element.Stepper; Stepper;
	import com.gestureworks.cml.element.Text; Text;
	import com.gestureworks.cml.element.SWC; SWC;
	import com.gestureworks.cml.element.SWF; SWF;	
	import com.gestureworks.cml.element.Frame; Frame;
	import com.gestureworks.cml.element.Video; Video;
	import com.gestureworks.cml.element.MP3; MP3;
	import com.gestureworks.cml.element.Graphic; Graphic;	
	import com.gestureworks.cml.element.Image; Image;
	import com.gestureworks.cml.element.Media; Media;
	import com.gestureworks.cml.element.Album; Album;	
	import com.gestureworks.cml.element.ModestMap; ModestMap;
	import com.gestureworks.cml.element.ModestMapMarker; ModestMapMarker;
<<<<<<< HEAD
	import com.gestureworks.cml.element.Paint; Paint;
	//import com.gestureworks.cml.element.Gigapixel; Gigapixel;
=======
>>>>>>> 29700cc86ce2f9f30d0272abd4ab0a81353da1e5
	import com.gestureworks.cml.element.Tab; Tab;
	import com.gestureworks.cml.element.Key; Key;	
	import com.gestureworks.cml.element.Magnifier; Magnifier;
	import com.gestureworks.cml.element.Flickr; Flickr;
	import com.gestureworks.cml.element.Menu; Menu;
	import com.gestureworks.cml.element.DropDownMenu; DropDownMenu;
	import com.gestureworks.cml.element.OrbMenu; OrbMenu;	
	import com.gestureworks.cml.element.Button; Button;
	import com.gestureworks.cml.element.RadioButtons; RadioButtons;	
	import com.gestureworks.cml.element.Drawer; Drawer;
	import com.gestureworks.cml.element.Dock; Dock;	
	import com.gestureworks.cml.element.MenuAlbum; MenuAlbum;	
	import com.gestureworks.cml.element.ProgressBar; ProgressBar;	
	import com.gestureworks.cml.element.Accordion; Accordion;	
	import com.gestureworks.cml.element.SlideMenu; SlideMenu;
	import com.gestureworks.cml.element.Hotspot; Hotspot;
	import com.gestureworks.cml.element.VideoCamera; VideoCamera;
	
		
	/////////////////////
	//  KITS  
	/////////////////////
	import com.gestureworks.cml.kits.LayoutKit; LayoutKit;		
	import com.gestureworks.cml.kits.BackgroundKit; BackgroundKit;		
	import com.gestureworks.cml.kits.StageKit; StageKit;
	import com.gestureworks.cml.kits.AttractKit; AttractKit;
	
	
	
	///////////////////////
	//  LAYOUTS 
	//////////////////////
	import com.gestureworks.cml.layouts.RandomLayout; RandomLayout;
	import com.gestureworks.cml.layouts.ListLayout; ListLayout;
	import com.gestureworks.cml.layouts.GridLayout; GridLayout;
	import com.gestureworks.cml.layouts.PointLayout; PointLayout;
	import com.gestureworks.cml.layouts.PileLayout; PileLayout;
	import com.gestureworks.cml.layouts.FanLayout; FanLayout;
	

	
	///////////////////////
	//  Filters 
	//////////////////////
	import com.gestureworks.cml.filters.DropShadowFilter; DropShadowFilter;	
	import com.gestureworks.cml.filters.GlowFilter; GlowFilter;	
	import com.gestureworks.cml.filters.BevelFilter; BevelFilter;	
	import com.gestureworks.cml.filters.BlurFilter; BlurFilter;	
	

	
	///////////////////////
	//  TWEENMAX 
	//////////////////////	
	import com.greensock.easing.Back; Back;
	import com.greensock.easing.Bounce; Bounce;
	import com.greensock.easing.Circ; Circ;
	import com.greensock.easing.Cubic; Cubic;
//	import com.greensock.easing.CustomEase; CustomEase;	
	import com.greensock.easing.Elastic; Elastic;
	import com.greensock.easing.Expo; Expo;
	import com.greensock.easing.Linear; Linear;
	import com.greensock.easing.Quad; Quad;
	import com.greensock.easing.Quart; Quart;
	import com.greensock.easing.Quint; Quint;
	//import com.greensock.easing.RoughEase; RoughEase;
	import com.greensock.easing.Sine; Sine;
	import com.greensock.easing.SlowMo; SlowMo;
//	import com.greensock.easing.SteppedEase; SteppedEase;
	import com.greensock.easing.Strong; Strong;

}