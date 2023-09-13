using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.RiskBasedAssesement.RBAReport
{
    public partial class RBAReportMex : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20163400";
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
              //  Authenticate();
                PopulateDdl();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
            GetStatic.ResizeFrame(Page);
        }

        private void PopulateDdl()
        {
            sdd.SetDDL2(ref sNativeCountry, "EXEC proc_countryMaster 'l'", "countryName", "", "All");
            sdd.SetExchangeDDL(ref sBranch, "EXEC proc_ExchangeDropdown @FLAG='branchList', @user = " + sdd.FilterString(GetStatic.GetUser()), "COMPANY_ID", "BRANCH_NAME", "", "All Branch");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void reportFor_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (reportFor.Text.ToUpper())
            {
                case "TXN RBA":
                    trSendingBranch.Visible = true;

                    trTxnCount.Visible = false;
                    trCurrencyCount.Visible = false;
                    trOutletCount.Visible = false;

                    rptType.Items.Add(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "TXN AVERAGE RBA":
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trCurrencyCount.Visible = true;
                    trOutletCount.Visible = true;

                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "PERIODIC RBA":
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trCurrencyCount.Visible = true;
                    trOutletCount.Visible = true;

                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
                case "FINAL RBA":
                    trSendingBranch.Visible = false;

                    trTxnCount.Visible = true;
                    trCurrencyCount.Visible = true;
                    trOutletCount.Visible = true;

                    rptType.Items.Remove(new ListItem("Summary Report-Branch", "Summary Report-Branch"));
                    break;
            }
        }
    }
}