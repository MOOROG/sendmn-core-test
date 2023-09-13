using Swift.API.Common;
using Swift.API.Common.Cancel;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.BL.ThirdParty.BankDeposit;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.UserControl
{
    public partial class UcTransaction : System.Web.UI.UserControl
    {
        private readonly DbResult msgDb = new DbResult();
        private RemittanceLibrary rl = new RemittanceLibrary();
        private SmtpMailSetting smtpMailSetting = new SmtpMailSetting();
        private readonly SmtpMailSetting _mailToAgent = new SmtpMailSetting();
        private ApproveTransactionDao at = new ApproveTransactionDao();
        private TranViewDao obj = new TranViewDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ModifyPayoutLocationId = "20121520";
        private const string ModifyPayoutLocationIdAg = "40101730";
    private RemittanceDao remitDao = new RemittanceDao();
    private readonly ModifyTransactionDao mtd = new ModifyTransactionDao();
    List<string> cds = new List<string>();
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

        public string isPartnerRealTime
        {
            get { return hddIsPartnerRealTime.Value; }
            set { hddIsPartnerRealTime.Value = value; }
        }

        public string partnerId
        {
            get { return hddPartnerId.Value; }
            set { hddPartnerId.Value = value; }
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

        public string PayStatus
        {
            get { return payStatus.Text; }
            set { payStatus.Text = value; }
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

        public string trnStatusBeforeCnlReq
        {
            get { return hddTrnSatusBeforeCnlReq.Value; }
            set { hddTrnSatusBeforeCnlReq.Value = value; }
        }

        public string PAgent
        {
            get { return pAgent.Value; }
            set { pAgent.Value = value; }
        }

        //public string LockTranSaction
        //{
        //    get { return lockTranSaction.Text; }
        //    set { lockTranSaction.Text = value; }
        //}

        public bool TranFound { get; set; }
        public string HoldTranId { get; set; }
    public string SAgentId {
      get { return hddSagentId.Value; }
      set { hddSagentId.Value = value; }
    }

    public void SearchData(string tranNo, string ctrlNo, string mode, string lockMode)
        {
            SearchData(tranNo, ctrlNo, mode, lockMode, "SEARCH", "ADM:SEARCH TXN");
        }

        public void SearchData(string tranNo, string ctrlNo, string mode, string lockMode, string viewType, string viewMsg, bool isArchive = false)
        {
            //pnlShowBankDetail.Visible = ShowBankDetail;
            tranNoName.Text = GetStatic.GetTranNoName();
            TranNo = tranNo;
            CtrlNo = ctrlNo;
            TranFound = false;
            DataSet ds = null;
            if (isArchive)
            {
                //var obj = new ArchiveReportsDao();
                //ds = obj.SelectTransaction(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);
            }
            else
            {
                var obj = new TranViewDao();
                ds = obj.SelectTransaction(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);
            }

            if (ds == null)
            {
                rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            if (ds.Tables.Count > 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    var tRow = ds.Tables[0].Rows[0];
                    customerSignatureImg.ImageUrl = "/Remit/Transaction/TxnDocView/TxnDocView.ashx?txnDate=" + tRow["createdDate"].ToString() + "&controlNo=" + tRow["controlNo"].ToString();

                    TranFound = true;
                    HoldTranId = tRow["holdTranId"].ToString();
          hddRealTranId.Value = tRow["realTranId"].ToString();
          rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                    lblControlNo.Text = tRow["controlNo"].ToString();
          lblControlNo2.Text = tRow["controlNo2"].ToString();
          lblTranNo.Text = tRow["tranId"].ToString();
                    hddTranId.Value = tRow["tranId"].ToString();
                    isRealTime.Value = tRow["isRealTime"].ToString();
                    hddIsPartnerRealTime.Value = tRow["isPartnerRealTime"].ToString();
                    hddPartnerId.Value = tRow["PartnerId"].ToString();
          if (tRow["fromWhere"] != null) {
            fromWhere.Value = tRow["fromWhere"].ToString();
            if (fromWhere.Value.Equals("remit")) {
              chStatus.Items.Remove(chStatus.Items.FindByValue("error"));
              if (tRow["tranStatus"].ToString().Equals("Paid") || tRow["tranStatus"].ToString().Equals("Cancel")) {
                statusChange.Visible = false;
              }
            } else {
              if (tRow["tranStatus"].ToString().Equals("Hold")) {
                statusChange.Visible = true;
              } else {
                statusChange.Visible = false;
              }
            }
          }
                    pnlExRate.Visible = false;
                    if (tRow["extCustomerId"].ToString() == "")
                        sCId.Visible = false;
                    else
                        sCustomerId.Text = tRow["extCustomerId"].ToString();

                    if (tRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        rMemId.Text = tRow["rMemId"].ToString();
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
                        //sName.Text = GetLinkTextForModification("Sender Name", "senderName", tRow);
                        //sName.Text = GetLinkTextForModification("Sender Name", "senderName", tRow);
                        //sAddress.Text = GetLinkTextForModification("Sender Address", "sAddress", tRow);
                        //sContactNo.Text = GetLinkTextForModification("Sender Contact No", "sContactNo", tRow);
                        //sIdType.Text = GetLinkTextForModification("Sender Id Type", "sIdType", tRow);
                        //sIdNo.Text = GetLinkTextForModification("Sender Id No", "sIdNo", tRow);
                        rName.Text = GetLinkTextForModification("Receiver Name", "receiverName", tRow);
                        rAddress.Text = GetLinkTextForModification("Receiver Address", "rAddress", tRow);
                        rContactNo.Text = GetLinkTextForModification("Receiver Contact No", "rContactNo", tRow);
                        rIdType.Text = GetLinkTextForModification("Receiver Id Type", "rIdType", tRow);
                        rIdNo.Text = GetLinkTextForModification("Receiver Id No", "rIdNo", tRow);

                        if (tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")
                        {
                            accountNo.Text = GetLinkTextForModification("Account No", "accountNo", tRow);
                            // bankName.Text = GetLinkTextForModification("Bank Name", "BankName",
                            // tRow); branchName.Text = GetLinkTextForModification("Branch Name",
                            // "pBranchName", tRow);
                        }
                    }
                    else
                    {
                        rName.Text = tRow["receiverName"].ToString(); //
                        rAddress.Text = tRow["rAddress"].ToString(); //
                        rContactNo.Text = tRow["rContactNo"].ToString(); //
                        rIdType.Text = tRow["rIdType"].ToString(); //
                        rIdNo.Text = tRow["rIdNo"].ToString(); //
                    }
                    sName.Text = tRow["senderName"].ToString(); //
                    customerId.Text = tRow["uniqueId"].ToString(); //
                    sAddress.Text = tRow["sAddress"].ToString(); //
                    sContactNo.Text = tRow["sContactNo"].ToString(); //
                    sIdType.Text = tRow["sIdType"].ToString(); //
                    sIdNo.Text = tRow["sIdNo"].ToString(); //

                    hdnRName.Value = tRow["receiverName"].ToString();
                    hdnSName.Value = tRow["senderName"].ToString();

                    sCountry.Text = tRow["sCountryName"].ToString();
                    sEmail.Text = tRow["sEmail"].ToString();
                    rCountry.Text = tRow["rCountryName"].ToString();
                    sDOB.Text = tRow["sDob"].ToString();

                    //Sending Agent Detail
                    hddSAgentEmail.Value = tRow["sAgentEmail"].ToString();
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

                    if (rl.HasRight(ModifyPayoutLocationId) || rl.HasRight(ModifyPayoutLocationIdAg))
                    {
                        if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() != "BANK DEPOSIT")
                        // mode: modification payout location
                        {
                            pAgentLocation.Text = GetLinkPayoutLocation("Payout Location", "pAgentLocation", tRow);
                            accountNo.Text = tRow["accountNo"].ToString();
                            //bankName.Text = tRow["BankName"].ToString();
                            branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
              bankListDdl.Enabled = false;
                        }
                        else if (mode == "u" && tRow["paymentMethod"].ToString().ToUpper() == "BANK DEPOSIT")
                        //modify mode & bank deposit mode
                        {
                            accountNo.Text = GetLinkPayoutLocation("Account Number", "accountNo", tRow);
                            //bankName.Text = GetLinkPayoutLocation("Bank Name", "BankName", tRow);
              bankListDdl.SelectedValue = tRow["pBank"].ToString();
              branchName.Text = GetLinkPayoutLocation("Branch Name", "BranchName", tRow);
                            pBranchName.Text = GetLinkPayoutLocation("Paying Branch", "pBranchName", tRow);
                            pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                        }
                        else
                        {
                            pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                            accountNo.Text = tRow["accountNo"].ToString();
              if (!cds.Contains(tRow["pBank"].ToString())) {
                bankName.Text = tRow["BankName"].ToString();
                bankListDdl.Visible = false;
                bankName.Visible = true;
              } else {
                bankListDdl.SelectedValue = tRow["pBank"].ToString();
                bankListDdl.Visible = true;
                bankListDdl.Enabled = false;
                bankName.Visible = false;
              }
              branchName.Text = tRow["BranchName"].ToString();
                            pBranchName.Text = tRow["pBranchName"].ToString();
                        }
                    }
                    else
                    {
                        pAgentLocation.Text = tRow["pAgentLocation"].ToString();
                        accountNo.Text = tRow["accountNo"].ToString();
            if (!cds.Contains(tRow["pBank"].ToString())) {
              bankName.Text = tRow["BankName"].ToString();
              bankListDdl.Visible = false;
              bankListDdl.Enabled = false;
              bankName.Visible = true;
            } else {
              bankListDdl.SelectedValue = tRow["pBank"].ToString();
              bankListDdl.Visible = true;
              bankListDdl.Enabled = false;
              bankName.Visible = false;
            }
            //bankName.Text = tRow["BankName"].ToString();
            //branchName.Text = tRow["BranchName"].ToString();
            //pBranchName.Text = tRow["pBranchName"].ToString();
          }
          //bankName.Text = tRow["BankName"].ToString();
          branchName.Text = tRow["BranchName"].ToString();
                    pBranchName.Text = tRow["pBranchName"].ToString();
                    pAgentLocation.Text = tRow["pAgentLocation"].ToString();

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
                    if (tRow["paymentMethod"].ToString().ToUpper().Equals("MOBILE WALLET"))
                    {
                        pnlShowBankDetail.Visible = true;
                    }

                    if (tRow["tranType"].ToString() == "I")
                    {
                        pnlExRate.Visible = false;
                        handling.Text = GetStatic.FormatData(tRow["handlingFee"].ToString(), "M");
                        exRate.Text = GetStatic.ShowDecimalRate(tRow["exRate"].ToString());
                    }

                    //bankDetails.Visible = false;
                    lblCollMode.Text = tRow["collMode"].ToString();
                    if (tRow["collMode"].ToString().ToLower() == "bank deposit")
                    {
                        //bankDetails.Visible = true;
                        PopulateBankDetails(ds.Tables[3]);
                    }
                    transferAmount.Text = GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");
                    relationship.Text = tRow["relationship"].ToString();
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
                PopulateVoucherDetail(TranNo);
                //pnlLog.Visible = false;
                if (ds.Tables[1].Rows.Count > 0)
                {
                    //pnlLog.Visible = true;
                    var dt = ds.Tables[1];
                    var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");
                    str.Append("<tr>");
                    str.Append("<th>Updated By</th>");
                    str.Append("<th>Updated Date</th>");
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

        private void PopulateBankDetails(DataTable dataTable)
        {
            if (null == dataTable || dataTable.Rows.Count == 0)
            {
                return;
            }

            int sNo = 0;
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dataTable.Rows)
            {
                sNo++;
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["PARTICULARS"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["TRANDATE"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["DEPOSITAMOUNT"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
            }
            bankDpositDetails.InnerHtml = sb.ToString();
        }

        public void PopulateVoucherDetail(string tranNo)
        {
            var obj = new TranViewDao();
            var dt = obj.SelectVoucherDetail(GetStatic.GetUser(), tranNo);
            if (dt.Rows.Count == 0 || null == dt)
            {
                return;
            }
            int sNo = 1;
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["voucherNo"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["voucherDate"].ToString() + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["voucherAmt"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["bankName"].ToString() + "</td>");
                sb.AppendLine("</tr>");
                sNo++;
            }
            voucherDetailDiv.InnerHtml = sb.ToString();
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
            //pnlPartnerRemarks.Visible = ShowApproveButton;
            ShowOFACList();
            ShowComplianceList();
            ShowCashLimitHoldList();
            string sql = "SELECT agentid, BankName FROM KoreanBankList where agentid is not null order by agentid";
            DataSet ds = obj.ExecuteDataset(sql);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
              foreach (DataRow row in ds.Tables[0].Rows) {
                ListItem listItem = new ListItem();
                listItem.Value = row["agentid"].ToString();
                listItem.Text = row["BankName"].ToString();
                bankListDdl.Items.Add(listItem);
          cds.Add(row["agentid"].ToString());
              }
            }
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
                var str = new StringBuilder("<table class='table table-responsive table-bordered table-striped'>");
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

        #endregion for desplaying a transaction comments log

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
                pnlOFAC.Visible = true;
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
                            if (strArr[j].Length > 3)
                            {
                                value = value.ToUpper().Replace(strArr[j], GetStatic.PutRedBackGround(strArr[j]));
                            }
                        }
                    }
                    str.Append("<td align=\"left\">" + value + "</td>");
                    str.Append("</tr>");
                }
                str.Append("</table>");
                displayOFAC.InnerHtml = str.ToString();

                string checkFlag = obj.checkFlagOFAC(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
                if (checkFlag == "Y")
                {
                    pnlReleaseBtn.Visible = false;
                    ofacApproveRemarks.Visible = false;
                }

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
                //pnlReleaseBtnCashHold.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                pnlCompliance.Visible = true;

                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='table table-responsive table-bordered table-striped'>");
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
                            var strArr = dr["Matched ControlNo"].ToString().Split(',');
                            var arrlen = strArr.Length;
                            str.Append("<td>");
                            for (int j = 0; j < arrlen; j++)
                            {
                                if (dr["csDetailRecId"].ToString() != "0")
                                {
                                    str.Append(strArr[j]);
                                }
                                else
                                {
                                    str.Append("<a href=\"#\" onclick=\"OpenInNewWindow('/Remit/Transaction/Reports/SearchTransaction.aspx?controlNo=" + strArr[j] + "')\">" + strArr[j] + "</a> &nbsp;");
                                }
                            }
                            str.Append("</td>");
                        }
                        else if (i == 3)
                        {
                            if (dr["csDetailRecId"].ToString() == "0")
                            {
                                str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" + dr["rowId"].ToString() + "&csID=" + dr["csDetailRecId"] + "')\">" + dr[i].ToString() + "</a></td>");
                            }
                            else
                            {
                                str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?type=compNew&id=" + dr["csDetailRecId"].ToString() + "')\">" + dr[i].ToString() + "</a></td>");
                            }
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
                {
                    pnlReleaseBtn.Visible = false;
                    complianceApproveRemarks.Visible = false;
                }

                GetStatic.AlertMessage(Page);
            }
        }

        public void ShowCashLimitHoldList()
        {
            var obj = new TranViewDao();
            var ds = obj.DisplayCashLimitHold(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");

            if (ds == null)
            {
                pnlCashLimitHold.Visible = false;
                pnlReleaseBtnCashHold.Visible = false;
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<table class='table table-responsive table-bordered table-striped'>");
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
                            //str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" + dr["rowId"].ToString() + "')\">" + dr[i].ToString() + "</a></td>");
                            str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                        }
                        else
                        {
                            str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
                str.Append("</table>");
                displayCashLimitHold.InnerHtml = str.ToString();

                string checkFlag = obj.checkFlagCashLimitHold(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, "");
                if (checkFlag == "Y")
                    pnlReleaseBtnCashHold.Visible = false;

                GetStatic.AlertMessage(Page);
            }
        }

        public void ShowPartnerRemarks()
        {
            var isrealTime = isRealTime.Value;
            if (isrealTime == "True")//is realtime
            {
                string sql = "SELECT CANCEL_REASON_CODE, CANCEL_REASON_TITLE FROM TBL_PARTNER_CANCEL_REASON (NOLOCK) WHERE PARTNER_ID = 394130 AND IS_ACTIVE = 1";
                pnlPartnerRemarks.Visible = true;
                partnerRemarksDiv.Visible = true;
                _sdd.SetDDL(ref ddlRemarks, sql, "CANCEL_REASON_CODE", "CANCEL_REASON_TITLE", "", "Select Reason");
            }
            else
            {
                pnlPartnerRemarks.Visible = false;
            }
        }

        protected void btnApproveCompliance_Click(object sender, EventArgs e)
        {
            SaveComplianceApproveRemarks();

            //DbResult result = obj.CheckTranInBothRule(GetStatic.GetUser(), hddTranId.Value);
            //if(result.ErrorCode == "1")
            //{
            //    SaveComplianceApproveRemarks();
            //}
            //else
            //{
            //    var apiRes = ApproveTxn();
            //    if(apiRes.ErrorCode == "0")
            //    {
            //        SaveComplianceApproveRemarks();
            //    }
            //    else
            //    {
            //        GetStatic.SetMessage(apiRes);
            //        GetStatic.AlertMessage(Page);
            //    }

            //}
        }

        private DbResult ApproveTxn()
        {
            DbResult _dbRes = at.GetTxnApproveDataCompliance(GetStatic.GetUser(), hddTranId.Value);
            if (_dbRes.ErrorCode != "0")
            {
                return _dbRes;
            }
            else if (_dbRes.Extra == "True")//is realtime
            {
                SendTransactionServices _tpSend = new SendTransactionServices();
                var result = _tpSend.ReleaseTransaction(new TFReleaseTxnRequest()
                {
                    TfPin = _dbRes.Id,
                    RequestBy = GetStatic.GetUser(),
                    ProviderId = _dbRes.Msg
                });
                _dbRes.ErrorCode = result.ResponseCode;
                _dbRes.Msg = result.Msg;
                _dbRes.Id = "";

                return _dbRes;
            }
            else
            {
                string newSession = Guid.NewGuid().ToString().Replace("-", "");
                var result = at.GetHoldedTxnForApprovedByAdminCompliance(GetStatic.GetUser(), hddTranId.Value, newSession);

                _dbRes.ErrorCode = result.ResponseCode;
                _dbRes.Msg = result.Msg;
                _dbRes.Id = "";
                return _dbRes;
            }
        }

        public void SaveComplianceApproveRemarks(string cashHoldLimitFlag = "")
        {
            DbResult dbResult = obj.SaveApproveRemarksComplaince(GetStatic.GetUser(), lblControlNo.Text, hddTranId.Value, remarksCompliance.Text, remarksOFAC.Text, remarksCashLimitHold.Text, cashHoldLimitFlag);

            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page);
            }
            else
            {
                //ShowComplianceList();
                //ShowOFACList();
                Response.Redirect("/Remit/Compliance/ApproveOFACandComplaince/Dashboard.aspx");
                return;
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
                SendMailNew(lblControlNo.Text);
            }
        }

        protected void SendMailNew(string controlNo)
        {
            string msgSubject = GetStatic.ReadWebConfig("jmeName", "")+ " No: " + controlNo;
            string msgBody = "Dear Sir/Madam,";
            msgBody += "<br /><br /> The Complaint detials are as below:";
            msgBody += "<br /><br /> Remitter Name: " + sName.Text;
            msgBody += "<br /><br /> Beneficiary Name: " + rName.Text;
            msgBody += "<br /><br /> Complaint Message: " + comments.Text;

            Task.Factory.StartNew(() => { SendEmailForComplaint(msgSubject, msgBody, "support@jme.com.np"); });
        }

        private void SendEmailForComplaint(string msgSubject, string msgBody, string toEmailId)
        {
            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };

            mail.SendSmtpMail(mail);
        }

        public void AddCommentApi()
        {
            var obj = new TranViewDao();
            var randObj = new Random();
            var sendSmsEmail = "";
            if (chkSms.Checked == true)
                sendSmsEmail = "sms";
            if (chkEmail.Checked == true)
                sendSmsEmail = "email";
            if (chkEmail.Checked && chkSms.Checked == true)
                sendSmsEmail = "both";

            string agentRefId = randObj.Next(1000000000, 1999999999).ToString();
            var dr = obj.AddCommentApi(GetStatic.GetUser(), agentRefId, lblControlNo.Text, hddTranId.Value, comments.Text, sendSmsEmail);
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
            delegate (object o, DoWorkEventArgs args)
            {
                var b = o as BackgroundWorker;
                smtpMailSetting.SendSmtpMail(smtpMailSetting);

                if (!string.IsNullOrEmpty(hddSAgentEmail.Value))
                    _mailToAgent.SendSmtpMail(_mailToAgent);
            });

            // what to do when progress changed (update the progress bar for example)
            bw.ProgressChanged += new ProgressChangedEventHandler(
            delegate (object o, ProgressChangedEventArgs args)
            {
                //label1.Text = string.Format("{0}% Completed", args.ProgressPercentage);
            });

            // what to do when worker completes its task (notify the user)
            bw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(
            delegate (object o, RunWorkerCompletedEventArgs args)
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

                    _mailToAgent.SmtpServer = dr1["smtpServer"].ToString();
                    _mailToAgent.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
                    _mailToAgent.SendEmailId = dr1["sendID"].ToString();
                    _mailToAgent.SendEmailPwd = dr1["sendPSW"].ToString();
                    _mailToAgent.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());
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

                    _mailToAgent.MsgSubject = dr3[0].ToString();
                    _mailToAgent.MsgBody = dr3[1].ToString();
                    _mailToAgent.ToEmails = hddSAgentEmail.Value;
                }
            }
        }

        private void UploadSms()
        {
            string sql = "exec [proc_sendSMSModule] @flag='sms'";
            sql = sql + " ,@user=" + rl.FilterString(GetStatic.GetUser());
            sql = sql + " ,@msg=" + rl.FilterString(comments.Text);

            var obj = new SwiftDao();
            string msg = obj.GetSingleResult(sql);
            if (msg.Contains("Sucessfully"))
            {
                msgDb.SetError("0", msg, "");
                comments.Text = "";
            }
            else
                msgDb.SetError("1", msg, "");
            GetStatic.PrintMessage(Page, msgDb);
        }

        public void SearchPartnerData(string ctrlNo, string mode, string lockMode, string viewType, string viewMsg, bool isArchive = false)
        {
            //pnlShowBankDetail.Visible = ShowBankDetail;
            tranNoName.Text = GetStatic.GetTranNoName();
            payoutPartnerPinDiv.Visible = true;

            // TranNo = tranNo;
            CtrlNo = ctrlNo;
            TranFound = false;
            DataSet ds = null;
            if (isArchive)
            {
                //var obj = new ArchiveReportsDao();
                //ds = obj.SelectTransaction(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);
            }
            else
            {
                var obj = new TranViewDao();
                ds = obj.SelectPartnerTransaction(GetStatic.GetUser(), ctrlNo, TranNo, lockMode, viewType, viewMsg);
            }

            if (ds == null)
            {
                rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                return;
            }
            if (ds.Tables.Count > 1)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    TranFound = true;
                    rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                    var tRow = ds.Tables[0].Rows[0];

                    lblControlNo.Text = tRow["controlNo"].ToString();
                    lblPartnerPayoutPin.Text = tRow["PartnerPIN"].ToString();
                    lblTranNo.Text = tRow["tranId"].ToString();
                    hddTranId.Value = tRow["tranId"].ToString();

                    pnlExRate.Visible = false;
                    if (tRow["extCustomerId"].ToString() == "")
                        sCId.Visible = false;
                    else
                        sCustomerId.Text = tRow["extCustomerId"].ToString();

                    if (tRow["rMemId"].ToString() == "")
                        rDisMemId.Visible = false;
                    else
                    {
                        rDisMemId.Visible = true;
                        rMemId.Text = tRow["rMemId"].ToString();
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
                        rIdType.Text = GetLinkTextForModification("Receiver Id Type", "rIdType", tRow);
                        rIdNo.Text = GetLinkTextForModification("Receiver Id No", "rIdNo", tRow);

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
                        rIdType.Text = tRow["rIdType"].ToString(); //
                        rIdNo.Text = tRow["rIdNo"].ToString(); //
                    }

                    hdnRName.Value = tRow["receiverName"].ToString();
                    hdnSName.Value = tRow["senderName"].ToString();

                    sCountry.Text = tRow["sCountryName"].ToString();
                    sEmail.Text = tRow["sEmail"].ToString();
                    rCountry.Text = tRow["rCountryName"].ToString();

                    //Sending Agent Detail
                    hddSAgentEmail.Value = tRow["sAgentEmail"].ToString();
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

                    if (rl.HasRight(ModifyPayoutLocationId) || rl.HasRight(ModifyPayoutLocationIdAg))
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
                    if (tRow["paymentMethod"].ToString().ToUpper().Equals("MOBILE WALLET"))
                    {
                        pnlShowBankDetail.Visible = true;
                    }

                    if (tRow["tranType"].ToString() == "I")
                    {
                        pnlExRate.Visible = false;
                        handling.Text = GetStatic.FormatData(tRow["handlingFee"].ToString(), "M");
                        exRate.Text = GetStatic.FormatData(tRow["exRate"].ToString(), "M");
                    }
                    transferAmount.Text = GetStatic.FormatData(tRow["tAmt"].ToString(), "M");
                    serviceCharge.Text = GetStatic.FormatData(tRow["serviceCharge"].ToString(), "M");
                    total.Text = GetStatic.FormatData(tRow["cAmt"].ToString(), "M");
                    payoutAmt.Text = GetStatic.FormatData(tRow["pAmt"].ToString(), "M");
                    relationship.Text = tRow["relationship"].ToString();
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
                PopulateVoucherDetail(TranNo);
                //pnlLog.Visible = false;
                if (ds.Tables[1].Rows.Count > 0)
                {
                    //pnlLog.Visible = true;
                    var dt = ds.Tables[1];
                    var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");
                    str.Append("<tr>");
                    str.Append("<th>Updated By</th>");
                    str.Append("<th>Updated Date</th>");
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

        protected void btnReleaseCashHoldLimit_Click(object sender, EventArgs e)
        {
            SaveComplianceApproveRemarks("saveCashHoldRmks");

            //DbResult result = obj.CheckTranInBothRule(GetStatic.GetUser(), hddTranId.Value);
            //if (result.ErrorCode == "1")
            //{
            //    SaveComplianceApproveRemarks("saveCashHoldRmks");
            //}
            //else
            //{
            //    var apiRes = ApproveTxn();
            //    if (apiRes.ErrorCode == "0")
            //    {
            //        SaveComplianceApproveRemarks("saveCashHoldRmks");
            //    }
            //    else
            //    {
            //        GetStatic.SetMessage(apiRes);
            //        GetStatic.AlertMessage(Page);
            //    }

            //}
        }

        protected void btnRejectTxn_Click(object sender, EventArgs e)
        {
            var tranId = hddTranId.Value;
            var remarksIdValue = remarksId.Value;
            DbResult _dbRes = at.GetTxnApproveData(GetStatic.GetUser(), tranId);
            if (_dbRes.Extra == "True")//is realtime
            {
                string ProcessId = Guid.NewGuid().ToString().Replace("-", "") + ":" + _dbRes.Extra2 + ":statusSync";

                CancelRequestServices crs = new CancelRequestServices();
                JsonResponse _resp = crs.CancelTransaction(new CancelTxn()
                {
                    ProviderId = _dbRes.Msg,
                    PartnerPinNo = _dbRes.Id,
                    CancelReason = remarksIdValue,
                    ProcessId = ProcessId.Substring(ProcessId.Length - 40, 40)
                });

                if (_resp.ResponseCode == "0")
                {
                    var dr = at.RejectHoldedTXN(GetStatic.GetUser(), hddTranId.Value, lblControlNo.Text);
                    GetStatic.SetMessage(dr);
                    if (dr.ErrorCode != "0")
                    {
                        GetStatic.AlertMessage(Page);
                    }
                    else
                    {
                        //ShowComplianceList();
                        //ShowOFACList();
                        Response.Redirect("/Remit/Compliance/ApproveOFACandComplaince/Dashboard.aspx");
                        return;
                    }
                }
                else
                {
                    var dr = new DbResult()
                    {
                        ErrorCode = "1",
                        Msg = _resp.Msg
                    };
                    GetStatic.SetMessage(dr);
                    GetStatic.AlertMessage(Page);
                }
            }
            else
            {
                var dr = at.RejectHoldedTXN(GetStatic.GetUser(), hddTranId.Value, lblControlNo.Text);
                GetStatic.SetMessage(dr);
                if (dr.ErrorCode != "0")
                {
                    GetStatic.AlertMessage(Page);
                }
                else
                {
                    //ShowComplianceList();
                    //ShowOFACList();
                    Response.Redirect("/Remit/Compliance/ApproveOFACandComplaince/Dashboard.aspx");
                    return;
                }
            }
        }

    protected void bankListDdl_SelectedIndexChanged(object sender, EventArgs e) {
      //string sql = "update remitTran set pBank = '" + bankListDdl.SelectedValue + "', pBankName = '" + bankListDdl.SelectedItem.Text + "' where dbo.decryptDb(controlNo) = '" + lblControlNo.Text + "'";
      //remitDao.ExecuteDataset(sql);
      //GetStatic.AlertMessage(Page, "Bank Changed!");

      DbResult dbResult = mtd.UpdateTransactionPayoutLocation(GetStatic.GetUser()
                                               , hddTranId.Value
                                               , "BankName"
                                               , null
                                               , null
                                               , bankListDdl.SelectedValue
                                               , null
                                               , GetStatic.GetIsApiFlag()
                                               , GetStatic.GetSessionId()
                                               );
      ManageMessage(dbResult);

    }

    protected void chStatusBtn_Click(object sender, EventArgs e) {
      DbResult dbRes = mtd.UpdateChangeStatus(GetStatic.GetUser(), hddTranId.Value, chStatus.SelectedValue);
      ManageMessage(dbRes);
    }

    protected void btnPaidTxn_Click(object sender, EventArgs e) {
      var tranArr = hddRealTranId.Value.Split(',');
      IBankDepositDao _dao = new BankDepositDao();
      var dbResult = _dao.PayBankDeposit(GetStatic.GetUser(), tranArr);
      Response.Redirect("/Remit/Transaction/Modify/ModifyTran.aspx");
    }
  }
}