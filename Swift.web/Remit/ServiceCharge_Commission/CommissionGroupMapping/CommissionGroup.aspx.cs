using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;

namespace Swift.web.Remit.DomesticOperation.CommissionGroupMapping
{
    public partial class CommissionGroup : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20131400";
        private const string AddEditFunctionId = "20131410";
        private const string DeleteFunctionId = "20131420";
        protected const string GridName = "grd_CommMappGrp";
        private readonly CommGroupMappingDao _commGrpMap = new CommGroupMappingDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                PopulateDdl();
                if(GetGroupId() != "0")
                {
                    LoadGrids();
                }
            }
        }
        private string GetGroupId()
        {
            return GetStatic.ReadQueryString("groupId", "0");
        }
        private void PopulateDdl()
        {
            _sdd.SetStaticDdl(ref group, "6600", GetGroupId(), "Select");
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
        }

        private void LoadGrids()
        {
            var ds = _commGrpMap.PackageDisplay(GetStatic.GetUser(), group.Text);
            if (ds.Tables.Count > 0)
            {
                var dt = ds.Tables[0];
                LoadDomesticPackage(dt);
            }
            if(ds.Tables.Count > 1)
            {
                var dt = ds.Tables[1];
                LoadInternationalPackage(dt);   
            }
        }

        private void LoadDomesticPackage(DataTable dt)
        {
            domestic.Visible = true;

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"gridTable\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\">");

            str.Append("<tr><td colspan=\"" + cols + "\"><div align=\"right\"><a href=\"PackageAdd.aspx?type=D&groupId=" + group.Text + "\"><img src=\"../../../images/add.gif\"/></a></div></td></tr>");
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

        private void LoadInternationalPackage(DataTable dt)
        {
            international.Visible = true;

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"gridTable\" cellpadding=\"5\" cellspacing=\"0\" align=\"center\">");

            str.Append("<tr><td colspan=\"" + cols + "\"><div align=\"right\"><a href=\"PackageAdd.aspx?type=I&groupId=" + group.Text + "\"><img src=\"../../../images/add.gif\"/></a></div></td></tr>");
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
            rpt_intl.InnerHtml = str.ToString();

        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadGrids();
        }

        private void DeleteRow()
        {
            DbResult dbResult = _commGrpMap.DeleteGroup(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);

            LoadGrids();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        protected void btnDeleteRecord_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        /*
        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("groupName", "Group Name", "LT"),
                                      new GridFilter("packageName", "Package Name", "LT")
                                  };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("groupId", "Group ID", "", "T"),
                                      new GridColumn("groupName", "Group Name", "", "T"),
                                      new GridColumn("packageName", "Package Name", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.GridWidth = 600;
            grid.RowIdField = "id";
            grid.CallBackFunction = "GridCallBack()";
            grid.ThisPage = "CommissionGroup.aspx";
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_commissionGroupMapping @flag = 'sg'";

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
         * */
    }
}