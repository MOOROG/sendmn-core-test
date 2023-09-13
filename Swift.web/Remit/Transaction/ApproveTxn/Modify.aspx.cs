using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ApproveTxn
{
    public partial class Modify : System.Web.UI.Page
    {
        private RemittanceLibrary sl = new RemittanceLibrary();
        private string GetTranId()
        {
            return GetStatic.ReadQueryString("tranId", "");
        }

        public void SearchData(string tranNo, string mode, string viewType, string viewMsg)
        {
            tranNoName.Text = GetStatic.GetTranNoName();
            var obj = new TranViewDao();
            var ds = obj.SelectTxnModificationAgent(GetStatic.GetUser(), tranNo, viewType, viewMsg, GetStatic.GetIp(), "");

            if (ds == null)
            {
                sl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            if (ds.Tables.Count > 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    sl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                    var tRow = ds.Tables[0].Rows[0];
                    lblControlNo.Text = tRow["controlNo"].ToString();
                    lblTranNo.Text = tRow["holdTranId"].ToString();
                    hddTranId.Value = tRow["holdTranId"].ToString();
                    sCustomerId.Text = tRow["sMemId"].ToString();

                    if (mode == "u") // mode: modification transaction
                    {
                        rName.Text = GetLinkTextForModification("Receiver Name", "receiverName", tRow);
                        rAddress.Text = GetLinkTextForModification("Receiver Address", "rAddress", tRow);
                        rContactNo.Text = GetLinkTextForModification("Receiver Contact No", "rContactNo", tRow);
                        rIdType.Text = GetLinkTextForModification("Receiver Id Type", "rIdType", tRow);
                        rIdNo.Text = GetLinkTextForModification("Receiver Id No", "rIdNo", tRow);
                        rTelNo.Text = GetLinkTextForModification("Telephone No","rTelNo",tRow);
                        accountNo.Text = GetLinkTextForModification("Account No", "accountNo", tRow);
                        relationship.Text = GetLinkTextForModification("Relationship With Sender", "relationship", tRow); 
                    }
                    else
                    {
                        accountNo.Text = tRow["accountNo"].ToString();
                        rName.Text = tRow["receiverName"].ToString();
                        rAddress.Text = tRow["rAddress"].ToString();
                        rContactNo.Text = tRow["rContactNo"].ToString();
                        rIdType.Text = tRow["rIdType"].ToString();
                        rIdNo.Text = tRow["rIdNo"].ToString();
                        rTelNo.Text = tRow["rTelNo"].ToString();
                        relationship.Text = tRow["relationship"].ToString();
                    }
                    sName.Text = tRow["senderName"].ToString();
                    sAddress.Text = tRow["sAddress"].ToString();
                    sContactNo.Text = tRow["sContactNo"].ToString();
                    sTelNo.Text = tRow["sTelNo"].ToString();
                    sIdType.Text = tRow["sIdType"].ToString();
                    sIdNo.Text = tRow["sIdNo"].ToString();

                    hdnRName.Value = tRow["receiverName"].ToString();
                    hdnSName.Value = tRow["senderName"].ToString();

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
                    
                    
                    bankName.Text = tRow["BankName"].ToString();
                    branchName.Text = tRow["BranchName"].ToString();
                    pBranchName.Text = tRow["pBranchName"].ToString();
                    
                   
                    pAgentName.Text = tRow["pAgentName"].ToString();
                    sAgentComm.Text = GetStatic.FormatData(tRow["sAgentComm"].ToString(), "M");
                    sAgentCommCurr.Text = tRow["sAgentCommCurrency"].ToString();

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
                    custRate.Text = tRow["custRate"].ToString();
                    settRate.Text = tRow["settRate"].ToString();

                    transferAmount.Text = GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");

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

                if (ds.Tables[1].Rows.Count > 0)
                {
                    pnlLog.Visible = true;
                    var dt = ds.Tables[1];
                    var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                    str.Append("<tr>");
                    str.Append("<th>Updated By</th>");
                    str.Append("<th width='130px'>Updated Date</th>");
                    str.Append("<th>Message</th>");
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
                        str.Append("</tr>");
                    }
                    str.Append("</table>");
                    rptLog.InnerHtml = str.ToString();
                }
                if (ds.Tables[2].Rows.Count > 0)
                {
                    var sb = new StringBuilder("");
                    sb.AppendLine("<table class='trnLog' style=\"width: 100%\" border=\"1\" cellspacing=0 cellpadding=\"3\"><tr>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>BANK/CASH</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Voucher No</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Amount</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Deposit Date</th>");
                    sb.AppendLine("<th nowrap='nowrap' align='left'>Narration</th></tr>");

                    for (int a = 0; a < ds.Tables[2].Rows.Count; a++)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[2].Rows[a]["bankName"] + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[2].Rows[a]["voucherNo"] + "</td>");
                        sb.AppendLine("<td align='left'>" + GetStatic.ShowDecimal(ds.Tables[2].Rows[a]["Amt"].ToString()) + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[2].Rows[a]["collDate"] + "</td>");
                        sb.AppendLine("<td align='left'>" + ds.Tables[2].Rows[a]["narration"] + "</td>");
                        sb.AppendLine("</tr>");
                    }
                    sb.AppendLine("</table>");
                    Ddetail.InnerHtml = sb.ToString();
                }
            }
        }

        public string GetLinkTextForModification(string label, string fieldName, DataRow dr)
        {
            var str = "<a href=# title='Edit Record'><div class = \"link\" onclick = \"EditData('" + label + "', '" + fieldName + "', '" + dr[fieldName] + "','" + hddTranId.Value + "')\">" +
                      dr[fieldName] + "<img border=0 src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\"/></a></div>";
            return str;
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SearchData(GetTranId(), "u", "SEARCH", "AGENT:SEARCH TXN FOR MODIFICATION");
            Authenticate();
            ShowOFACList();
            ShowComplianceList();
        }

        private void Authenticate()
        {
            sl.CheckSession();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (GetStatic.GetIsApiFlag() == "Y")
                AddCommentApi();
            else
                AddComment();
            comments.Text = "";
            ShowLog();
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
                    str.Append("</tr>");
                }
                str.Append("</table>");
                rptLog.InnerHtml = str.ToString();
            }
        }
        #endregion

        protected void btnReloadDetail_Click(object sender, EventArgs e)
        {
            SearchData(GetTranId(), "u", "SEARCH", "AGENT:SEARCH TXN FOR MODIFICATION");
        }

        public void ShowOFACList()
        {
            var obj = new TranViewDao();
            var ds = obj.DisplayOFAC(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

            if (ds == null)
            {
                pnlOFAC.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var senderName = hdnSName.Value;
                var recName = hdnRName.Value;
                var name = senderName + ' ' + recName;

                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    str.Append("<td align=\"left\">" + dr[0] + "</td>");
                   
                    var strArr = name.Split(' ');
                    var arrlen = strArr.Length;
                    string value = dr[1].ToString();
                    for (int j = 0; j < arrlen; j++)
                    {
                        if (!string.IsNullOrWhiteSpace(strArr[j]))
                        {
                            value = value.ToUpper().Replace(strArr[j],GetStatic.PutRedBackGround(strArr[j]));
                        }
                    }
                    str.Append("<td align=\"left\">" + value + "</td>");
                    str.Append("</tr>");
                }
                str.Append("</table>");
                displayOFAC.InnerHtml = str.ToString();
                GetStatic.AlertMessage(Page);
            }
        }

        public void ShowComplianceList()
        {
            var obj = new TranViewDao();
            var ds = obj.DisplayCompliance(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

            if (ds == null)
            {
                pnlCompliance.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='trnLog' border=\"1\" cellspacing=0 cellpadding=\"3\">");
                str.Append("<tr>");
                for (int i = 2; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 2; i < cols; i++)
                    {
                        if (i == 4)
                        {
                            var strArr = dr["Matched Tran ID"].ToString().Split(',');
                            var arrlen = strArr.Length;
                            str.Append("<td>");
                            for (int j = 0; j < arrlen; j++)
                            {
                                str.Append("<a href=\"#\" onclick=\"OpenInNewWindow('/Remit/Transaction/Reports/SearchTransaction.aspx?tranId=" + strArr[j] + "')\">" + strArr[j] + "</a> &nbsp;");
                            }
                            str.Append("</td>");
                        }
                        else if (i == 3)
                        {
                            str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" + dr["rowId"].ToString() + "&csID=" + dr["csDetailRecId"] + "')\">" + dr[i].ToString() + "</a></td>");
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
                str.Append("</table>");
                displayCompliance.InnerHtml = str.ToString();
                GetStatic.AlertMessage(Page);
            }
        }

        public void AddComment()
        {
            var obj = new TranViewDao();
            DbResult dbResult = obj.AddComment(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, comments.Text);
            ManageMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.CallBackJs1(Page, "Result", "alert('" + dbResult.Msg + "')");
                return;
            }
            else
            {
                //SetupEmailSetting();
                //SendMail();
            }
        }

        public void AddCommentApi()
        {
            GetStatic.AddTroubleTicket(Page, lblControlNo.Text, comments.Text, 2);
            AddComment();
        }
        /*
        private delegate void DoStuff(); //delegate for the action

        private void SendMail()
        {
            var myAction = new DoStuff(AsyncMailProcessing);
            myAction.BeginInvoke(null, null);
        }

        private void AsyncMailProcessing()
        {
            var bw = new BackgroundWorker();

            // this allows our worker to report progress during work
            bw.WorkerReportsProgress = true;

            // what to do in the background thread
            bw.DoWork += new DoWorkEventHandler(
            delegate(object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                smtpMailSetting.SendSmtpMail(smtpMailSetting);
            });

            // what to do when progress changed (update the progress bar for example)
            bw.ProgressChanged += new ProgressChangedEventHandler(
            delegate(object o, ProgressChangedEventArgs args)
            {
                //label1.Text = string.Format("{0}% Completed", args.ProgressPercentage);
            });

            // what to do when worker completes its task (notify the user)
            bw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(
            delegate(object o, RunWorkerCompletedEventArgs args)
            {
                var dbResult = new DbResult();
                dbResult.SetError("0", "Mail Sent Successfully", "");
                GetStatic.PrintMessage(Page, dbResult);
            });

            bw.RunWorkerAsync();
        }

        private void SetupEmailSetting()
        {
            var obj = new SystemEmailSetupDao();
            var ds = obj.GetDataForEmail(GetStatic.GetUser(), "Trouble", lblControlNo.Text, comments.Text);
            if (ds == null)
                return;
            if (ds.Tables.Count == 0)
                return;
            if (ds.Tables.Count > 1)
            {
                //Email Server Settings
                if (ds.Tables[0].Rows.Count > 0)
                {
                    var dr1 = ds.Tables[0].Rows[0];
                    smtpMailSetting.SmtpServer = dr1["smtpServer"].ToString();
                    smtpMailSetting.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
                    smtpMailSetting.SendEmailId = dr1["sendID"].ToString();
                    smtpMailSetting.SendEmailPwd = dr1["sendPSW"].ToString();
                    smtpMailSetting.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());
                }
                if (ds.Tables[1].Rows.Count == 0)
                    return;
                //Email Receiver
                if (ds.Tables[1].Rows.Count > 0)
                {
                    var dt = ds.Tables[1];
                    foreach (DataRow dr2 in dt.Rows)
                    {
                        if (!string.IsNullOrEmpty(smtpMailSetting.ToEmails))
                            smtpMailSetting.ToEmails = smtpMailSetting.ToEmails + ",";
                        smtpMailSetting.ToEmails = smtpMailSetting.ToEmails + dr2["email"].ToString();
                    }
                }
                //Email Subject and Body
                if (ds.Tables[2].Rows.Count > 0)
                {
                    var dr3 = ds.Tables[2].Rows[0];
                    if (dr3 == null)
                        return;
                    smtpMailSetting.MsgSubject = dr3[0].ToString();
                    smtpMailSetting.MsgBody = dr3[1].ToString();
                }
            }
        }
          */
    }
}