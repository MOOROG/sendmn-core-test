using System;
using System.Web.UI.WebControls;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.PaidTrnReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20162500";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                fromDate.Text = DateTime.Now.ToString("d");
                toDate.Text = DateTime.Now.ToString("d");
                PopulateDdl();
                Authenticate();
            }
            
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            sdd.SetDDL(ref sendCountry, "EXEC proc_countryMaster @flag = 'ocl'", "countryName", "countryName", "Nepal", "All");
            sdd.SetDDL(ref recCountry, "EXEC proc_countryMaster @flag = 'ocl'", "countryName", "countryName", "Nepal", "All");

            sendCountry.Enabled = false;
            recCountry.Enabled = false;

            sdd.SetDDL(ref sendAgent, "select agentId,agentName from agentMaster where agentType IN (2903,2904)", "agentId", "agentName", "", "All");
            sdd.SetDDL(ref recAgent, "select agentId,agentName from agentMaster where agentType IN (2903,2904)", "agentId", "agentName", "", "All");

            LoadState(ref sendZone, sendCountry.Text, "");
            LoadState(ref recZone, recCountry.Text, "");

            LoadDistrict(ref sendDistrict, sendZone.Text, "");
            LoadDistrict(ref recDistrict, recZone.Text, "");

            LoadLocation(ref sendLocation, sendDistrict.Text, "");
            LoadLocation(ref recLocation, recDistrict.Text, "");
        }

        private void LoadState(ref DropDownList ddl, string countryName, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl2', @countryName=" + sdd.FilterString(countryName);
            sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        protected void sendAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            var s = sendAgent.Text;
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

        protected void sendZone_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref sendDistrict, sendZone.Text, "");
        }

        protected void recZone_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref recDistrict, recZone.Text, "");
        }

        protected void sendDistrict_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadLocation(ref sendLocation, sendDistrict.Text, "");
        }

        protected void recDistrict_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadLocation(ref recLocation, recDistrict.Text, "");
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

        protected void sendLocation_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgentLocation(ref sendAgent, sendLocation.Text, "");
        }
    }
}