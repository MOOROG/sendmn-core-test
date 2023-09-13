using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.International.SendMoney
{
    public partial class FormLoader : System.Web.UI.Page
    {
        private string _bankId = GetStatic.ReadQueryString("bankId", "");

        protected void Page_Load(object sender, EventArgs e)
        {
            ReturnValue();
        }

        private void ReturnValue()
        {
            switch (GetQueryType())
            {
                case "bb":
                    PopulateBranchName();
                    break;
            }
        }

        private string GetQueryType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private void PopulateBranchName()
        {
            var dao = new RemittanceDao();
            var html = new StringBuilder();
            if (string.IsNullOrEmpty(_bankId) || _bankId == "undefined")
            {
                return;
            }
            var sql = "EXEC proc_dropDownLists @flag = 'pickBranchById', @agentId=" + dao.FilterString(_bankId);
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                html.Append("<select id=\"branch\" class=\"form-control\"><option value = \"-1\">No Branches Found</option></select>");
                Response.Write(html.ToString());
                return;
            }
            html.Append("<select id=\"branch\" class=\"form-control\" >");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["agentId"] + "\">" + dr["agentName"] + "</option>");
            }
            html.Append("</select>");
            Response.Write(html.ToString());
        }
    }
}