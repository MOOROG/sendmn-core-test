using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Utilities.ModifyRequest
{
    public partial class TxnDetail : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                ShowTxnDetail();
            }
        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }

        protected string PrintBreadCrum()
        {
            return "Reports » Transaction Detail";
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }

        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") == "Y");
        }

        private void ShowTxnDetail()
        {
            string txnId = "";
            string cntNo = "";

            if (GetStatic.ReadQueryString("searchBy", "") == "controlNo")
                cntNo = GetStatic.ReadQueryString("searchValue", "");
            else if (GetStatic.ReadQueryString("searchBy", "") == "tranId")
                txnId = GetStatic.ReadQueryString("searchValue", "");

            if (txnId != "" || cntNo != "")
            {
                ucTran.ShowCommentBlock = ShowCommentFlag();
                ucTran.ShowBankDetail = ShowBankDetail();

                ucTran.SearchData(txnId, cntNo, "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");

                if (!ucTran.TranFound)
                {
                    divMsg.InnerHtml = "<h2>No Transaction Found</h2>";
                }
                divTranDetails.Visible = ucTran.TranFound;
                divMsg.Visible = !ucTran.TranFound;
            }
        }
    }
}