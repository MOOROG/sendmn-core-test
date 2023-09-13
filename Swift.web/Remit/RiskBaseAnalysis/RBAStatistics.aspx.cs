using System;
using Swift.web.Library;

namespace Swift.web.Remit.RiskBaseAnalysis
{
	public partial class RBAStatistics : System.Web.UI.Page
	{
		private readonly StaticDataDdl sdd = new StaticDataDdl();
		private readonly SwiftLibrary sl = new SwiftLibrary();
		private const string ViewFunctionId = "20191700";
		protected void Page_Load(object sender, EventArgs e)
		{
			sl.CheckSession();
			if (!IsPostBack)
			{
				Authenticate();
				PopulateDdl();
				fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
				toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
			}
			GetStatic.ResizeFrame(Page);
		}

		private void PopulateDdl()
		{
			sdd.SetDDL(ref sCountry, "EXEC proc_countryMaster 'scl'", "countryId", "countryName", "133", "Select");
			LoadSendingAgent("133");
		}
		protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
		{
			if (sCountry.Text != "")
				LoadSendingAgent(sCountry.Text);
			else
				sAgent.Items.Clear();
			sCountry.Focus();
		}
		private void LoadSendingAgent(string countryId)
		{
			sdd.SetDDL(ref sAgent, "EXEC proc_agentMaster @flag='alc',@agentCountryId='" + countryId + "'", "agentId", "agentName", "", "All");
		}

		protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
		{
			if (sAgent.Text != "")
				PopulateBranch(sAgent.Text);
			else
				sBranch.Items.Clear();
			sAgent.Focus();
		}
		private void Authenticate()
		{
			sl.CheckAuthentication(ViewFunctionId);
		}
		protected void PopulateBranch(string agentId)
		{
			sdd.SetDDL(ref sBranch, "EXEC proc_agentMaster @flag='bl',@parentId='" + agentId + "'", "agentId", "agentName", "", "All");
		}
	}
}