package gameentity{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class CueBall extends Ball {
		public var m_stick:Stick;
		

		public function CueBall(stick:Stick, offset:Point, scale:Rectangle) {
			// constructor code
			super(-1, offset, scale);
			m_stick=stick;
		}

		public function resetPosition():void {
			this.vx=0;
			this.vy=0;
			this.px=0.5;
			this.py=0.5;
		}
		
		public function reappear():void {
			resetPosition();
			setTimeout (appear, 2000);
		}
		
		public function disappear():void {
			this.visible=false;
		}
		
		public function appear():void {
			this.visible=true;
		}
		
	}
}