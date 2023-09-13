using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.DongaPushAPI
{
    public class DongaPushDetail
    {
        //Get Api Key params
        public string SumTransaction { get; set; }          //How many data will be sent in batch from below all Sum's (if we send SumUSD and SumVND then it will be 2)
        public string SumUSD { get; set; }
        public string SumAUD { get; set; }
        public string SumCAD { get; set; }
        public string SumEUR { get; set; }
        public string SumVND { get; set; }
        public string SumGBP { get; set; }
        public string SumJPY { get; set; }

        public string controlNo { get; set; }
        public string SessionID { get; set; }

        //Send Txn params
        public string TransactionID { get; set; }           //The trading code
        public string Sender { get; set; }                  //Full name of sender in board
        public string Receiver { get; set; }                //Full name of the beneficiary in Vietnam
        public string Address { get; set; }                 //The address of the beneficiary
        public string CityCode { get; set; }                //City/Province code of the beneficiary
        public string DistrictCode { get; set; }            //District code of the beneficiary
        public string Amount { get; set; }                  //The amount of money tranfered
        public string SCurrency { get; set; }               //Currency transferred to the beneficiary
        public string RCurrency { get; set; }               //Currency the beneficiary will received
        public string PaymentMode { get; set; }             //CP: Counter Pickup, HD: Home Delivery and TA: To Account
        public string Phone { get; set; }
        public string BankAccount { get; set; }             //Bank number of the beneficiary’s bank account
        public string BankCode { get; set; }                //Bank code of the beneficiary
        public string BranchState { get; set; }             //Branch name of beneficiary’s bank (If is provided: DAMTC will make sure completed transaction in a shortest time.)
        public string Note { get; set; }                    //Notice of transaction
    }
}
