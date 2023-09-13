using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.ExRate
{
    public class ExRateResponse
    {
        public string ErrorCode { get; set; }
        public string ErrCode { get; set; }
        public string ErrorMsg { get; set; }
        public string mirsErrCode { get; set; }
        public string mirsPayoutAgentRate { get; set; }
        public string mirsRateCreatedDate { get; set; }
        public string mirsPayoutCurrency { get; set; }
        public string Msg { get; set; }
        public string Id { get; set; }
        public string scCharge { get; set; }
        public string exRateDisplay { get; set; }
        public string exRate { get; set; }
        public string place { get; set; }
        public string pCurr { get; set; }
        public string currDecimal { get; set; }
        public string pAmt { get; set; }
        public string sAmt { get; set; }
        public string disc { get; set; }
        public string bankTransafer { get; set; }
        public string bankPayout { get; set; }
        public string bankRate { get; set; }
        public string bankFee { get; set; }
        public string bankSave { get; set; }
        public string bankName { get; set; }
        public string collAmt { get; set; }
        public string collCurr { get; set; }
        public string exRateOffer { get; set; }
        public string scOffer { get; set; }
        public string scAction { get; set; }
        public string scValue { get; set; }
        public string scDiscount { get; set; }
        public string amountLimitPerTran { get; set; }
        public string amountLimitPerDay { get; set; }
        public string customerTotalSentAmt { get; set; }
        public string minAmountLimitPerTran { get; set; }
        public string maxAmountLimitPerTran { get; set; }
        public string PerTxnMinimumAmt { get; set; }
        public string tpExRate { get; set; }
        public string tpPCurr { get; set; }
        public string schemeAppliedMsg { get; set; }
        public string schemeId { get; set; }
        public string PayoutPartner { get; set; }
        public string EXRATEID { get; set; }
        public string DateToday { get; set; }
        public string AgentRefId { get; set; }
        public string ComplianceErrorCode { get; set; }
        public string ComplianceId { get; set; }
        public string ComplianceMsg { get; set; }
        public string ComplianceVType { get; set; }
        public string ForexSessionId { get; set; }
    }
    public class TFExRateResponse
    {
        public string PayerName { get; set; }
        public string ModeOfPaymentName { get; set; }
        public decimal StartRate { get; set; }
        public decimal EndRate { get; set; }
        public string PayerId { get; set; }
        public string PaymentModeId { get; set; }
        public string ReceiveCountryIsoCode { get; set; }
        public string ReceiveCountryName { get; set; }
        public string RateStartDate { get; set; }
        public string RateExpiryDate { get; set; }
        public string ReceiveCurrencyIsoCode { get; set; }
    }

    public class _ExRateResponse
    {
        public List<TFExRateResponse> Rates { get; set; }
    }
}