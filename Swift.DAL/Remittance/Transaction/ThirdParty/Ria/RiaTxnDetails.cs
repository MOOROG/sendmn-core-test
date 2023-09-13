using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Transaction.ThirdParty.Ria
{
    public class RiaTxnDetails
    {
        public string User { get; set; }
        public string BranchCode { get; set; }
        public string RemitDate { get; set; }
        public string CollectAmount { get; set; }
        public string PayoutAmount { get; set; }
        public string PayoutCurrency { get; set; }
        public string USDExRate { get; set; }
        public string ServiceCharge { get; set; }
        public string SenderName { get; set; }
        public string SenderIdNumber { get; set; }
        public string SenderCountry { get; set; }
        public string SenderCountryId { get; set; }
        public string ControlNumber { get; set; }
        public string ReceiverName { get; set; }
        public string ReceiverCountry { get; set; }
        public string ReceiverCountryId { get; set; }
        public string OrderNumber { get; set; }
        public string SequenceNumber { get; set; }
        public string PaymentMethod { get; set; }
        public string sIdType { get; set; }
        public string sIdTypeText { get; set; }
        public string sMobile { get; set; }
        public string sEmail { get; set; }
    }
}
