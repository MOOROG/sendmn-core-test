using System;
using System.Web.UI;
using Swift.web.Library;


namespace Swift.web.Remit.Transaction.Reports.UserWiseTran
{
    public partial class Manage : Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20162400";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
            }
            fromDate1.Text = DateTime.Now.ToString("MM/dd/yyyy");
            toDate1.Text = DateTime.Now.ToString("MM/dd/yyyy");
            fromDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
            toDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            sdd.SetDDL3(ref country, "EXEC proc_dropDownLists @flag = 'sCountry'", "countryName", "countryName", "", "Select");
            sdd.SetDDL3(ref recCountry, "EXEC proc_dropDownLists @flag = 'pCountry'", "countryName", "countryName", "", "All");
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (country.Text != "")
                sdd.SetDDL3(ref agent, "EXEC proc_dropDownLists @flag='agentByCountryName',@country='" + country.Text + "'", "agentId", "agentName", "", "Select");
            else
                agent.Text = "";
        }

        protected void agent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (agent.Text != "")
                sdd.SetDDL3(ref branch, "EXEC proc_agentMaster @flag='bl',@parentId='" + agent.Text + "'", "agentId", "agentName", "", "All");
            else
                branch.Text = "";
        }

        protected void branch_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (branch.Text != "")
                sdd.SetDDL3(ref userName, "EXEC proc_dropDownLists @flag='userList1',@branchId='" + branch.Text + "'", "userName", "userName", "", "All");
            else
                userName.Text = "";
        }

        protected void userType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (userType.Text == "HO")
                sdd.SetDDL(ref userName1, "EXEC [proc_applicationUsers] @flag='HO'", "userName", "userName", "", "All");
            else if (userType.Text == "Agent")
                sdd.SetDDL(ref userName1, "EXEC [proc_applicationUsers] @flag='agent'", "userName", "userName", "", "All");
            else
                userName1.Text = "";
        }
    }
}