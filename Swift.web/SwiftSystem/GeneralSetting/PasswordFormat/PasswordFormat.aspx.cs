using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.PasswordFormat
{
    public partial class PasswordFormat : Page
    {
        private const string ViewFunctionId = "10111300";
        private const string AddEditFunctionId = "10111310";
        private const string DeleteFunctionId = "10111320";
        private readonly PasswordPolicyDao _obj = new PasswordPolicyDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected long RowId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                GetStatic.SetActiveMenu(ViewFunctionId);
                MakeNumericTextBox();
                PopulateDataById();
            }
        }

        #region Method

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref loginAttemptCount);
            Misc.MakeNumericTextbox(ref pwdHistoryNum);
            Misc.MakeNumericTextbox(ref minPwdLength);
            Misc.MakeNumericTextbox(ref specialCharNo);
            Misc.MakeNumericTextbox(ref numericNo);
            Misc.MakeNumericTextbox(ref capNo);
            Misc.MakeNumericTextbox(ref lockUserDays);
            Misc.MakeNumericTextbox(ref invalidControlNoForDay);
            Misc.MakeNumericTextbox(ref invalidControlNoContinous);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnSave.Visible = _sl.HasRight(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.Select(GetStatic.GetUser());
            if (dr == null)
                return;
            loginAttemptCount.Text = dr["loginAttemptCount"].ToString();
            minPwdLength.Text = dr["minPwdLength"].ToString();
            pwdHistoryNum.Text = dr["pwdHistoryNum"].ToString();
            specialCharNo.Text = dr["specialCharNo"].ToString();
            numericNo.Text = dr["numericNo"].ToString();
            capNo.Text = dr["capNo"].ToString();
            isActive.Text = dr["isActive1"].ToString();
            lockUserDays.Text = dr["lockUserDays"].ToString();
            invalidControlNoForDay.Text = dr["invControlNoForDay"].ToString();
            invalidControlNoContinous.Text = dr["invControlNoContinous"].ToString();
            operationTimeFrom.Text = dr["operationTimeFrom"].ToString();
            operationTimeTo.Text = dr["operationTimeTo"].ToString();
            globalOperationTimeEnable.Text = dr["globalOperationTimeEnable"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), loginAttemptCount.Text, minPwdLength.Text,
                                            pwdHistoryNum.Text, specialCharNo.Text, numericNo.Text, capNo.Text,
                                            isActive.Text,lockUserDays.Text,invalidControlNoForDay.Text,invalidControlNoContinous.Text,
                                            operationTimeFrom.Text, operationTimeTo.Text, globalOperationTimeEnable.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("PasswordFormat.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
        #endregion

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion
    }
}