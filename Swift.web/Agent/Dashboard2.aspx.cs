using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Agent
{
    public partial class Dashboard2 : System.Web.UI.Page
    {
        private RemittanceLibrary rl = new RemittanceLibrary();
        private string VaultTransferViewFunctionId = "20198000";

        protected void Page_Load(object sender, EventArgs e)
        {
            rl.CheckSession();
            if (!IsPostBack)
            {
                PopulateMenu();
                userName.Text = GetStatic.GetAgentName() + " (" + GetStatic.ReadSession("user", "") + ")";
                if (rl.HasRight(VaultTransferViewFunctionId))
                {
                    PopulateNotification();
                }
            }
        }

        protected void PopulateNotification()
        {
            string sql = "EXEC proc_notification @user = " + rl.FilterString(getUser()) + ", @portal='agent', @branch_id=" + rl.FilterString(GetStatic.GetBranch());
            DataTable dt = rl.ExecuteDataTable(sql);
            if (null == dt)
            {
                return;
            }
            if (dt.Rows.Count == 0)
            {
                return;
            }
            StringBuilder sb = new StringBuilder();
            int counter = 0;

            foreach (DataRow item in dt.Rows)
            {
                counter += Convert.ToInt16(item["count"].ToString());
                sb.AppendLine("<li class=\"clearfix\">");
                sb.AppendLine("<a href=\"" + item["link"].ToString() + "\" target=\"mainFrame\">");
                sb.AppendLine("<span class=\"pull-left\">");
                sb.AppendLine("<i class=\"fa fa-bell\" style='color:#0e96ec'></i>");
                sb.AppendLine("</span>");
                sb.AppendLine("<span class=\"media-body\">");
                sb.AppendLine(item["msg"].ToString());
                sb.AppendLine("<em>" + item["msg1"].ToString() + "</em>");
                sb.AppendLine("</span>");
                sb.AppendLine("</a></li>");
            }
            countNotification.InnerHtml = counter.ToString();
            notiUL.InnerHtml = "<li class=\"notify-title\">" + counter.ToString() + " New Notification(s)</li>" + sb.ToString();
        }

        protected string getUser()
        {
            return GetStatic.GetUser();
        }

        protected void PopulateMenu()
        {
            StringBuilder sb = new StringBuilder();
            string sql = "exec menu_proc @flag = 'agent', @user = '" + getUser() + "'";
            DataSet ds = rl.ExecuteDataset(sql);
            DataTable menuGroup = ds.Tables[0];
            //sb.AppendLine("<div id=\"navbar-main\" class=\"navbar-collapse collapse\">");
            //sb.AppendLine("<ul class=\"nav navbar-nav\">");
            //sb.AppendLine("<li class=\"active\"><a href=\"../Agent/Dashboard.aspx\">Dashboard</a></li>");
            sb.AppendLine("<li><a href=\"/Agent/AgentMain.aspx\" target='mainFrame'>Dashboard</a></li> ");
            if (ds.Tables[0].Rows.Count == 0 || ds.Tables[1].Rows.Count == 0)
            {
                //sb.AppendLine("</li></ul>");
                //sb.AppendLine("</div>");
                menu.InnerHtml = sb.ToString();
                return;
            }

            for (int i = 0; i <= menuGroup.Rows.Count; i++)
            {
                if (menuGroup.Rows.Count != 0)
                {
                    string menuGroupName = menuGroup.Rows[0]["AgentMenuGroup"].ToString();
                    DataRow[] rows = ds.Tables[1].Select("AgentMenuGroup = ('" + menuGroupName + "')");
                    if (rows.Length > 0)
                        sb.AppendLine(GetMenuContents(menuGroupName, rows));
                    DataRow[] rowsToRemove = menuGroup.Select("AgentMenuGroup = ('" + menuGroupName + "')");
                    foreach (DataRow row in rowsToRemove)
                    {
                        menuGroup.Rows.Remove(row);
                    }
                }
                i = 0;
            }
            //sb.AppendLine("</li></ul>");
            //sb.AppendLine("</div>");
            sb.AppendLine("<li><a href=\"/Logout.aspx\" style='background-color:#333'>Logout</a></li> ");
            menu.InnerHtml = sb.ToString();
        }

        private string GetMenuContents(string menuGroup, DataRow[] dr)
        {
            StringBuilder sb = new StringBuilder("");
            DataTable dt = CreateDataTable();

            foreach (DataRow row in dr)
            {
                dt.ImportRow(row);
            }
            sb.AppendLine("<li><a href=\"#\">" + menuGroup + "<span class=\"caret\"></span></a> ");
            sb.AppendLine("<ul>");
            for (int i = 0; i <= dt.Rows.Count; i++)
            {
                if (dt.Rows.Count != 0)
                {
                    DataRow[] menuList = dt.Select("AgentMenuGroup = ('" + dt.Rows[0]["AgentMenuGroup"].ToString() + "')");
                    string subMainMenu = menuList[0]["AgentMenuGroup"].ToString();

                    foreach (DataRow row in menuList)
                    {
                        //sb.AppendLine("<li><a tabindex=\"-1\" href=\"" + row["linkPage"].ToString() + "\" target=\"mainFrame\">" + row["menuName"].ToString() + "</a></li>");
                        sb.AppendLine("<li><a href=\"" + row["linkPage"].ToString() + "\" target=\"mainFrame\">" + row["menuName"].ToString() + "</a></li>");
                    }

                    DataRow[] rows = dt.Select("AgentMenuGroup = ('" + dt.Rows[0]["AgentMenuGroup"].ToString() + "')");
                    foreach (DataRow row in rows)
                    {
                        dt.Rows.Remove(row);
                    }
                }
                i = 0;
            }
            sb.AppendLine("</ul></li>");
            return sb.ToString();
        }

        private DataTable CreateDataTable()
        {
            DataTable dt = new DataTable();
            DataColumn linkPage = new DataColumn("linkPage", Type.GetType("System.String"));
            DataColumn menuName = new DataColumn("menuName", Type.GetType("System.String"));
            DataColumn agentMenuGroup = new DataColumn("AgentMenuGroup", Type.GetType("System.String"));
            dt.Columns.Add(linkPage);
            dt.Columns.Add(agentMenuGroup);
            dt.Columns.Add(menuName);

            return dt;
        }
    }
}