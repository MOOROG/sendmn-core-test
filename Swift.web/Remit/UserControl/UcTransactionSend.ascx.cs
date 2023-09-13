using System;
using System.ComponentModel;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.UserControl
{
    public partial class UcTransactionSend : System.Web.UI.UserControl
    {
        private RemittanceLibrary sl = new RemittanceLibrary();
        private SmtpMailSetting smtpMailSetting = new SmtpMailSetting();
        private const string ModifyPayoutLocationId = "20121520";
        private const string ModifyPayoutLocationIdAg = "40101730";
        public bool ShowDetailBlock { get; set; }
        public bool ShowLogBlock { get; set; }

        private bool _showCommentBlock = true;
        public bool ShowCommentBlock
        {
            get { return _showCommentBlock; }
            set { _showCommentBlock = value; }
        }

        public bool ShowBankDetail { get; set; }
        public bool ShowOfac { get; set; }
        public bool ShowCompliance { get; set; }
        public bool ShowApproveButton { get; set; }
        public bool ShowSettlment { get; set; }

        public string PAgent
        {
            get { return pAgent.Value; }
            set { pAgent.Value = value; }
        }
        public string TranNo
        {
            get { return hddTranId.Value; }
            set { hddTranId.Value = value; }
        }
        public string CtrlNo
        {
            get { return lblControlNo.Text; }
            set { lblControlNo.Text = value; }
        }
        public string PayTokenId
        {
            get { return hddPayTokenId.Value; }
            set { hddPayTokenId.Value = value; }
        }
        public string TranStatus
        {
            get { return tranStatus.Text; }
            set { tranStatus.Text = value; }
        }
        public string ModeOfPayment
        {
            get { return modeOfPayment.Text; }
            set { modeOfPayment.Text = value; }
        }
        public string CreatedBy
        {
            get { return createdBy.Text; }
            set { createdBy.Text = value; }
        }
        public string ApprovedBy
        {
            get { return approvedBy.Text; }
            set { approvedBy.Text = value; }
        }
        public string PaidBy
        {
            get { return paidBy.Text; }
            set { paidBy.Text = value; }
        }
        public string CancelRequestedBy
        {
            get { return cancelRequestedBy.Text; }
            set { cancelRequestedBy.Text = value; }
        }
        public string CancelApprovedBy
        {
            get { return cancelApprovedBy.Text; }
            set { cancelApprovedBy.Text = value; }
        }

        public bool TranFound { get; set; }

        public void SearchData(string tranNo, string ctrlNo, string mode, string lockMode)
        {
            SearchData(tranNo, ctrlNo, mode, lockMode, "SEARCH", "ADM:SEARCH TXN");
        }

        public void SearchData(string tranNo, string ctrlNo, string mode, string lockMode, string viewType, string viewMsg)
        {
            tranNoName.Text = GetStatic.GetTranNoName();
            TranNo = tranNo;
            CtrlNo = ctrlNo;
            TranFound = false;

            var obj = new TranViewDao();
            var ds = obj.SelectTransactionInt(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg, GetStatic.GetIp(), GetStatic.GetDcInfo());

            if (ds == null)
            {
                sl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            if (ds.Tables.Count > 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    TranFound = true;
                    sl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                    var tRow = ds.Tables[0].Rows[0];
                    lblControlNo.Text = tRow["controlNo"].ToString();
                    hddTranId.Value = tRow["tranId"].ToString();
                    lblTranNo.Text = tRow["holdTranId"].ToString();
                    lblTranRefId.Text = tRow["tranId"].ToString();
                    TranNo = lblTranRefId.Text;
                    if (tRow["sMemId"].ToString() == "")
                        sDisMemId.Visible = false;
                    else
                    {
                        sDisMemId.Visible = true;
                        sMemId.Text = tRow["sMemId"].ToString();
                    }
                    if (tRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        rMemId.Text = tRow["rMemId"].ToString();
                    }

                    PAgent = tRow["pAgent"].ToString();

                    if (tRow["tranStatus"].ToString().ToUpper() == "LOCK")
                    {
                        lockAudit.Visible = true;
                        var html = new StringBuilder("Locked By ");
                        html.Append(tRow["lockedBy"] + " on " + tRow["lockedDate"]);
                        lockAudit.InnerHtml = html.ToString();
                    }

                    if (mode == "u") // mode: modification transaction
                    {
                        sName.Text = GetLinkTextForModification("Sender Name", "senderName", tRow);
                        sName.Text = GetLinkTextForModification("Sender Name", "senderName", tRow);
                        sAddress.Text = GetLinkTextForModification("Sender Address", "sAddress", tRow);
                        sContactNo.Text = GetLinkTextForModification("Sender Contact No", "sContactNo", tRow);
                        sIdType.Text = GetLinkTextForModification("Sender Id Type", "sIdType", tRow);
                        sIdNo.Text = GetLinkTextForModification("Sender Id No", "sIdNo", tRow);
                        rName.Text = GetLinkTextForModification("Receiver Name", "receiverName", tRow);
                        rAddress.Text = GetLinkTextForModification("Receiver Address", "rAddress", tRow);
                        rContactNo.Text = GetLinkTextForModification("Receiver Contact No", "rContactNo", tRow);
                        rIdType.Text = GetLinkTextForModification("Receiver Id Type", "rIdType", tRow);
                        rIdNo.Text = GetLinkTextForModification("Receiver Id No", "rIdNo", tRow);
                        sTelNo.Text = tRow["sTelNo"].ToString();
                        rTelNo.Text = tRow["rTelNo"].ToString();
                        if (tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")
                        {
                            accountNo.Text = GetLinkTextForModification("Account No", "accountNo", tRow);
                            bankName.Text = GetLinkTextForModification("Bank Name", "BankName", tRow);
                            branchName.Text = GetLinkTextForModification("Branch Name", "pBranchName", tRow);
                        }
                    }
                    else
                    {
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
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "CANCEL")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "CANCELLED Transaction";
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "BLOCK")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Block Transaction";
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "CANCELREQUEST")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Cancel Requested !";
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "LOCK")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Locked Transaction!";
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "COMPLIANCE")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "Compliance Transaction!";
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "OFAC")
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

                    if (sl.HasRight(ModifyPayoutLocationId) || sl.HasRight(ModifyPayoutLocationIdAg))
                    {
                        if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() != "BANK DEPOSIT")  // mode: modification payout location
                        {
                            accountNo.Text = tRow["accountNo"].ToString();
                            bankName.Text = tRow["BankName"].ToString();
                            branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
                        }
                        else if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")   //modify mode & bank deposit mode
                        {
                            accountNo.Text = GetLinkPayoutLocation("Account Number", "accountNo", tRow);
                            bankName.Text = GetLinkPayoutLocation("Bank Name", "BankName", tRow);
                            branchName.Text = GetLinkPayoutLocation("Branch Name", "BranchName", tRow);
                            pBranchName.Text = GetLinkPayoutLocation("Paying Branch", "pBranchName", tRow);
                        }
                        else
                        {
                            accountNo.Text = tRow["accountNo"].ToString();
                            bankName.Text = tRow["BankName"].ToString();
                            branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
                        }
                    }
                    else
                    {
                        accountNo.Text = tRow["accountNo"].ToString();
                        bankName.Text = tRow["BankName"].ToString();
                        branchName.Text = tRow["BranchName"].ToString();
                        pBranchName.Text = tRow["pBranchName"].ToString();
                    }

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
                    pnlShowBankDetail.Visible = tRow["paymentMethod"].ToString().ToUpper().Equals("BANK DEPOSIT");
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

                    transferAmount.Text = tRow["tAmt"].ToString();// GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = tRow["cAmt"].ToString();//GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
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

                if (ds.Tables[1].Rows.Count > 0)
                {
                    pnlLog.Visible = true;
                    var dt = ds.Tables[1];
                    var str = new StringBuilder("<table class='table' border=\"0\" cellspacing=0 cellpadding=\"3\">");
                    str.Append("<tr>");
                    str.Append("<th>Updated By</th>");
                    str.Append("<th width='130px'>Updated Date</th>");
                    str.Append("<th>Message</th>");
                    //str.Append("<th>Msg Type</th>");
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
                       // str.Append("<td align='left'>" + dr["msgType"] + "</td>");
                        str.Append("</tr>");
                    }
                    str.Append("</table>");
                    rptLog.InnerHtml = str.ToString();
                }
              if (ds.Tables[2].Rows.Count > 0)
                {
                    var sb = new StringBuilder("");
                    sb.AppendLine("<table class='table' style=\"width: 100%\" border=\"0\" cellspacing=0 cellpadding=\"3\"><tr>");
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

        public void SearchData(string tranNo, string ctrlNo)
        {
            SearchData(tranNo, ctrlNo, "");
        }

        public void SearchData(string tranNo, string ctrlNo, string lockMode)
        {
            SearchData(tranNo, ctrlNo, "", lockMode);
        }

        public string GetLinkTextForModification(string label, string fieldName, DataRow dr)
        {
            var str = "<a href=# title='Edit Record'><div class = \"link\" onclick = \"EditData('" + label + "', '" + fieldName + "', '" + dr[fieldName] + "','" + hddTranId.Value + "')\">" +
                      dr[fieldName] + "<img border=0 src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\"/></a></div>";
            return str;
        }

        public string GetLinkPayoutLocation(string label, string fieldName, DataRow dr)
        {
            var str = "<a href=# title='Edit Record'><div class = \"link\" onclick = \"EditPayoutLocation('" + label + "', '" + fieldName + "', '" + dr[fieldName] + "','" + hddTranId.Value + "')\">" +
                      dr[fieldName] + "<img border=0 src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\"/></a></div>";
            return str;
        }

        public void SearchData()
        {
            //if TranNo is not blank, search by tranNo
            //if CtrlNo is not blank, search by ctrlNo
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            pnlDetail.Visible = ShowDetailBlock;
            pnlComment.Visible = ShowCommentBlock;

            lblAddComp.Visible = ShowCommentBlock;
            lblSettl.Visible = ShowSettlment;
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
                var str = new StringBuilder("<table class='table' border=\"1\" cellspacing=0 cellpadding=\"3\">");
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
                SetupEmailSetting();
                SendMail();
            }
        }

        public void AddCommentApi()
        {
            GetStatic.AddTroubleTicket(Page, lblControlNo.Text, comments.Text, 2);
            AddComment();
        }

        private delegate void DoStuff(); //delegate for the action

        private void SendMail()
        {
            var myAction = new DoStuff(AsyncMailProcessing);
            //invoke it asynchrnously, control passes to next statement
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

    }
}