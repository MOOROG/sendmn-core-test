using Swift.DAL.BL.System.Notification;
using Swift.web.Library;
using System;

namespace Swift.web.ApplicationLog
{
    public partial class ViewDetail : System.Web.UI.Page
    {
        private string id = null;
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly ApplicationLogsDao _obj = new ApplicationLogsDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            loadData();
        }

        protected string getId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private void loadData()
        {
            var dr = _obj.getData(getId().ToString());
            if (dr == null)
            {
                return;
            }
            var msg = dr["fieldValue"].ToString().Trim();
            msg = msg.Replace("-:::-", "</br>");

            logMsg.InnerHtml = msg.ToString();
        }
    }
}