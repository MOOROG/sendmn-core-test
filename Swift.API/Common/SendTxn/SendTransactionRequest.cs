using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SendTxn
{
    public class SendTransactionRequest
    {
        public string ProcessId { get; set; }
        public string UserName { get; set; }
        public string ProviderId { get; set; }
        public string SessionId { get; set; }
        public string RequestedBy { get; set; }

        public int TranId { get; set; }

        public bool isTxnAlreadyCreated { get; set; }

        #region SenderInformation

        public TxnSender Sender { get; set; }

        #endregion SenderInformation

        #region receiveInformtaion

        public TxnReceiver Receiver { get; set; }

        #endregion receiveInformtaion

        #region txnInformation

        public TxnTransaction Transaction { get; set; }

        #endregion txnInformation

        #region agentInformation

        public TxnAgent Agent { get; set; }

        #endregion agentInformation

        public bool IsRealtime { get; set; }

        public string IsManualSc { get; set; }

        public decimal ManualSc { get; set; }
        public bool IsApproveTxn { get; set; }
    }

  public class MobileRemitRequest {
    public string User { get; set; }
    public string SenderId { get; set; }
    public string ReceiverId { get; set; }
    public string DeliveryMethodId { get; set; }
    public string PBranch { get; set; }
    public string PAgent { get; set; }
    public string PCurr { get; set; }
    public string CollCurr { get; set; }
    public string CollAmt { get; set; }
    public string PayoutAmt { get; set; }
    public string TransferAmt { get; set; }
    public string ServiceCharge { get; set; }
    public string Discount { get; set; }
    public string ExRate { get; set; }
    public string CalBy { get; set; }
    public string PurposeOfRemittance { get; set; }
    public string SourceOfFund { get; set; }
    public string RelWithSender { get; set; }
    public string Occupation { get; set; }
    public string IpAddress { get; set; }
    public string RState { get; set; }
    public string RLocation { get; set; }
    public string TpExRate { get; set; }
    public string TpPCurr { get; set; }
    public string PayOutPartner { get; set; }
    public string FOREX_SESSION_ID { get; set; }
    public string PaymentType { get; set; }
    public string IsAgreed { get; set; }
    public string TxnPassword { get; set; }
    public string ProcessId { get; set; }
    public string ReceiverAccountNo { get; set; }
    public string schemeId { get; set; }
    public bool isUseBiometric { get; set; }
    public txnCompliance txnCompliance { get; set; }
    public string senderIsOrg { get; set; }
    public string receiverIsOrg { get; set; }
    public string receiverBinn { get; set; }
    public string receiverBikk { get; set; }
    public string transactionDesc { get; set; }
    public string whichCur { get; set; }
  }

  public class txnCompliance {
    public List<result> result { get; set; }
    public string txnType { get; set; }
  }

  public class result {
    public string answer { get; set; }
    public string qId { get; set; }
    public string qType { get; set; }
  }
}