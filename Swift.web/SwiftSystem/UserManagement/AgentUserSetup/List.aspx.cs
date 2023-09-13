using Swift.API.Common;
using Swift.API.GoogleAuthenticator;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;

namespace Swift.web.SwiftSystem.UserManagement.AgentUserSetup
{
    public partial class List : Page
    {
        private string GridName="grdUsersAgent";
        private const string ViewFunctionId = "10101100";
        private const string AddEditFunctionId = "10101110";
        private const string DeleteFunctionId = "10101120";
        private const string ApproveFunctionId = "10101130";
        private const string AssignRoleId = "10101150";
        private const string AssignLimit = "10101160";
        private const string ResetPassword = "10101170";
        private const string LockUser = "10101180";
        private const string SendQRCode = "10101140";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private GoogleAuthenticatorAPI _auth = new GoogleAuthenticatorAPI();
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetMode() == 1)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        protected void LoadTab()
        {
            switch (GetMode())
            {
                case 1:
                    agentListTab.Visible = true;
                    agentListTab.InnerHtml =
                        "<a href=\"../../../Remit/Administration/AgentSetup/List.aspx\">Agent Setup</a>";
                    pnlBreadCrumb.Visible = false;
                    spnCname.InnerHtml = _sl.GetAgentBreadCrumb(GetAgent());
                    break;
                case 2:
                    agentListTab.Visible = true;
                    agentListTab.InnerHtml =
                        "<a href=\"../../../Remit/Administration/AgentSetup/Functions/ListAgent.aspx\">Agent List</a>";
                    pnlBreadCrumb.Visible = true;
                    spnCname.InnerHtml = _sl.GetAgentBreadCrumb(GetAgent());
                    break;
                default:
                    agentListTab.Visible = false;
                    break;
            }
        }

        protected string GetAgent()
        {
            return GetStatic.ReadQueryString("agentId", "");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("haschanged", "Change Status", "2"),
                                       new GridFilter("userName", "User Name", "LT"),
                                       new GridFilter("firstName", "First Name", "LT"),
                                       new GridFilter("lastName", "Last Name", "LT"),
                                       new GridFilter("agentName", "Agent Name", "T"),
                                       new GridFilter("isLocked", "Lock Status", "2"),
                                       new GridFilter("isActive", "Is Active", "2")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("agentCode", "Agent ID", "", "T"),
                                       new GridColumn("employeeId", "Employee ID", "", "T"),
                                       new GridColumn("userName", "User Name", "", "LT"),
                                       new GridColumn("name", "Name", "", "LT"),
                                       new GridColumn("Address", "Address", "", "T"),
                                       new GridColumn("contactNo", "Contact No", "", "T"),
                                       new GridColumn("agentName", "Branch/Agent", "", "T"),
                                       new GridColumn("lockStatus", "Lock Status", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            if (GetMode() == 1 || GetMode() == 2)
            {
                _grid.LoadGridOnFilterOnly = false;
                _grid.AlwaysShowFilterForm = false;
                _grid.EnableFilterCookie = false;
            }
            else
            {
                _grid.LoadGridOnFilterOnly = true;
                _grid.AlwaysShowFilterForm = true;
                _grid.EnableFilterCookie = true;
            }
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New User";
            _grid.RowIdField = "userId";
            _grid.MultiSelect = false;

            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AddPage = "manage.aspx?agentId=" + GetAgent() + "&mode=" + GetMode();
            _grid.AllowCustomLink = true;
            var customLinkText = new StringBuilder();
            if (_sl.HasRight(ResetPassword))
                customLinkText.Append(
                    "<a href = \"ResetPassword.aspx?userName=@userName&agentId=" + GetAgent() +
                    "&mode=" + GetMode() +
                    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/icon_reset.gif\" border=0 title=\"Reset Password\" alt=\"Reset Password\" /></a>&nbsp;&nbsp;");
            if (_sl.HasRight(AssignRoleId))
                customLinkText.Append(
                    "<a href = \"../ApplicationUserSetup/UserRole.aspx?userName=@userName&userId=@userId&agentId=" +
                    GetAgent() + "&mode=" +
                    GetMode() +
                    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/role_icon.gif\" border=0 title=\"Assign Role\" alt=\"Assign Role\" /></a>&nbsp;&nbsp;");
            if (_sl.HasRight(AssignLimit))
                customLinkText.Append(
                    "<a href = \"../UserApprovalLimit/List.aspx?userName=@userName&userId=@userId&agentId=@agentId&mode=" +
                    GetMode() +
                    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/limit.png\" border=0 title=\"Limit Assign\" alt=\"Limit Assign\" /></a>&nbsp;&nbsp;");
            if (_sl.HasRight(LockUser))
                customLinkText.Append(
                       "<a href = '#'><img src=\"" + GetStatic.GetUrlRoot() + "/images/unlock.png\" height=\"17\" width=\"16\" border=0 title=\"Lock/Unlock User\" alt=\"Lock/Unlock User\" onclick=\"LockUnlock(@userId);\" /></a>&nbsp;&nbsp;");
            //customLinkText.Append(
            //    "<a href = \"../UserLockDetail/List.aspx?userName=@userName&userId=@userId&agentId=@agentId&mode=" +
            //    GetMode() +
            //    "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/reset_password.gif\" border=0 title=\"Lock User\" alt=\"Lock User\" /></a>");
            //if (_sl.HasRight(SendQRCode))
            //    customLinkText.Append("<a class=\"btn btn-xs btn-primary\" href=\"javascript:void(0);\" onclick=\"SendEmail('@userId', '@userName')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Send QR Code\"><i class=\"fa fa-envelope\"></i></btn>");

            _grid.CustomLinkText = customLinkText.ToString();

            _grid.CustomLinkVariables = "userName,userId,agentId";
            _grid.InputPerRow = 4;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.GridMinWidth = 800;
            //_grid.InputLabelOnLeftSide = true;
            string agentId = GetAgent();
            string sql = agentId != ""
                             ? "[proc_applicationUsers] @flag = 's',@agentId = " + _grid.FilterString(GetAgent())
                             : "[proc_applicationUsers] @flag = 's'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (GetMode() == 1)
                GetStatic.AlertMessage(Page);
            else
                GetStatic.PrintMessage(Page);
        }

        protected void btnLockUnlockUser_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.LockUnlockUser(GetStatic.GetUser(), hddUserId.Value);
            ManageMessage(dbResult);
            LoadGrid();
        }

        protected void btnSendEmail_Click(object sender, EventArgs e)
        {
            GoogleAuthenticatorModel _model = new GoogleAuthenticatorModel();
            string _key = Guid.NewGuid().ToString().Replace("-", ""); //GetStatic.ReadWebConfig("2FAGoogle", "");
            string _keyForEncDec = GetStatic.ReadWebConfig("keyForEncryptionDecryption", "");
            string userName = hddUserName.Value;

            string userUniqueKeyEncrypted = EncryptDecryptUtility.Encrypt(userName + _key, _keyForEncDec);

            DataRow dr = _obj.GetUser2FAuthDetails(GetStatic.GetUser(), hddUserId.Value, userUniqueKeyEncrypted, hddUserName.Value);

            if (string.IsNullOrEmpty(dr["email"].ToString()))
            {
                GetStatic.AlertMessage(this, "Email address for the user is empty, please udpate email first!");
                return;
            }

            _model = _auth.GenerateCodeAndImageURL(userName, userUniqueKeyEncrypted);
            string msgBody = GetEmailMsgBody(dr, _model.BarCodeImageUrl, _model.ManualEntryKey);

            string msgSubject = "QR Code to access "+ GetStatic.ReadWebConfig("jmeName", "") + " Remit System";

            string mailSend = GetStatic.SendEmail(msgSubject, msgBody, dr["email"].ToString());
            if (mailSend == "Mail Send")
            {
                GetStatic.AlertMessage(this, "Mail send successfully!");
            }
            else
            {
                GetStatic.AlertMessage(this, "Error while sending Email!");
            }
        }

        private string GetEmailMsgBody(DataRow dr, string imageLink, string manualCode)
        {
            var mailBody = "Dear Mr./Ms./Mrs. " + dr["NAME"].ToString() + ",";
            mailBody +=
                    "<br><br>Your QR code for the "+ GetStatic.ReadWebConfig("jmeName", "") + " Remit System is:";
            mailBody +=
                    "<br><br>Please download Google Authenticator from " +
                     "<a href=\"https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2\">Google Play Store</a> " +
                    "or <a href=\"http://appstore.com/googleauthenticator\">Apple Store</a>";

            mailBody +=
                "<br><br>1. open Google Authenticator app in your mobile";
            mailBody +=
                "<br><br>2. click + sign on the right hand side of the app and select Scan barcode from the popup display. Scan the QR code received in your email";
            mailBody +=
                "<br><br>3. the App will then display a six-digit code number which is required for login...the code number changes every 30 second";
            mailBody +=
                "<br><br><br><img src=\"" + imageLink + "\"/>";
            mailBody +=
                "<br><br>Or Input the below code manually:<br><b>" + manualCode + "</b>";
            mailBody +=
              "<br><br><br><span style='background-color:yellow'><b>After successfully adding in Google Authenticator, please permanently delete this email.</b></span>";
            mailBody +=
               "<br><br>Thank You.";
            mailBody +=
               "<br><br><br>Regards,";
            mailBody +=
               "<br>"+ GetStatic.ReadWebConfig("jmeName", "") + " Online Team";
            mailBody +=
               "<br>Head Office";
            mailBody +=
               "<br>Post Code: 169-0073 Omori Building 4F(AB), Hyakunincho 1-10-7, Shinjuku-ku, Tokyo, Japan ";
            mailBody +=
               "<br>Phone number 08034104278 ";
            return mailBody;
        }
    }
}