using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.AgentGroupSetup
{
    public partial class List : Page
    {
        private const string GridName = "grdAgentGrp12";
        private const string ViewFunctionId = "20111200";
        private const string AddEditFunctionId = "20111210";
        private const string DeleteFunctionId = "20111220";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly AgentGroupDao obj = new AgentGroupDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        private void LoadGroupCat(ref DropDownList groupCat, string defaultValue)
        {
            var sql = "select typeID, typeDesc from staticDataType where typeID between 6300 and 6900";
            _sdd.SetDDL(ref groupCat, sql, "typeID", "typeDesc", defaultValue, "All");
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("GroupCat", "Group Cat", "", "T"),
                                      new GridColumn("SubGroup", "Group Detail", "", "T"),
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("createdBy", "Created User", "", "T"),
                                      new GridColumn("createdDate", "Date", "", "D"),
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            string groupCatId = IsPostBack ? groupCat.Text : GetStatic.ReadValue(GridName, "groupCat");
            string groupDateilId = IsPostBack ? groupDetail.Text : GetStatic.ReadValue(GridName, "groupDetail");
            string agentNam = IsPostBack ? agentName.Text : GetStatic.ReadValue(GridName, "agentName");
            if (!IsPostBack)
            {
                LoadGroupCat(ref groupCat, groupCatId);
            }

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Group";
            grid.RowIdField = "rowID";
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            grid.AddPage = "Manage.aspx";

            grid.AllowCustomLink = true;
            grid.CustomLinkVariables = "rowID";

            string sql = "[proc_agentGroup] @flag = 'sG',@GroupCat=" + grid.FilterString(groupCatId) + ",@SubGroup=" + grid.FilterString(groupDateilId) + ",@agentName=" + grid.FilterString(agentNam) + "";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);

            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        protected void SaveAsCookie()
        {
            GetStatic.WriteValue(GridName, ref groupCat, "groupCat");
            GetStatic.WriteValue(GridName, ref groupDetail, "groupDetail");
            GetStatic.WriteValue(GridName, ref agentName, "agentName");
        }

        protected void groupCat_SelectedIndexChanged(object sender, EventArgs e)
        {
            var sql = "select valueid, detailDesc from staticDataValue where typeID = " + _sdd.FilterString(groupCat.Text.ToString());
            _sdd.SetDDL(ref groupDetail, sql, "valueid", "detailDesc", "", "All");
            groupCat.Focus();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            SaveAsCookie();
            LoadGrid();
        }
    }
}