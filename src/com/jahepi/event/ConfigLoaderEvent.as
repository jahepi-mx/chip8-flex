package com.jahepi.event {
	
	import com.jahepi.loader.Config;
	
	import flash.events.Event;
	
	public class ConfigLoaderEvent extends Event {
		
		public static var ON_CONFIG_LOAD_COMPLETE:String = "OnConfigLoadCompleteEvent";
		private var config:Config;
		
		public function ConfigLoaderEvent(config:Config, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.config = config;
		}
		
		public function getConfig():Config {
			return this.config;
		}
	}
}