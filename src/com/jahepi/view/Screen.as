package com.jahepi.view {
	
	import com.jahepi.chip8.Chip8;
	import com.jahepi.event.Chip8Event;
	import com.jahepi.loader.Config;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	public class Screen extends Sprite {
		
		private var chip8:Chip8;
		private var config:Config;
		private var pixels:Array;
		private var _width:Number;
		private var _height:Number;
		
		[Embed(source='assets/beep.mp3')]
		private var embedSound:Class;
		private var sound:Sound;
		
		public function Screen(chip8:Chip8, config:Config, width:Number, height:Number) {
			super();
			this.chip8 = chip8;
			this.config = config;
			this._width = width;
			this._height = height;
			this.pixels = new Array();
			this.sound = new embedSound();
			this.chip8.addEventListener(Chip8Event.ON_BEEP, this.onBeep);
			this.chip8.addEventListener(Chip8Event.ON_UPDATE_GRAPHICS, this.onDraw);
		}
		
		public function onBeep(evt:Chip8Event):void {
			this.sound.play();
		}
		
		public function onDraw(evt:Chip8Event):void {
			var pixelWidth:Number = this._width / Chip8.DISPLAY_WIDTH;
			var pixelHeight:Number = this._height / Chip8.DISPLAY_HEIGHT;
			var display:ByteArray = chip8.getDisplay();
			for (var i:uint = 0, x:uint = 0, y:uint = 0; i < display.length; i++) {	
				var pixel:Pixel = this.pixels[i];
				if (pixel == null) {
					pixel = new Pixel(x++, y, pixelWidth, pixelHeight);
					if (x == Chip8.DISPLAY_WIDTH) {
						x = 0;
						y++;
					}
					this.pixels[i] = pixel;
					this.addChild(pixel);
				}
				var bit:uint = display[i];
				if (bit == 1) {
					pixel.changePixelColor(this.config.getVariable("screenPixelOnColor"));
				} else {
					pixel.changePixelColor(this.config.getVariable("screenPixelOffColor"));
				}
			}
		}
	}
}