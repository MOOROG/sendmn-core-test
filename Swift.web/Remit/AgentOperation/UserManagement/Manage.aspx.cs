using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AgentOperation.UserManagement
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40112500";
        private const string AddEditFunctionId = "40112510";
        private const string DeleteFunctionId = "40112530";

        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadBreadCrumb();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    btnDelete.Visible = false;
                    PopulateDdl(null);
                    PullDefaultValueById();
                }
            }
        }

        private void LoadBreadCrumb()
        {
            spnCname.InnerHtml = _sdd.GetAgentBreadCrumb(GetAgent());
        }

        private void PullDefaultValueById()
        {
            DataRow dr = _obj.PullDefaultValueById(GetStatic.GetUser(), GetAgent().ToString());
            if (dr == null)
                return;

            city.Text = dr["city"].ToString();
            country.SelectedValue = dr["countryId"].ToString();
            state.SelectedValue = dr["state"].ToString();
            zip.Text = dr["zip"].ToString();
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref state, country.Text, "");
            LoadRegionSettings(country.Text);
            country.Focus();
        }

        protected void state_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref district, state.Text, "");
            state.Focus();
        }

        #region Method

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = _sdd.HasRight(DeleteFunctionId);
            btnSumit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetStaticDdl(ref salutation, "1700", GetStatic.GetRowData(dr, "salutation"), "Select");
            _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                        GetStatic.GetRowData(dr, "countryId"), "Select");
            LoadState(ref state, country.Text, GetStatic.GetRowData(dr, "state"));
            LoadDistrict(ref district, state.Text, GetStatic.GetRowData(dr, "district"));
            LoadRegionSettings(country.Text);
            _sdd.SetStaticDdl(ref gender, "1800", GetStatic.GetRowData(dr, "gender"), "Select");

            //_sdd.SetDDL(ref branch,
            //            "EXEC proc_agentMaster @flag = 'al4', @user = " + _sdd.FilterString(GetStatic.GetUser()),
            //            "agentId", "agentName", GetStatic.GetRowData(dr, "agentId"), "Select");

            if (GetAgent() != "")
            {
                var agentDao = new AgentDao();
                branchName.Text = agentDao.SelectAgentById(GetAgent());
                hdnBranchName.Value = agentDao.SelectAgentById(GetAgent());
            }
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            salutation.Text = dr["salutation"].ToString();
            userName.Text = dr["userName"].ToString();

            firstName.Text = dr["firstName"].ToString();
            middleName.Text = dr["middleName"].ToString();
            lastName.Text = dr["lastName"].ToString();
            gender.Text = dr["gender"].ToString();
            var res = dr["agentName"].ToString().Split('|');
            hdnBranchName.Value = res[0] + "|" + res[1];
            branchName.Text = res[0] + "|" + res[1];
            hdnAgentType.Value = res[2];
            address.Text = dr["address"].ToString();

            city.Text = dr["city"].ToString();
            country.SelectedValue = dr["countryId"].ToString();
            telephoneNo.Text = dr["telephoneNo"].ToString();
            mobileNo.Text = dr["mobileNo"].ToString();

            email.Text = dr["email"].ToString();
            userName.Text = dr["userName"].ToString();
            pwd.Text = dr["pwd"].ToString();
            confirmPassword.Text = dr["pwd"].ToString();

            userName.Enabled = false;
            pwd.Attributes.Add("value", "xxxxxxxxxxxxxxxx");
            pwd.Enabled = false;
            confirmPassword.Attributes.Add("value", "xxxxxxxxxxxxxxxx");
            confirmPassword.Enabled = false;
            PopulateDdl(dr);
        }

        //private void Update()
        //{
        //    var res = hdnBranchName.Value.Split('|');
        //    hdnBranchId.Value = res[1];
        //    DbResult dbResult = _obj.Update(GetStatic.GetUser()
        //                                    , GetId().ToString()
        //                                    , userName.Text
        //                                    , salutation.Text
        //                                    , firstName.Text
        //                                    , middleName.Text
        //                                    , lastName.Text
        //                                    , gender.SelectedValue
        //                                    , state.Text
        //                                    , district.Text
        //                                    , zip.Text
        //                                    , address.Text
        //                                    , city.Text
        //                                    , country.SelectedValue
        //                                    , telephoneNo.Text
        //                                    , mobileNo.Text
        //                                    , email.Text
        //                                    , pwd.Text
        //                                    , hdnBranchId.Value
        //                                    , "15"
        //                                    , "12"
        //                                    , "300"
        //                                    , "00:00:00"
        //                                    , "23:59:59"
        //                                    , "S"
        //                                    , "60"
        //                                    , "00:00:00"
        //                                    , "23:59:59"
        //                                    , "07:00:00"
        //                                    , "17:00:00"
        //                                    , "00:00:00"
        //                                    , "23:59:59"
        //                                    , ""
        //                                    , ""
        //                                    , ""
        //                                    , ""
        //                                    , ""
        //                                    );
        //    ManageMessage(dbResult);
        //}

        private void DeleteRow()
        {
            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "Select");
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sdd.FilterString(zone);
            _sdd.SetDDL(ref ddl, sql, "districtId", "districtName", defaultValue, "Select");
        }

        protected void LoadRegionSettings(string countryId)
        {
            if (countryId == "151")
            {
                lblRegionType.Text = "Zone";
                pnlDistrict.Visible = true;
                pnlZip.Visible = false;
            }
            else
            {
                lblRegionType.Text = "State";
                pnlDistrict.Visible = false;
                pnlZip.Visible = true;
            }
        }

        #endregion Method

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            //Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx?agentId=" + GetAgent() + "&mode=" + GetMode());
        }

        #endregion Element Method
    }
}