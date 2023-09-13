using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Commission.CommissionGroupMapping
{
    public partial class PackageAdd : System.Web.UI.Page
    {
        private string GridName = "";
        private const string ViewFunctionId = "20131400";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();
        private CommGroupMappingDao _commGrp = new CommGroupMappingDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }

            SetGrid(GetType());
        }

        private void SetGrid(string type)
        {
            if (type == "D")
            {
                GridName = "grid_DomesticPac";
            }
            if (type == "I")
            {
                GridName = "grid_InternationalPac";
            }

            LoadGrid(type);
        }

        private void LoadGrid(string type)
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("detailTitle", "Code", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("detailTitle", "Code", "", "T"),
                                      new GridColumn("detailDesc", "Description", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = false;
            grid.MultiSelect = true;
            grid.ShowCheckBox = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "valueId";
            grid.ThisPage = "PackageAdd.aspx";
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;

            grid.AllowEdit = false;
            grid.GridWidth = 800;

            string sql = "[proc_commissionPackageAdd] @flag ='grid',@type = " + grid.FilterString(type) + ",@groupId=" + grid.FilterString(GetGroupId());
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string rsList = grid.GetRowId(GridName);
            DbResult dbResult = _commGrp.AddCommissionGroup(GetStatic.GetUser(), GetGroupId(), rsList);
            ManageMessage(dbResult);
        }

        private string GetGroupId()
        {
            return GetStatic.ReadQueryString("groupId", "");
        }

        private string GetType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);

            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("CommissionGroup.aspx?groupId=" + GetGroupId());
            }
            else
            {
                GetStatic.PrintMessage(Page);
                //GetStatic.AlertMessageBox(Page);
            }
        }
    }
}