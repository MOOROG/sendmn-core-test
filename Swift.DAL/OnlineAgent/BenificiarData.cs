using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Swift.DAL.OnlineAgent
{
    public class BenificiarData
    {
        public string Flag { get; set; }
        public string ReceiverId { get; set; }
        public string customerId { get; set; }
        public string membershipId { get; set; }
        public string Country { get; set; }
        public string Email { get; set; }
        public string BenificiaryType { get; set; }
        public string ReceiverFName { get; set; }
        public string ReceiverMName { get; set; }
        public string ReceiverLName { get; set; }
        public string ReceiverLName2 { get; set; }
        public string ReceiverAddress { get; set; }
        public string State { get; set; }
        public string ReceiverCity { get; set; }
        public string ContactNo { get; set; }
        public string SenderMobileNo { get; set; }
        public string Relationship { get; set; }
        public string PlaceOfIssue { get; set; }
        public string TypeId { get; set; }
        public string TypeValue { get; set; }
        public string PurposeOfRemitance { get; set; }
        public string PayoutPatner { get; set; }
        public string PaymentMode { get; set; }
        public string BankLocation { get; set; }
        public string BankName { get; set; }
        public string BenificaryAc { get; set; }
        public string Remarks { get; set; }
        public string NativeCountry { get; set; }
        public string OtherRelationDescription { get; set; }
        public int agentId { get; set; }
    public string approvedBy { get; set; }
    public DateTime? approvedDate { get; set; }
    public int isOrg { get; set; }
    public string bIkk { get; set; }
    public string bInn { get; set; }
  }
}