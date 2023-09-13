using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Commission;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Commission.AgentCommissionRule
{
    public partial class AgentCommission : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20131500";
        private const string AddEditFunctionId = "20131510";
        private const string DeleteFunctionId = "20131520";
        private readonly AgentCommissionDao _commGrpMap = new AgentCommissionDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetMode() == "1")
                {
                    GetStatic.AlertMessage(Page);
                    btnBack.Visible = false;
                }
                PrintMsg();
                LoadBreadCrumb();
                OnLoadGrids();
                ViewChangeSetting();
            }
            //OnDomesticGrid();
            //DeleteRow();
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            PrintMsg();
        }

        private void PrintMsg()
        {
            if (GetMode() == "1")
                GetStatic.AlertMessage(Page);
            else
                GetStatic.PrintMessage(Page);
        }

        private void LoadBreadCrumb()
        {
            hdnAgentId.Value = GetAgentId().ToString();
            spnCname.InnerHtml = _sdd.GetAgentBreadCrumb(hdnAgentId.Value);
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected string GetAgentName()
        {
            return GetStatic.ReadQueryString("agentName", "");
        }

        protected string GetMode()
        {
            return GetStatic.ReadQueryString("mode", "");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            serviceCharge.Visible = false;
            payComm.Visible = false;
            sendComm.Visible = false;
            OnLoadGrids();

            ViewChangeSetting();
        }

        private void ViewChangeSetting()
        {
            var dr = _commGrpMap.GetAgentCommissionAuditLog(GetStatic.GetUser(), hdnAgentId.Value);
            if (dr == null)
            {
                lblAgent.Text = "";
                spnViewChanges.InnerHtml = "";
                return;
            }

            lblAgent.Text = GetAgentName();
            var param = "dialogHeight:1200px;dialogWidth:1200px;dialogLeft:20;dialogTop:20;center:yes";
            string url = "";
            url = "AgentCommissionApprove.aspx?agentId=" + hdnAgentId.Value + "&ruleType=cs";
            var html = new StringBuilder();
            if (dr["createdBy"].ToString() == GetStatic.GetUser())
                html.Append(Misc.GetIcon("wait", "PopUpWithCallBack('" + url + "', '" + param + "');"));
            else
                html.Append(Misc.GetIcon("viewchanges", "PopUpWithCallBack('" + url + "', '" + param + "');"));
            spnViewChanges.InnerHtml = html.ToString();
        }

        private void OnLoadGrids()
        {
            DataSet ds = _commGrpMap.IntlRuleDisplay(GetStatic.GetUser(), (hdnAgentId.Value == "" ? GetAgentId().ToString() : hdnAgentId.Value));
            if (ds.Tables.Count > 0)
            {
                var dt = ds.Tables[0];
                LoadServiceCharge(dt);
            }
            if (ds.Tables.Count > 1)
            {
                var dt = ds.Tables[1];
                LoadPayCommission(dt);
            }
            if (ds.Tables.Count > 2)
            {
                var dt = ds.Tables[2];
                LoadSendCommission(dt);
            }
        }

        private void LoadServiceCharge(DataTable dt)
        {
            serviceCharge.Visible = true;
            int cols = dt.Columns.Count;

            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"gridTable\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\">");
            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=sc&agentName=" + GetAgentName() + "&agentId=" + hdnAgentId.Value + "&mode=" + GetMode() + "'>" + Misc.GetIcon("add") + "</a></div></td></tr>");
            str.Append("<tr class='hdtitle'>");
            for (int i = 3; i < cols; i++)
            {
                str.Append("<th class=\"headingTH\"><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("<th align=\"left\"></th>");
            str.Append("</tr>");
            var j = 0;
            foreach (DataRow dr in dt.Rows)
            {
                str.Append(++j % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                for (int i = 3; i < cols; i++)
                {
                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
                }
                str.Append("<td align=\"left\">" + Misc.GetIcon("delete","IsDelete('" + dr["id"] + "')") + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rpt_sc.InnerHtml = str.ToString();
        }

        private void LoadPayCommission(DataTable dt)
        {
            payComm.Visible = true;
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"gridTable\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\">");

            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=cp&agentName=" + GetAgentName() + "&agentId=" + hdnAgentId.Value + "&mode=" + GetMode() + "'>" + Misc.GetIcon("add") + "</a></div></td></tr>");
            str.Append("<tr class='hdtitle'>");
            for (int i = 3; i < cols; i++)
            {
                str.Append("<th class=\"headingTH\"><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("<th align=\"left\"></th>");
            str.Append("</tr>");
            var j = 0;
            foreach (DataRow dr in dt.Rows)
            {
                str.Append(++j % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                for (int i = 3; i < cols; i++)
                {
                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
                }
                str.Append("<td align=\"left\">" + Misc.GetIcon("delete", "IsDelete('" + dr["id"] + "')") + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");

            rpt_cp.InnerHtml = str.ToString();
        }

        private void LoadSendCommission(DataTable dt)
        {
            sendComm.Visible = true;
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"gridTable\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\">");

            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=cs&agentName=" + GetAgentName() + "&agentId=" + hdnAgentId.Value + "&mode=" + GetMode() + "'>" + Misc.GetIcon("add") + "</a></div></td></tr>");
            str.Append("<tr class='hdtitle'>");
            for (int i = 3; i < cols; i++)
            {
                str.Append("<th class=\"headingTH\"><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("<th align=\"left\"></th>");
            str.Append("</tr>");
            var j = 0;
            foreach (DataRow dr in dt.Rows)
            {
                str.Append(++j % 2 == 1 ? "<tr class=\"oddbg\">" : "<tr class=\"evenbg\">");
                for (int i = 3; i < cols; i++)
                {
                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
                }
                str.Append("<td align=\"left\">" + Misc.GetIcon("delete", "IsDelete('" + dr["id"] + "')") + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");

            rpt_cs.InnerHtml = str.ToString();
        }

        protected void btnDeleteRecord_Click(object sender, EventArgs e)
        {
            var dbResult = _commGrpMap.Delete(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);
            OnLoadGrids();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }
    }
}