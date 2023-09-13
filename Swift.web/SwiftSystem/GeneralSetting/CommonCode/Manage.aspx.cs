using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.SwiftSystem.GeneralSetting.CommonCode {
  public partial class Manage : Page {
    private const string ViewFunctionId = "10111001";
    private const string AddEditFunctionId = "10111011";
    private const string DeleteFunctionId = "10111021";
    private readonly StaticDataDao _obj = new StaticDataDao();
    private readonly StaticDataDdl _sl = new StaticDataDdl();
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        GetStatic.SetActiveMenu(ViewFunctionId);
        PopulateDataById();
      }
    }
    private void Authenticate() {
      _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
    }

    private void PopulateDataById() {
      DataRow dr = _obj.SelectByCode(GetStatic.ReadQueryString("code", ""), "edit");
      if (dr == null)
        return;
      occupCode.Text = dr["code"].ToString();
      nameMongolian.Text = dr["message"].ToString();
      nameEnglish.Text = dr["type"].ToString();
      evalPoint.Text = dr["evalPoint"].ToString();
    }

    protected void btnSubmit_Click(object sender, EventArgs e) {
      DataRow dbRow = _obj.SelectByCode(occupCode.Text, "update", nameMongolian.Text, nameEnglish.Text, evalPoint.Text);
      GetStatic.SetMessage(dbRow[0].ToString(),dbRow[1].ToString());
      Response.Redirect("List.aspx");
    }
  }
}