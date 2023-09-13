using Swift.web.Library;
using System;

namespace Swift.web.Remit.CreditRiskManagement.Reports
{
    public partial class CreditSecurityRPT : System.Web.UI.Page
    {
        public RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20181800";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            txtDate.ReadOnly = true;
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void securitytype_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (securitytype.Text == "bg" || securitytype.Text == "fd")
                isexpiry.Visible = true;
            else
                isexpiry.Visible = false;
        }
    }
}