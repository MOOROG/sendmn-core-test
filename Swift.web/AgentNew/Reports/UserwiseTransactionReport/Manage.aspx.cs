using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.UserwiseTransactionReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40121400";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

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
            var sql = "EXEC proc_dropDownLists @flag = 'rh-branch', @userType =" + sdd.FilterString(GetStatic.GetUserType()) + ", @branchId=" + sdd.FilterString(GetStatic.GetBranch()) + " , @user=" + sdd.FilterString(GetStatic.GetUser());
            var label = GetStatic.GetUserType().ToLower().Equals("rh") ? "All" : "";
            label = GetStatic.GetUserType().ToLower().Equals("ah") ? "All" : "";
            sdd.SetDDL(ref branch, sql, "agentId", "agentName", "", label);

            sdd.SetDDL3(ref userName, "EXEC proc_dropDownLists @flag='userList1',@branchId='" + branch.Text + "'", "userName", "userName", "", "All");
            sdd.SetDDL3(ref recCountry, "EXEC proc_dropDownLists @flag = 'pCountry'", "countryName", "countryName", "", "All");
        }

        protected void branch_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(branch.Text))
                sdd.SetDDL3(ref userName, "EXEC proc_dropDownLists @flag='userList1',@branchId='" + branch.Text + "'", "userName", "userName", "", "All");
            else
                userName.Items.Clear();
        }
    }
}