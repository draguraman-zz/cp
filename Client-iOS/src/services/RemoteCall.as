package services
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.ByteArray;
	
	import util.ConfigurationUtil;
	
	public class RemoteCall
	{
		/** Standard Error Codes. */
		private const TRANSPORT_FAILURE_AMF_FAULT:int = 1;
		private const TRANSPORT_FAILURE_NET_STATUS:int = 2;
		private const TRANSPORT_FAILURE_IO_ERROR:int = 4;
		private const TRANSPORT_FAILURE_ASYNC_ERROR:int = 4;
		private const TRANSPORT_FAILURE_SECURITY_ERROR:int = 5;
		
		protected var m_net:NetConnection;
		
		protected var m_responder:Responder;
		
		protected var m_errorCallback:Function=null;
		
		protected var m_resultCallback:Function=null;
		
		public function RemoteCall(inOnResult:Function=null, inOnError:Function=null)
		{
			
			m_errorCallback=inOnError;
			m_resultCallback=inOnResult;
			
			m_responder=new Responder(onResult, onError);				
			trace('Initiating Network Connection ...');
			m_net = new NetConnection();
			m_net.addEventListener(NetStatusEvent.NET_STATUS, onError, false, 0, true);
			m_net.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			m_net.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError, false, 0, true);
			m_net.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true);
			{
				var gateway: String = ConfigurationUtil.getGateway();
				m_net.connect(gateway);
				trace('Gateway is: '+gateway);
			}
		}		
		
		protected function onResult(result:Object):void {
			if(m_resultCallback!=null) {
				m_resultCallback(result);
			}
		}
		
		protected function onError(result:Object):void {
			trace("Error in Call.");
			if(m_errorCallback!=null) {
				m_errorCallback(result);
			}
		}			
		
		public function call(funcName:String, ... arguments:Array):void {
			var allArgs:Array=[funcName, m_responder];
			{
				var callStr:String = "Call: "+funcName+"("; 
				for (var key:Object in arguments) {
					var value:Object = arguments[key];
					if(value is ByteArray && ByteArray(value).bytesAvailable > 2048)
						callStr += " " + "ByteArray"+",";
					else if(value is String && String(value).length > 2048) 
						callStr += " " + "String"+",";
					else
						callStr+=" " + arguments[key]+",";
				}
				callStr+=")";
				trace(callStr);
			}
			allArgs=allArgs.concat(arguments);
			m_net.call.apply(funcName,allArgs);
		}  	
	}	
}
