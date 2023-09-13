namespace Swift.API
{
	public class DbResult
	{
		public string ErrorCode { get; set; }
		public string Msg { get; set; }
		public string Id { get; set; }
		public string Extra { get; set; }
        public string Extra2 { get; set; }
		public string RequestXML { get; set; }
		public string ResponseXML { get; set; }
		public string TpErrorCode { get; set; }

		public DbResult() { }

		public void SetError(string errorCode, string msg, string id)
		{
			ErrorCode = errorCode;
			Msg = msg;
			Id = id;
		}       
	}
}
