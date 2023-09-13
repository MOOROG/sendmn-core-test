using Swift.DAL.Common;
using System.Collections.Generic;

namespace Swift.DAL.Domain {
  public class IRHTranDetail {
    public string User { get; set; }
    public string AgentRefId { get; set; }
    public string SenderId { get; set; }
    public string SenFirstName { get; set; }
    public string SenMiddleName { get; set; }
    public string SenLastName { get; set; }
    public string SenLastName2 { get; set; }
    public string SenGender { get; set; }
    public string SenIdType { get; set; }
    public string SenIdNo { get; set; }
    public string SenIdValid { get; set; }
    public string SenDob { get; set; }
    public string SenTel { get; set; }
    public string SenMobile { get; set; }
    public string SenNaCountry { get; set; }
    public string SenCity { get; set; }
    public string SenPostCode { get; set; }
    public string SenAdd1 { get; set; }
    public string SenAdd2 { get; set; }
    public string SenEmail { get; set; }
    public string SenCompany { get; set; }
    public string SmsSend { get; set; }

    public string ReceiverId { get; set; }
    public string RecFirstName { get; set; }
    public string RecMiddleName { get; set; }
    public string RecLastName { get; set; }
    public string RecLastName2 { get; set; }
    public string RecGender { get; set; }
    public string RecIdType { get; set; }
    public string RecIdNo { get; set; }
    public string RecIdValid { get; set; }
    public string RecDob { get; set; }
    public string RecTel { get; set; }
    public string RecMobile { get; set; }
    public string RecNaCountry { get; set; }
    public string RecCity { get; set; }
    public string RecPostCode { get; set; }
    public string RecAdd1 { get; set; }
    public string RecAdd2 { get; set; }
    public string RecEmail { get; set; }
    public string RecAccountNo { get; set; }
    public string RecCountry { get; set; }
    public string RecCountryId { get; set; }
    public string DeliveryMethod { get; set; }
    public string DeliveryMethodId { get; set; }
    public string PBank { get; set; }
    public string PBankName { get; set; }
    public string PBankBranch { get; set; }
    public string PBankBranchName { get; set; }
    public string PBankType { get; set; }

    public string PAgent { get; set; }
    public string PAgentName { get; set; }

    public string PCurr { get; set; }
    public string CollCurr { get; set; }
    public string CollAmt { get; set; }
    public string CustomerLimit { get; set; }
    public string PayoutAmt { get; set; }
    public string TransferAmt { get; set; }
    public string ServiceCharge { get; set; }
    public string Discount { get; set; }
    public string ExRate { get; set; }

    public string SchemeCode { get; set; }
    public string SchemeType { get; set; }
    public string CouponTranNo { get; set; }
    public string PurposeOfRemittance { get; set; }
    public string SourceOfFund { get; set; }
    public string IsYourMoney { get; set; }
    public string IsPep { get; set; }
    public string RelWithSender { get; set; }
    public string Occupation { get; set; }
    public string PayoutMsg { get; set; }
    public string Company { get; set; }
    public string NCustomer { get; set; }
    public string ECustomer { get; set; }

    public string SBranch { get; set; }
    public string SBranchName { get; set; }
    public string SAgent { get; set; }
    public string SAgentName { get; set; }
    public string SSuperAgent { get; set; }
    public string SSuperAgentName { get; set; }
    public string SettlingAgent { get; set; }
    public string SCountry { get; set; }
    public string SCountryId { get; set; }

    public string SessionId { get; set; }
    public string CancelRequestId { get; set; }
    public string TxnPassword { get; set; }
    public string Salary { get; set; }
    public string MemberCode { get; set; }

    public string TtName { get; set; }
    public string CwPwd { get; set; }

    public string OfacRes { get; set; }
    public string OfacReason { get; set; }
    public string DcInfo { get; set; }
    public string IpAddress { get; set; }
    public string VoucherDetail { get; set; }

    public string CustomerRisk { get; set; }
    public string RBATxnRisk { get; set; }
    public string RBACustomerRisk { get; set; }
    public string RBACustomerRiskValue { get; set; }

    public string pStateId { get; set; }
    public string pStateName { get; set; }
    public string pCityId { get; set; }
    public string pCityName { get; set; }
    public string pTownId { get; set; }
    public string tpExRate { get; set; }
    public string tpRefNo { get; set; }
    public string tpRefNo2 { get; set; }
    public string tpTranId { get; set; }

    //New fields
    public string isManualSC { get; set; }
    public string manualSC { get; set; }
    public string sCustStreet { get; set; }
    public string sCustLocation { get; set; }
    public string sCustomerType { get; set; }
    public string sCustBusinessType { get; set; }
    public string sCustIdIssuedCountry { get; set; }
    public string sCustIdIssuedDate { get; set; }
    public string receiverId { get; set; }
    public string payoutPartner { get; set; }

    public string cashCollMode { get; set; }
    public string customerDepositedBank { get; set; }
    public string introducer { get; set; }
    public string IsOnBehalf { get; set; }
    public string PayerId { get; set; }
    public string PayerBranchId { get; set; }
    public string IsFromTabPage { get; set; }
    public string CustomerPassword { get; set; }
    public string controlNumber { get; set; }
    public string isAdditionalCDDI { get; set; }
    public string CDDIXml { get; set; }
    public string calcBy { get; set; }
    public string promotionCode { get; set; }
    public string promotionAmount { get; set; }
    public List<result> ComplaincrData { get; set; }
    public string ComplaincrDataStr { get; set; }
  }

  public class IRHTranDetailNew {
    public string User { get; set; }
    public string AgentRefId { get; set; }
    public string SenderId { get; set; }
    public string SenFirstName { get; set; }
    public string SenMiddleName { get; set; }
    public string SenLastName { get; set; }
    public string SenLastName2 { get; set; }
    public string SenGender { get; set; }
    public string SenIdType { get; set; }
    public string SenIdNo { get; set; }
    public string SenIdValid { get; set; }
    public string SenDob { get; set; }
    public string SenTel { get; set; }
    public string SenMobile { get; set; }
    public string SenNaCountry { get; set; }
    public string SenCity { get; set; }
    public string SenPostCode { get; set; }
    public string SenEmail { get; set; }
    public string SenCompany { get; set; }
    public string SmsSend { get; set; }

    public string ReceiverId { get; set; }
    public string RecFirstName { get; set; }
    public string RecMiddleName { get; set; }
    public string RecLastName { get; set; }
    public string RecGender { get; set; }
    public string RecIdType { get; set; }
    public string RecIdNo { get; set; }
    public string RecIdValid { get; set; }
    public string RecDob { get; set; }
    public string RecTel { get; set; }
    public string RecMobile { get; set; }
    public string RecNaCountry { get; set; }
    public string RecCity { get; set; }
    public string RecAdd1 { get; set; }
    public string RecEmail { get; set; }
    public string RecAccountNo { get; set; }
    public string RecCountry { get; set; }
    public string RecCountryId { get; set; }
    public string DeliveryMethod { get; set; }
    public string DeliveryMethodId { get; set; }
    public string PBank { get; set; }
    public string PBankName { get; set; }
    public string PBankBranch { get; set; }
    public string PBankBranchName { get; set; }
    public string PBankType { get; set; }

    public string PAgent { get; set; }
    public string PAgentName { get; set; }

    public string PCurr { get; set; }
    public string CollCurr { get; set; }
    public string CollAmt { get; set; }
    public string CustomerLimit { get; set; }
    public string PayoutAmt { get; set; }
    public string TransferAmt { get; set; }
    public string ServiceCharge { get; set; }
    public string ExRate { get; set; }

    public string SchemeCode { get; set; }
    public string SchemeType { get; set; }
    public string CouponTranNo { get; set; }
    public string PurposeOfRemittance { get; set; }
    public string SourceOfFund { get; set; }
    public string RelWithSender { get; set; }
    public string Occupation { get; set; }
    public string PayoutMsg { get; set; }
    public string Company { get; set; }
    public string NCustomer { get; set; }
    public string ECustomer { get; set; }

    public string SBranch { get; set; }
    public string SBranchName { get; set; }
    public string SAgent { get; set; }
    public string SAgentName { get; set; }
    public string SSuperAgent { get; set; }
    public string SSuperAgentName { get; set; }
    public string SettlingAgent { get; set; }
    public string SCountry { get; set; }
    public string SCountryId { get; set; }

    public string SessionId { get; set; }
    public string CancelRequestId { get; set; }
    public string TxnPassword { get; set; }
    public string Salary { get; set; }
    public string MemberCode { get; set; }

    public string TtName { get; set; }
    public string CwPwd { get; set; }

    public string OfacRes { get; set; }
    public string OfacReason { get; set; }
    public string DcInfo { get; set; }
    public string IpAddress { get; set; }
    public string VoucherDetail { get; set; }

    public string CustomerRisk { get; set; }
    public string RBATxnRisk { get; set; }
    public string RBACustomerRisk { get; set; }
    public string RBACustomerRiskValue { get; set; }

    public string pStateId { get; set; }
    public string pStateName { get; set; }
    public string pCityId { get; set; }
    public string pCityName { get; set; }
    public string pTownId { get; set; }
    public string tpExRate { get; set; }
    public string tpRefNo { get; set; }
    public string tpRefNo2 { get; set; }
    public string tpTranId { get; set; }

    //New fields
    public string isManualSC { get; set; }
    public string manualSC { get; set; }
    public string sCustStreet { get; set; }
    public string sCustLocation { get; set; }
    public string sCustomerType { get; set; }
    public string sCustBusinessType { get; set; }
    public string sCustIdIssuedCountry { get; set; }
    public string sCustIdIssuedDate { get; set; }
    public string receiverId { get; set; }
    public string payoutPartner { get; set; }

    public string cashCollMode { get; set; }
    public string customerDepositedBank { get; set; }
    public string introducer { get; set; }
    public string IsOnBehalf { get; set; }
  }
}
