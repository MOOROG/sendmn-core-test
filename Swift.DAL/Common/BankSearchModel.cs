namespace Swift.DAL.Common
{
    public class BankSearchModel
    {
        public string User { get; set; }
        public string SearchType { get; set; }
        public string SearchValue { get; set; }
        public string PAgent { get; set; }
        public string PAgentType { get; set; }
        public string PCountryName { get; set; }
        public string PayoutPartner { get; set; }
        public string PaymentMode { get; set; }
    }
}
