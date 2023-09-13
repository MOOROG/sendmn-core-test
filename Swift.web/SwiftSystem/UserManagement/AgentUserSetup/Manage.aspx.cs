using Swift.DAL.BL.SwiftSystem;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.UserManagement.AgentUserSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10101100";
        private const string AddEditFunctionId = "10101110";
        private readonly AgentUserDao _obj = new AgentUserDao();
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _sdd.CheckSession();
                Authenticate();
                PopulateDdl();
           
                if (GetId() > 0)
                    PopulateDataById();
                else if(GetAgent() != "")
                    PullDefaultValueById();
            }
        }

        private void PullDefaultValueById()
        {
            string agentId = GetAgent();
            if (agentId == "0" || agentId == "")
            {
                var result = hdnBranchName.Value.Split('|');
                agentId = result[1];
            }

            DataRow dr = _obj.PullDefaultValueById(GetStatic.GetUser(), agentId);
            if (dr == null)
                return;

            var res = dr["agentName"].ToString().Split('|');
            hdnBranchName.Value = res[0] + "|" + res[1];
            branchName.Text = res[0] + "|" + res[1];
            hdnAgentType.Value = res[2];

            branchNameAuto.Text = res[0];
            branchNameAuto.Value = res[1];

            country.Text = dr["countryId"].ToString();
            LoadRegionSettings(country.Text);
            LoadState(ref state, country.Text, "");
            _sdd.SelectByTextDdl(ref state, dr["state"].ToString());
            LoadDistrict(ref district, state.Text, "");
            _sdd.SelectByTextDdl(ref district, dr["district"].ToString());
            //city.Text = dr["city"].ToString();
            zip.Text = dr["zip"].ToString();
            address.Text = dr["address"].ToString();
            telephoneNo.Text = dr["phone1"].ToString();
            mobileNo.Text = dr["mobile1"].ToString();
            email.Text = dr["email"].ToString();
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sdd.FilterString(zone);
            _sdd.SetDDL(ref ddl, sql, "districtId", "districtName", defaultValue, "Select");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "Select");
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
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

        #region Method


        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");

        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
            btnSumit.Visible = _sdd.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl()
        {
            _sdd.SetDDL(ref country, "Proc_dropdown_remit @flag = 'static', @typeID = '1'", "valueId", "detailTitle", "", "Select Country");
            _sdd.SetDDL(ref district, "Proc_dropdown_remit @flag = 'static', @typeID = '3'", "valueId", "detailTitle", "", "Select District");
            //coment by gagan
            //_sdd.SetDDL(ref state, "Proc_dropdown_remit @flag = 'static', @typeID = '7012'", "valueId", "detailTitle", "", "Select Province");
            //_sdd.SetDDL(ref state, "Proc_dropdown_remit @flag = 'static', @typeID = '2'", "valueId", "detailTitle", "", "Select State");
            _sdd.SetDDL(ref gender, "Proc_dropdown_remit @flag = 'static', @typeID = '4'", "valueId", "detailTitle", "", "Select Gender");
            _sdd.SetDDL(ref salutation, "Proc_dropdown_remit @flag = 'static', @typeID = '5'", "valueId", "detailTitle", "", "Select Salutation");
            //_sdd.SetDDL(ref ddlAgent, "SELECT agentId, agentName FROM dbo.agentMaster WHERE agentId = '" + GetAgentId() + "'", "agentId", "agentName", "", "");
            //_sdd.SetDDL(ref ddlBranch, "exec proc_dropDownList @FLAG ='branchList'", "BRANCH_ID", "BRANCH_NAME", "", "Select Branch");
        }

        public string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            userName.Text = dr["userName"].ToString();
            firstName.Text = dr["firstName"].ToString();
            middleName.Text = dr["middleName"].ToString();
            lastName.Text = dr["lastName"].ToString();
            address.Text = dr["address"].ToString();

            var res = dr["agentName"].ToString().Split('|');
            hdnBranchName.Value = res[0] + "|" + res[1];
            branchName.Text = res[0] + "|" + res[1];
            hdnAgentType.Value = res[2];

            branchNameAuto.Text = res[0];
            branchNameAuto.Value = res[1];

            zip.Text = dr["zip"].ToString();
            //city.Text = dr["city"].ToString();
            country.SelectedValue = dr["countryId"].ToString();
            district.SelectedValue = dr["district"].ToString();
            salutation.SelectedValue = dr["salutation"].ToString();
            gender.SelectedValue = dr["gender"].ToString();
            state.Text = dr["state"].ToString();
            telephoneNo.Text = dr["telephoneNo"].ToString();
            mobileNo.Text = dr["mobileNo"].ToString();
            email.Text = dr["email"].ToString();

            sessionTimeOutPeriod.Text = dr["sessionTimeOutPeriod"].ToString();
            userAccessLevel.SelectedValue = dr["accessMode"].ToString();
            loginTime.Text = dr["loginTime"].ToString();
            logoutTime.Text = dr["logoutTime"].ToString();
            sendTrnFrom.Text = dr["fromSendTrnTime"].ToString();
            sendTrnTo.Text = dr["toSendTrnTime"].ToString();
            payTrnFrom.Text = dr["fromPayTrnTime"].ToString();
            payTrnTo.Text = dr["toPayTrnTime"].ToString();

            userName.Enabled = false;
            pwdChangeDays.Text = dr["pwdChangeDays"].ToString();
            pwdChangeWarningDays.Text = dr["pwdChangeWarningDays"].ToString();
            maxReportViewDays.Text = dr["maxReportViewDays"].ToString();
        }


        private void Update()
        {
            //var res = hdnBranchName.Value.Split('|');
            //hdnBranchId.Value = res[1];
            DbResult dbResult = _obj.Update(GetStatic.GetUser()
                                            , branchNameAuto.Value
                                            , GetId().ToString()
                                            , userName.Text
                                            , firstName.Text
                                            , middleName.Text
                                            , lastName.Text
                                            , state.Text
                                            , address.Text
                                            , country.Text
                                            , telephoneNo.Text
                                            , mobileNo.Text
                                            , email.Text
                                            , pwdChangeDays.Text
                                            , pwdChangeWarningDays.Text
                                            , sessionTimeOutPeriod.Text
                                            , loginTime.Text
                                            , logoutTime.Text
                                            , userAccessLevel.SelectedValue
                                            , maxReportViewDays.Text
                                            , "A", district.SelectedValue, salutation.SelectedValue, gender.SelectedValue, zip.Text
                                            , sendTrnFrom.Text, sendTrnTo.Text, payTrnFrom.Text, payTrnTo.Text
                                            );
            ManageMessage(dbResult);
            if (dbResult.ErrorCode == "1")
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
                Response.Redirect("List.aspx?agentId=" + GetAgentId() + "");
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

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (country.SelectedValue != "")
            {
                _sdd.SetDDL(ref state, "Proc_dropdown_remit @flag = 'filterState', @countryId = '" + country.SelectedValue + "'", "stateId", "stateName", "", "Select State");
            }
        }

        protected void state_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (state.SelectedValue != "")
            {
                _sdd.SetDDL(ref district, "Proc_dropdown_remit @flag = 'filterDist', @zone = '" + state.SelectedValue + "'", "districtId", "districtName", "", "Select District");
            }
        }


    }
}