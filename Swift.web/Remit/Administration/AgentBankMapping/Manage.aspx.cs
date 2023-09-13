using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.AgentBankMapping
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly CountryDao obj = new CountryDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(Page);
            if (!IsPostBack)
            {
                PopulateMenu();
            }
        }

        private void PopulateMenu()
        {
            _sdd.SetDDL(ref ddlApiBank, "exec proc_dropDownLists2 @flag='getAPIBank' ", "agentId", "agentName", "", "Select");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            DataTable dt = obj.getAgentMappingData(ddlApiBank.SelectedValue, GetStatic.GetUser());
            int count = 1;
            StringBuilder sb = new StringBuilder();
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            showData.Visible = true;
            foreach (DataRow dr in dt.Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td>" + (count++) + "  </td>");
                sb.Append("<td>" + dr["partnerName"].ToString() + "  </td>");
                sb.Append("<td>" + dr["checkbox"].ToString() + "  </td>");
                sb.Append("</tr>");
            }
            rpt.InnerHtml = sb.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var checkedvalue = Request.Form["functionId"];
            DbResult res = obj.SaveData(checkedvalue, GetStatic.GetUser(), ddlApiBank.SelectedValue);
            GetStatic.SetMessage(res);
            if (res.ErrorCode != "0")
            {
                return;
            }
            Response.Redirect("List.aspx");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            showData.Visible = false;
            PopulateMenu();
        }
    }
}