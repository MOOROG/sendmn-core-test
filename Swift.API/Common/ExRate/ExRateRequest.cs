using Swift.API.Common.SendTxn;
using System.Collections.Generic;

namespace Swift.API.Common.ExRate {
  public class ExRateRequest {
    public string ProcessId { get; set; }
    public string UserName { get; set; }
    public string ProviderId { get; set; }
    public string RequestedBy { get; set; }
    public string CustomerId { get; set; }
    public string SCountry { get; set; }
    public string SAgent { get; set; }
    public string PAgentId { get; set; }
    public string PAgentName { get; set; }
    public string SSuperAgent { get; set; }
    public string SBranch { get; set; }
    public string AgentRefId { get; set; }
    public string CollCurrency { get; set; }
    public string PAgent { get; set; }
    public string SchemeId { get; set; }
    public string PayoutPartner { get; set; }
    public string PCountry { get; set; }
    public string PCurrency { get; set; }
    public string CAmount { get; set; }
    public string PAmount { get; set; }
    public string ServiceType { get; set; }
    public string CalcBy { get; set; }
    public string TpExRate { get; set; }
    public string TpPCurrnecy { get; set; }
    public string PaymentType { get; set; }
    public string CouponCode { get; set; }
    public string Amount { get; set; }
    public bool IsManualSc { get; set; }
    public string ManualSc { get; set; }
    public bool IsDefault { get; set; }
    public string CardOnline { get; set; }
    public string ForexSessionId { get; set; }
    public bool IsOnline { get; set; }
    public string pCountryCode { get; set; }
    public string SCurrency { get; set; }
    public string pCountryName { get; set; }
    public bool isExRateCalcByPartner { get; set; }
  }

  public class ExRateCalculateRequest {
    public string cAmount { get; set; }
    public string calcBy { get; set; }
    public string pAgent { get; set; }
    public string pAmount { get; set; }
    public string pCountry { get; set; }
    public string pCountryName { get; set; }
    public string pCurrency { get; set; }
    public string paymentType { get; set; }
    public string payoutPartner { get; set; }
    public string processId { get; set; }
    public string sCountry { get; set; }
    public string sCurrency { get; set; }
    public string schemeId { get; set; }
    public string serviceType { get; set; }
    public string serviceTypeDescription { get; set; }
    public string tpExRate { get; set; }
    public string tpPCurrnecy { get; set; }
    public string userId { get; set; }
    public string receiverIsOrg { get; set; }
  }

  public class CommonRequest {
    public string ProcessId { get; set; }
    public string UserName { get; set; }
    public string ProviderId { get; set; }
    public string SessionId { get; set; }
  }

  public class ExRateCalculate : CommonRequest {
    public string RequestedBy { get; set; }

    public int CustomerId { get; set; }

    public int SCountry { get; set; }
    public int SAgent { get; set; }
    public int SSuperAgent { get; set; }
    public int SBranch { get; set; }
    public string AgentRefId { get; set; }
    public string CollCurrency { get; set; }

    public int PAgentId { get; set; }
    public string PAgentName { get; set; }
    public int PayoutPartner { get; set; }

    public int PCountry { get; set; }

    public string PCountryName { get; set; }

    public string PCurrency { get; set; }

    public string SCurrency { get; set; }

    public decimal CAmount { get; set; }
    public decimal PAmount { get; set; }
    public string ServiceType { get; set; }
    public string CalcBy { get; set; }
    public string PaymentType { get; set; }
    public string CouponCode { get; set; }

    public bool IsManualSc { get; set; }
    public decimal ManualSc { get; set; }
    public string CardOnline { get; set; }

    public bool IsOnline { get; set; }
    public string pCountryCode { get; set; }
    public bool IsExRateCalcByPartner { get; set; }
    public string tPExRate { get; set; }
    public string ProcessFor { get; set; }
    public string receiverIsOrg { get; set; }
  }

  public class ExRateMobileCalc {
      public string cAmount { get; set; }
      public string calcBy { get; set; }
      public string pAgent { get; set; }
      public string pAmount { get; set; }
      public string pCountry { get; set; }
      public string pCountryName { get; set; }
      public string pCurrency { get; set; }
      public string paymentType { get; set; }
      public string payoutPartner { get; set; }
      public string processId { get; set; }
      public string sCountry { get; set; }
      public string sCurrency { get; set; }
      public string schemeId { get; set; }
      public string serviceType { get; set; }
      public string serviceTypeDescription { get; set; }
      public string tpExRate { get; set; }
      public string tpPCurrnecy { get; set; }
      public string userId { get; set; }
  }

  public class TpSendMoney : CommonRequest {
    public string SenderId { get; set; }
    public string SIpAddress { get; set; }
    public bool IsRealtime { get; set; }
    public string RequestedBy { get; set; }
    public ReceiverInfo Receiver { get; set; }
    public CustomerDueDiligence CDD { get; set; }
    public int SCountryId { get; set; }
    public int PCountryId { get; set; }
    public int DeliveryMethodId { get; set; }
    public int PBranchId { get; set; }
    public int PBankId { get; set; }
    public string CollCurr { get; set; }
    public string PayoutCurr { get; set; }
    public string CollAmt { get; set; }
    public string PayoutAmt { get; set; }
    public string TransferAmt { get; set; }
    public string ServiceCharge { get; set; }
    public string ExRate { get; set; }
    public string CalBy { get; set; }
    public string TpExRate { get; set; }
    public string TpPCurr { get; set; }
    public int PayOutPartnerId { get; set; }
    public string ForexSessionId { get; set; }
    public string PaymentType { get; set; }
    public string SourceType { get; set; }
    public string ScDiscount { get; set; }
    public string SchemeId { get; set; }
    public txnCompliance txnCompliance { get; set; }
    public string senderIsOrg { get; set; }
    public string receiverIsOrg { get; set; }
    public string receiverBinn { get; set; }
    public string receiverBikk { get; set; }
    public string transactionDesc { get; set; }
    public string whichCur { get; set; }
  }
  public class ReceiverInfo {
    public string ReceiverId { get; set; }
    public string FirstName { get; set; }
    public string MiddleName { get; set; }
    public string LastName { get; set; }
    public string IdType { get; set; }
    public string IdNo { get; set; }
    public string IdIssue { get; set; }
    public string IdExpiry { get; set; }
    public string Dob { get; set; }
    public string MobileNo { get; set; }
    public string NativeCountry { get; set; }
    public int StateId { get; set; }
    public int DistrictId { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string Email { get; set; }
    public string AccountNo { get; set; }
  }

  public class CustomerDueDiligence {
    public string PurposeOfRemittance { get; set; }
    public string RelWithSender { get; set; }
    public string SourceOfFund { get; set; }
  }

}