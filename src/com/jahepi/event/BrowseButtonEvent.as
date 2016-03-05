package com.jahepi.event {
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class BrowseButtonEvent extends Event {
		
		public static var ON_LOAD_BYTES:String = "onLoadBytes";
		
		private var data:ByteArray;
		
		public function BrowseButtonEvent(type:String, data:ByteArray, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public function getData():ByteArray {
			return this.data;
		}
	}
}