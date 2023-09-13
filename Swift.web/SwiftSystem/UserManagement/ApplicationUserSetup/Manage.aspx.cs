using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup {
  public partial class Manage : Page {
    private const string ViewFunctionId = "10101300";
    private const string AddEditFunctionId = "10101310";

    private readonly ApplicationUserDao _obj = new ApplicationUserDao();
    private readonly RemittanceLibrary _sdd = new RemittanceLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        Authenticate();
        PopulateDdl();
        if(GetId() > 0)
          PopulateDataById();
      }
    }

    #region Method


    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("userId");
    }

    //private bool Authenticate()
    //{
    //    _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
    //    btnSumit.Visible = _sdd.HasRight(AddEditFunctionId);
    //}

    public void Authenticate() {
      _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
    }

    public bool CheckHasAddEditRight() {
      return _sdd.HasRight(AddEditFunctionId);
    }

    private void PopulateDdl() {
      _sdd.SetDDL(ref country, "Proc_dropdown_remit @flag = 'country'", "countryId", "countryName", "", "Select Country");
      _sdd.SetDDL(ref district, "SELECT  districtId,districtName FROM dbo.zoneDistrictMap ORDER BY districtName", "districtId", "districtName", "", "Select District");
      _sdd.SetDDL(ref state, "SELECT  stateId, stateName FROM countryStateMaster ORDER BY stateName", "stateId", "stateName", "", "Select State");
      _sdd.SetDDL(ref gender, "Proc_dropdown_remit @flag = 'static', @typeID = '4'", "valueId", "detailTitle", "", "Select Gender");
      _sdd.SetDDL(ref salutation, "Proc_dropdown_remit @flag = 'static', @typeID = '5'", "valueId", "detailTitle", "", "Select Salutation");
      _sdd.SetDDL(ref ddlAgent, "exec [SendMnPro_Remit].dbo.[proc_agentMaster] @flag='al6'", "agentId", "agentName", "", "All");
    }

    private void PopulateDataById() {
      DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
      if(dr == null)
        return;

      userName.Text = dr["userName"].ToString();
      firstName.Text = dr["firstName"].ToString();
      middleName.Text = dr["middleName"].ToString();
      lastName.Text = dr["lastName"].ToString();
      address.Text = dr["address"].ToString();

      ddlAgent.Text = dr["agentCode"].ToString();

      currencyId.Text = dr["currencyIds"].ToString();
      country.SelectedValue = dr["countryId"].ToString();
      district.SelectedValue = dr["district"].ToString();
      salutation.SelectedValue = dr["salutation"].ToString();
      gender.SelectedValue = dr["gender"].ToString();
      state.Text = dr["state"].ToString();
      telephoneNo.Text = dr["telephoneNo"].ToString();
      mobileNo.Text = dr["mobileNo"].ToString();
      email.Text = dr["email"].ToString();

      sessionTimeOutPeriod.Text = dr["sessionTimeOutPeriod"].ToString();
      userAccessLevel.Text = dr["userAccessLevel"].ToString();

      loginTime.Text = dr["loginTime"].ToString();
      logoutTime.Text = dr["logoutTime"].ToString();

      userName.Enabled = false;
      pwdChangeDays.Text = dr["pwdChangeDays"].ToString();
      pwdChangeWarningDays.Text = dr["pwdChangeWarningDays"].ToString();
      maxReportViewDays.Text = dr["maxReportViewDays"].ToString();

      string passwordtxt = dr["pwd"].ToString();

      confirmPassword.Attributes.Add("value", passwordtxt);
      password.Attributes.Add("value", passwordtxt);
      password.Attributes.Add("readonly", "readonly");
      confirmPassword.Attributes.Add("readonly", "readonly");
    }


    private void Update() {
      DbResult dbResult = _obj.Update(GetStatic.GetUser()
                                      , GetStatic.GetAgentId()
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
                                      ,"HO", district.SelectedValue, salutation.SelectedValue, gender.SelectedValue
                                      ,password.Text
                                      ,currencyId.Text
                                      ,ddlAgent.SelectedValue
                                      );
      ManageMessage(dbResult);
    }
    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if(dbResult.ErrorCode == "0")
        Response.Redirect("List.aspx");
      else {
        GetStatic.PrintMessage(Page);
      }
    }


    #endregion

    #region Element Method

    protected void btnSumit_Click(object sender, EventArgs e) {
      Update();
    }

    #endregion

    protected void country_SelectedIndexChanged(object sender, EventArgs e) {
      if(country.SelectedValue != "") {
        _sdd.SetDDL(ref state, "Proc_dropdown_remit @flag = 'filterState', @countryId = '" + country.SelectedValue + "'", "stateId", "stateName", "", "Select State");
      }
    }

    protected void state_SelectedIndexChanged(object sender, EventArgs e) {
      if(state.SelectedValue != "") {
        _sdd.SetDDL(ref district, "Proc_dropdown_remit @flag = 'filterDist', @zone = '" + state.SelectedValue + "'", "districtId", "districtName", "", "Select District");
      }
    }
  }
}