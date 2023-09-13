using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.PaidTXN_Int_Rpt
{
    public partial class ManageInternational : System.Web.UI.Page
    {

        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20190000";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDdl();
                Authenticate();
            }
            fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            sdd.SetDDL(ref sendCountry, "EXEC proc_countryMaster @flag = 'ocl1'", "countryName", "countryName", "", "All");
            sdd.SetDDL(ref recCountry, "EXEC proc_countryMaster @flag = 'ocl'", "countryName", "countryName", "", "All");

            sdd.SetDDL(ref sendAgent, "exec [proc_agentMaster] @flag='al6'", "agentId", "agentName", "", "All");
            sdd.SetDDL(ref recAgent, "select agentId,agentName from agentMaster where agentType IN (2903,2904)", "agentId", "agentName", "", "All");

            LoadState(ref sendZone, sendCountry.Text, "");
            LoadState(ref recZone, recCountry.Text, "");
            LoadDistrict(ref recDistrict, recZone.Text, "");
            LoadLocation(ref recLocation, recDistrict.Text, "");
        }

        private void LoadState(ref DropDownList ddl, string countryName, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl2', @countryName=" + sdd.FilterString(countryName);
            sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        protected void sendAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (sendAgent.Text != "")
                sdd.SetDDL(ref sendBranch, "select agentId,agentName from agentMaster where parentId='" + sendAgent.Text + "'", "agentId", "agentName", "", "All");

        }

        protected void recAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (recAgent.Text != "")
                sdd.SetDDL(ref recBranch, "select agentId,agentName from agentMaster where parentId='" + recAgent.Text + "'", "agentId", "agentName", "", "All");
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + sdd.FilterString(zone);
            sdd.SetDDL3(ref ddl, sql, "districtId", "districtName", defaultValue, "All");
        }

        private void LoadLocation(ref DropDownList ddl, string districtId, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'll',@districtId=" + sdd.FilterString(districtId);
            sdd.SetDDL3(ref ddl, sql, "locationId", "locationName", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryName, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'alc1',@agentCountry=" + sdd.FilterString(countryName);
            sdd.SetDDL3(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        protected void recZone_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref recDistrict, recZone.Text, "");
        }

        protected void recDistrict_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadLocation(ref recLocation, recDistrict.Text, "");
        }

        protected void sendCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref sendZone, sendCountry.SelectedItem.Text, "");
            LoadAgent(ref sendAgent, sendCountry.SelectedItem.Text, "");
            sendCountry.Focus();
        }
        protected void recCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref recZone, recCountry.SelectedItem.Text, "");
            recCountry.Focus();
        }

        protected void recLocation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgentLocation(ref recAgent, recLocation.Text, "");
        }

        private void LoadAgentLocation(ref DropDownList ddl, string locationId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'all',@agentLocation=" + sdd.FilterString(locationId);
            sdd.SetDDL3(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

    }
}