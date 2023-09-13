using Common.Utility;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.KJBank.CustomerSetup
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20134000";
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (GetId() != "")
                {
                    PopulateData();
                }
            }
        }

        protected string GetId()
        {
            return GetStatic.ReadQueryString("customerId", "");
        }

        protected void PopulateData()
        {
            string email = _cd.GetEmail(GetId(), GetStatic.GetUser());
            if (!string.IsNullOrEmpty(email))
            {
                txtEmail.Text = email;
            }
        }

        protected void changePass_Click(object sender, EventArgs e)
        {
            DbResult _res = new DbResult();
            CheckPasswordUtility _checkPass = new CheckPasswordUtility();
            string checkPassResult = _checkPass.CheckPassword(newPassword.Text, "", "", txtEmail.Text);
            if (!string.IsNullOrEmpty(checkPassResult))
            {
                _res.SetError("1", checkPassResult, null);
                GetStatic.CallBackJs1(this, "error", "ShowMsg('" + checkPassResult + "');");
            }
            else
            {
                _res = _cd.ResetPassword(GetStatic.GetUser(), newPassword.Text, GetId());
                if (_res.ErrorCode == "0")
                {
                    GetStatic.CallBackJs1(this, "Success", "ShowMsg('s');");
                    //Response.Redirect("ModifyCustomer.aspx");
                }
                else
                {
                    GetStatic.CallBackJs1(this, "Success", "ShowMsg('" + checkPassResult + "');");
                }
            }
        }
    }
}