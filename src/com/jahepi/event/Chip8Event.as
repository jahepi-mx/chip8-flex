package com.jahepi.event {
	
	import flash.events.Event;
	
	/**
	 * ...
	 * @author jahepi
	 */
	public class Chip8Event extends Event {
		
		public static var ON_BEEP:String = "onBeep";
		public static var ON_UPDATE_GRAPHICS:String = "onUpdateGraphics";
		
		public function Chip8Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);	
		} 
		
		public override function clone():Event { 
			return new Chip8Event(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("Chip8Event", "type", "bubbles", "cancelable", "eventPhase"); 
		}	
	}
}