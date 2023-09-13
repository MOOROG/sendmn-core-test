using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports
{
    public partial class TranReportMaster : Page
    {
        private readonly TranReportDao _obj = new TranReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        RemittanceLibrary sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20161100";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                sendDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                sendDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //paidDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //paidDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //cancelledDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //cancelledDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //approvedDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //approvedDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateDdl();
                LoadFieldSelectionBox();
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateDdl()
        {
            _sdd.SetDDL(ref transactionType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
                        "", "All");
           
           // _sdd.SetStaticDdl(ref tranStatus, "5400", "", "Select");
            _sdd.SetStaticDdl(ref sDistrict, "1200", "", "All");
            _sdd.SetStaticDdl(ref rDistrict, "1200", "", "All");

            //LoadHub(ref sHub, "");
            //LoadHub(ref rHub, "");
            LoadOrderBy(ref orderBy,"Select");
            LoadSuperAgent(ref ssAgent,GetStatic.ReadWebConfig("domesticSuperAgentId", ""), "");
            LoadSuperAgent(ref rsAgent, GetStatic.ReadWebConfig("domesticSuperAgentId", "") , "");
            LoadCountry(ref sCountry, "10001", "");
            LoadCountry(ref rCountry, "10001", "");
            LoadAgent(ref sAgent, ssAgent.Text, sCountry.Text, "");
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            LoadBranch(ref sBranch, sAgent.Text, "");
            LoadBranch(ref rBranch, rAgent.Text, "");
            _sdd.SetDDL(ref tranStatus, "SELECT valueId,detailTitle FROM staticDataValue WHERE typeID=5400", "detailTitle", "detailTitle", "", "All");
            _sdd.SetDDL(ref sLocation, "EXEC proc_zoneDistrictMap @flag = 'll'", "locationId", "locationName", "", "All");
            _sdd.SetDDL(ref rLocation, "EXEC proc_zoneDistrictMap @flag = 'll'", "locationId", "locationName", "", "All");
        }

        protected void LoadFieldSelectionBox()
        {
            DataSet ds = _obj.GetFieldList(GetStatic.GetUser());
            if (ds == null)
                return;

            divTranSend.InnerHtml = GetStatic.DataTableToCheckBox(ds.Tables[0], "tranSend", "id", "alias");
            divSender.InnerHtml = GetStatic.DataTableToCheckBox(ds.Tables[1], "sender", "id", "alias");
            divTranPay.InnerHtml = GetStatic.DataTableToCheckBox(ds.Tables[2], "tranPay", "id", "alias");
            divReceiver.InnerHtml = GetStatic.DataTableToCheckBox(ds.Tables[3], "receiver", "id", "alias");
        }

        private void LoadCountry(ref DropDownList ddl, string hubId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'cal', @agentId=" + _sdd.FilterString(hubId);
            _sdd.SetDDL(ref ddl, sql, "countryName", "countryName", defaultValue, "All");
        }
        
        private void LoadOrderBy(ref DropDownList ddl, string defaultValue)
        {
            _sdd.SetDDL(ref ddl, "EXEC proc_tranMasterReport @flag = 'l2'", "title", "alias", defaultValue, "Select");
        }

        private void LoadSuperAgent(ref DropDownList ddl, string agentId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'sal'";

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadBranch(ref DropDownList ddl, string parentId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'bl', @parentId=" + _sdd.FilterString(parentId);

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }
        private void LoadAgent(ref DropDownList ddl, string parentId, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_agentMaster @flag = 'al1', @parentId=" + _sdd.FilterString(parentId) + ",@agentCountry='" + countryId+"'";

            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadState(ref DropDownList ddl, string countryName, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl2', @countryName=" + _sdd.FilterString(countryName);

            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sdd.FilterString(zone);
            _sdd.SetDDL3(ref ddl, sql, "districtId", "districtName", defaultValue, "Select");
        }
  
        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref sZone, sCountry.Text, "");
            LoadAgent(ref sAgent,ssAgent.Text,sCountry.Text,"");
            sCountry.Focus();
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref rZone, rCountry.Text, "");
            LoadAgent(ref rAgent, rsAgent.Text, rCountry.Text, "");
            rCountry.Focus();
        }

        protected void sAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref sBranch, sAgent.Text, "");
            sAgent.Focus();
        }

        protected void rAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBranch(ref rBranch, rAgent.Text, "");
            rAgent.Focus();
        }

        protected void sZone_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref sDistrict, sZone.Text, "");
        }

        protected void rZone_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref rDistrict, rZone.Text, "");
        }
    }
}