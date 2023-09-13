using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.ApplicationLog
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (GetId() != "")
                {
                    PopulateErrorMsg();
                }
            }
        }

        private void PopulateErrorMsg()
        {
            string sql = "SELECT errorDetails FROM ErrorLogs WHERE id = '"+GetId()+"'";
            var res = _sl.GetSingleResult(sql);

            ErrorDiv.InnerHtml = res.ToString();
        }

        private string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }
    }
}