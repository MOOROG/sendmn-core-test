using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports
{
    public partial class SearchPartnerPin : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20204001";
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                string Partnerpin = GetStatic.ReadQueryString("controlNo", "");
                if (!string.IsNullOrEmpty(Partnerpin))
                {
                    ShowTxnDetail(Partnerpin);
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
            ShowTxnDetail(PIN.Text);
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }
        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") == "Y");
        }

        private void ShowTxnDetail(string PIN)
        {
            if (string.IsNullOrEmpty(PIN))
            {
                GetStatic.AlertMessage(Page, "Sorry, Invalid Input.");
                return;
            }

            ucTran.ShowCommentBlock = ShowCommentFlag();
            ucTran.ShowBankDetail = ShowBankDetail();

            ucTran.SearchPartnerData(PIN, "", "", "SEARCH", "ADM: VIEW PARTNER  (SEARCH PARTNER TRANSACTION)");
            if (!ucTran.TranFound)
            {
                GetStatic.AlertMessage(Page, "Sorry, Partner TXN Not Found.");
                return;
            }
            divTranDetails.Visible = ucTran.TranFound;
            divControlno.Visible = !ucTran.TranFound;
        }
    }
}