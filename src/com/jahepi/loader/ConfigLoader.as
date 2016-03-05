package com.jahepi.loader {
	
	import com.jahepi.event.ConfigLoaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ConfigLoader extends EventDispatcher {
		
		private static var PATH:String = "config.xml";
		
		private var loader:URLLoader;
		
		public function ConfigLoader(target:IEventDispatcher = null) {
			super(target);
			this.loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, this.onLoadComplete);	
		}
		
		public function load():void {
			this.loader.load(new URLRequest(PATH));
		}
		
		private function onLoadComplete(e:Event):void {
			
			var config:Config = new Config();
			
			var xml:XML = XML(e.target.data);
			
			for each (var variable:XML in xml..variable) {
				config.setVariable(variable.@name, variable.toString());
			}
			
			for each (var keymapper:XML in xml..key) {
				config.setKey(keymapper.toString(), keymapper.@value);
			}
			
			var event:ConfigLoaderEvent = new ConfigLoaderEvent(config, ConfigLoaderEvent.ON_CONFIG_LOAD_COMPLETE);
			this.dispatchEvent(event);
		}
	}
}