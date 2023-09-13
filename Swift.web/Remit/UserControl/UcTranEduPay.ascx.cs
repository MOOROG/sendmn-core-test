using System;
using System.ComponentModel;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
namespace Swift.web.Remit.UserControl
{
    public partial class UcTranEduPay : System.Web.UI.UserControl
    {
        private RemittanceLibrary sl = new RemittanceLibrary();
        private SmtpMailSetting smtpMailSetting = new SmtpMailSetting();
        private const string AddTroubleTicketFunctionId = "20121810";
        private const string AddTroubleTicketFunctionIdAg = "40101720";
        private const string ModifyPayoutLocationId = "20121520";
        private const string ModifyPayoutLocationIdAg = "40101730";
        public bool ShowDetailBlock { get; set; }
        public bool ShowLogBlock { get; set; }
        public bool ShowCommentBlock { get; set; }
        public bool ShowBankDetail { get; set; }
        public bool ShowOfac { get; set; }
        public bool ShowCompliance { get; set; }
        public bool ShowApproveButton { get; set; }

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

        //public string LockTranSaction
        //{
        //    get { return lockTranSaction.Text; }
        //    set { lockTranSaction.Text = value; }
        //}

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
            var ds = obj.SelectTransactionEduPay(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);

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
                    lblTranNo.Text = tRow["tranId"].ToString();
                    hddTranId.Value = tRow["tranId"].ToString();
                    pnlExRate.Visible = false;
                    if (tRow["extCustomerId"].ToString() == "")
                        sCId.Visible = false;
                    else
                        sCustomerId.Text = tRow["extCustomerId"].ToString();
                    if (tRow["sMemId"].ToString() == "")
                        sDisMemId.Visible = false;
                    else
                    {
                        sDisMemId.Visible = true;
                        sMemId.Text = tRow["sMemId"].ToString();
                    }
                    if (tRow["tranStatus"].ToString().ToUpper() == "CANCEL")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "CANCELLED Transaction";
                    }
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

                        stdName.Text = GetLinkTextForModification("Student Name", "stdName", tRow);
                        stdLevel.Text = GetLinkTextForModification("Student Name", "stdLevel", tRow);
                        stdRollRegNo.Text = GetLinkTextForModification("Student Name", "stdRollRegNo", tRow);
                        stdSemYr.Text = GetLinkTextForModification("Student Name", "stdSemYr", tRow);
                        feeTypeId.Text = GetLinkTextForModification("Student Name", "feeTypeId", tRow);

                        if (tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")
                        {
                            accountNo.Text = GetLinkTextForModification("Account No", "accountNo", tRow);
                            bankName.Text = GetLinkTextForModification("Bank Name", "BankName", tRow);
                            branchName.Text = GetLinkTextForModification("Branch Name", "pBranchName", tRow);
                        }
                    }
                    else
                    {
                        sName.Text = tRow["senderName"].ToString(); //
                        sAddress.Text = tRow["sAddress"].ToString(); //
                        sContactNo.Text = tRow["sContactNo"].ToString(); //
                        sIdType.Text = tRow["sIdType"].ToString(); //
                        sIdNo.Text = tRow["sIdNo"].ToString(); //

                        rName.Text = tRow["receiverName"].ToString(); //
                        rAddress.Text = tRow["rAddress"].ToString(); //
                        rContactNo.Text = tRow["rContactNo"].ToString(); //

                        stdName.Text = tRow["stdName"].ToString();
                        stdLevel.Text = tRow["stdLevel"].ToString();
                        stdRollRegNo.Text = tRow["stdRollRegNo"].ToString();
                        stdSemYr.Text = tRow["stdSemYr"].ToString();
                        feeTypeId.Text = tRow["feeTypeId"].ToString();
                    }

                    sCountry.Text = tRow["sCountryName"].ToString();
                    sEmail.Text = tRow["sEmail"].ToString();
                    rCountry.Text = tRow["rCountryName"].ToString();

                    //Sending Agent Detail
                    sAgentName.Text = tRow["sAgentName"].ToString();
                    sBranchName.Text = tRow["sBranchName"].ToString();
                    sAgentCountry.Text = tRow["sCountryName"].ToString();
                    sAgentDistrict.Text = tRow["sAgentDistrict"].ToString();
                    sAgentCity.Text = tRow["sAgentCity"].ToString();
                    sAgentLocation.Text = tRow["sAgentLocation"].ToString();

                    //Payout Agent Detail
                    pAgentCountry.Text = tRow["pAgentCountry"].ToString();
                    pAgentDistrict.Text = tRow["pAgentDistrict"].ToString();
                    pAgentCity.Text = tRow["pAgentCity"].ToString();

                    if (sl.HasRight(ModifyPayoutLocationId) || sl.HasRight(ModifyPayoutLocationIdAg))
                    {
                        if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() != "BANK DEPOSIT")
                        // mode: modification payout location
                        {
                            pAgentLocation.Text = GetLinkPayoutLocation("Payout Location", "pAgentLocation", tRow);
                            accountNo.Text = tRow["accountNo"].ToString();
                            bankName.Text = tRow["BankName"].ToString();
                            branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
                        }
                        else if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")
                        //modify mode & bank deposit mode
                        {
                            accountNo.Text = GetLinkPayoutLocation("Account Number", "accountNo", tRow);
                            bankName.Text = GetLinkPayoutLocation("Bank Name", "BankName", tRow);
                            branchName.Text = GetLinkPayoutLocation("Branch Name", "BranchName", tRow);
                            pBranchName.Text = GetLinkPayoutLocation("Paying Branch", "pBranchName", tRow);
                            pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                        }
                        else
                        {
                            pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                            accountNo.Text = tRow["accountNo"].ToString();
                            bankName.Text = tRow["BankName"].ToString();
                            branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
                        }
                    }
                    else
                    {
                        pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                        accountNo.Text = tRow["accountNo"].ToString();
                        bankName.Text = tRow["BankName"].ToString();
                        branchName.Text = tRow["BranchName"].ToString();
                        pBranchName.Text = tRow["pBranchName"].ToString();
                    }
                    pAgentName.Text = tRow["pAgentName"].ToString();
                    modeOfPayment.Text = tRow["paymentMethod"].ToString();

                    tranStatus.Text = tRow["tranStatus"].ToString();
                    payStatus.Text = tRow["payStatus"].ToString();

                    sAgentComm.Text = GetStatic.FormatData(tRow["sAgentComm"].ToString(), "M");
                    sAgentCommCurr.Text = tRow["sAgentCommCurrency"].ToString();
                    if (payStatus.Text == "Paid")
                    {
                        payAgentComm.Visible = true;
                        pAgentComm.Text = GetStatic.FormatData(tRow["pAgentComm"].ToString(), "M");
                        pAgentCommCurr.Text = tRow["pAgentCommCurrency"].ToString();
                    }

                    pnlShowBankDetail.Visible = (tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT" ? true : false);

                    if (tRow["tranType"].ToString() == "I")
                    {
                        pnlExRate.Visible = true;
                        handling.Text = GetStatic.FormatData(tRow["handlingFee"].ToString(), "M");
                        exRate.Text = GetStatic.FormatData(tRow["exRate"].ToString(), "M");
                    }
                    transferAmount.Text = GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");

                    if (tRow["payoutMsg"].ToString() == "-")
                        trpMsg.Visible = false;
                    else
                        payoutMsg.Text = tRow["payoutMsg"].ToString();

                    tAmtCurr.Text = tRow["collCurr"].ToString();
                    scCurr.Text = tRow["collCurr"].ToString();
                    totalCurr.Text = tRow["collCurr"].ToString();
                    pAmtCurr.Text = tRow["payoutCurr"].ToString();

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

                pnlLog.Visible = false;
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
                      dr[fieldName] + "<img border=0 src=\"/Images/edit.gif\"/></a></div>";
            return str;
        }

        public string GetLinkPayoutLocation(string label, string fieldName, DataRow dr)
        {
            var str = "<a href=# title='Edit Record'><div class = \"link\" onclick = \"EditPayoutLocation('" + label + "', '" + fieldName + "', '" + dr[fieldName] + "','" + hddTranId.Value + "')\">" +
                      dr[fieldName] + "<img border=0 src=\"/Images/edit.gif\"/></a></div>";
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
            pnlDetail.Visible = ShowDetailBlock;
            pnlLog.Visible = ShowLogBlock;
            pnlComment.Visible = (sl.HasRight(AddTroubleTicketFunctionId) || sl.HasRight(AddTroubleTicketFunctionIdAg)) && ShowCommentBlock;

            pnlReleaseBtn.Visible = ShowApproveButton;

            //pnlOFAC.Visible = ShowOfac;
            ShowOFACList();
            //pnlCompliance.Visible = ShowCompliance;
            ShowComplianceList();


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
                    for (int i = 0; i < cols; i++)
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table>");
                displayOFAC.InnerHtml = str.ToString();

                string checkFlag = obj.checkFlagOFAC(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
                if (checkFlag == "Y")
                    pnlReleaseBtn.Visible = false;

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

                string checkFlag = obj.checkFlagCompliance(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
                if (checkFlag == "Y")
                    pnlReleaseBtn.Visible = false;

                GetStatic.AlertMessage(Page);
            }
        }

        protected void btnApproveCompliance_Click(object sender, EventArgs e)
        {
            SaveComplianceApproveRemarks();
        }

        public void SaveComplianceApproveRemarks()
        {
            var obj = new TranViewDao();
            DbResult dbResult = obj.SaveApproveRemarksComplaince(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, remarksCompliance.Text, remarksOFAC.Text,remarksCashLimitHold.Text);

            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page);
            }
            else
            {
                ShowComplianceList();
                ShowOFACList();
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
                SetupEmailSetting();
                SendMail();
            }
        }

        public void AddCommentApi()
        {
            var obj = new TranViewDao();
            var randObj = new Random();
            string agentRefId = randObj.Next(1000000000, 1999999999).ToString();
            var dr = obj.AddCommentApi(GetStatic.GetUser(), agentRefId, lblControlNo.Text, hddTranId.Value, comments.Text,"");
            if (dr[0].ToString() == "0" || dr[0].ToString().ToUpper() == "SUCCESS")
            {
                AddComment();
            }
            else
            {
                GetStatic.AlertMessage(Page, dr[1].ToString());
            }
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
            var obj = new TranViewDao();
            var ds = obj.GetEmailFormat(GetStatic.GetUser(), "Trouble", hddTranId.Value, "", comments.Text);
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