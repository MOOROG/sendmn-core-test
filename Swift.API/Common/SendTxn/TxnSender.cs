using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.Common.SendTxn
{
    public class TxnSender
    {
        public int CustomerId { get; set; }
        public string SFirstName { get; set; }
        public string SMiddleName { get; set; }
        public string SLastName1 { get; set; }
        public string SLastName2 { get; set; }
        public string SFullName { get; set; }
        public string SIdType { get; set; }
        public string SIdNo { get; set; }
        public string SIdIssueDate { get; set; }
        public string SIdExpiryDate { get; set; }
        public int SOccuptionId { get; set; }
        public string SOccuptionName { get; set; }
        public string SBirthDate { get; set; }
        public string SEmail { get; set; }
        public string SCityId { get; set; }
        public string SCity { get; set; }
        public string SState { get; set; }
        public string FormOfPaymentId { get; set; }
        public string SZipCode { get; set; }
        public string SNativeCountry { get; set; }
        public string SMobile { get; set; }
        public string STel { get; set; }
        public string SAddress { get; set; }
        public string SIpAddress { get; set; }
        public string SGender { get; set; }
        public string SCustStreet { get; set; }
        public string SCustLocation { get; set; }
        public string SourceOfFund { get; set; }
        public string Pwd { get; set; }
        public bool IsIndividual { get; set; }
        public int SCountryId { get; set; }
        public string SCountryName { get; set; }
        public int SBranchId { get; set; }
        public string SBranchName { get; set; }
        public int CustomerDepositedBank { get; set; }
    }
}