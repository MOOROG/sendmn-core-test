using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.Utilities.AgentFinder
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40134200";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDDL();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref district, "EXEC proc_zoneDistrictMap @flag = 'dis'", "districtId", "districtName", "", "Select");
        }

        protected void district_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (district.Text == "")
                location.Text = null;
            else
                _sdd.SetDDL(ref location, "EXEC proc_zoneDistrictMap @flag = 'dwl', @districtId = '" + district.Text + "'", "districtCode", "districtName", "All", "");
        }

        private void LoadGridView()
        {
            var obj = new AgentDao();
            if (location.Text == "")
            {
                location.Text = null;
            }
            var ds = obj.DisplayMatchAgentWithDisLoc(GetStatic.GetUser(), district.Text, location.Text, "");

            if (ds == null)
            {
                divLoadGrid.Visible = false;
                PrintMessage("Agent not found!");
                return;
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                var dt = ds.Tables[0];
                int cols = dt.Columns.Count;
                var str = new StringBuilder("<div class=\"panel panel-default\"><div class=\"panel-heading\">Search Result</div><div class=\"panel-body\"><table class='table table-condensed' border=\"0\" cellspacing=0 cellpadding=\"3\"></div></div>");
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    for (int i = 0; i < cols; i++)
                    {
                        str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                str.Append("</table></fieldset>");
                divLoadGrid.Visible = true;
                divLoadGrid.InnerHtml = str.ToString();
            }
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }

        protected void btnAgentFind_Click(object sender, EventArgs e)
        {
            LoadGridView();
        }
    }
}