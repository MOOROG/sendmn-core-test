using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.PaidTrnReport
{
    public partial class PaidTranList : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20162800";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
                toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            }
            Authenticate();
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            sdd.SetDDL(ref sendAgent, "select agentId,agentName from agentMaster where agentType IN (2903,2904)", "agentId", "agentName", "", "All");
            sdd.SetDDL(ref recAgent, "select agentId,agentName from agentMaster where agentType IN (2903,2904) ORDER BY agentName", "agentId", "agentName", "", "All");
        }
        protected void recAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (recAgent.Text != "")
                sdd.SetDDL(ref recBranch, "select agentId,agentName from agentMaster where parentId='" + recAgent.Text + "' order by agentName", "agentId", "agentName", "", "All");
        }
    }
}