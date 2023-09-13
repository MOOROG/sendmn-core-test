using Swift.web.Library;
using System;
using System.Web.UI;

namespace SwiftHrManagement.web
{
    public partial class ProjectMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string redirect = "";
            Page.Header.DataBind();
            if (GetStatic.GetUser() == "")
            {
                redirect = Request.Url.ToString();
                Response.Redirect(GetStatic.GetDefaultPage() + "?redirect=" + redirect);
            }

            //Code to Clear Cache
            Response.ClearHeaders();
            Response.AddHeader("Cache-Control", "no-cache, no-store, max-age=0, must-revalidate");
            Response.AddHeader("Pragma", "no-cache");
        }

        protected void lnkSignOut_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }
    }
}