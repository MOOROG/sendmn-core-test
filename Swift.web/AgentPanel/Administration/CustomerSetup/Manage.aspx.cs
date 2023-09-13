using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.Administration.CustomerSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string GridName = "CustomerRefund";
        private const string ViewFunctionId = "40133900";
        private const string AddEditFunctionId = "40133910";
        private const string DeleteFunctionId = "40133920";
        private const string ApproveFunctionId = "40133920";
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly CustomerSetupIntlDao _obj = new CustomerSetupIntlDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(Page);
            if (!IsPostBack)
            {
                Authenticate();
                MakeNumericTextbox();
                ManageSetting();
            }
        }

        private void ManageSetting()
        {
            if (GetId() > 0)
                PopulateDataById();
            else
                PopulateDdl(null);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sl.HasRight(AddEditFunctionId);
        }

        private bool ClientValidation()
        {
            if (dob.Text == "")
                return true;
            DateTime _dob = Convert.ToDateTime(dob.Text);
            if (_dob > DateTime.Now)
            {
                lblDobChk.Text = "Invalid Date";
                dob.Focus();
                return false;
            }
            if ((DateTime.Now.Year - _dob.Year) < 18)
            {
                lblDobChk.Text = "Customer not Eligible";
                dob.Focus();
                return false;
            }
            return true;
        }

        private void MakeNumericTextbox()
        {
            Misc.MakeNumericTextbox(ref mobile);
            Misc.MakeNumericTextbox(ref homePhone);
            Misc.MakeNumericTextbox(ref workPhone);
            Misc.MakeNumericTextbox(ref zipCode);
        }

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("customerId");
        }

        protected string GetCustomerName()
        {
            return "Customer Name : " + _obj.GetCustomerName(GetId().ToString());
        }

        protected string GetSection()
        {
            return GetStatic.ReadQueryString("section", "");
        }

        private void PopulateDdl(DataRow dr)
        {
            _sl.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l2', @user = " + _sl.FilterString(GetStatic.GetUser()), "countryId", "countryName",
                       GetStatic.GetRowData(dr, "country"), "Select");
            _sl.SetDDL(ref occupation, "EXEC proc_dropDownLists @flag = 'occupation'", "occupationId", "detailTitle", GetStatic.GetRowData(dr, "occupation"), "Select");
            _sl.SetStaticDdl(ref district, "3", GetStatic.GetRowData(dr, "district"), "Select");
            LoadRegionSettings(country.Text);
            _sl.SetDDL(ref nativeCountry, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                       GetStatic.GetRowData(dr, "nativeCountry"), "Select");
            _sl.SetStaticDdl(ref gender, "4", GetStatic.GetRowData(dr, "gender"), "Select");
            _sl.SetStaticDdl(ref customerType, "4700", GetStatic.GetRowData(dr, "customerType"), "Select");
            LoadState(ref state, country.Text, GetStatic.GetRowData(dr, "state"));
            LoadDistrict(ref district, state.Text, GetStatic.GetRowData(dr, "district"));
            _sl.SetDDL(ref ddlRelation, "EXEC proc_countryMaster @flag = '321', @user = " + _sl.FilterString(GetStatic.GetUser()), "valueId", "detailTitle",
                       GetStatic.GetRowData(dr, "relationId"), "Select");

            _sl.SetDDL(ref idType, "EXEC proc_currencyMaster @flag = 'id'", "valueId", "detailTitle",
                       GetStatic.GetRowData(dr, "idType"), "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            membershipId.Text = dr["membershipId"].ToString();
            firstName.Text = dr["firstName"].ToString();
            middleName.Text = dr["middleName"].ToString();
            lastName1.Text = dr["lastName1"].ToString();
            lastName2.Text = dr["lastName2"].ToString();
            address.Text = dr["address"].ToString();
            state.Text = dr["state"].ToString();
            zipCode.Text = dr["zipCode"].ToString();
            city.Text = dr["city"].ToString();
            email.Text = dr["email"].ToString();
            homePhone.Text = dr["homePhone"].ToString();
            workPhone.Text = dr["workPhone"].ToString();
            mobile.Text = dr["mobile"].ToString();
            dob.Text = dr["dob1"].ToString();
            isBlackListed.Text = dr["isBlackListed"].ToString();
            relationFullName.Text = dr["relativeName"].ToString();
            companyName.Text = dr["companyName"].ToString();
            idNumber.Text = dr["idNumber"].ToString();
            if (!string.IsNullOrWhiteSpace(dr["memberIDissuedDate"].ToString()))
            {
                midBox.Visible = true;
                membershipId.ReadOnly = true;
                isMemberIssued.Visible = false;
                isMemberIssued.Checked = false;
            }
            else
            {
                membershipId.ReadOnly = false;
                midBox.Visible = false;
                isMemberIssued.Visible = true;
                isMemberIssued.Checked = false;
            }

            PopulateDdl(dr);

            if (GetStatic.GetAgentType() == "2904" || GetStatic.GetIsActAsBranch().ToUpper() == "Y")
            {
                if (string.IsNullOrEmpty(dr["approvedBy"].ToString()) && dr["createdBy"].ToString() == GetStatic.GetUser())
                {
                    btnSave.Visible = true;
                }
                else
                {
                    btnSave.Visible = false;
                }
            }
        }

        private void Update()
        {
            if (!ClientValidation())
                return;
            var isMemberIssue = GetStatic.GetBoolToChar(isMemberIssued.Checked);
            if (isMemberIssue == "Y" && string.IsNullOrWhiteSpace(membershipId.Text))
            {
                GetStatic.PrintErrorMessage(Page, "Member Id should not be blank");
                return;
            }
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), GetId().ToString(), "0", membershipId.Text,
                                           firstName.Text, middleName.Text, lastName1.Text, lastName2.Text,
                                           country.SelectedValue, address.Text, state.Text, zipCode.Text, district.Text,
                                           city.Text, email.Text, homePhone.Text, workPhone.Text, mobile.Text,
                                           nativeCountry.SelectedValue, dob.Text, occupation.Text, gender.Text, customerType.Text,
                                           isBlackListed.Text, ddlRelation.Text, relationFullName.Text, companyName.Text,
                                           isMemberIssue, GetStatic.GetAgent(), GetStatic.GetBranch(), idType.Text, idNumber.Text);

            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            else
                Response.Redirect("List.aspx");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sl.FilterString(countryId);

            _sl.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "Select");
        }

        protected void LoadRegionSettings(string countryId)
        {
            if (countryId == "Nepal")
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

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sl.FilterString(zone);
            _sl.SetDDL(ref ddl, sql, "districtId", "districtName", defaultValue, "Select");
        }

        #endregion Method

        #region Element Method

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref state, country.Text, "");
            LoadRegionSettings(country.SelectedItem.Text);
            country.Focus();
        }

        protected void state_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDistrict(ref district, state.Text, "");
            state.Focus();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            if (GetSection() == "")
                Response.Redirect("List.aspx");
            else
                GetStatic.CallBackJs1(Page, "Close Window", "window.close();");
        }

        #endregion Element Method

        protected void isMemberIssued_CheckedChanged(object sender, EventArgs e)
        {
            midBox.Visible = isMemberIssued.Checked ? true : false;
        }
    }
}