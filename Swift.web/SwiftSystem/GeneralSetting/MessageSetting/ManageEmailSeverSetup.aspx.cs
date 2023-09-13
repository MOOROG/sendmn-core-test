using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using System.Collections.Generic;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class ManageEmailSeverSetup : Page
    {
        private readonly MessageSettingDao obj = new MessageSettingDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "10111400";
        private const string AddEditFunctionId = "10111410";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();                
                GetStatic.PrintMessage(Page);
                if (GetId()>0)
                    PopulateDataById();
            }
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("id");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByIdEmailServerSetup(GetStatic.GetUser());
            if (dr == null)
                return;

            emailSMTPServer.Text = dr["smtpServer"].ToString();
            emailSMTPPort.Text = dr["smtpPort"].ToString();
            emailSendId.Text = dr["sendID"].ToString();
            emailSendPsw.Attributes.Add("value", dr["sendPSW"].ToString()); 
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateEmailServerSetup(GetStatic.GetUser(), GetId().ToString() ,emailSMTPServer.Text, emailSMTPPort.Text, emailSendId.Text, emailSendPsw.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("emailServerList.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}