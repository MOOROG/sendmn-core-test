using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.PayTransaction
{
    public class PayTxnConfirm : CommonParam
    {
        public string SendingPartner { get; set; }
        public string rowId { get; set; }
        public string ControlNo { get; set; }
        public string ReceivingTokenId { get; set; }
        public string sCountry { get; set; }
        public string rIdType { get; set; }
        public string rIdNumber { get; set; }
        public string rIdPlaceOfIssue { get; set; }
        public string rIdPlaceOfIssueCode { get; set; }
        public string rIdIssueDate { get; set; }
        public string rIdExpiryDate { get; set; }
        public string rContactNo { get; set; }
        public string rDob { get; set; }
        public string receiverAddress { get; set; }
        public string receiverCity { get; set; }
        public string benefStateId { get; set; }
        public string benefCityId { get; set; }
        public string receiverCountry { get; set; }
        public string receiverCountryCode { get; set; }
        public string relationType { get; set; }
        public string relativeName { get; set; }
        public string customerId { get; set; }
        public string rBankName { get; set; }
        public string rBankBranch { get; set; }
        public string rCheque { get; set; }
        public string rAccountNo { get; set; }
        public string relationship { get; set; }
        public string purposeOfRemittance { get; set; }
        public string occupation { get; set; }
        public string txnDate { get; set; }
        public string pAmount { get; set; }
        public txnCompliance txnCompliance { get; set; }
    }

    public class txnCompliance
    {
        public List<result> result { get; set; }
        public string txnType { get; set; }
    }

    public class result
    {
        public string answer { get; set; }
        public string qId { get; set; }
        public string qType { get; set; }
    }
}