package util
{
	/**
	 * Computes CRC32 data checksum of a data stream.
	 * The actual CRC32 algorithm is described in RFC 1952
	 * (GZIP file format specification version 4.3).
	 * 
	 * @author David Chang
	 * @date January 2, 2007.
	 */

	public class CRC32
	{
		/** The crc data checksum so far. */
		private var crc:int;
		
		/** The fast CRC table. Computed once when the CRC32 class is loaded. */
		private static var crcTable:Array = makeCrcTable();
		
		/** Make the table for a fast CRC. */
		private static function makeCrcTable():Array {
			var crcTable:Array = new Array(256);
			for (var n:uint = 0; n < 256; n++) {
				var c:int = n;
				for (var k:uint = 8; --k >= 0; ) {
					if((c & 1) != 0) c = 0xedb88320 ^ (c >>> 1);
					else c = c >>> 1;
				}
				crcTable[n] = c;
			}
			return crcTable;
		}
		
		/**
		 * Returns the CRC32 data checksum computed so far.
		 */
		private function getValue():int {
			var crcSigned:int = crc as int;
			return crcSigned;
		}
		
		/**
		 * Resets the CRC32 data checksum as if no update was ever called.
		 */
		private function reset():void {
			crc = 0;
		}
		
		/**
		 * Adds the complete byte array to the data checksum.
		 * 
		 * @param buf the buffer which contains the data
		 */
		private function update(string:String):void {
			var off:uint = 0;
			var len:uint = string.length;			
			var c:int = crc ^ -1;
			while(--len >= 0) {
				var val: int = string.charCodeAt(off++);
				if(val == 13) //Ignore \r
					continue;
				val = val & 0xffffffff;
				var y: int = (c ^ val) & 0xff;
				var x: int = crcTable[y];
				c = (c >>> 8) ^ x;
			}
			crc = c ^ -1;
		}
		
		public function crc32(string: String): uint {
			reset();
			update(string);
			return getValue();
		}
	}
}