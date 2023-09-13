﻿using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.UserControl
{
    public partial class UcTran : System.Web.UI.UserControl
    {
        private RemittanceLibrary sl = new RemittanceLibrary();

        private readonly UcTranDao _obj = new UcTranDao();
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

            var ds = _obj.SelectTransaction(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);

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

                    if (tRow["tranStatus"].ToString().ToUpper() == "Cancel")
                    {
                        showHideTranStatus.Visible = true;
                        highLightTranStatus.InnerText = "CANCELLED Transaction";
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

                        if (tRow["paymentMethod"].ToString().ToLower() == "bank deposit")
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
                        rIdType.Text = tRow["rIdType"].ToString(); //
                        rIdNo.Text = tRow["rIdNo"].ToString(); //
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

                    if (mode == "p" && tRow["paymentMethod"].ToString().ToLower() != "bank deposit") // mode: modification payout location
                    {
                        pAgentLocation.Text = GetLinkPayoutLocation("Payout Location", "pAgentLocation", tRow);
                        accountNo.Text = tRow["accountNo"].ToString();
                        bankName.Text = tRow["BankName"].ToString();
                        branchName.Text = tRow["BranchName"].ToString();

                        pBranchName.Text = tRow["pBranchName"].ToString();
                    }
                    else if (mode == "p" && tRow["paymentMethod"].ToString().ToLower() == "bank deposit") //modify mode & bank deposit mode
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
                    pAgentName.Text = tRow["pAgentName"].ToString();
                    modeOfPayment.Text = tRow["paymentMethod"].ToString();

                    tranStatus.Text = tRow["tranStatus"].ToString();
                    payStatus.Text = tRow["payStatus"].ToString();

                    //pnlShowBankDetail.Visible = (tRow["paymentMethod"].ToString() == "Bank Deposit" ? true : false);
                    trAc.Visible = (tRow["paymentMethod"].ToString().ToLower() == "bank deposit" ? true : false);
                    trBank.Visible = (tRow["paymentMethod"].ToString().ToLower() == "bank deposit" ? true : false);
                    trBranch.Visible = (tRow["paymentMethod"].ToString().ToLower() == "bank deposit" ? true : false);

                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");
                    relationship.Text = tRow["relationship"].ToString();
                    payoutMsg.Text = tRow["payoutMsg"].ToString();
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
            pnlComment.Visible = ShowCommentBlock;

            pnlReleaseBtn.Visible = ShowApproveButton;
            ShowOFACList();
            ShowComplianceList();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            AddComment();
            comments.Text = "";
            ShowLog();
        }

        #region for desplaying a transaction comments log

        public void ShowLog()
        {
            var ds = _obj.DisplayLog(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

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
            var ds = _obj.DisplayOFAC(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

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

                string checkFlag = _obj.checkFlagOFAC(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
                if (checkFlag == "Y")
                    pnlReleaseBtn.Visible = false;

                GetStatic.AlertMessage(Page);
            }
        }

        public void ShowComplianceList()
        {
            var ds = _obj.DisplayCompliance(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

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

                string checkFlag = _obj.checkFlagCompliance(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
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
            DbResult dbResult = _obj.SaveApproveRemarksComplaince(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, remarksCompliance.Text, remarksOFAC.Text);

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
            DbResult dbResult = _obj.AddComment(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, comments.Text);
            ManageMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.CallBackJs1(Page, "Result", "alert('" + dbResult.Msg + "')");
                return;
            }
            else
            {
                SendEmail();
            }
        }

        private void SendEmail()
        {
            var smtpMailSetting = new SmtpMailSetting();

            var ds = _obj.GetEmailFormat(GetStatic.GetUser(), hddTranId.Value, comments.Text);
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
            smtpMailSetting.SendSmtpMail(smtpMailSetting);
        }
    }
}