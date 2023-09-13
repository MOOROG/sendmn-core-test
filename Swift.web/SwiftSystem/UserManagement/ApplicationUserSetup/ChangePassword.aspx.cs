﻿using System;
using System.Web.UI;
using Swift.DAL.BL.System.UserManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup
{
    public partial class ChangePassword : Page
    {
        private readonly ApplicationUserDao _obj = new ApplicationUserDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            PopulateUserName();
            if (!IsPostBack)
            {
                Authenticate();
            }

        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }

        private void ManageMessage2(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                GetStatic.AlertMessage(Page);
            }
        }

        protected void PopulateUserName()
        {
            userName.Text = GetStatic.GetUser();
        }

        private void Update()
        {
            DbResult dbResult = _obj.ChangePassword(userName.Text, pwd.Text, oldPwd.Text);
            ManageMessage2(dbResult);
            if (dbResult.ErrorCode=="0")
            {
                Response.Redirect("~/Admin/Dashboard.aspx");
            }
        }

        protected void btnOk_Click(object sender, EventArgs e)
        {
            if (pwd.Text != confirmPwd.Text)
            {
                msg.Text = "Confirm Password Doesn't Match";
                return;
            }
            else
            {
                Update();
            }
        }
    }
}