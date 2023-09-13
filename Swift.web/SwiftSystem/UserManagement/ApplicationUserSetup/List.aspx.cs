using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.API.Common;
using Swift.API.GoogleAuthenticator;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class List : Page
    {
        private const string GridName = "exUsersList";
        private const string ViewFunctionId = "10101300";
        private const string AddEditFunctionId = "10101310";
        private const string DeleteFunctionId = "10101320";
        private const string ApproveFunctionId = "10101330";
        private const string AssignRoleId = "10101350";
        private const string ResetPassword = "10101370";
        private const string LockUser = "10101380";
        private const string SendQRCode = "10101360";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private GoogleAuthenticatorAPI _auth = new GoogleAuthenticatorAPI();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);

            }
            LoadGrid();
            DeleteRow();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("userName", "User Name:", "a"),
                                       new GridFilter("firstName", "First Name:", "LT"),
                                       new GridFilter("isActive", "Lock Status:", "2")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       //new GridColumn("branchName", "Branch Name","", "T"),
                                       new GridColumn("userId", "User ID","", "a"),
                                       new GridColumn("userName", "User Name","", "a"),
                                       new GridColumn("agentCode", "Agent Code", "", "T"),
                                       new GridColumn("name", "Name", "", "LT"),
                                       new GridColumn("address", "Address", "", "LT"),
                                       new GridColumn("lastLoginTs", "Last Login", "", "T"),
                                       new GridColumn("lastPwdChangedOn", "Password Change", "", "T"),
                                       new GridColumn("lockStatus", "Lock Status", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New User";
            _grid.RowIdField = "userId";
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.AddPage = "manage.aspx";
            _grid.AllowCustomLink = true;
            _grid.InputLabelOnLeftSide = false;
            _grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;

            var customLinkText = new StringBuilder();
            if (_sl.HasRight(AssignRoleId))
                customLinkText.Append("<a href = \"../AdminUserSetup/UserRole.aspx?userName=@userName&userId=@userId" + "\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/role_icon.gif\" border=0 title=\"Assign Role\" alt=\"Assign Role\" /></a>&nbsp;&nbsp;");

            if (_sl.HasRight(LockUser))
                customLinkText.Append(
                        "<a href = '#'><img src=\"" + GetStatic.GetUrlRoot() + "/images/unlock.png\" height=\"17\" width=\"16\" border=0 title=\"Lock/Unlock User\" alt=\"Lock/Unlock User\" onclick=\"LockUnlock(@userId,'l');\" /></a>&nbsp;&nbsp;");
            if (_sl.HasRight(ResetPassword))
                customLinkText.Append("<a href =\"ResetPassword.aspx?userName=@userName&agentId=" +GetAgent()+"&mode=" + GetMode() +"\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/change_password.png\" border=0 title=\"Reset Password\" alt=\"Reset Password\" \" /></a>&nbsp;&nbsp;");

            //if (_sl.HasRight(SendQRCode))
            //    customLinkText.Append("<a class=\"btn btn-xs btn-primary\" href=\"javascript:void(0);\" onclick=\"SendEmail('@userId', '@userName')\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Send QR Code\"><i class=\"fa fa-envelope\"></i></btn>");

            _grid.CustomLinkText = customLinkText.ToString();

            _grid.CustomLinkVariables = "userName,userId";
            _grid.InputPerRow = 4;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.InputLabelOnLeftSide = true;
            _grid.GridMinWidth = 800;

            //string sql = " [proc_applicationUsers] @flag = 's',@userType='HO'";
            string sql = "[proc_applicationUsers] @flag = 'hs', @agentId = " + _grid.FilterString(GetStatic.GetHoAgentId());

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId );
        }

        private void DeleteRow()
        {
            if (!isRefresh)
            {
                string id = _grid.GetCurrentRowId(GridName);
                if (string.IsNullOrEmpty(id))
                    return;
                DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
                ManageMessage(dbResult);
                LoadGrid();
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
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }
        protected void LockUnlockUser_Click(object sender, EventArgs e)
        {
                if (string.IsNullOrWhiteSpace(hdnchangeType.Value))
                    return;
                DbResult dbResult = null;
                if (hdnchangeType.Value == "l")
                    dbResult = _obj.LockUnlockUser(GetStatic.GetUser(), hddUserId.Value);

                if (hdnchangeType.Value == "r")
                    dbResult = _obj.ResetPassword(GetStatic.GetUser(), hddUserId.Value);

                ManageMessage(dbResult);
                LoadGrid();
                hdnchangeType.Value = "";
                hddUserId.Value = "";
        }
    
        #region Browser Refresh
        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion

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