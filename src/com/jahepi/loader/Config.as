package com.jahepi.loader {

	public class Config {
		
		private var keys:Object;
		private var variables:Object;
		
		public function Config() {
			this.keys = new Object();
			this.variables = new Object();
		}
		
		public function setKey(key:String, value:*):void {
			this.keys[key] = value;
		}
		
		public function getKey(key:String):* {
			if (this.keys.hasOwnProperty(key)) {
				return this.keys[key];
			}
			
			return null;
		}
		
		public function setVariable(key:String, value:*):void {
			this.variables[key] = value;
		}
		
		public function getVariable(key:String):* {
			if (this.variables.hasOwnProperty(key)) {
				return this.variables[key];
			}
			
			return null;
		}
	}
}