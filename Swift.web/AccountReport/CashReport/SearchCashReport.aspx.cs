using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AccountReport.CashReport
{
    public partial class SearchCashReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private string ViewFunctionId = "20190300";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
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
            //sl.SetDDL(ref sCountry, "EXEC proc_dropDownLists @flag='sCountry'", "countryId", "countryName", "", "Select");
            //sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list',@param1=" + sdd.FilterString(sCountry.SelectedItem.Text) + ",@param='" + GetStatic.GetUser() + "'", "agentId", "agentName", "", "Select");
            //sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='partner-list'", "agentId", "agentName", "", "Select");

        }

        //protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        //{
        //    if (string.IsNullOrWhiteSpace(sCountry.Text))
        //        payoutPartner.Items.Clear();
        //    else
        //        sdd.SetDDL3(ref payoutPartner, "EXEC proc_dropDownLists @flag='Partneragent',@country=" + sdd.FilterString(sCountry.Text), "agentId", "agentName", "", "Select");
        //}
    }
}