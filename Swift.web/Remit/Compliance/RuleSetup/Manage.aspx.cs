using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Compliance.RuleSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private CsMasterDao obj = new CsMasterDao();
        private RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20192100";
        private const string AddEditFunctionId = "20192101";
        private const string DeleteFunctionId = "20192104";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                if (GetId() > 0)
                {
                    PopulateDataById();
                    btnDisable.Visible = true;
                }
                else
                {
                    PopulateDdl(null);
                    btnDisable.Visible = false;
                }
                PopulateData();
            }
        }

        #region QueryString

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("csMasterId");
        }

        protected string GetSCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("sCountry").ToString();
        }

        protected string GetRCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rCountry").ToString();
        }

        protected string GetSAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("sAgent").ToString();
        }

        protected string GetRAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("rAgent").ToString();
        }

        protected string GetSState()
        {
            return GetStatic.ReadNumericDataFromQueryString("sState").ToString();
        }

        protected string GetRState()
        {
            return GetStatic.ReadNumericDataFromQueryString("rState").ToString();
        }

        protected string GetSZip()
        {
            return GetStatic.ReadNumericDataFromQueryString("sZip").ToString();
        }

        protected string GetRZip()
        {
            return GetStatic.ReadNumericDataFromQueryString("rZip").ToString();
        }

        protected string GetSGroup()
        {
            return GetStatic.ReadNumericDataFromQueryString("sGroup").ToString();
        }

        protected string GetRGroup()
        {
            return GetStatic.ReadNumericDataFromQueryString("rGroup").ToString();
        }

        protected string GetSCustType()
        {
            return GetStatic.ReadNumericDataFromQueryString("sCustType").ToString();
        }

        protected string GetRCustType()
        {
            return GetStatic.ReadNumericDataFromQueryString("rCustType").ToString();
        }

        protected string GetCurrency()
        {
            return GetStatic.ReadNumericDataFromQueryString("currency").ToString();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = swiftLibrary.HasRight(AddEditFunctionId);
        }

        #endregion QueryString

        #region Populate DropDown

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetStaticDdl(ref sGroup, "4300", GetStatic.GetRowData(dr, "sGroup"), "Select");
            _sdd.SetStaticDdl(ref rGroup, "4300", GetStatic.GetRowData(dr, "sGroup"), "Select");
            _sdd.SetStaticDdl(ref sCustType, "4700", GetStatic.GetRowData(dr, "sCustType"), "All");
            _sdd.SetStaticDdl(ref rCustType, "4700", GetStatic.GetRowData(dr, "rCustType"), "All");

            _sdd.SetDDL(ref ruleScope, "proc_csMaster @flag = 'ruleScope', @user = '" + GetStatic.GetUser() + "' ", "0", "1", GetStatic.GetRowData(dr, "ruleScope"), "Select");

            LoadCountry(ref sCountry, GetStatic.GetRowData(dr, "sCountry"), "sCountry");
            LoadCountry(ref rCountry, GetStatic.GetRowData(dr, "rCountry"), "rCountry");
            LoadAgent(ref sAgent, sCountry.Text, GetStatic.GetRowData(dr, "sAgent"));
            LoadAgent(ref rAgent, rCountry.Text, GetStatic.GetRowData(dr, "rAgent"));
            LoadState(ref sState, sCountry.Text, GetStatic.GetRowData(dr, "sState"));
            LoadState(ref rState, rCountry.Text, GetStatic.GetRowData(dr, "rState"));
            _sdd.SetDDL(ref currency, "EXEC proc_currencyMaster 'l'", "currencyId", "currencyCode", GetStatic.GetRowData(dr, "currency"), "Select");
        }

        private void PopulateData()
        {
            var sCountryId = GetSCountryId();
            var rCountryId = GetRCountryId();
            var sAgentId = GetSAgent();
            var rAgentId = GetRAgent();
            var sStateId = GetSState();
            var rStateId = GetRState();
            var sZipCode = GetSZip();
            var rZipCode = GetRZip();
            var sGroupId = GetSGroup();
            var rGroupId = GetRGroup();
            var sCustTypeId = GetSCustType();
            var rCustTypeId = GetRCustType();
            var currencyId = GetCurrency();

            if (sCountryId != "0")
            {
                sCountry.SelectedValue = sCountryId;
                LoadAgent(ref sAgent, sCountryId, "");
                LoadState(ref sState, sCountryId, "");
            }
            if (rCountryId != "0")
            {
                rCountry.SelectedValue = rCountryId;
                LoadAgent(ref rAgent, rCountryId, "");
                LoadState(ref rState, rCountryId, "");
            }
            if (sAgentId != "0")
            {
                sAgent.SelectedValue = sAgentId;
            }
            if (rAgentId != "0")
            {
                rAgent.SelectedValue = rAgentId;
            }
            if (sStateId != "0")
            {
                sState.SelectedValue = sStateId;
            }
            if (rStateId != "0")
            {
                rState.SelectedValue = rStateId;
            }
            if (sZipCode != "0")
            {
                sZip.Text = sZipCode;
            }
            if (rZipCode != "0")
            {
                rZip.Text = rZipCode;
            }
            if (sGroupId != "0")
            {
                sGroup.SelectedValue = sGroupId;
            }
            if (rGroupId != "0")
            {
                rGroup.SelectedValue = rGroupId;
            }
            if (sCustTypeId != "0")
            {
                sCustType.SelectedValue = sCustTypeId;
            }
            if (rCustTypeId != "0")
            {
                rCustType.SelectedValue = rCustTypeId;
            }
            if (currencyId != "0")
            {
                currency.SelectedValue = currencyId;
            }
        }

        #endregion Populate DropDown

        #region Method

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            sZip.Text = dr["sZip"].ToString();
            rZip.Text = dr["rZip"].ToString();
            if (dr["isEnable"].ToString().ToUpper() == "N" || string.IsNullOrEmpty(dr["isEnable"].ToString()))
            {
                btnDisable.Text = "Enable";
            }
            PopulateDdl(dr);

            DisableField();
        }

        private void DisableField()
        {
        }

        private void Update()
        {
            var dbResult = obj.Update(GetStatic.GetUser()
                , GetId().ToString()
                , sCountry.SelectedValue
                , sAgent.SelectedValue
                , sState.SelectedValue
                , sZip.Text
                , sGroup.SelectedValue
                , sCustType.SelectedValue
                , rCountry.SelectedValue
                , rAgent.SelectedValue
                , rState.SelectedValue
                , rZip.Text
                , rGroup.SelectedValue
                , rCustType.SelectedValue
                , currency.SelectedValue
                , ruleScope.SelectedValue);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx");
            }
        }

        #endregion Method

        #region Control Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref sAgent, sCountry.Text, "");
            LoadState(ref sState, sCountry.Text, "");
            sCountry.Focus();
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref rAgent, rCountry.Text, "");
            LoadState(ref rState, rCountry.Text, "");
            rCountry.Focus();
        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue, string country)
        {
            var sql = "EXEC proc_countryMaster @flag = 'ocl'";
            sql = sql + ",@countryType=" + _sdd.FilterString(country);
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, "All");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", defaultValue, "All");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            var sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId=" + _sdd.FilterString(countryId);

            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "All");
        }

        protected void btnDisable_Click(object sender, EventArgs e)
        {
            Disable();
        }

        #endregion Control Method

        private void Disable()
        {
            var dbResult = obj.Disable(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }
    }
}