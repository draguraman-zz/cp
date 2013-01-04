package gameentity
{
	

	public class MultiGameState extends GameState
	{
		public function MultiGameState(boardwidth:Number,boardheight:Number)
		{
			super(boardwidth, boardheight);
		}		
		
		public override function load():void{	
			
		}
		
		protected override function persistPlayerImpl():void {
		}

		public override function persist(isReset:Boolean = false):void {	
		}

		protected override function persistImpl(variables:Object):void {
		}

	}
		
}
