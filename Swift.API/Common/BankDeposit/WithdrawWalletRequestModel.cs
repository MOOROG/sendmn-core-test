using Swift.API.Common.PayTransaction;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.BankDeposit {
  public class WithdrawWalletRequestModel : CommonParam {
    public string userID { get; set; }
    public string controlNo { get; set; }
    public string[] tranId { get; set; }
    public string amount { get; set; }
    public string description { get; set; }
    public string currency { get; set; }
    public string flag { get; set; }
  }

  public class CancelRiaTxn : CommonParam {
    public string PartnerPinNo { get; set; }

    public string CancelReason { get; set; }
  }

  public class ChangeOutgoing {
    public string docId { get; set; }
    public string trnDate { get; set; }
    public string trnCurrency { get; set; }
    public string trnAmount { get; set; }
    public string trnSendPoint { get; set; }
    public string trnPickupPoint { get; set; }
    public string trnService { get; set; }
    public string sName { get; set; }
    public string sLastName { get; set; }
    public string sSurName { get; set; }
    public string sPhone { get; set; }
    public string sIDtype { get; set; }
    public string sIDnumber { get; set; }
    public string bName { get; set; }
    public string bLastName { get; set; }
    public string bSurName { get; set; }
    public string bAccount { get; set; }
    public string bBank { get; set; }
  }
}
