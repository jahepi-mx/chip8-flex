package {
	
	import com.jahepi.chip8.Chip8;
	import com.jahepi.event.BrowseButtonEvent;
	import com.jahepi.event.Chip8Event;
	import com.jahepi.event.ConfigLoaderEvent;
	import com.jahepi.loader.Config;
	import com.jahepi.loader.ConfigLoader;
	import com.jahepi.view.BrowseButton;
	import com.jahepi.view.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author jahepi
	 */
	[SWF(backgroundColor = "#FFFFFF", frameRate = "60")]
	
	public class Main extends Sprite {
		
		private var chip8:Chip8;
		private var config:Config;
		private var screen:Screen;
		private var browseButton:BrowseButton;
		
		public function Main():void {
			if (this.stage) {
				init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			var configLoader:ConfigLoader = new ConfigLoader();
			configLoader.addEventListener(ConfigLoaderEvent.ON_CONFIG_LOAD_COMPLETE, this.onLoadConfig);
			configLoader.load();
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function onLoadConfig(event:ConfigLoaderEvent):void {
			this.config = event.getConfig();
			this.chip8 = new Chip8();
			this.chip8.init();
			
			// 10% height for browse button of the total screen height
			this.browseButton = new BrowseButton(this.config.getVariable("screenWidth"), (this.config.getVariable("screenHeight") * 0.10));
			this.browseButton.y = this.config.getVariable("screenHeight");
			
			this.stage.stageWidth = this.config.getVariable("screenWidth");
			this.stage.stageHeight = Number(this.config.getVariable("screenHeight")) + this.browseButton.getHeight();
			
			this.screen = new Screen(this.chip8, this.config, this.config.getVariable("screenWidth"), this.config.getVariable("screenHeight"));
			
			this.addChild(this.screen);
			this.addChild(this.browseButton);
			
			this.browseButton.addEventListener(BrowseButtonEvent.ON_LOAD_BYTES, this.onLoadBytes);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
		}
		
		private function onLoadBytes(event:BrowseButtonEvent):void {
			
			if (this.hasEventListener(Event.ENTER_FRAME)) {
				this.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			}
				
			this.chip8.init();
			this.chip8.loadBytesToMemory(event.getData());
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onKeyDown(event:KeyboardEvent):void {
			var key:uint = int(this.config.getKey(event.charCode.toString()));
			this.chip8.setKeyDown(key);
		}
		
		private function onKeyUp(event:KeyboardEvent):void {
			var key:uint = int(this.config.getKey(event.charCode.toString()));
			this.chip8.setKeyUp(key);
		}
		
		private function onEnterFrame(e:Event):void {
			var fps:uint = uint(this.config.getVariable("fps"));
			for (var i:uint = 0; i < fps; i++) {
				this.chip8.run();
			}
		}
	}	
}