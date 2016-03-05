package com.jahepi.view {
	
	import com.jahepi.event.BrowseButtonEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class BrowseButton extends Sprite {
		
		private var _width:Number;
		private var _height:Number;
		private var fileReference:FileReference;
		
		public function BrowseButton(width:Number, height:Number) {
			super();
			this._width = width;
			this._height = height;
			this.buttonMode  = true;
			this.mouseChildren = false;
			this.draw();
			this.fileReference = new FileReference();
			this.fileReference.addEventListener(Event.COMPLETE, this.onCompleteLoadFile);
			this.fileReference.addEventListener(Event.SELECT, this.onSelectFile);
			this.addEventListener(MouseEvent.CLICK, this.onClick);
		}
		
		private function onSelectFile(event:Event):void {
			this.fileReference.load();
		}
		
		private function onCompleteLoadFile(event:Event):void {
			this.dispatchEvent(new BrowseButtonEvent(BrowseButtonEvent.ON_LOAD_BYTES, this.fileReference.data));
		}
		
		private function onClick(event:MouseEvent):void {
			this.fileReference.browse();
		}
		
		private function draw():void {
			
			this.graphics.beginFill(0x00FFFF, 1);
			this.graphics.drawRect(0, 0, this._width, this._height);
			this.graphics.endFill();
			
			var textfield:TextField = new TextField();
			textfield.autoSize = TextFieldAutoSize.LEFT;
			textfield.text = "Cargar Programa CHIP8";
			textfield.selectable = false;
			this.addChild(textfield);
			
			textfield.x = (this.width / 2) - (textfield.width / 2);
			textfield.y = (this.height / 2) - (textfield.height / 2);
		}
		
		public function getHeight():Number {
			return this._height;
		}
	}
}