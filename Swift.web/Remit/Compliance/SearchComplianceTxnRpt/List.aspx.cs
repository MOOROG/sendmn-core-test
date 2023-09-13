using Swift.web.Library;
using System;

namespace Swift.web.Remit.Compliance.SearchComplianceTxnRpt
{
    public partial class List : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20197001";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            GetStatic.ResizeFrame(Page);
            GetStatic.Process(ref btnSearch);
            Misc.MakeNumericTextbox(ref txnNo, true);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string txnId = txnNo.Text;
            string cntNo = controlNo.Text;

            if (string.IsNullOrEmpty(txnId) && string.IsNullOrEmpty(cntNo))
            {
                GetStatic.AlertMessage(Page, "Sorry, Invalid Input.");
                return;
            }

            Response.Redirect("Manage.aspx?tranId=" + txnId + "&controlNo=" + cntNo);
        }

        private void Authenticate()
        {
            obj.CheckAuthentication(ViewFunctionId);
        }
    }
}