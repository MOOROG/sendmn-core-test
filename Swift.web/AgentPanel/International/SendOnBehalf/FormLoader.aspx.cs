using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.International.SendOnBehalf
{
    public partial class FormLoader : System.Web.UI.Page
    {
        private string _bankId = GetStatic.ReadQueryString("bankId", "");
        private string _isBranchByName = GetStatic.ReadQueryString("isBranchByName", "");
        private string _branchSelected = GetStatic.ReadQueryString("branchSelected", "");

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
            if (string.IsNullOrEmpty(_isBranchByName))
            {
                foreach (DataRow dr in dt.Rows)
                {
                    html.Append("<option value = \"" + dr["agentId"] + "\">" + dr["agentName"] + "</option>");
                }
            }
            else
            {
                foreach (DataRow dr in dt.Rows)
                {
                    if (_isBranchByName.ToUpper() == "Y")
                    {
                        if (_branchSelected.ToUpper() == dr["agentName"].ToString().ToUpper())
                        {
                            html.Append("<option value = \"" + dr["agentId"] + "\" selected=\"selected\">" + dr["agentName"] + "</option>");
                        }
                        else
                        {
                            html.Append("<option value = \"" + dr["agentId"] + "\">" + dr["agentName"] + "</option>");
                        }
                    }
                    else
                    {
                        if (_branchSelected == dr["agentId"].ToString())
                        {
                            html.Append("<option value = \"" + dr["agentId"] + "\" selected=\"selected\">" + dr["agentName"] + "</option>");
                        }
                        else
                        {
                            html.Append("<option value = \"" + dr["agentId"] + "\">" + dr["agentName"] + "</option>");
                        }
                    }
                }
            }
            html.Append("</select>");

            Response.Write(html.ToString());
        }
    }
}