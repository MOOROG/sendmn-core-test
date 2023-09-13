using System;
using System.Xml.Serialization;

namespace Swift.API.Common.SyncModel.Bank
{
    public class BankRequest : CommonRequest
    {
        public string CountryCode { get; set; }
        public string BankName { get; set; }
        public string RoutingNumber { get; set; }
        public string StateId { get; set; }
        public string Swiftcode { get; set; }
        public int StartIndex { get; set; }
        public int PageSize { get; set; }
        public bool IsBranch { get; set; }
        public int CityId { get; set; }
        public string PaymentMethod { get; set; }
    public string CurrencyCode { get; set; }
    public string bankId { get; set; }
    }

  public class GetStatus : CommonRequest {
    public string ControlNo { get; set; }
    public string PartnerPinNo { get; set; }
    public string TranNo { get; set; }
    public bool IsFromPartnerPinNo { get; set; }
    public string TranFlag { get; set; }
    public string fromDt { get; set; }
    public string toDt { get; set; }
  }

  public class Statements {
    public string record { get; set; }
    public string tranDate { get; set; }
    public string postDate { get; set; }
    public string time { get; set; }
    public string branch { get; set; }
    public string teller { get; set; }
    public string journal { get; set; }
    public string code { get; set; }
    public string amount { get; set; }
    public string balance { get; set; }
    public string debit { get; set; }
    public string correction { get; set; }
    public string description { get; set; }
    public string relatedAccount { get; set; }
    public string fromAccount { get; set; }
    public string toAccount { get; set; }
    public string dbOrCr {
      get {
        if (Convert.ToDecimal(amount) < 0) {
          return "zarlaga";
            } else {
          return "orlogo";
        }
      }
    }
    public string amountMoneyFormat {
      get {
        double mney = Convert.ToDouble(amount);
        return String.Format("{0:n}", mney);
          }
    }
    public string balanceMoneyFormat {
      get {
        double mney = Convert.ToDouble(balance);
        return String.Format("{0:n}", mney);
      }
    }
  }

  public class Ntry {

    [XmlElement(ElementName = "NtryRef")]
    public object NtryRef { get; set; }

    [XmlElement(ElementName = "Amt")]
    public object Amt { get; set; }

    [XmlElement(ElementName = "TxRt")]
    public object TxRt { get; set; }

    [XmlElement(ElementName = "TxDt")]
    public object TxDt { get; set; }

    [XmlElement(ElementName = "CtAcct")]
    public object CtAcct { get; set; }

    [XmlElement(ElementName = "TxAddInf")]
    public object TxAddInf { get; set; }

    [XmlElement(ElementName = "TxPostedDt")]
    public object TxPostedDt { get; set; }

    [XmlElement(ElementName = "txnType")]
    public object TxnType { get; set; }

    [XmlElement(ElementName = "Balance")]
    public object Balance { get; set; }

    public string amountMoneyFormat {
      get {
        double mney = Convert.ToDouble(Amt);
        return String.Format("{0:n}", mney);
      }
    }
    public string ntryRef {
      get {
        string ntryRef = NtryRef.ToString();
        return ntryRef;
      }
    }
    public string txRt {
      get {
        string ntryRef = TxRt.ToString();
        return ntryRef;
      }
    }
    public string txDt {
      get {
        string ntryRef = TxDt.ToString();
        return ntryRef;
      }
    }
    public string txAddInf {
      get {
        string ntryRef = TxAddInf.ToString();
        return ntryRef;
      }
    }
    public string txPostedDt {
      get {
        string ntryRef = TxPostedDt.ToString();
        return ntryRef;
      }
    }
    public string txnType {
      get {
        string ntryRef = TxnType.ToString();
        return ntryRef;
      }
    }
    public string ntrybalance {
      get {
        double ntryRef = Convert.ToDouble(Balance);
        return String.Format("{0:n}", ntryRef);
      }
    }
  }

}