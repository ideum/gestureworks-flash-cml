package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.managers.FontManager;
	/** 
	 * The CMLCore class is the registry file for classes that are capable of
	 * being loaded by the CML Parser.
	 * 
	 * <p>You can register your own class for CML loading by placing your class file
	 * in either no package, or one of the following packages: </p>
	 * 
	 * <ul>
	 *	<li>com.gestureworks.buttons</li>
	 *	<li>com.gestureworks.components</li>
	 *	<li>com.gestureworks.element</li>
	 *	<li>com.gestureworks.filters</li>
	 *	<li>com.gestureworks.layouts</li>
	 *	<li>com.gestureworks.menus</li>
	 * </ul>
	 * 
	 * <p>Register custom packages by pushing into the CMLCore.packages array.
	 * 
	 * <p>You can then use one of the following procedures to register your class:</p>
	 * <listing version="3.0">com.gestureworks.cml.elements.CustomClass; CustomClass;</listing>
	 * <p>or</p>
	 * <listing version="3.0">CMLCore.classes.push(CMLCustomClass);</listing>
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CML_AIR
	 */		
	public class CMLCore {
		/**
		 * The packages that are searchable by the CML parser. To add you own package, simply push
		 * a new string into this array.
		 */
		public static var packages:Array = [
			"",
			"com.gestureworks.cml.buttons.",			
			"com.gestureworks.cml.components.",		
			"com.gestureworks.cml.elements.",
			"com.gestureworks.cml.filters.",
			"com.gestureworks.cml.layouts.",
			"com.gestureworks.cml.menus.",
			"com.gestureworks.cml.away3d.elements.",
			"com.gestureworks.cml.away3d.geometries.",
			"com.gestureworks.cml.away3d.lights.",			
			"com.gestureworks.cml.away3d.materials.",
			"com.gestureworks.cml.away3d.textures.",
			"com.gestureworks.cml.away3d.layouts."
		];
		
		/**
		 * Custom classes can be registered by either pushing into this array or using the following import 
		 * syntax (note the reference to the class after the import statement):
		 * <listing version="3.0">import com.gestureworks.cml.components.MediaViewer; MediaViewer;</listing> 
		 */		
		public static var classes:Array = [];		
		
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
	import com.gestureworks.cml.components.GigapixelViewer; GigapixelViewer;
	import com.gestureworks.cml.components.LiveVideoViewer; LiveVideoViewer;
	import com.gestureworks.cml.components.SlideshowViewer; SlideshowViewer;
	import com.gestureworks.cml.components.FlipBookViewer; FlipBookViewer;
	
	
	
	/////////////////////
	//  ELEMENTS   
	/////////////////////
	import com.gestureworks.cml.elements.Include; Include;			
	import com.gestureworks.cml.elements.Container; Container;
	import com.gestureworks.cml.elements.View; View;
	import com.gestureworks.cml.elements.Stack; Stack;	
	import com.gestureworks.cml.elements.TLF; TLF;	
	import com.gestureworks.cml.elements.TouchContainer; TouchContainer;
	import com.gestureworks.cml.elements.Slider; Slider;		
	import com.gestureworks.cml.elements.RadialSlider; RadialSlider;
	import com.gestureworks.cml.elements.Toggle; Toggle;
    import com.gestureworks.cml.elements.Switch; Switch;
	import com.gestureworks.cml.elements.DatePicker; DatePicker;
	import com.gestureworks.cml.elements.YouTube; YouTube;
	import com.gestureworks.cml.elements.Slideshow; Slideshow;
	import com.gestureworks.cml.elements.ColorPicker; ColorPicker;
	import com.gestureworks.cml.elements.MaskContainer; MaskContainer;
	import com.gestureworks.cml.elements.TabbedContainer; TabbedContainer;
	import com.gestureworks.cml.elements.TouchKeyboard; TouchKeyboard;
	import com.gestureworks.cml.elements.Dial; Dial;
	import com.gestureworks.cml.elements.ScrollBar; ScrollBar;
	import com.gestureworks.cml.elements.ScrollPane; ScrollPane;
	import com.gestureworks.cml.elements.Stepper; Stepper;
	import com.gestureworks.cml.elements.Text; Text;
	import com.gestureworks.cml.elements.SWC; SWC;
	import com.gestureworks.cml.elements.SWF; SWF;	
	import com.gestureworks.cml.elements.Frame; Frame;
	import com.gestureworks.cml.elements.Video; Video;
	import com.gestureworks.cml.elements.MP3; MP3;
	import com.gestureworks.cml.elements.Graphic; Graphic;	
	import com.gestureworks.cml.elements.Image; Image;
	import com.gestureworks.cml.elements.Media; Media;
	import com.gestureworks.cml.elements.Album; Album;	
	import com.gestureworks.cml.elements.ModestMap; ModestMap;
	import com.gestureworks.cml.elements.ModestMapMarker; ModestMapMarker;
	import com.gestureworks.cml.elements.Paint; Paint;
	import com.gestureworks.cml.elements.Gigapixel; Gigapixel;
	import com.gestureworks.cml.elements.Tab; Tab;
	import com.gestureworks.cml.elements.Key; Key;	
	import com.gestureworks.cml.elements.Magnifier; Magnifier;
	import com.gestureworks.cml.elements.Flickr; Flickr;
	import com.gestureworks.cml.elements.Menu; Menu;
	import com.gestureworks.cml.elements.DropDownMenu; DropDownMenu;
	import com.gestureworks.cml.elements.OrbMenu; OrbMenu;	
	import com.gestureworks.cml.elements.Button; Button;
	import com.gestureworks.cml.elements.RadioButtons; RadioButtons;	
	import com.gestureworks.cml.elements.Drawer; Drawer;
	import com.gestureworks.cml.elements.Dock; Dock;	
	import com.gestureworks.cml.elements.MenuAlbum; MenuAlbum;	
	import com.gestureworks.cml.elements.ProgressBar; ProgressBar;	
	import com.gestureworks.cml.elements.Accordion; Accordion;	
	import com.gestureworks.cml.elements.SlideMenu; SlideMenu;
	import com.gestureworks.cml.elements.Hotspot; Hotspot;
	import com.gestureworks.cml.elements.VideoCamera; VideoCamera;
	import com.gestureworks.cml.elements.Background; Background;		
	import com.gestureworks.cml.elements.Attract; Attract;
	import com.gestureworks.cml.elements.StageKit; StageKit;	
	import com.gestureworks.cml.elements.PopupMenu; PopupMenu;
	import com.gestureworks.cml.elements.SVG; SVG;
	
	
	///////////////////////
	//  LAYOUTS 
	//////////////////////
	import com.gestureworks.cml.layouts.RandomLayout; RandomLayout;
	import com.gestureworks.cml.layouts.ListLayout; ListLayout;
	import com.gestureworks.cml.layouts.GridLayout; GridLayout;
	import com.gestureworks.cml.layouts.PointLayout; PointLayout;
	import com.gestureworks.cml.layouts.PileLayout; PileLayout;
	import com.gestureworks.cml.layouts.FanLayout; FanLayout;
	import com.gestureworks.cml.layouts.LayoutKit; LayoutKit;		
	

	
	///////////////////////
	//  Filters 
	//////////////////////
	import com.gestureworks.cml.filters.DropShadow; DropShadow;	
	import com.gestureworks.cml.filters.Glow; Glow;	
	import com.gestureworks.cml.filters.Bevel; Bevel;	
	import com.gestureworks.cml.filters.Blur; Blur;	
	

	
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