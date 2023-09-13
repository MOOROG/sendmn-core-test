using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Reports.TxnSummary
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "40121700";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReceiverCountry();
                Authenticate();
                PopulateDdl();
                from.Text = DateTime.Now.ToString("yyyy-MM-dd");
                to.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            if (GetStatic.GetUserType() == "AB")
                sdd.SetDDL3(ref branch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "");
            else if (GetStatic.GetUserType() == "AH")
                sdd.SetDDL3(ref branch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "All");
            else
                sdd.SetDDL3(ref branch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "");
            //sl.SetDDL(ref branch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId="+GetStatic.GetBranch()+",@userType=" + GetStatic.GetUserType(), "agentId", "agentName", "", "");
        }

        private void LoadReceiverCountry()
        {
            var sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() + "',@agentid='" + GetStatic.GetAgentId() + "'";
            sdd.SetDDL(ref beneficiary, sql, "countryId", "countryName", "", "");
        }

        protected void beneficiary_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(beneficiary.Text))
            {
                agentName.Items.Clear();
            }
            else
            {
                var sql = "EXEC proc_dropDownLists @flag='agent', @country =" + beneficiary.SelectedValue;
                sl.SetDDL(ref agentName, sql, "agentId", "agentName", "", "All");
            }
        }
    }
}