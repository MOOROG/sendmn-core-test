using System;
using Swift.web.Library;

namespace Swift.web.Responsive.Reports.SettlementDomestic
{
    public partial class Manage : System.Web.UI.Page
    {
        protected string AgentMapCode = "";
        protected string BranchMapCode = "";
        protected string Flag = "";
        protected string AgentId = "";
        protected string BranchId = "";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private const string ViewFunctionId = "40121300";
        private const string ViewAllBranchReportFunctionId = "40121310";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
                PopulateData();
            }
        }

        private void Authenticate()
        {
            _rl.CheckAuthentication(ViewFunctionId);
        }
        
        private void PopulateData()
        {
            var isActAsBranch = GetStatic.GetIsActAsBranch();
            var agentType = GetStatic.GetAgentType();
            var agentMapCode = GetStatic.GetMapCodeInt();
            var parentMapCode = GetStatic.GetParentMapCodeInt();
            var agentId = GetStatic.GetAgentId();
            AgentId = GetStatic.GetAgent();
            BranchId = GetStatic.GetBranch();
            var settlingAgent = GetStatic.GetSettlingAgent();
            var isSettlingAgent = "N";
            if (agentId == settlingAgent)
                isSettlingAgent = "Y";

            if (isActAsBranch == "Y" && agentType == "2903") // Private Agents
            {
                AgentMapCode = agentMapCode;
                BranchMapCode = agentMapCode;
            }
            else if (agentType == "2904") // Bank & Finance
            {
                if (isSettlingAgent == "N")
                {
                    if (_rl.HasRight(ViewAllBranchReportFunctionId))
                    {
                        AgentMapCode = parentMapCode;
                        BranchMapCode = agentMapCode;
                        Flag = "Y";
                        trBranch.Visible = true;
                        PopulateDdl(parentMapCode);
                    }
                    else
                    {
                        AgentMapCode = parentMapCode;
                        BranchMapCode = agentMapCode;
                    }
                }
                if (isSettlingAgent == "Y")
                {
                    AgentMapCode = agentMapCode;
                    BranchMapCode = agentMapCode;
                }
            }
        }
        private void PopulateDdl(string aMapCode)
        {
            string sql = "EXEC FastMoneyPro_account.dbo.PROC_SETTLEMENT_REPORT_V2 @FLAG = 'DDL_BRANCH',@AGENT =" + _rl.FilterString(aMapCode) + "";
            _sdd.SetDDL3(ref branch, sql, "map_code", "agent_name", "", "All");
        }
    }
}