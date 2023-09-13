using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.Domain
{
    public class TranDetail
    {
        public string User { get; set; }
        public string ControlNo { get; set; }
        public string TxnId { get; set; }
        public string AgentRefId { get; set; }
        public string SBranch { get; set; }
        public string SBranchName { get; set; }
        public string SAgent { get; set; }
        public string SAgentName { get; set; }
        public string SSuperAgent { get; set; }
        public string SSuperAgentName { get; set; }
        public string SettlingAgent { get; set; }
        public string MapCodeInt { get; set; }
        public string MapCodeDom { get; set; }
        public string PBankBranch { get; set; }
        public string AccountNo { get; set; }
        public string PLocation { get; set; }
        public string TransferAmt { get; set; }
        public string ServiceCharge { get; set; }
        public string TotalCollection { get; set; }
        public string PayoutAmt { get; set; }
        public string DeliveryMethod { get; set; }
        public string SenderId { get; set; }
        public string SMemId { get; set; }
        public string SFirstName { get; set; }
        public string SMiddleName { get; set; }
        public string SLastName1 { get; set; }
        public string SLastName2 { get; set; }
        public string SAddress { get; set; }
        public string SContactNo { get; set; }
        public string SIDType { get; set; }
        public string SIDNo { get; set; }
        public string SEmail { get; set; }
        public string ReceiverId { get; set; }
        public string RMemId { get; set; }
        public string RFirstName { get; set; }
        public string RMiddleName { get; set; }
        public string RLastName1 { get; set; }
        public string RLastName2 { get; set; }
        public string RAddress { get; set; }
        public string RContactNo { get; set; }
        public string RIDType { get; set; }
        public string RIDNo { get; set; }
        public string RelWithSender { get; set; }
        public string PayoutMsg { get; set; }
        public string txtPass { get; set; }
        public string DcInfo { get; set; }
        public string IpAddress { get; set; }
        public string ComplianceAction { get; set; }
        public string CompApproveRemark { get; set; }

        public string SDOB { get; set; }
        public string SIDIssuedDate { get; set; }
        public string SIDValidDate { get; set; }

        public string SDOBBs { get; set; }
        public string SIDIssuedDateBs { get; set; }
        public string SIDValidDateBs { get; set; }
        public string SIDIssuedPlace { get; set; }
        // for fee collection transaction send
        public string StdCollege { get; set; }
        public string StdName { get; set; }
        public string StdLevel { get; set; }
        public string StdFeeType { get; set; }
        public string StdRollRegNo { get; set; }
        public string StdSemYr { get; set; }
        public string StdDesc { get; set; }

        //Customer Due Diligence Information -(CDDI)
        public string SourceOfFund { get; set; }
        public string PurposeOfRemit { get; set; }
        public string Occupation { get; set; }
        public string TopupMobileNo { get; set; }

        //Sajilo Wallet Cash IN
        public string SWalletId { get; set; }
        public string RWalletId { get; set; }
        public string SMobile { get; set; }
        public string RMobile { get; set; }
        public string REmail { get; set; }

        public string txnBatchId { get; set; }
        public string txnDocFolder { get; set; }

        //Issue Customer Card
        public string CustCardId { get; set; }
        public string sGender { get; set; }
        public string sParentSpouseName { get; set; }

        public string sAmountThreshold { get; set; }
    }
}
