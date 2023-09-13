using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.SearchTxnReport
{
    public partial class SearchTransaction : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                controlNoName.Text = GetStatic.GetTranNoName();
                string txnId = GetStatic.ReadQueryString("tranId", "");
                string cntNo = GetStatic.ReadQueryString("controlNo", "");
                if (!string.IsNullOrEmpty(txnId) || !string.IsNullOrEmpty(cntNo))
                {
                    ShowTxnDetail(txnId, cntNo);
                }
            }
            GetStatic.ResizeFrame(Page);
            GetStatic.Process(ref btnSearch);
            Misc.MakeNumericTextbox(ref txnNo, true);
        }

        private void Authenticate()
        {
            obj.CheckSession();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ShowTxnDetail(txnNo.Text, controlNo.Text);
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
        }
    }
}