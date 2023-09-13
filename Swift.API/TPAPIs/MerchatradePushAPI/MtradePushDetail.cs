using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.MerchatradePushAPI
{
    public class MtradePushDetail
    {
        public string collTranId { get; set; }                              //GME unique number
        public string controlNo { get; set; }
        public string payoutAgentCd { get; set; }
        public string payoutAmount { get; set; }
        public string payoutCurrency { get; set; }
        public string payoutMode { get; set; }                              //1 - Bank Deposit and 2 - Cash Payment
        public string senderFirstName { get; set; }
        public string senderMiddleName { get; set; }
        public string senderLastName { get; set; }
        public string senderAddress { get; set; }
        public string senderNationalityCd { get; set; }
        public string senderIdCardTypeCd { get; set; }
        public string senderIdCardTypeNo { get; set; }
        public string senderMonthlySalary { get; set; }                     //X
        public string receiverFirstName { get; set; }                       //X
        public string receiverMiddleName { get; set; }                      //X
        public string receiverLastName { get; set; }
        public string receiverAddress { get; set; }
        public string senderPhoneNo { get; set; }
        public string receiverPhoneNo { get; set; }
        public string receiverNationalityCd { get; set; }
        public string receiverBankCd { get; set; }                          //only for bank depost, for cassh-empty
        public string receiverBankBranchCd { get; set; }                    //only for bank depost, for cassh-empty
        public string receiverBankAcNo { get; set; }                        //only for bank depost, for cassh-empty
        public string receiverIdCardTypeCd { get; set; }
        public string receiverIdCardTypeNo { get; set; }
        public string senderRelationWithReceiverCd { get; set; }
        public string sourceOfFundCd { get; set; }
        public string reasonOfRemittanceCd { get; set; }
        public string senderOccupationCd { get; set; }
        public string senderBirthDate { get; set; }                         //Company regd. date
        public string reasonOfRemittanceText { get; set; }
        public string sourceOfFundText { get; set; }
        public string remarks { get; set; }
        public string occupationText { get; set; }                          //Text for other nature of business
        public string relationshipText { get; set; }
        public string remitType { get; set; }
        public string countryofBusiness { get; set; }                       //Country of business. ISO country code 2 digit
        public string personName { get; set; }                              //Authorized person name
        public string personIdCardTypeCd { get; set; }
        public string personIdCardTypeNo { get; set; }
        public string personDateofBirth { get; set; }                       //YYYY-MM-DD
        public string personDesignation { get; set; }
        public string personNationalityCd { get; set; }
    }
}
