using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.Reports.StatementOfAccount
{
    public partial class Manage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20161700";
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

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
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag='sCountry'", "countryId", "countryName", "", "Select");
            sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownLists @flag='alcC',@param1=" + sdd.FilterString(sCountry.SelectedItem.Text) + ",@param='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "Select");
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(sCountry.Text))
                sAgent.Items.Clear();
            else
                sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownLists @flag='agents_ForSoa',@param1=" + sdd.FilterString(sCountry.Text), "agentId", "agentName", "", "Select");
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(sCountry.Text))
                sAgent.Items.Clear();
            else
                sdd.SetDDL3(ref branchUser, "EXEC proc_dropDownLists @flag='branchUser',@agentId=" + sdd.FilterString(sAgent.Text), "agentId", "agentName", "", "All");
            //sdd.SetDDL3(ref sBranch, "EXEC proc_dropDownLists @flag='branch',@agentId=" + sdd.FilterString(sAgent.Text), "agentId", "agentName", "", "All");
        }
    }
}