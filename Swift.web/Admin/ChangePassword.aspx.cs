using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Text.RegularExpressions;

namespace Swift.web.Admin {
  public partial class ChangePassword : System.Web.UI.Page {
    private readonly ApplicationUserDao _obj = new ApplicationUserDao();
    private readonly SwiftLibrary _sl = new SwiftLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        _sl.CheckSession();
        userName.Text = GetStatic.GetUser();
      }
    }

    protected void changePass_Click(object sender, EventArgs e) {
      string pattern = @"^(?=.*?[A-Z])(?=(.*[a-z]){1,})(?=(.*[\d]){1,})(?=(.*[\W]){1,})(?!.*\s).{8,}$";
      Regex rg = new Regex(pattern);
      if (!Regex.Match(newPassword.Text.Trim(), pattern).Success && !Regex.Match(confirmPassword.Text.Trim(), pattern).Success) {
        GetStatic.AlertMessage(this, "Password must be Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character");
        return;
      }
      if (newPassword.Text.Trim() != confirmPassword.Text.Trim()) {
        GetStatic.AlertMessage(this, "Password and confirm passowrd are not same!!");
        return;
      } else {
        UpdatePassword();
      }
    }

    private void UpdatePassword() {
      DbResult dbResult = _obj.ChangePassword(userName.Text, newPassword.Text, oldPassword.Text);
      ManageMessage(dbResult);
      if (dbResult.ErrorCode == "0") {
        GetStatic.SetMessage(dbResult);
        //GetStatic.CallBackJs1(this, "", "SuccessMethod()");
        Response.Redirect("Dashboard.aspx");
      }
    }

    private void ManageMessage(DbResult dbResult) {
      GetStatic.SetMessage(dbResult);
      if (dbResult.ErrorCode == "0") {
        GetStatic.PrintMessage(Page);
      } else {
        GetStatic.AlertMessage(Page);
      }
    }
  }
}