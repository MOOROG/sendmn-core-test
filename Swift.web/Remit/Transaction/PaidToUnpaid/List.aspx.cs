using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.PaidToUnpaid
{
    public partial class List : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20122400";
        protected void Page_Load(object sender, EventArgs e)
        {
            btnPaidToUnpaid.Visible = false;
            if (!IsPostBack)
            {
                Authenticate();
                controlNoName.Text = GetStatic.GetTranNoName();
                string cntNo = GetStatic.ReadQueryString("controlNo", "");
                if (!string.IsNullOrEmpty(cntNo))
                {
                    ShowTxnDetail("", cntNo);
                }
            }
            GetStatic.ResizeFrame(Page);
            GetStatic.Process(ref btnSearch);
        }

        private void Authenticate()
        {
            obj.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ShowTxnDetail("", controlNo.Text);
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }
        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") == "Y");
        }

        private void ShowTxnDetail(string txnId, string cntNo)
        {
            if (string.IsNullOrEmpty(txnId) && string.IsNullOrEmpty(cntNo))
            {
                GetStatic.AlertMessage(Page, "Sorry, Invalid Input.");
                return;
            }

            ucTran.ShowCommentBlock = ShowCommentFlag();
            ucTran.ShowBankDetail = ShowBankDetail();
            ucTran.SearchData(txnId, cntNo, "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");
            if (!ucTran.TranFound)
            {
                GetStatic.AlertMessage(Page, "Sorry, Transaction Not Found.");
                return;
            }
            divTranDetails.Visible = ucTran.TranFound;
            divControlno.Visible = !ucTran.TranFound;
            btnPaidToUnpaid.Visible = ucTran.TranFound;
        }

        protected void btnPaidToUnpaid_Click(object sender, EventArgs e)
        {
            LockUnlock dao = new LockUnlock();
            var dbresult = dao.PaidToUnpaidTxn(GetStatic.GetUser(), ucTran.CtrlNo);
            GetStatic.AlertMessage(this, dbresult.Msg);
           if (dbresult.ErrorCode == "0")
            {
                ShowTxnDetail("", controlNo.Text);
                btnPaidToUnpaid.Visible = false;
            }
        }
    }
}