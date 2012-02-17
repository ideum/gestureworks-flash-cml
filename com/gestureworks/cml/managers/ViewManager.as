package  com.gestureworks.cml.managers {
	import flash.display.DisplayObject;
	//import id.core.ApplicationGlobals;
	//import id.core.TouchComponent;
	import flash.display.Sprite;
	
	
	public class ViewManager {
		
		private var w:Number;
		private var h:Number;
		private var id:int;
		public var n:int;
		
		private var box:Number;
		
		private var layout:String;
		private var randomEntryVector:Boolean;
		
		//-- starting values --//
		public var x0:Number;
		public var y0:Number;
		public var r0:Number;
		//----target values ---//
		public var x1:Number;
		public var y1:Number;
		public var r1:Number;
		
		private var amp:Number = 200;
		private var phase:Number = (Math.PI/180)*180;

		public function ViewManager(k:int) {
			id = k;
			init();
			trace(k,id)
		}
		
		private function init():void{
			
			/*layout = ApplicationGlobals.dataManager.data.Template.ocanvasLayout;
			randomEntryVector = ApplicationGlobals.dataManager.data.Template.tween.randomEntryVector  == "true"?true:false;
			w = ApplicationGlobals.application.stage.stageWidth
			h = ApplicationGlobals.application.stage.stageHeight;
			box = 200;
			n =  8; //CollectionViewer.displayNumber*/
		}
		
		/*public function calcPoints():void{
			
			trace("number",n)
			//-- set entry point --//
			
							if(randomEntryVector){
								r0 = 0;
								randomPerimeter();
							}
							else {
								r1 = 0;
								x1 = 0;
								y1 = 0;
							}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
				if (layout == "random"){
					trace("random");
	
						r1 = Math.random()*360;
						x1 = Math.random()*w;
						y1 = Math.random()*h;
							
						trace("values:",x0,y0,r0,x1,y1,r1);
				}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "grid"){
				trace("grid");
				
				var sqrtn:int = Math.round(Math.sqrt(n));
				var sepw:int = box;
				var seph:int = box;
				var gw:Number = sqrtn-1*sepw;
				var gh:Number = sqrtn-1*seph;
				
				for (var j=0; j<sqrtn; j++) {
					for (var i=0; i<sqrtn; i++) {
						var nodenum:Number = (i+1)+(j*sqrtn);
						var x1:Number = sepw*(i) + w/2 - box;
						var y1:Number = seph*(j) + h/2 - box;
						var r1:Number = 0;
					}
				}
				
				trace("values:",x0,y0,r0,x1,y1,r1);
				
			}
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "line"){
			 trace("line");
			 
				var sepw:int = box;
				
					x1 = id*sepw;
					y1 = h/2;
					r1 = 0;
					
					trace("values:",id,x0,y0,r0,x1,y1,r1);
			}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "diagonal"){
				trace("diagonal");
				var sepw:int = box/4;
				var seph:int = box/4;
		
					y1 = id*sepw + 100;
					x1 = id*seph + 100;
					r1 = 0;
					
					trace("values:",id,x0,y0,r0,x1,y1,r1);
			}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "fan"){
				trace("fan");
			
				var div = 180/n;
				var ang:Number = (Math.PI/180)*div;
				var theta:Number = (ang*id + phase);
				
					x1 = amp*Math.cos(theta)+ w/2;
					y1 = amp*Math.sin(theta)+ h/2 + 100;
					r1 = theta*(180/Math.PI);
					
					trace("values:",id,x0,y0,r0,x1,y1,r1);
			}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "pile"){
			 trace("pile");
			 
				var ranx:int = Math.random()*10;
				var rany:Number = Math.random()*10;

				if (this.polaroidArray[i].orientationDir == Polaroid.LANDSCAPE){
					r1 = i*5;
					x1 = w/2//w/4;
					y1 = h/2;
				}
				if (this.polaroidArray[i].orientationDir == Polaroid.PORTRAIT || this.polaroidArray[i].orientationDir == Polaroid.SQUARE) {
					r1 = i*10;
					x1 = w/2;//w*3/4;
					y1 = h/2;
				}
			}
			
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
			
			if (layout == "grid2"){
			
			trace("grid2");
			 
			var box:Number = 200;
			var n:int = objects.length;
			var sqrtn:int = Math.round(Math.sqrt(n));
			var diff:int = n -(sqrtn*sqrtn);
			var div6:Number = n%6;
			var div5:Number = n%5;
			var div4:Number = n%4;
			var div3:Number = n%3;
			var div2:Number = n%2;
			var sepw:int = box;
			var seph:int = box;
			var gw:Number = sqrtn-1*sepw;
			var gh:Number = sqrtn-1*seph;
			var i,j,d,t:int
			var nodenum:Number;
			var _X:Number;
			var _Y:Number;
			var _Z:Number;
			var _R:Number;
			var _YAX:Number;
			
			trace("box size",box, diff);
			
			if(!diff){
				d=sqrtn;
			for (j=0; j<d; j++) {
				for (i=0; i<d; i++) {
					nodenum = (i+1)+(j*d);
					
					_X = sepw*(i) + 0.5*(box - d*box + w);
					_Y = seph*(j) + 0.5*(box - d*box + h);
					_Z = 0;
					_R = 0;
					_YAX = 0;
					addChild(objects[nodenum-1]);
					TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
				}
			}
			}
			else if(diff){	
				trace(div5,div4,div3);
				
				if(div6==0){
					d=6;
					for (j=0; j<(n/d); j++) {
						for (i=0; i<d; i++) {
							nodenum = (i+1)+(j*d);
							
							_X = sepw*(i) + 0.5*(box - d*box + w);
							_Y = seph*(j) + 0.5*(box- (n/d)*box + h);
							_Z = 0;
							_R = 0;
							_YAX = 0;
							addChild(objects[nodenum-1]);
							TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
						}
					}
				}
				else if(div5==0){
					d=5;
					for (j=0; j<(n/d); j++) {
						for (i=0; i<d; i++) {
							nodenum = (i+1)+(j*d);
							
							_X = sepw*(i) + 0.5*(box - d*box + w);
							_Y = seph*(j) + 0.5*(box- (n/d)*box + h);
							_Z = 0;
							_R = 0;
							_YAX = 0;
							addChild(objects[nodenum-1]);
							TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
						}
					}
				}
				else if(div4==0){
					d=4;
					for (j=0; j<(n/d); j++) {
						for (i=0; i<d; i++) {
							nodenum = (i+1)+(j*d);
							
							_X = sepw*(i) + 0.5*(box - d*box + w);
							_Y = seph*(j) + 0.5*(box- (n/d)*box + h);
							_Z = 0;
							_R = 0;
							_YAX = 0;
							addChild(objects[nodenum-1]);
							TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
						}
					}
				}
				else if(div3==0){
					d=3;
					for (j=0; j<(n/d); j++) {
						for (i=0; i<d; i++) {
							nodenum = (i+1)+(j*d);
							_X = sepw*(i) + 0.5*(box - d*box + w);
							_Y = seph*(j) + 0.5*(box- (n/d)*box + h);
							_Z = 0;
							_R = 0;
							_YAX = 0;
							
							addChild(objects[nodenum-1]);
							TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
						}
					}
				}
				else if((div2==0)&&(n<4)){
					d=2;
					for (j=0; j<(n/d); j++) {
						for (i=0; i<d; i++) {
							nodenum = (i+1)+(j*d);
							_X = sepw*(i) + 0.5*(box - d*box + w);
							_Y = seph*(j) + 0.5*(box- (n/d)*box + h);
							_Z = 0;
							_R = 0;
							_YAX = 0;
							
							addChild(objects[nodenum-1]);
							TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
						}
					}
				}
				//----------------------------------------------------------------//
				else if((div5!=0)&&(n>12)){
					d=5;
					 t= Math.floor(n/d);
					trace("remainder",div5,t);
					for (j=0; j<=t; j++) {
						if(j!=t){
							for (i=0; i<d; i++) {
								nodenum = (i+1)+(j*d);
								_X = sepw*(i) + 0.5*(box - d*box + w);
								_Y = seph*(j) + 0.5*(box-  (t+1)*box + h);
								_Z = 0;
								_R = 0;
								_YAX = 0;
								
								addChild(objects[nodenum-1]);
								TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
							}
						}
						if(j==t){
							trace("bottom");
							for (i=0; i<d; i++) {
								nodenum = (i+1)+(j*d);
								_X = sepw*(i) + 0.5*(box - d*box + w + sepw*(d-div5));
								_Y = seph*(j) + 0.5*(box-  (t+1)*box + h);
								_Z = 0;
								_R = 0;
								_YAX = 0;
								
								addChild(objects[nodenum-1]);
								TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
							}
						}
					}
				}
					else if((div4!=0)&&(n<12)){
					d=4;
					t= Math.floor(n/d);
					trace("remainder",div4,t);
					for (j=0; j<=t; j++) {
						if(j!=t){
							for (i=0; i<d; i++) {
								nodenum = (i+1)+(j*d);
								_X = sepw*(i) + 0.5*(box - d*box + w);
								_Y = seph*(j) + 0.5*(box-  (t+1)*box + h);
								_Z = 0;
								_R = 0;
								_YAX = 0;
								
								addChild(objects[nodenum-1]);
								TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
							}
						}
						if(j==t){
							trace("bottom");
							for (i=0; i<d; i++) {
								nodenum = (i+1)+(j*d);
								_X = sepw*(i) + 0.5*(box - d*box + w + sepw*(d-div4));
								_Y = seph*(j) + 0.5*(box-  (t+1)*box + h);
								_Z = 0;
								_R = 0;
								_YAX = 0;
								
								addChild(objects[nodenum-1]);
								TweenLite.to(objects[nodenum-1], speed, {x:_X, y:_Y, rotation:_R, alpha:1});
							}
						}
					}
				}
				//----------------------------------------------------------------//
				
				
			}
			}	
			/////////////////////////////////////////////////////////////
			//---------------------------------------------------------//
			/////////////////////////////////////////////////////////////
		}
		
		private function randomPerimeter():void
		{
			var w = ApplicationGlobals.application.stage.stageWidth;
			var h = ApplicationGlobals.application.stage.stageHeight;
			var X = Math.random()*w;
			var Y = Math.random()*h;
			var xa:Number = (w/h)*Y;
			var xb:Number = (-w/h)*(Y-h);
			var ya:Number = (h/w)*X;
			var yb:Number = (-h/w)*X + h;
			var region:int;
			
			if((xa<X<xb)&&(Y<h/2)){
				region = 4;
			}
			else if((xa<X<xb)&&(Y>h/2)){
			region = 2;
			}
			else if((ya<Y<yb)&&(X<w/2)){
				region = 1;
			}
			else if((ya<Y<yb)&&(X>w/2)){
				region = 3;
			}
			
			if(region==1){
				x0 = 0;
				y0 = Y;
			}
			else if(region==2){
				x0 = X;
				y0 = 0;
			}
			else if(region==3){
				x0 = w;
				y0 = Y;
			}
			else if(region==4){
				x0 = X;
				y0 = h;
			}
		
			
			
		}*/
		//--------------------------------------------//
	}
}
