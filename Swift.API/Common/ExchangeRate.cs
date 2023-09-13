namespace Swift.API.Common
{
    public class ExchangeRate
    {
        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderName { get; set; }
        public string RequestedBy { get; set; }
        public int CustomerId { get; set; }
        public int SCountry { get; set; }
        public int SAgent { get; set; }
        public int SSuperAgent { get; set; }
        public int SBranch { get; set; }
        public string AgentRefId { get; set; }
        public string CollCurrency { get; set; }
        public int PAgent { get; set; }
        public int SchemeId { get; set; }
        public int PayoutPartner { get; set; }
        public int PCountry { get; set; }
        public string PCurrency { get; set; }
        public decimal CAmount { get; set; }
        public decimal PAmount { get; set; }
        public string ServiceType { get; set; }
        public string CalcBy { get; set; }
        public decimal TpExRate { get; set; }
        public string TpPCurrnecy { get; set; }
        public string PaymentType { get; set; }
        public string CouponCode { get; set; }
        public decimal Amount { get; set; }
        public bool IsManualSc { get; set; }
        public decimal ManualSc { get; set; }
        public bool IsDefault { get; set; }
        public string CardOnline { get; set; }
        public string ForexSessionId { get; set; }
        public bool IsOnline { get; set; }
    }
}