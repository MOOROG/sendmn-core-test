namespace Swift.API.Common.SMS
{
    public class SMSRequestModel
    {
        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string RequestedBy { get; set; }
        public string MobileNumber { get; set; }
        public string SMSBody { get; set; }
        public string method { get; set; }
        public string ProviderId { get; set; }
        public string MTID { get; set; }
    }
}
