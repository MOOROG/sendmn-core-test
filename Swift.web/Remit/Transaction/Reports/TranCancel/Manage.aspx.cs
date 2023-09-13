using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.TranCancel
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20163300";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {

            sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag = 'sCountry'", "countryName", "countryName", "", "All");
            sdd.SetDDL(ref rCountry, "EXEC proc_dropDownLists @flag='pCountry'", "countryName", "countryName", "", "");
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sAgent.Text != "")
                sdd.SetDDL3(ref sBranch, "EXEC proc_agentMaster @flag='bl',@parentId='" + sAgent.Text + "'", "agentId", "agentName", "", "All");
            else
                sBranch.Text = "";
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(rCountry.Text))
            {
                rAgent.Items.Clear();
            }
            else
                sl.SetDDL(ref rAgent, "EXEC proc_dropDownLists @flag='agent_1',@country=" + sdd.FilterString(rCountry.Text), "agentId", "agentName", "", "All");
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sCountry.Text != "")
            {
                sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownLists @flag='agent_1',@country='" + sCountry.Text + "'",
                            "agentId", "agentName", "", "All");
            }
            else
                sAgent.Text = "";
        }
    }
}