using System;
using Swift.DAL.BL.System.UserManagement;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class PasswordPolicy : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private ApplicationUserDao dao = new ApplicationUserDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                //Misc.MakeIntegerTextbox(ref wrongLogin, false, true);
                //Misc.MakeIntegerTextbox(ref pwdMinLen, false, true);
                //Misc.MakeIntegerTextbox(ref pwdRecHistory, false, true);
                //Misc.MakeIntegerTextbox(ref specialChar, false, true);
                //Misc.MakeIntegerTextbox(ref Numeric, false, true);
                //Misc.MakeIntegerTextbox(ref capAlpha, false, true);
                //Misc.MakeIntegerTextbox(ref lockInDay, false, true);
                Misc.MakeNumericTextbox(ref cdd);
                Misc.MakeNumericTextbox(ref edd);
                Misc.MakeNumericTextbox(ref txnApprove);
                Misc.MakeNumericTextbox(ref morethenTOindBranch);
                LoadPolicyData();
            }
        }
        private void LoadPolicyData()
        {
            var dr = dao.GetPolicyData(GetStatic.GetUser());
            if (null == dr || dr["errorCode"].ToString()=="1")
                return;

            //wrongLogin.Text = dr["loginAttemptCount"].ToString();
            //pwdMinLen.Text = dr["minPwdLength"].ToString();
            //pwdRecHistory.Text = dr["pwdHistoryNum"].ToString();
            //specialChar.Text = dr["specialCharNo"].ToString();
            //Numeric.Text = dr["numericNo"].ToString();
            //capAlpha.Text = dr["capNo"].ToString();
            //lockInDay.Text = dr["lockUserDays"].ToString();
            cdd.Text = dr["chkCddOn"].ToString();
            edd.Text = dr["chkeddOn"].ToString();
            txnApprove.Text = dr["txnApproveAmt"].ToString();
            morethenTOindBranch.Text = dr["holdCustTxnMoreBrnch"].ToString();
            isActive.Checked = (dr["isActive"].ToString()=="Y"?true:false);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var dbResult = dao.PasswordPolicy(GetStatic.GetUser(),(isActive.Checked?"Y":"N"), cdd.Text, edd.Text, txnApprove.Text, morethenTOindBranch.Text);
            GetStatic.PrintMessage(this, dbResult);
        }
    }
}