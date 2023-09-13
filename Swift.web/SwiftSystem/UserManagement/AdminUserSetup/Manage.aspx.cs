using System;
using System.Data;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string AddEditFunctionId = "10101310";

        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                if (GetId() > 0)
                    PopulateDataById();
            }
        }

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(AddEditFunctionId);
        }

        private void PopulateDdl()
        {
            _sdd.SetStaticDDL(ref country, "1", "REF_CODE", "REF_CODE", "", "Select Country");
            _sdd.SetStaticDDL(ref state, "2", "REF_CODE", "REF_CODE", "", "Select State");
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
            city.Text = dr["city"].ToString();
            country.SelectedValue = dr["countryId"].ToString();
            state.SelectedValue = dr["State"].ToString();
            telephoneNo.Text = dr["telephoneNo"].ToString();
            mobileNo.Text = dr["mobileNo"].ToString();
            email.Text = dr["email"].ToString();

            sessionTimeOutPeriod.Text = dr["sessionTimeOutPeriod"].ToString();
            userAccessLevel.SelectedValue = dr["accessMode"].ToString();
            loginTime.Text = dr["loginTime"].ToString();
            logoutTime.Text = dr["logoutTime"].ToString();

            userName.Enabled = false;
            pwdChangeDays.Text = dr["pwdChangeDays"].ToString();
            pwdChangeWarningDays.Text = dr["pwdChangeWarningDays"].ToString();
            maxReportViewDays.Text = dr["maxReportViewDays"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(),GetStatic.GetAgentId(), GetId().ToString(), userName.Text, firstName.Text, middleName.Text, lastName.Text
                                            , state.Text, address.Text, country.SelectedValue, telephoneNo.Text, mobileNo.Text, email.Text, pwdChangeDays.Text
                                            , pwdChangeWarningDays.Text, sessionTimeOutPeriod.Text, loginTime.Text, logoutTime.Text, userAccessLevel.Text
                                            , maxReportViewDays.Text,"A", "", "", "", "","","");
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
    }
}