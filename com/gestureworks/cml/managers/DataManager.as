package  com.gestureworks.cml.managers 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
		 * THE DATA MANAGER 
		 * FOR EACH VIEW THE DATA MANAGER TELLS THE MENU WHICH ITEMS ARE AVAILABEL TO SHOW
		 * THE MENU CAN THEN UPDATE THE LAYOUT MANAGER WITH A NEW LIST OF ITEMS
		 * IF THERE IS NO MENU THE DATA MANAGER TALKS DIRECLTY TO THE LAYOUT MANAGER
		 * 
		 * THE DATA MANAGER IS THERFOR IN CHARGE OF ORGANIZING TOUCH CONTAINER ITEMS
		 * IT MUST SORT ALPHABETICALLY, NUMERICALLY, ACENDING, DECENDING
		 * IT MUST BE ABLE TO SEARCH PARSED DATA LISTS FOR KEYWORDS
		 * IT MUST BE ABLE TO SEARCH PARSED DATA LISTS FOR
		 * IT MAUS BE ABLE TO ASK FOR MORE PARSED DATA LISTS
		 */
	
	public class DataManager {
		
		//private var w:Number;
		//private var h:Number;
		//private var id:int;
		//public var n:int;
		//private var box:Number;
		//private var layout:String;
		//private var randomEntryVector:Boolean;

		public function DataManager() {
			init();
			//trace(k,id)
		}
		
		private function init():void{
			
			//layout = ApplicationGlobals.dataManager.data.Template.ocanvasLayout;
			//randomEntryVector = ApplicationGlobals.dataManager.data.Template.tween.randomEntryVector  == "true"?true:false;
			//w = ApplicationGlobals.application.stage.stageWidth
			//h = ApplicationGlobals.application.stage.stageHeight;
			//box = 200;
			//n =  8; //CollectionViewer.displayNumber
		}
		
		
		
		//--------------------------------------------//
	}
}
