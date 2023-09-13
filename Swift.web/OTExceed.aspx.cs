using Swift.web.Library;
using System;
using System.Text;

namespace Swift.web
{
    public partial class OTExceed : System.Web.UI.Page
    {
        private RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            //Authenticate();
            PrintMsg();
        }

        private void Authenticate()
        {
            _sl.CheckSession();
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
            html.Append("<div id=\"errorExplanation\"><div>You are not allowed to do transaction at this time</div></div>");
            divMsg.InnerHtml = html.ToString();
        }
    }
}