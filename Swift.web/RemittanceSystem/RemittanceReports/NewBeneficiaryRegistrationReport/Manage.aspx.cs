using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.RemittanceSystem.RemittanceReports.NewBeneficiaryRegistrationReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20309000";
        protected string AgentId = "";
        protected string BranchId = "";
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
            PopulateData();
            PopulateDDL();
        }
        private void PopulateData()
        {
            AgentId = GetStatic.GetAgent();
            BranchId = GetStatic.GetBranch();
        }
        private void Authenticate()
        {
            _rl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDDL()
        {
            _sl.SetDDL(ref sBranch, "EXEC proc_sendPageLoadData @flag='S-AGENT',@user='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "Select Branch/Agent");
        }
    }
}