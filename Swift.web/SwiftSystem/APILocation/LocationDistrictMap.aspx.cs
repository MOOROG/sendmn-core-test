using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.APILocationMapping
{
    public partial class LocationDistrictMap : System.Web.UI.Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111700";
        private const string AddEditFunctionId = "10111710";
        private const string DeleteFunctionId = "10111720";
        private readonly ApiLocationMapperDao _obj = new ApiLocationMapperDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected long RowId;

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            GetStatic.SetActiveMenu(ViewFunctionId);
            if (!IsPostBack)
            {
                PopulateDdl(null);
                if (GetApiDistrictCode() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        protected void state_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref district, state.Text, "");
            state.Focus();
        }

        #region Method

        private long GetApiDistrictCode()
        {
            return GetStatic.ReadNumericDataFromQueryString("districtCode");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSumit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetDDL(ref apiDistrictCode, "EXEC proc_apiLocation @flag = 'l'", "districtCode", "districtName",
                        GetApiDistrictCode().ToString(), "");

            _sdd.SetDDL(ref state, "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(GetStatic.GetDomesticCountryId()), "stateId",
                        "stateName", GetStatic.GetRowData(dr, "stateId"), "Select");

            LoadDistrict(ref district, state.Text, GetStatic.GetRowData(dr, "districtId"));

        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sdd.FilterString(zone);

            _sdd.SetDDL(ref ddl, sql, "districtId", "districtName", defaultValue, "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetApiDistrictCode().ToString());
            if (dr == null)
                return;
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), district.Text,
                                            GetApiDistrictCode().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion

        protected void district_SelectedIndexChanged(object sender, EventArgs e)
        {
            var dr = _obj.SelectStateByDistrict(GetStatic.GetUser(), district.Text);
            if(dr == null)
                return;
            state.Text = dr["state"].ToString();
            district.Focus();
        }
    }
}