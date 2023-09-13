using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.TranCancel
{
    public partial class View : System.Web.UI.Page
    {
        private RemittanceLibrary sl = new RemittanceLibrary();

        public void SearchData()
        {

            string controlNo = GetStatic.ReadQueryString("controlNo", "");
            var obj = new TranViewDao();
            var ds = obj.SelectCancelTransactionReceipt(GetStatic.GetUser(), controlNo);

            if (ds.Tables.Count > 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    sl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                    var tRow = ds.Tables[0].Rows[0];
                    lblControlNo.Text = tRow["controlNo"].ToString();
                    lblTranNo.Text = tRow["tranId"].ToString();
                    hddTranId.Value = tRow["tranId"].ToString();

                    sCustomerId.Text = tRow["sMemId"].ToString();
                    //   PAgent = tRow["pAgent"].ToString();

                    if (tRow["tranStatus"].ToString().ToUpper() == "LOCK")
                    {
                        lockAudit.Visible = true;
                        var html = new StringBuilder("Locked By ");
                        html.Append(tRow["lockedBy"] + " on " + tRow["lockedDate"]);
                        lockAudit.InnerHtml = html.ToString();
                    }


                    sName.Text = tRow["senderName"].ToString();
                    sAddress.Text = tRow["sAddress"].ToString();
                    sContactNo.Text = tRow["sContactNo"].ToString();
                    sTelNo.Text = tRow["sTelNo"].ToString();
                    sIdType.Text = tRow["sIdType"].ToString();
                    sIdNo.Text = tRow["sIdNo"].ToString();

                    rName.Text = tRow["receiverName"].ToString();
                    rAddress.Text = tRow["rAddress"].ToString();
                    rContactNo.Text = tRow["rContactNo"].ToString();
                    rIdType.Text = tRow["rIdType"].ToString();
                    rIdNo.Text = tRow["rIdNo"].ToString();
                    rTelNo.Text = tRow["rTelNo"].ToString();
                    if (tRow["tranStatus"].ToString() == "Cancel")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "CANCELLED Transaction";
                    }
                    if (tRow["tranStatus"].ToString() == "Block")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Block Transaction";
                    }
                    if (tRow["tranStatus"].ToString() == "CancelRequest")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Cancel Requested !";
                    }
                    if (tRow["tranStatus"].ToString() == "Lock")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Locked Transaction!";
                    }
                    if (tRow["tranStatus"].ToString() == "Compliance")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Compliance Transaction!";
                    }
                    if (tRow["tranStatus"].ToString() == "OFAC")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "OFAC Transaction!";
                    }


                    sCountry.Text = tRow["sCountryName"].ToString();
                    sCity.Text = tRow["sCity"].ToString();
                    sEmail.Text = tRow["sEmail"].ToString();
                    sNativeCountry.Text = tRow["nativeCountry"].ToString();

                    rCountry.Text = tRow["rCountryName"].ToString();
                    rCity.Text = tRow["rCity"].ToString();

                    //Sending Agent Detail
                    sAgentName.Text = tRow["sAgentName"].ToString();
                    sBranchName.Text = tRow["sBranchName"].ToString();
                    sAgentCountry.Text = tRow["sCountryName"].ToString();
                    sAgentAddress.Text = tRow["sAgentAddress"].ToString();

                    //Payout Agent Detail
                    pAgentCountry.Text = tRow["pAgentCountry"].ToString();
                    pAgentAddress.Text = tRow["pAgentAddress"].ToString();


                    accountNo.Text = tRow["accountNo"].ToString();
                    bankName.Text = tRow["BankName"].ToString();
                    branchName.Text = tRow["BranchName"].ToString();
                    pBranchName.Text = tRow["pBranchName"].ToString();

                    pAgentName.Text = tRow["expectedPayoutAgent"].ToString();

                    //sAgentComm.Text = GetStatic.FormatData(tRow["sAgentComm"].ToString(), "M");
                    //sAgentCommCurr.Text = tRow["sAgentCommCurrency"].ToString();
                    if (payStatus.Text == "Paid")
                    {
                        payAgentComm.Visible = true;
                        pAgentComm.Text = GetStatic.FormatData(tRow["pAgentComm"].ToString(), "M");
                        pAgentCommCurr.Text = tRow["pAgentCommCurrency"].ToString();
                    }

                    //Transaction Information
                    pnlShowBankDetail.Visible = tRow["CashOrBank"].ToString().ToUpper().Equals("BANK");
                    modeOfPayment.Text = tRow["paymentMethod"].ToString();
                    lblStatus.Text = tRow["payStatus"].ToString();
                    tranStatus.Text = tRow["tranStatus"].ToString();
                    lbltrnsubStatus.Text = tRow["tranStatus"].ToString();

                    payStatus.Text = tRow["payStatus"].ToString();
                    payoutMsg.Text = tRow["payoutMsg"].ToString();
                    sourceOfFund.Text = tRow["sourceOfFund"].ToString();
                    reasonOfRemit.Text = tRow["purposeOfRemit"].ToString();

                    //Payout Amount 
                    //handling.Text = GetStatic.FormatData(tRow["handlingFee"].ToString(), "M");
                    //exRate.Text = tRow["exRate"].ToString();
                    custRate.Text = tRow["custRate"].ToString();
                    //settRate.Text = tRow["settRate"].ToString();

                    transferAmount.Text = GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");
                    relationship.Text = tRow["relationship"].ToString();

                    tAmtCurr.Text = tRow["collCurr"].ToString();
                    scCurr.Text = tRow["collCurr"].ToString();
                    totalCurr.Text = tRow["collCurr"].ToString();
                    pAmtCurr.Text = tRow["payoutCurr"].ToString();

                    //Transaction Log Information
                    createdBy.Text = tRow["createdBy"].ToString();
                    createdDate.Text = tRow["createdDate"].ToString();
                    approvedBy.Text = tRow["approvedBy"].ToString();
                    approvedDate.Text = tRow["approvedDate"].ToString();
                    paidBy.Text = tRow["paidBy"].ToString();
                    paidDate.Text = tRow["paidDate"].ToString();
                    cancelRequestedBy.Text = tRow["cancelRequestBy"].ToString();
                    cancelRequestedDate.Text = tRow["cancelRequestDate"].ToString();
                    cancelApprovedBy.Text = tRow["cancelApprovedBy"].ToString();
                    cancelApprovedDate.Text = tRow["cancelApprovedDate"].ToString();

                    hddPayTokenId.Value = tRow["payTokenId"].ToString();

                    tblCreatedLog.Visible = createdBy.Text != "";
                    tblApprovedLog.Visible = approvedBy.Text != "";
                    tblPaidLog.Visible = paidBy.Text != "";
                    tblCancelRequestedLog.Visible = cancelRequestedBy.Text != "";
                    tblCancelApprovedLog.Visible = cancelApprovedBy.Text != "";
                }

                //if (ds.Tables[1].Rows.Count > 0)
                //{
                //    pnlLog.Visible = true;
                //    var dt = ds.Tables[1];
                //    var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                //    str.Append("<tr>");
                //    str.Append("<th>Updated By</th>");
                //    str.Append("<th width='130px'>Updated Date</th>");
                //    str.Append("<th>Message</th>");
                //    //str.Append("<th>Msg Type</th>");
                //    str.Append("</tr>");
                //    foreach (DataRow dr in dt.Rows)
                //    {
                //        str.Append("<tr>");
                //        str.Append("<td align='left'>" + dr["createdBy"] + "</td>");
                //        str.Append("<td align='left'>" + dr["createdDate"] + "</td>");
                //        if (dr["fileType"].ToString() == "")
                //        {
                //            str.Append("<td align='left'>" + dr["message"] + "</td>");
                //        }
                //        else
                //        {
                //            str.Append("<td align='left'><a title='View Deposit Slip' target='_blank' href='/doc/" + lblControlNo.Text + "/" + dr["rowId"].ToString() + "." + dr["fileType"].ToString() + "'>" + dr["message"] + "</a></td>");
                //        }
                //        // str.Append("<td align='left'>" + dr["msgType"] + "</td>");
                //        str.Append("</tr>");
                //    }
                //    str.Append("</table>");
                //    rptLog.InnerHtml = str.ToString();
                //}
                if (ds.Tables[1].Rows.Count > 0)
                {
                    var sb = new StringBuilder("");
                    sb.AppendLine("<table class='trnLog' style=\"width: 100%\" border=\"1\" cellspacing=0 cellpadding=\"3\"><tr>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>BANK/CASH</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Voucher No</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Amount</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Deposit Date</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Narration</th></tr>");

                    for (int a = 0; a < ds.Tables[1].Rows.Count; a++)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[1].Rows[a]["bankName"] + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[1].Rows[a]["voucherNo"] + "</td>");
                        sb.AppendLine("<td align='left'>" + GetStatic.ShowDecimal(ds.Tables[1].Rows[a]["Amt"].ToString()) + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[1].Rows[a]["collDate"] + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[1].Rows[a]["narration"] + "</td>");
                        sb.AppendLine("</tr>");
                    }
                    sb.AppendLine("</table>");
                    Ddetail.InnerHtml = sb.ToString();
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            SearchData();
        }

        private void Authenticate()
        {
            sl.CheckSession();
        }


        #region for desplaying a transaction comments log

        public void ShowLog()
        {
            var obj = new TranViewDao();
            var ds = obj.DisplayLog(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

            if (ds == null)
                return;
            if (ds.Tables[0].Rows.Count > 0)
            {
                pnlLog.Visible = true;
                var dt = ds.Tables[0];
                var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                str.Append("<th>Updated By</th>");
                str.Append("<th width='130px'>Updated Date</th>");
                str.Append("<th>Message</th>");
                // str.Append("<th>Msg Type</th>");
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    str.Append("<td align='left'>" + dr["createdBy"] + "</td>");
                    str.Append("<td align='left'>" + dr["createdDate"] + "</td>");
                    if (dr["fileType"].ToString() == "")
                    {
                        str.Append("<td align='left'>" + dr["message"] + "</td>");
                    }
                    else
                    {
                        str.Append("<td align='left'><a title='View Deposit Slip' target='_blank' href='/doc/" + lblControlNo.Text + "/" + dr["rowId"].ToString() + "." + dr["fileType"].ToString() + "'>" + dr["message"] + "</a></td>");
                    }
                    //str.Append("<td align='left'>" + dr["msgType"] + "</td>");
                    str.Append("</tr>");
                }
                str.Append("</table>");
                rptLog.InnerHtml = str.ToString();
            }
        }
        #endregion

    }
}