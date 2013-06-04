package martian.m4gic.tools
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.*;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import martian.m4gic.data.Ini;
	
	public class Stats extends Sprite
	{	
		private var _xml : XML;
		
		private var _text : TextField;
		private var _style : StyleSheet;
		
		private var _timer : uint;
		private var _fps : uint;
		private var _ms : uint;
		private var _ms_prev : uint;
		private var _mem : Number;
		private var _mem_max : Number;
		
		private var _name : String;
		private var _obj : Object;
		
		private var _graph : BitmapData;
		private var _rectangle : Rectangle;
		
		private var _fps_graph : uint;
		private var _mem_graph : uint;
		private var _mem_max_graph : uint;
		
		private var _theme : Object = new Object(); 
		
		/**
		 * A simple stat module made by Mr doob and pimped by myself
		 * @param theme : an object describing the theme. Possible values are : bg(int), bga(Number), fps(int), ms(int), mem(int), memmax(int), nograph(Boolean)
		 */
		
		public function Stats(theme:Object = null):void
		{
			var ini:Ini = new Ini(theme);
				_theme.bg = ini.integer("bg", 0x000033);
				_theme.bga = ini.number("bga", 1);
				_theme.fps = ini.integer("fps", 0xffff00);
				_theme.ms = ini.integer("fps", 0x00ff00);
				_theme.mem = ini.integer("fps", 0x00ffff);
				_theme.memmax = ini.integer("fps", 0xff0070);
				_theme.obj = ini.integer("obj", 0xff7f00);
				_theme.nograph = ini.boolean("nograph", false);
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			graphics.beginFill(_theme.bg, _theme.bga);
			graphics.drawRect(0, 0, 70, (_theme.nograph ? 50 : 70));
			graphics.endFill();
			
			_mem_max = 0;
			
			_xml = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax><obj>OBJ:</obj></xml>;
			
			_style = new StyleSheet();
			_style.setStyle("xml", {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			_style.setStyle("fps", {color: hex2css(_theme.fps)});
			_style.setStyle("ms", {color: hex2css(_theme.ms)});
			_style.setStyle("mem", {color: hex2css(_theme.mem)});
			_style.setStyle("memMax", {color: hex2css(_theme.memmax)});
			_style.setStyle("obj", {color: hex2css(_theme.obj)});
			
			_text = new TextField();
			_text.width = 70;
			_text.height = 50;
			_text.styleSheet = _style;
			_text.condenseWhite = true;
			_text.selectable = false;
			_text.mouseEnabled = false;
			addChild(_text);
			
			var bitmap : Bitmap = new Bitmap( _graph = new BitmapData(70, 50, false, _theme.bg) );
			bitmap.y = (_theme.nograph ? 50 : 70);
			
			if (!_theme.nograph) { addChild(bitmap); }
			
			_rectangle = new Rectangle( 0, 0, 1, _graph.height );			
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void
		{
			_timer = getTimer();
			
			if( _timer - 1000 > _ms_prev )
			{
				_ms_prev = _timer;
				_mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				_mem_max = _mem_max > _mem ? _mem_max : _mem;
				
				_fps_graph = Math.min( 50, ( _fps / stage.frameRate ) * 50 );
				_mem_graph =  Math.min( 50, Math.sqrt( Math.sqrt( _mem * 5000 ) ) ) - 2;
				_mem_max_graph =  Math.min( 50, Math.sqrt( Math.sqrt( _mem_max * 5000 ) ) ) - 2;
				
				_graph.scroll( 1, 0 );
				
				_graph.fillRect( _rectangle , _theme.bg );
				_graph.setPixel( 0, _graph.height - _fps_graph, _theme.fps);
				_graph.setPixel( 0, _graph.height - ( ( _timer - _ms ) >> 1 ), _theme.ms );
				_graph.setPixel( 0, _graph.height - _mem_graph, _theme.mem);
				_graph.setPixel( 0, _graph.height - _mem_max_graph, _theme.memmax);
				
				_obj = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY))[0];
				_name = getQualifiedClassName(_obj);
				_name = _name.substr(_name.lastIndexOf(":") + 1);
				
				_xml.fps = "FPS: " + _fps + " / " + stage.frameRate;
				_xml.mem = "MEM: " + _mem;
				_xml.memMax = "MAX: " + _mem_max;
				_xml.obj = _name.toUpperCase();
				
				_fps = 0;
			}
			
			_fps++;
			
			_xml.ms = "MS: " + (_timer - _ms);
			_ms = _timer;
			
			_text.htmlText = _xml;
		}
		
		private function onClick(e:MouseEvent):void
		{
			mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
			_xml.fps = "FPS: " + _fps + " / " + stage.frameRate;
			_text.htmlText = _xml;
		}
		
		private function hex2css(color:int):String
		{
			return "#" + color.toString(16);
		}
	}
}