using System;

namespace Swift.DAL.OnlineAgent
{
    public class OnlineCustomerModel
    {
        public string flag { get; set; }
        public string customerId { get; set; }
        public string membershipId { get; set; }
        public string firstName { get; set; }
        public string middleName { get; set; }
        public string lastName1 { get; set; }
        public string lastName2 { get; set; }
        public string country { get; set; }
        public string address { get; set; }
        public string state { get; set; }
        public string province { get; set; }
        public string zipCode { get; set; }
        public string district { get; set; }
        public string city { get; set; }
        public string email { get; set; }
        public string homePhone { get; set; }
        public string workPhone { get; set; }
        public string mobile { get; set; }
        public string nativeCountry { get; set; }
        public string dob { get; set; }
        public string placeOfIssue { get; set; }
        public string customerType { get; set; }
        public string occupation { get; set; }
        public string isBlackListed { get; set; }
        public string createdBy { get; set; }
        public string createdDate { get; set; }
        public string modifiedBy { get; set; }
        public string modifiedDate { get; set; }
        public string approvedBy { get; set; }
        public string approvedDate { get; set; }
        public string isDeleted { get; set; }
        public string lastTranId { get; set; }
        public int relationId { get; set; }
        public string relativeName { get; set; }
        public string address2 { get; set; }
        public string fullName { get; set; }
        public string postalCode { get; set; }
        public string idExpiryDate { get; set; }
        public string idType { get; set; }
        public string idNumber { get; set; }
        public string telNo { get; set; }
        public string companyName { get; set; }
        public string gender { get; set; }
        public int salaryRange { get; set; }
        public Decimal bonusPointPending { get; set; }
        public Decimal Redeemed { get; set; }
        public Decimal bonusPoint { get; set; }
        public Decimal todaysSent { get; set; }
        public int todaysNoOfTxn { get; set; }
        public int agentId { get; set; }
        public int branchId { get; set; }
        public DateTime memberIDissuedDate { get; set; }
        public string memberIDissuedByUser { get; set; }
        public string memberIDissuedAgentId { get; set; }
        public string memberIDissuedBranchId { get; set; }
        public Decimal totalSent { get; set; }
        public string idIssueDate { get; set; }
        public bool onlineUser { get; set; }
        public string customerPassword { get; set; }
        public string customerStatus { get; set; }
        public string isActive { get; set; }
        public string islocked { get; set; }
        public string sessionId { get; set; }
        public DateTime lastLoginTs { get; set; }
        public string howDidYouHear { get; set; }
        public string ansText { get; set; }
        public string ansEmail { get; set; }
        public string state2 { get; set; }
        public string ipAddress { get; set; }
        public string marketingSubscription { get; set; }
        public string userInfoDetail { get; set; }
        public string verifyDoc1 { get; set; }
        public string verifyDoc2 { get; set; }
        public string verifyDoc3 { get; set; }
        public string verifyDoc4 { get; set; }
        public string bankName { get; set; }
        public string bankId { get; set; }
        public string accountNumber { get; set; }
        public int HasDeclare { get; set; }

        /// <summary>
        /// Added Field
        /// </summary>
        public string street { get; set; }

        public string senderCityjapan { get; set; }
        public string streetJapanese { get; set; }
        public string visaStatus { get; set; }
        public string employeeBusinessType { get; set; }
        public string nameofEmployeer { get; set; }
        public string ssnNo { get; set; }
        public string sourceOfFound { get; set; }
        public bool remitanceAllowed { get; set; }
        public string remarks { get; set; }
        public string registrationNo { get; set; }
        public string organizationType { get; set; }
        public string dateOfIncorporation { get; set; }
        public string natureOfCompany { get; set; }
        public string position { get; set; }
        public string nameofAuthoPerson { get; set; }
        public string MonthlyIncome { get; set; }
        public string IsCounterVisited { get; set; }
        public string AdditionalAddress { get;set; }
        public string DocumentType { get;set; }

    public string occupType { get; set; }
    public string isOrg { get; set; }
    public string userName { get; set; }
    public string nonMonPep { get; set; }

  }
}