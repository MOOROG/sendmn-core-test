namespace Swift.DAL.Common
{
    public class KJAutoRefundModel
    {
        public string bankCode;
        public string bankAccountNo;

        public string flag { get; set; }
        public string customerId { get; set; }
        public string customerSummary { get; set; }
        public string amount { get; set; }
        public string action { get; set; }
        public string actionDate { get; set; }
        public string actionBy { get; set; }
        public string rowId { get; set; }
    }
    public class AccountTransferToBank
    {
        public string obpId { get; set; }
        public string accountNo { get; set; }
        public string accountPassword { get; set; }
        public string receiveInstitution { get; set; }
        public string receiveAccountNo { get; set; }
        public string amount { get; set; }
        public string bankBookSummary { get; set; }
        public string transactionSummary { get; set; }
    }
}