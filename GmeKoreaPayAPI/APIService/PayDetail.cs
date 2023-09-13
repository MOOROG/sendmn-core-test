namespace GMEPayAPI.APIService
{
    public class PayDetail
    {
        public string PartnerId { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string PinNo { get; set; }
        public string SessionId { get; set; }
        public string ReceivingTokenId { get; set; }
        public string RecIdType { get; set; }
        public string RecIdNumber { get; set; }
        public string RecIdIssuePlace { get; set; }
        public string RecIdIssueDate { get; set; }
        public string RecDOB { get; set; }
        public string RecOccupation { get; set; }
    }
}
