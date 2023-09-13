namespace Swift.DAL.SwiftDAL
{
    public class DbResult
    {
        private string _errorCode = "";
        private string _msg = "";
        private string _id = "";
        private string _extra = "";
		private string _tpErrorCode = "";
        public DbResult() { }

        public string ErrorCode
        {
            set { _errorCode = value; }
            get { return _errorCode; }
        }

        public string Msg
        {
            set { _msg = value; }
            get { return _msg; }
        }

        public string Id
        {
            set { _id = value; }
            get { return _id; }
        }

        public string Extra
        {
            set { _extra = value; }
            get { return _extra; }
        }
        public string Extra2 { get; set; }
		public string TpErrorCode
		{
			get { return _tpErrorCode; }
			set { _tpErrorCode = value; }
		}
        public void SetError(string errorCode, string msg, string id)
        {
            ErrorCode = errorCode;
            Msg = msg;
            Id = id;
        }
    }
}
