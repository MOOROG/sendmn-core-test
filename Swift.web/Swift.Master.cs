using System;
using Swift.web.Library;

namespace Swift.web
{
    public partial class Swift : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Page.Header.DataBind();
            //Download();
        }

        //private void Download()
        //{
        //    var mode = GetStatic.ReadQueryString("mode", "");
        //    var reportName = GetStatic.ReadQueryString("reportName", "");
        //    if (mode == "download")
        //    {
        //        string format = GetStatic.ReadQueryString("format", "xls");
        //        Response.Clear();
        //        Response.ClearContent();
        //        Response.ClearHeaders();
        //        Response.ContentType = "application/vnd.ms-excel";
        //        Response.AddHeader("Content-Disposition", "inline; filename=" + reportName + "." + format);
        //    }
        //}
    }
}
