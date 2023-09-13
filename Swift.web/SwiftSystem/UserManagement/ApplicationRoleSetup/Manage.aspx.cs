using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup
{
    public partial class Manage : Page
    {
        public const string AddEditFunctionId = "10101010";
        private readonly ApplicationRoleDao _roleDao = new ApplicationRoleDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                if (GetId() > 0)
                {
                    PupulateDataById();
                }
            }
        }

        private static long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("roleId");
        }

        private void Update()
        {
            DbResult dbResult = _roleDao.Update(GetId().ToString(), roleName.Text, type.SelectedValue, GetStatic.GetUser(), isActive.Text);
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

        private void PupulateDataById()
        {
            DataRow dr = _roleDao.SelectById(GetId().ToString(), GetStatic.GetUser());
            if (dr == null)
                return;
            roleName.Text = dr["roleName"].ToString();
            type.SelectedValue = dr["roleType"].ToString();
            isActive.Text = dr["isActive"].ToString();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(AddEditFunctionId);
        }

        protected void BtnSave_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}