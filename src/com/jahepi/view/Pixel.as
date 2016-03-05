package com.jahepi.view {
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author jahepi
	 */
	public class Pixel extends Sprite {
		
		private var _width:Number;
		private var _height:Number;
		
		public function Pixel(x:Number, y:Number, width:Number, height:Number) {
			super();
			this._width = width;
			this._height = height;
			this.graphics.beginFill(0x0);
			this.graphics.drawRect(x * this._width, y * this._height, this._width, this._height);
			this.graphics.endFill();
		}
		
		public function changePixelColor(colorParam:uint):void {
			var color:ColorTransform = new ColorTransform();
			color.color = colorParam;
			this.transform.colorTransform = color;
		}
	}
}