using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.DailySendingReportAgent
{
    public partial class DailySendingReportAgent : System.Web.UI.Page
    {
        private string ViewFunctionId = "20302700";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            _sl.SetDDL(ref payoutPartner, "EXEC PROC_API_ROUTE_PARTNERS @flag='partner'", "agentId", "agentName", "", "All");
            _sdd.SetDDL(ref sAgent, "EXEC proc_sendPageLoadData @flag='S-AGENT-BEHALF',@user='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "All");
        }
    }
}