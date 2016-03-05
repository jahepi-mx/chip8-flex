package com.jahepi.chip8 {
	
	import com.jahepi.event.Chip8Event;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class Chip8 extends EventDispatcher {
		
		public static var DISPLAY_WIDTH:uint = 64;
		public static var DISPLAY_HEIGHT:uint = 32;
		
		private var fontSet:Array = [
			0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
			0x20, 0x60, 0x20, 0x20, 0x70, // 1
			0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
			0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
			0x90, 0x90, 0xF0, 0x10, 0x10, // 4
			0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
			0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
			0xF0, 0x10, 0x20, 0x40, 0x40, // 7
			0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
			0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
			0xF0, 0x90, 0xF0, 0x90, 0x90, // A
			0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
			0xF0, 0x80, 0x80, 0x80, 0xF0, // C
			0xE0, 0x90, 0x90, 0x90, 0xE0, // D
			0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
			0xF0, 0x80, 0xF0, 0x80, 0x80  // F
		];
		
		// 4096 slot size, each slot has 1 byte
		private var memory:ByteArray;
		// 64x32 slot size, each slot has 1 byte
		private var display:ByteArray;
		// 16 slot size, each slot has 1 byte
		private var v:ByteArray;
		// 16 slot size, each slot has 2 bytes
		private var stack:Array;
		// 16 slot size, each slot has 1 byte
		private var keyboard:ByteArray;
		// 1 byte long
		private var stackPointer:uint;
		// 2 bytes long
		private var delayTimer:uint;
		// 2 bytes long
		private var soundTimer:uint;
		// 2 bytes long
		private var pc:uint;
		// 2 bytes long (12 bits are usually used)
		private var i:uint;
		
		public function Chip8() {
			
		}
		
		public function init():void {			
			
			this.memory = new ByteArray();
			this.memory.length = 4096;
			
			this.display = new ByteArray();
			this.display.length = (DISPLAY_WIDTH * DISPLAY_HEIGHT);
			
			this.v = new ByteArray();
			this.v.length = 16;
			
			this.keyboard = new ByteArray();
			this.keyboard.length = 16;
			
			this.stack = new Array(16);
			
			this.stackPointer = 0;
			this.pc = 0x0200;
			this.i = 0x0;
			this.soundTimer = 0;
			this.delayTimer = 0;
			
			this.arrayInit(this.stack);
			this.loadFontSet();
			for (var i:uint = 0; i < 0x000F; i++) {
				this.keyboard[i] = 0x0;
			}
		}
		
		public function loadBytesToMemory(byteArray:ByteArray):void {
			var index:uint = 0;
			while (byteArray.bytesAvailable) {
				this.memory[0x0200 + index] = byteArray.readByte();
				index++;
			}
		}
		
		private function loadFontSet():void {
			for (var i:uint = 0; i < 0x0050; i++) {
				this.memory[i] = this.fontSet[i] & 0x00FF;
			}
		}
		
		private function arrayInit(array:Array):void {
			for (var i:uint = 0; i < array.length; i++) {
				array[i] = 0x0;
			}
		}
		
		public function getDisplay():ByteArray {
			return this.display;
		}
		
		public function setKeyDown(key:uint):void {
			if (key <= 0x000F) {
				this.keyboard[key] = 1;
			}
		}
		
		public function setKeyUp(key:uint):void {
			if (key <= 0x000F) {
				this.keyboard[key] = 0;
			}
		}
		
		public function run():void {
			
			var opcode:uint = (this.memory[this.pc] << 8) | this.memory[this.pc + 1];
			//trace("Opcode: " + opcode.toString(16));
			
			var x:uint = ((opcode & 0x0F00) >> 8) & 0x000F;
			var y:uint = ((opcode & 0x00F0) >> 4) & 0x000F;
			
			switch (opcode & 0xF000) {
				
				case 0x0000:
					
					switch (opcode & 0x00FF) {
						
						case 0x00E0:
							// 00E0. Clears the screen.
							for (var e:uint = 0; e < this.display.length; e++) {
								this.display[e] = 0x0;
							}
							this.pc += 2;
							this.dispatchEvent(new Chip8Event(Chip8Event.ON_UPDATE_GRAPHICS, true));
							break;
						
						case 0x00EE:
							// 00EE. Returns from a subroutine.
							// The interpreter sets the program counter to the address at the top of the stack, then subtracts 1 from the stack pointer.
							this.pc = (this.stack[--this.stackPointer] + 2);
							break;
						
						default:
							trace("Opcode no soportado 0x000!");
							break;
					}
					break;
				
				case 0x1000:
					// 1NNN. Jumps to address NNN.
					// The interpreter sets the program counter to nnn.
					this.pc = opcode & 0x0FFF;
					break;
				
				case 0x2000:
					// 2NNN. Calls subroutine at NNN.
					// The interpreter increments the stack pointer, then puts the current PC on the top of the stack. The PC is then set to nnn.
					this.stack[this.stackPointer++] = this.pc;
					this.pc = opcode & 0x0FFF;
					break;
				
				case 0x3000:
					// 3XNN. Skips the next instruction if VX equals NN.
					// The interpreter compares register Vx to nn, and if they are equal, increments the program counter by 2.
					if (this.v[x] == (opcode & 0x00FF)) {
						this.pc += 4;
					} else {
						this.pc += 2;
					}
					break;
				
				case 0x4000:
					// 4XNN. Skips the next instruction if VX doesn't equal NN.
					// The interpreter compares register Vx to nn, and if they are not equal, increments the program counter by 2.
					if (this.v[x] != (opcode & 0x00FF)) {
						this.pc += 4;
					} else {
						this.pc += 2;
					}
					break;
				
				case 0x5000:
					// 5XY0. Skips the next instruction if VX equals VY.
					// The interpreter compares register Vx to register Vy, and if they are equal, increments the program counter by 2.
					if (this.v[x] == this.v[y]) {
						this.pc += 4;
					} else {
						this.pc += 2;
					}
					break;
				
				case 0x6000:
					// 6XNN. Sets VX to NN.
					// The interpreter puts the value nn into register Vx.
					this.v[x] = (opcode & 0x00FF);
					this.pc += 2;
					break;
				
				case 0x7000:
					// 7XNN. Adds NN to VX.
					// The interpreter puts the value nn into register Vx.
					this.v[x] += (opcode & 0x00FF);
					this.pc += 2;
					break;
				
				case 0x8000:
					
					switch (opcode & 0x000F) {
						
						case 0x0000:
							// 8XY0. Sets VX to the value of VY.
							this.v[x] = this.v[y];
							this.pc += 2;
							break;
						
						case 0x0001:
							// 8XY1. Sets VX to VX or VY.
							this.v[x] = (this.v[x] | this.v[y]);
							this.pc += 2;
							break;
						
						case 0x0002:
							// 8XY2. Sets VX to VX and VY.
							this.v[x] = (this.v[x] & this.v[y]);
							this.pc += 2;
							break;
						
						case 0x0003:
							// 8XY3. Sets VX to VX xor VY.
							this.v[x] = (this.v[x] ^ this.v[y]);
							this.pc += 2;
							break;
						
						case 0x0004:
							// 8XY4. Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
							// The values of Vx and Vy are added together. If the result is greater than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0. Only the lowest 8 bits of the result are kept, and stored in Vx.
							if (this.v[y] > (0x00FF - this.v[x])) {
								this.v[0x000F] = 1;
							} else {
								this.v[0x000F] = 0;
							}
							this.v[x] = (this.v[x] + this.v[y]);
							this.pc += 2;
							break;
						
						case 0x0005:
							// 8XY5. VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
							// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted from Vx, and the results stored in Vx.
							if (this.v[x] > this.v[y]) {
								this.v[0x000F] = 1;
							} else {
								this.v[0x000F] = 0;
							}
							this.v[x] = (this.v[x] - this.v[y]);
							this.pc += 2;
							break;
						
						case 0x0006:
							// 8XY6. Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift
							this.v[0x000F] = this.v[x] & 0x0001;
							this.v[x] = (this.v[x] >> 1);
							this.pc += 2;
							break;
						
						case 0x0007:
							// 8XY7. Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't
							// If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted from Vy, and the results stored in Vx.
							if (this.v[y] > this.v[x]) {
								this.v[0x000F] = 1;
							} else {
								this.v[0x000F] = 0;
							}
							this.v[x] = (this.v[y] - this.v[x]);
							this.pc += 2;
							break;
						
						case 0x000E:
							// 8XYE. Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift
							this.v[0x000F] = (this.v[x] >> 7) & 0x0001;
							this.v[x] = (this.v[x] << 1);
							this.pc += 2;
							break;
						
						default:
							trace("Opcode no soportado 0x8000!");
							break;
					}
					break;
				
				case 0x9000:
					// 9XY0. Skips the next instruction if VX doesn't equal VY.
					// The values of Vx and Vy are compared, and if they are not equal, the program counter is increased by 2.
					if (this.v[x] != this.v[y]) {
						this.pc += 4;
					} else {
						this.pc += 2;
					}
					break;
				
				case 0xA000:
					// ANNN. Sets I to the address NNN.
					// The value of register I is set to nnn.
					this.i = (opcode & 0x0FFF);
					this.pc += 2;
					break;
				
				case 0xB000:
					// BNNN. Jumps to the address NNN plus V0.
					// The program counter is set to nnn plus the value of V0.
					this.pc = ((opcode & 0x0FFF) + this.v[0x0]);
					break;
				
				case 0xC000:
					// CXNN. Sets VX to a random number and NN.
					// The interpreter generates a random number from 0 to 255, which is then ANDed with the value kk. The results are stored in Vx. See instruction 8xy2 for more information on AND.
					var rand:uint = (Math.random() * 0x00FF);
					this.v[x] = ((opcode & 0x00FF) & rand) & 0x00FF;
					this.pc += 2
					break;
				
				case 0xD000:
					// DXYN. Sprites stored in memory at location in index register (I), maximum 8bits wide. Wraps around the screen. 
					// If when drawn, clears a pixel, register VF is set to 1 otherwise it is zero. All drawing is XOR drawing (e.g. it toggles the screen pixels)
					/* The interpreter reads n bytes from memory, starting at the address stored in I. These bytes are then displayed as sprites 
					* on screen at coordinates (Vx, Vy). Sprites are XORed onto the existing screen. If this causes any pixels to be erased, VF is set to 1, 
					* otherwise it is set to 0. If the sprite is positioned so part of it is outside the coordinates of the display, it wraps 
					* around to the opposite side of the screen. See instruction 8xy3 for more information on XOR, and section 2.4, 
					* Display, for more information on the Chip-8 screen and sprites. */
					var height:uint = opcode & 0x000F;
					x = this.v[x];
					y = this.v[y];
					this.v[0x000F] = 0;
					for (var yPos:int = 0; yPos < height; yPos++) {
						var data:uint = this.memory[this.i + yPos];
						for (var xPos:uint = 0; xPos < 8; xPos++) {
							if ((data & (0x0080 >> xPos)) != 0) {
								var totalX:uint = (x + xPos);
								var totalY:uint = (y + yPos);
								var index:uint = (totalY * 64) + totalX;
								if (this.display[index] == 1) {
									this.v[0x000F] = 1;
								}
								this.display[index] ^= 1;
							}
						}
					}
					this.pc += 2;
					this.dispatchEvent(new Chip8Event(Chip8Event.ON_UPDATE_GRAPHICS, true));
					break;
				
				case 0xE000:	
					
					switch (opcode & 0x00FF) {
						
						case 0x009E:
							// EX9E. Skips the next instruction if the key stored in VX is pressed.
							// Checks the keyboard, and if the key corresponding to the value of Vx is currently in the down position, PC is increased by 2.
							if (this.keyboard[this.v[x]] == 1) { 
								this.pc += 4;
							} else {
								this.pc += 2;
							}
							break;
						
						case 0x00A1:
							// EXA1. Skips the next instruction if the key stored in VX isn't pressed.
							// Checks the keyboard, and if the key corresponding to the value of Vx is currently in the up position, PC is increased by 2.
							if (this.keyboard[this.v[x]] == 0) { 
								this.pc += 4;
							} else {
								this.pc += 2;
							}
							break;
						
						default:
							trace("Opcode no soportado 0xE000!");
							break;
					}
					break;
				
				case 0xF000:
					
					switch (opcode & 0x00FF) {
						
						case 0x0007: 
							// FX07. Set Vx = delay timer value.
							this.v[x] = this.delayTimer & 0x00FF;
							this.pc += 2;
							break;
						
						case 0x000A: 
							// FX0A. A key press is awaited, and then stored in VX.
							// All execution stops until a key is pressed, then the value of that key is stored in Vx.
							for (var u:int = 0; u < this.keyboard.length; u++) {
								if (this.keyboard[u] == 1) { 
									this.v[x] = u;
									this.pc += 2;
									break;
								}
							}
							break;
						
						case 0x0015: 
							// FX15. DT is set equal to the value of Vx.
							this.delayTimer = this.v[x];
							this.pc += 2;
							break;
						
						case 0x0018: 
							// FX18. ST is set equal to the value of Vx.
							this.soundTimer = this.v[x];
							this.pc += 2;
							break;
						
						case 0x001E: 
							// The values of I and Vx are added, and the results are stored in I.
							this.i += this.v[x];
							this.pc += 2;
							break;
						
						case 0x0029:
							// Set I = location of sprite for digit Vx.
							// The value of I is set to the location for the hexadecimal sprite corresponding to the value of Vx. 
							this.i = this.v[x] * 0x0005;
							this.pc += 2;
							break;
						
						case 0x0033:
							// The interpreter takes the decimal value of Vx, and places the hundreds digit 
							// in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.
							this.memory[this.i] = Math.floor(this.v[x] / 100) as uint;
							this.memory[this.i + 1] = Math.floor((this.v[x] % 100) / 10) as uint;
							this.memory[this.i + 2] = Math.floor((this.v[x] % 100) % 10) as uint;
							this.pc += 2;
							break;
						
						case 0x0055:
							// Store registers V0 through Vx in memory starting at location I.
							// The interpreter copies the values of registers V0 through Vx into memory, starting at the address in I.
							for (var z:uint = 0; z <= x; z++) {
								this.memory[this.i + z] = this.v[z];
							}
							this.pc += 2;
							break;
						
						case 0x0065:
							// Read registers V0 through Vx from memory starting at location I.
							// The interpreter reads values from memory starting at location I into registers V0 through Vx.
							for (var a:uint = 0; a <= x; a++) {
								this.v[a] = this.memory[this.i + a];
							}
							this.i += (x + 1);
							this.pc += 2;
							break;
						
						default:
							trace("Opcode no soportado 0xF000!");
							break;
					}
					break;
				
				default:
					trace("Opcode no soportado ?");
					break;
			}
			
			if (this.delayTimer > 0) {
				this.delayTimer--;
			}
			
			if (this.soundTimer > 0) {
				if (this.soundTimer == 1) {
					this.dispatchEvent(new Chip8Event(Chip8Event.ON_BEEP, true));
				}
				this.soundTimer--;
			}
		}
	}
}