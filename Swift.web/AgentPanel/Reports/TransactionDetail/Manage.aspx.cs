using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Reports.TxnDetail
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "40121600";

        protected string GetBranch()
        {
            return GetStatic.GetBranch();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateBenificiary();
                PopulatePaymentType();
                sl.SetPayStatusDdl(ref status, "", "All");
                PopulateTranStatus();
                frmDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateBenificiary()
        {
            var sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() +
                      "',@agentid='" + GetStatic.GetAgentId() + "'";
            sl.SetDDL(ref pCountry, sql, "countryId", "countryName", "", "");

            //sl.SetDDL(ref Sbranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
            //    GetStatic.GetBranch() + ",@userType=" + GetStatic.GetUserType(), "agentId", "agentName", "", "");

            if (GetStatic.GetUserType() == "AB")
                sdd.SetDDL3(ref Sbranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "");
            else if (GetStatic.GetUserType() == "AH")
                sdd.SetDDL3(ref Sbranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "All");
            else
                sdd.SetDDL3(ref Sbranch, "EXEC proc_dropDownLists @flag ='rh-branch',@branchId=" +
                        sdd.FilterString(GetStatic.GetBranch()) + ",@userType=" + sdd.FilterString(GetStatic.GetUserType()), "agentId", "agentName", "", "");
        }

        private void PopulateTranStatus()
        {
            var label = "";

            if (status.Text.ToLower().Equals("unpaid") || string.IsNullOrWhiteSpace(status.Text))
            {
                label = "All";
            }
            sl.SetTranStatusDdl(ref tranType, status.Text, "", label);
        }

        private void PopulateAgent()
        {
            var sql = "EXEC proc_dropDownLists @flag='agent', @country =" + pCountry.SelectedValue;
            sl.SetDDL(ref pAgent, sql, "agentId", "agentName", "", "All");
        }

        private void PopulatePaymentType()
        {
            var sql = "EXEC proc_sendPageLoadData @flag='recModeByCountry-txnReport',@countryId = " + GetStatic.GetCountryId() + ", @agentId =" + GetStatic.GetAgent() + ",@pCountryId =" + sl.FilterString(pCountry.Text);
            sl.SetDDL(ref paymentType, sql, "serviceTypeId", "typeTitle", "", "All");
        }

        protected void status_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateTranStatus();
        }

        protected void pCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(pCountry.Text))
            {
                pAgent.Items.Clear();
            }
            else
            {
                PopulateAgent();
            }
            PopulatePaymentType();
        }
    }
}