using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.DomesticOperation.CommissionGroupMapping
{
    public partial class CommissionPackage : Page
    {
        private const string ViewFunctionId = "20131400";
        private const string AddEditFunctionId = "20131410";
        private const string DeleteFunctionId = "20131420";
        protected const string GridName = "grd_CommMappPck";
        protected const string GridName1 = "grd_CommMappPck1";
        protected const string GridName2 = "grd_CommMappPck2";
        protected const string GridName3 = "grd_CommMappPck3";
        private readonly CommGroupMappingDao _commGrpMap = new CommGroupMappingDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);

                if (GetTypeValue() == "D")
                {
                    type.Text = "D";
                    _sdd.SetStaticDdl(ref package, "6400", GetPackageId().ToString(), "Select");
                    OnDomesticGrid();
                }
                if (GetTypeValue() == "I")
                {
                    type.Text = "I";
                    _sdd.SetStaticDdl(ref package, "6500", GetPackageId().ToString(), "Select");
                    OnLoadGrids();
                    ViewChangeSetting();
                }
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
            GetStatic.PrintMessage(Page);
        }

        protected long GetPackageId()
        {
            return GetStatic.ReadNumericDataFromQueryString("packageId");
        }

        private string GetTypeValue()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            domestic.Visible = false;
            serviceCharge.Visible = false;
            payComm.Visible = false;
            sendComm.Visible = false;

            if (type.Text == "D")
                OnDomesticGrid();
            else
                OnLoadGrids();

            ViewChangeSetting();
        }

        private void ViewChangeSetting()
        {
            var dr = _commGrpMap.GetPackageAuditLog(GetStatic.GetUser(), package.Text);
            if (dr == null)
            {
                lblPackage.Text = "";
                spnViewChanges.InnerHtml = "";
                return;
            }

            lblPackage.Text = package.SelectedItem.Text;
            var param = "dialogHeight:1200px;dialogWidth:1200px;dialogLeft:20;dialogTop:20;center:yes";
            string url = "";
            if (type.Text == "I")
                url = "CommissionPackageApprove.aspx?packageId=" + package.Text + "&ruleType=cs";
            else if (type.Text == "D")
                url = "CommissionPackageApprove.aspx?packageId=" + package.Text + "&ruleType=ds";
            var html = new StringBuilder();
            if (dr["createdBy"].ToString() == GetStatic.GetUser())
                html.Append("<img src=\"../../../images/wait-icon.png\" border=\"0\" class=\"showHand\" onclick=\"PopUpWithCallBack('" + url + "', '" +
                        param + "');\"");
            else
                html.Append("<img src=\"../../../images/view-changes.jpg\" border=\"0\" class=\"showHand\" onclick=\"PopUpWithCallBack('" + url + "', '" +
                            param + "');\"");
            spnViewChanges.InnerHtml = html.ToString();
        }

        private void OnDomesticGrid()
        {
            domestic.Visible = true;

            DataTable dt = _commGrpMap.DomesticRuleDisplay(GetStatic.GetUser(), package.Text);

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='table table-responsive table-bordered table-striped'>");

            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?type=D&packageId=" + package.Text + "'><img src=\"../../../images/add.gif\" border=0 alt=\"Add Rule\" title=\"Add Rule\"/></a></div></td></tr>");
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
                    str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                }
                str.Append("<td align=\"left\"><img style=\"cursor:pointer;\" onclick = \"IsDelete('" + dr["id"].ToString() + "')\" border = '0' title = \"Confirm Delete\" src=\"../../../images/delete.gif\" /></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rpt_domestic.InnerHtml = str.ToString();
        }

        private void OnLoadGrids()
        {
            DataSet ds = _commGrpMap.IntlRuleDisplay(GetStatic.GetUser(), (package.Text == "" ? GetPackageId().ToString() : package.Text));
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

            var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");
            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=sc&type=I&packageId=" + package.Text + "'><img src=\"../../../images/add.gif\" border=0 alt=\"Add Rule\" title=\"Add Rule\"/></a></div></td></tr>");
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
                    str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                }
                str.Append("<td align=\"left\"><img style=\"cursor:pointer;\" onclick = \"IsDelete('" + dr["id"].ToString() + "')\" border = '0' title = \"Confirm Delete\" src=\"../../../images/delete.gif\" /></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rpt_sc.InnerHtml = str.ToString();
        }

        private void LoadPayCommission(DataTable dt)
        {
            payComm.Visible = true;
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");

            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=cp&type=I&packageId=" + package.Text + "'><img src=\"../../../images/add.gif\" border=0 alt=\"Add Rule\" title=\"Add Rule\"/></a></div></td></tr>");
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
                    str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                }
                str.Append("<td align=\"left\"><img style=\"cursor:pointer;\" onclick = \"IsDelete('" + dr["id"].ToString() + "')\" border = '0' title = \"Confirm Delete\" src=\"../../../images/delete.gif\" /></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");

            rpt_cp.InnerHtml = str.ToString();
        }

        private void LoadSendCommission(DataTable dt)
        {
            sendComm.Visible = true;
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");

            str.Append("<tr><td colspan='" + cols + "'><div align=\"right\"><a href='RuleAdd.aspx?flag=cs&type=I&packageId=" + package.Text + "'><img src=\"../../../images/add.gif\" border=0 alt=\"Add Rule\" title=\"Add Rule\"/></a></div></td></tr>");
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
                    str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
                }
                str.Append("<td align=\"left\"><img style=\"cursor:pointer;\" onclick = \"IsDelete('" + dr["id"].ToString() + "')\" border = '0' title = \"Confirm Delete\" src=\"../../../images/delete.gif\" /></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");

            rpt_cs.InnerHtml = str.ToString();
        }

        protected void type_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (type.Text != "")
            {
                if (type.Text == "D")
                    _sdd.SetStaticDdl(ref package, "6400", "", "Select");
                else
                    _sdd.SetStaticDdl(ref package, "6500", "", "Select");
            }
        }

        protected void btnDeleteRecord_Click(object sender, EventArgs e)
        {
            var dbResult = _commGrpMap.Delete(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);

            if (type.Text == "D")
                OnDomesticGrid();
            else
                OnLoadGrids();
        }
    }
}