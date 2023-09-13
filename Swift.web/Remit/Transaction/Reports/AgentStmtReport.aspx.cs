using System;
using System.Web.UI;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports
{
    public partial class AgentStmtReport : Page
    {
        private const string ViewFunctionId = "20161400";
        private readonly StaticDataDdl _sl = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

       
    }
}