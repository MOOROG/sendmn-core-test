using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.IntlReports.SettlementReport
{
    public partial class PayingAgent : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private string ViewFunctionId = "20190100";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
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
        //private void PopulateDdl()
        //{
        //    //sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag='sCountry'", "countryId", "countryName", "", "Select");
        //    //sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list',@param1=" + sdd.FilterString(sCountry.SelectedItem.Text) + ",@param='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "Select");
        //    sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list'", "agentId", "agentName", "", "Select");

        //}
        private void PopulateDdl()
        {
            sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag='sCountry'", "countryId", "countryName", "", "Select");
            sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownLists @flag='alcC',@param1=" + sdd.FilterString(sCountry.SelectedItem.Text) + ",@param='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "All");

        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(sCountry.Text))
                sAgent.Items.Clear();
            else
                sdd.SetDDL3(ref sAgent, "EXEC proc_dropDownLists @flag='agent',@country=" + sdd.FilterString(sCountry.Text), "agentId", "agentName", "", "All");
        }
    }
}