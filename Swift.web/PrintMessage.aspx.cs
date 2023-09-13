using Swift.web.Library;
using System;
using System.Text;

namespace Swift.web
{
    public partial class PrintMessage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            PrintMsg();
        }

        private string GetMessage()
        {
            return GetStatic.ReadQueryString("msg", "");
        }

        private string GetErrorCode()
        {
            return GetStatic.ReadQueryString("errorCode", "");
        }

        private void PrintMsg()
        {
            var msg = GetMessage();
            var errorCode = GetErrorCode();
            var html = new StringBuilder();
            if (errorCode == "0" || errorCode.ToUpper() == "SUCCESS")
                html.Append("<div id=\"success\"><div>" + msg + "</div></div>");
            else
                html.Append("<div id=\"errorExplanation\" style='margin-top:230px'><div>" + msg + "</div></div>");
            divMsg.InnerHtml = html.ToString();
        }
    }
}