using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common
{
    public class PayerDataRequest
    {
        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderId { get; set; }
        public string SessionId { get; set; }
        public string CountryIsoCode { get; set; }
        public int CityId { get; set; }
        public string TownId { get; set; }
        public string PaymentModeId { get; set; }
        public string ReceiveCurrencyIsoCode { get; set; }
        public string BankId { get; set; }
        public string SourceCurrencyIsoCode { get; set; }
        public int StartIndex { get; set; }
        public int PageSize { get; set; }
        public string FeeProduct { get; set; }
    }

    public class TFPayerMasterResults
    {
        public int PayerInternalCode { get; set; }
        public string PayerName { get; set; }
        public decimal CustomerRate { get; set; }
        public bool IsThirdParty { get; set; }
        public bool IsAnywhere { get; set; }
        public string Label { get; set; }
        public List<PayerDetailsResults> PayerDetailsResults { get; set; }
    }

    public class PayerDetailsResults
    {
        public string PayerId { get; set; }
        public string PayerName { get; set; }
        public string BranchId { get; set; }
        public string BranchName { get; set; }
        public string BranchAddress { get; set; }
        public string BankId { get; set; }
        public string BankName { get; set; }
        public string NeedBank { get; set; }
    }
}
