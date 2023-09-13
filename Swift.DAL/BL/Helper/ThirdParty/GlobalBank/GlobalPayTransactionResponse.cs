using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.Helper.ThirdParty.GlobalBank
{
    public class GlobalPayTransactionResponse
    {
        public string SuccessCode { get; set; }
        public string TokenId { get; set; }
        public string RadNo { get; set; }
        public string BenefName { get; set; }
        public string BenefTel { get; set; }
        public string BenefMobile { get; set; }
        public string BenefAddress { get; set; }
        public string BenefAccIdNo { get; set; }
        public string BenefIdType { get; set; }
        public string SenderName { get; set; }
        public string SenderAddress { get; set; }
        public string SenderTel { get; set; }
        public string SenderMobile { get; set; }
        public string SenderIdType { get; set; }
        public string SenderIdNo { get; set; }
        public string RemittanceEntryDt { get; set; }
        public string RemittanceAuthorizedDt { get; set; }
        public string Remarks { get; set; }
        public string RemitType { get; set; }
        public string RCurrency { get; set; }
        public string PCurrency { get; set; }
        public string PCommission { get; set; }
        public string Amount { get; set; }
        public string LocalAmount { get; set; }
        public string ExchangeRate { get; set; }
        public string DollarRate { get; set; }
        public string TPAgentID { get; set; }
        public string TPAgentName { get; set; }

    }
}