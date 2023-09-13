using Swift.web.Library;
using System;

namespace Swift.web.Remit.CreditRiskManagement.Reports
{
    public partial class TopupHistoryRpt : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20181800";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                fromDate.ReadOnly = true;
                toDate.ReadOnly = true;
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}