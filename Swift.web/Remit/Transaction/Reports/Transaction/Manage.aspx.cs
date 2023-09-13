using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.Transaction
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20163500";
        private const string ViewAdvanceSearch = "20163510";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextBox();
                PopulateDdl();
                if (sl.HasRight(ViewAdvanceSearch))
                    ShowHideAd.Visible = true;
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                localDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                localDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
            //GetStatic.ResizeFrame(Page);
        }
        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref cAmtFrom);
            Misc.MakeNumericTextbox(ref cAmtTo);
            Misc.MakeNumericTextbox(ref pAmtFrom);
            Misc.MakeNumericTextbox(ref pAmtTo);
            Misc.MakeNumericTextbox(ref tranNo);
        }
        private void PopulateDdl()
        {
            sdd.SetDDL3(ref sCountry, "EXEC proc_dropDownLists @flag = 'sCountry'", "countryId", "countryName", "", "All");
            sdd.SetDDL3(ref rCountry, "EXEC proc_dropDownLists @flag = 'pCountry'", "countryId", "countryName", "", "All");
            sdd.SetDDL3(ref receivingMode, "EXEC proc_serviceTypeMaster @flag = 'l2'", "typeTitle", "typeTitle", "", "All");
            sdd.SetDDL3(ref status, @"SELECT valueId,case when detailTitle = 'Payment' then 'Unpaid' else detailTitle end detailTitle
FROM staticDataValue WHERE typeID=5400", "detailTitle", "detailTitle", "", "All");
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sCountry.Text != "")
                sdd.SetDDL3(ref sAgent, "EXEC proc_agentMaster @flag='alc',@agentCountryId='" + sCountry.Text + "'", "agentId", "agentName", "", "All");
            else
                sAgent.Text = "";
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (rCountry.Text != "")
                sdd.SetDDL3(ref rAgent, "EXEC proc_agentMaster @flag='alc',@agentCountryId='" + rCountry.Text + "'", "agentId", "agentName", "", "All");
            else
                rAgent.Text = "";
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sAgent.Text != "")
                sdd.SetDDL3(ref sBranch, "EXEC proc_agentMaster @flag='bl',@parentId='" + sAgent.Text + "'", "agentId", "agentName", "", "All");
            else
                sBranch.Text = "";
        }

        protected void rAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (rAgent.Text != "")
                sdd.SetDDL3(ref rBranch, "EXEC proc_agentMaster @flag='bl',@parentId='" + rAgent.Text + "'", "agentId", "agentName", "", "All");
            else
                rBranch.Text = "";
        }

    }
}