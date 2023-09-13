using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.Send.SendMoneyv2
{
    public partial class SendIntlReceipt : System.Web.UI.Page
    {
        private readonly ReceiptDao obj = new ReceiptDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            GetStatic.AlertMessage(this.Page);
            ShowData();
            //ShowMultipleReceipt();
        }

        private string GetControlNo()
        {
            return GetStatic.ReadQueryString("controlNo", "");
        }

        protected void ShowData()
        {
            //lblControlNo.Text = GetStatic.GetTranNoName();
            DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
            if (ds.Tables.Count >= 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    //Load Sender Information
                    DataRow sRow = ds.Tables[0].Rows[0];
                    senderName.Text = sRow["senderName"].ToString();
                    sMemId.Text = sRow["sMemId"].ToString();
                    sAddress.Text = sRow["sAddress"].ToString();
                    sNativeCountry.Text = sRow["sNativeCountry"].ToString();
                    purpose.Text = sRow["purpose"].ToString();
                    sDob.Text = sRow["sDob"].ToString();
                    sContactNo.Text = sRow["sContactNo"].ToString();

                    //Load Receiver Information
                    receiverName.Text = sRow["receiverName"].ToString();
                    pAgentCountry.Text = sRow["pAgentCountry"].ToString();
                    paymentMode.Text = sRow["paymentMode"].ToString();
                    rContactNo.Text = sRow["rContactNo"].ToString();
                    pAgent.Text = sRow["pAgent"].ToString();
                    rAddress.Text = sRow["rAddress"].ToString();
                    pBankName.Text = sRow["pBankName"].ToString();


                    pBranchName.Text = sRow["pBranchName"].ToString();
                    accountNo.Text = sRow["accountNo"].ToString();
                    rAmtWords.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
                    controlNo.Text = sRow["controlNo"].ToString();
                    createdBy.Text = sRow["createdBy"].ToString();
                    approvedDate.Text = sRow["approvedDate"].ToString();

                    cAmt.Text = GetStatic.ShowDecimal(sRow["cAmt"].ToString()) + sRow["collCurr"].ToString();
                    serviceCharge.Text = sRow["serviceCharge"].ToString() + sRow["collCurr"].ToString();


                    tAmt.Text = GetStatic.ShowDecimal(sRow["tAmt"].ToString()) + sRow["collCurr"].ToString();
                    exRate.Text = sRow["exRate"].ToString();
                    pAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + sRow["payoutCurr"].ToString();


                    operator1.Text = sRow["createdBy"].ToString();

                    //for second from
                    //Load Sender Information
                    senderName1.Text = sRow["senderName"].ToString();
                    sMemId1.Text = sRow["sMemId"].ToString();
                    sAddress1.Text = sRow["sAddress"].ToString();
                    sNativeCountry1.Text = sRow["sNativeCountry"].ToString();
                    purpose1.Text = sRow["purpose"].ToString();
                    sDob1.Text = sRow["sDob"].ToString();
                    sContactNo1.Text = sRow["sContactNo"].ToString();

                    //Load Receiver Information
                    receiverName1.Text = sRow["receiverName"].ToString();
                    pAgentCountry1.Text = sRow["pAgentCountry"].ToString();
                    paymentMode1.Text = sRow["paymentMode"].ToString();
                    rContactNo1.Text = sRow["rContactNo"].ToString();
                    pAgent1.Text = sRow["pAgent"].ToString();
                    rAddress1.Text = sRow["rAddress"].ToString();
                    pBankName1.Text = sRow["pBankName"].ToString();


                    pBranchName1.Text = sRow["pBranchName"].ToString();
                    accountNo1.Text = sRow["accountNo"].ToString();
                    rAmtWords1.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
                    controlNo1.Text = sRow["controlNo"].ToString();
                    createdBy1.Text = sRow["createdBy"].ToString();
                    approvedDate1.Text = sRow["approvedDate"].ToString();

                    cAmt1.Text = GetStatic.ShowDecimal(sRow["cAmt"].ToString()) + sRow["collCurr"].ToString();
                    serviceCharge1.Text = sRow["serviceCharge"].ToString() + sRow["collCurr"].ToString();


                    tAmt1.Text = GetStatic.ShowDecimal(sRow["tAmt"].ToString()) + sRow["collCurr"].ToString();
                    exRate1.Text = sRow["exRate"].ToString();
                    pAmt1.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + sRow["payoutCurr"].ToString();


                    operator2.Text = sRow["createdBy"].ToString();



                }
            }

        }
    }
}