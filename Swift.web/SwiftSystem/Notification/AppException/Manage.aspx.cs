using System;
using System.Data;
using System.Web.UI;
using Swift.web.Library;
using Swift.DAL.BL.System.Notification;
namespace Swift.web.SwiftSystem.Notification.AppException
{
    public partial class Manage : Page
    {
        ApplicationLogsDao log = new ApplicationLogsDao();
        private const string ViewFunctionId = "10121400";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadMessage();
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadMessage()
        {
            var id = GetStatic.ReadNumericDataFromQueryString("id").ToString();            
            DataRow row = log.GetAppExecDetails(GetStatic.GetUser(), id);

            if (row != null)
            {
                dcUserName.Text = row["dcUserName"].ToString();
                dcIdNo.Text = row["dcIdNo"].ToString();
                ipAddress.Text = row["ipAddress"].ToString();
                errMsg.InnerHtml = row["errorDetails"].ToString();
            }
            else
            {
                errMsg.InnerHtml = "<span style= 'color:red'>Error while loading message </span>";
            }
        }
    }
}