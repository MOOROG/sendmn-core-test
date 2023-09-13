using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SendTxn
{
    public class TxnReceiver
    {
        public string ReceiverId { get; set; }
        public string RFullName { get; set; }
        public string RFirstName { get; set; }
        public string RMiddleName { get; set; }
        public string RLastName { get; set; }
        public string RIdType { get; set; }
        public string RIdNo { get; set; }
        public string RIdIssuedDate { get; set; }
        public string RIdValidDate { get; set; }
        public string RDob { get; set; }
        public string RTel { get; set; }
        public string RMobile { get; set; }
        public string RNativeCountry { get; set; }
        public string RCity { get; set; }
        public string RAdd1 { get; set; }
        public string REmail { get; set; }
        public string RAccountNo { get; set; }
        public string RGender { get; set; }
        public int RCountryId { get; set; }
        public string RCountry { get; set; }
        public int RelWithSenderId { get; set; }
        public string RelWithSenderName { get; set; }
        public string RStateId { get; set; }
        public string RStateName { get; set; }
        public string RCityCode { get; set; }
        public string RDistrictCode { get; set; }
        public string UnitaryBankAccountNo { get; set; }
        public string RLocation { get; set; }
        public string RLocationName { get; set; }
    }
}