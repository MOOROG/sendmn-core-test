using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.RiskBasedAssesement.RBAReport
{
    public partial class RBAReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20163400";
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
               // Authenticate();
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
            GetStatic.ResizeFrame(Page);
        }

        private void PopulateDdl()
        {
            sdd.SetDDL(ref sCountry, "EXEC proc_countryMaster 'scl'", "countryId", "countryName", "", "Select");
            sdd.SetDDL2(ref rCountry, "EXEC proc_countryMaster 'rcl'", "countryName", "", "All");
            sdd.SetDDL2(ref sNativeCountry, "EXEC proc_countryMaster 'l'", "countryName", "", "All");

            sCountry.Text = "133";
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sCountry.Text != "")
                sdd.SetDDL(ref sAgent, "EXEC proc_agentMaster @flag='alc',@agentCountryId='" + sCountry.Text + "'", "agentId", "agentName", "", "All");
            else
                sAgent.Items.Clear();
            sCountry.Focus();
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sAgent.Text != "")
                sdd.SetDDL(ref sBranch, "EXEC proc_agentMaster @flag='bl',@parentId='" + sAgent.Text + "'", "agentId", "agentName", "", "All");
            else
                sBranch.Items.Clear();
            sAgent.Focus();
        }

        protected void reportFor_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (reportFor.Text.ToUpper())
            {
                case "TXN RBA":
                    trSendingAgent.Visible = true;
                    trSendingBranch.Visible = true;

                    trTxnCount.Visible = false;
                    trBenCountryCount.Visible = false;
                    trBenCount.Visible = false;
                    trOutletCount.Visible = false;

                    trReceiverCountry.Visible = true;

                    rptType.Items.Add(new ListItem("Summary Report-Agent", "Summary Report-Agent"));
                    rptType.Items.Add(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "TXN AVERAGE RBA":
                    trSendingAgent.Visible = false;
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trBenCountryCount.Visible = true;
                    trBenCount.Visible = true;
                    trOutletCount.Visible = true;

                    trReceiverCountry.Visible = false;

                    rptType.Items.Remove(new ListItem("Summary Report-Agent", "Summary Report-Agent"));
                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "PERIODIC RBA":
                    trSendingAgent.Visible = false;
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trBenCountryCount.Visible = true;
                    trBenCount.Visible = true;
                    trOutletCount.Visible = true;

                    trReceiverCountry.Visible = false;

                    rptType.Items.Remove(new ListItem("Summary Report-Agent", "Summary Report-Agent"));
                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "FINAL RBA":
                    trSendingAgent.Visible = false;
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trBenCountryCount.Visible = true;
                    trBenCount.Visible = true;
                    trOutletCount.Visible = true;

                    trReceiverCountry.Visible = false;

                    rptType.Items.Remove(new ListItem("Summary Report-Agent", "Summary Report-Agent"));
                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
            }
        }
    }
}