namespace Swift.API.Common.SendTxn
{
    public class TxnTransaction
    {
        public string TxnDate { get; set; }
        public string JMEControlNo { get; set; }
        public string PurposeOfRemittanceName { get; set; }
        public string CollectionMode { get; set; }
        public int DeliveryMethodId { get; set; }
        public string DeliveryMethod { get; set; }
        public string PCurr { get; set; }
        public string CollCurr { get; set; }
        public decimal CAmt { get; set; }
        public decimal PAmt { get; set; }
        public decimal TAmt { get; set; }
        public decimal ServiceCharge { get; set; }
        public decimal Discount { get; set; }
        public decimal ExRate { get; set; }
        public decimal Rate { get; set; }
        public string PComm { get; set; }
        public decimal SettlementDollarRate { get; set; }
        public string CalBy { get; set; }
        public string Introducer { get; set; }
        public string IsManualSc { get; set; }
        public decimal ManualSc { get; set; }
        public string RLocation { get; set; }
        public string RLocationName { get; set; }
        public string TpRefNo { get; set; }
        public string TpTranId { get; set; }
        public int PayOutPartner { get; set; }
        public string PaymentType { get; set; }
        public string PayoutMsg { get; set; }
        public string FOREX_SESSION_ID { get; set; }

    }
}