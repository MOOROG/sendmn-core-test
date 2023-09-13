using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web
{
    public partial class Administration : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _remit = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMenuTiles();
            }
        }

        protected void LoadMenuTiles()
        {
            string sql = "exec sp_menuTilesGroupWise @flag=" + _remit.FilterString(GetMenuGroup());
            DataSet ds = _remit.ExecuteDataset(sql);
            if (ds.Tables.Count == 0 || ds.Tables == null)
            {
                return;
            }
            StringBuilder sb = new StringBuilder("");

            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                sb.Append(GenerateTile(ds.Tables[0].Rows[i]));
            }
            if (ds.Tables[1].Rows.Count != 0 || ds.Tables[1].Rows != null)
            {
                title.Text = ds.Tables[1].Rows[0][0].ToString();
            }
            divTilesMain.InnerHtml = sb.ToString();
        }

        private string GetMenuGroup()
        {
            return GetStatic.ReadQueryString("mtype", "");
        }

        private string GenerateTile(DataRow dr)
        {
            string fontAwesomeClass = "fa fa-users";
            StringBuilder sb = new StringBuilder("<div class=\"col-md-3\">");
            sb.AppendLine("<a href=\"" + dr["linkPage"].ToString() + "\" class=\"information\">");
            sb.AppendLine("<div class=\"panel panel-success\">");
            sb.AppendLine("<div class=\"panel-heading\">");
            sb.AppendLine("<h3 class=\"panel-title\">");
            sb.AppendLine(dr["menuName"].ToString());
            sb.AppendLine("</h3>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"panel-body\">");
            sb.AppendLine("<div class=\"row\">");
            sb.AppendLine("<div class=\"col-md-2\">");
            sb.AppendLine("<i class=\"" + fontAwesomeClass + "\" aria-hidden=\"true\"></i>");
            sb.AppendLine("</div>");
            sb.AppendLine("<div class=\"col-md-10\">");
            sb.AppendLine("<p>" + dr["menuDescription"].ToString() + "</p>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</div>");
            sb.AppendLine("</a>");
            sb.AppendLine("</div>");

            return sb.ToString();
        }
    }
}