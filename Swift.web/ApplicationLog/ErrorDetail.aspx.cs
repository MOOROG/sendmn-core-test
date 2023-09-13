using Swift.DAL.ApplicationLogs;
using Swift.web.Library;
using System;

namespace Swift.web.ApplicationLog
{
    public partial class ErrorDetail : System.Web.UI.Page
    {
        private readonly LogDAO lg = new LogDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadErrorData();
        }

        private void LoadErrorData()
        {
            var dr = lg.GetErrorDetails(GetStatic.ReadQueryString("id", ""));

            error.InnerHtml = dr["errorDetails"].ToString();
        }
    }
}