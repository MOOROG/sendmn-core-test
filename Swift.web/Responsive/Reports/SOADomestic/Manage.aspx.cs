using System;
using Swift.web.Library;

namespace Swift.web.Responsive.Reports.SOADomestic
{
    public partial class Manage : System.Web.UI.Page
    {
        protected string AgentMapCode = "";
        protected string AgentId = "";
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private const string ViewFunctionId = "40121000";

        protected void Page_Load(object sender, EventArgs e)
        {
            _rl.CheckSession();
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
            var agentName = GetStatic.GetAgentName();
            var parentMapCode = GetStatic.GetParentMapCodeInt();
            var agentId = GetStatic.GetAgentId();
            AgentId = GetStatic.GetAgent();
            var settlingAgent = GetStatic.GetSettlingAgent();
            var isSettlingAgent = "N";
            if (agentId == settlingAgent)
                isSettlingAgent = "Y";

            if (isActAsBranch == "Y" && agentType == "2903") // Private Agents
            {
                AgentMapCode = agentMapCode;
            }
            else if (agentType == "2904") // Bank & Finance
            {
                if (isSettlingAgent == "N")
                    AgentMapCode = parentMapCode;
                if (isSettlingAgent == "Y")
                    AgentMapCode = agentMapCode;
            }
            lblAgent.Text = agentName + "- " + AgentMapCode;
        }
    }
}
   