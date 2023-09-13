using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.UnpaidTxnReport
{
    public partial class PayingAgentSettlementReport : System.Web.UI.Page
    {
        private readonly string ViewFunctionId = "20167600";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                ToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                Authenticate();
                RemittanceLibrary r = new RemittanceLibrary();
                r.SetDDL(ref PayingAgent, "EXEC Proc_dropdown_remit @FLAG='SettlingAgent'", "agentId", "AgentName", "", "Select Paying Agent");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}