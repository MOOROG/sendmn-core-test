using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.RemittanceSystem.RemittanceReports.NewCustomerRegistrationReport
{
    public partial class NewCustomerRegistrationReport : System.Web.UI.Page
    {
        RemittanceLibrary _sl = new RemittanceLibrary();
        private string ViewFunctionId = "20302200";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            PopulateDDL();
            if (!IsPostBack)
            {
                from.Text = DateTime.Now.ToString("yyyy/MM/dd");
                to.Text = DateTime.Now.ToString("yyyy/MM/dd");
            }

        }
        private void Authenticate()
        {
            _sl.HasRight(ViewFunctionId);
        }
        private void PopulateDDL()
        {
            _sl.SetDDL( ref sBranch, "EXEC proc_sendPageLoadData @flag='S-AGENT',@user='" + GetStatic.GetUser() + "'", "agentId", "agentName", "All", "All");
        }
    }
}