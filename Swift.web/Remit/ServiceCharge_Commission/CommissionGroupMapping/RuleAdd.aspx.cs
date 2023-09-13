using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.DomesticOperation.CommissionSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.DomesticOperation.CommissionGroupMapping
{
    public partial class RuleAdd : System.Web.UI.Page
    {
        private string GridName = "";
        private const string ViewFunctionId = "20131400";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private CommGroupMappingDao _commGrp = new CommGroupMappingDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }

            SetGrid(GetFlag());
        }
        private void SetGrid(string flag)
        {
            if (flag == "sc")
            {
                GridName = "grid_scAdd";
            }
            if (flag == "cp")
            {
                GridName = "grid_cpAdd";
            }
            if (flag == "cs")
            {
                GridName = "grid_csAdd";
            }
            if (flag == "ds")
            {
                GridName = "grid_dsAdd";
            }
            LoadGrid(flag);
        }
        private string GetRowIdField(string flag)
        {
            string rowId = null;
            if (flag == "sc")
            {
                rowId = "sscMasterId";
            }
            if (flag == "cp")
            {
                rowId = "scPayMasterId";
            }
            if (flag == "cs")
            {
                rowId = "scSendMasterId";
            }
            if (flag == "ds")
            {
                rowId = "scMasterId";
            }
            return rowId;
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private  string GetFlag()
        {
            return GetStatic.ReadQueryString("flag", "ds");
        }
        private string GetPackageId()
        {
            return GetStatic.ReadQueryString("packageId", "");
        }
        private string GetType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        ////private void LoadSCGrid(string flag)
        ////{
        ////    grid.FilterList = new List<GridFilter>
        ////                          {
        ////                              new GridFilter("Code", "Code", "LT")
        ////                          };

        ////    grid.ColumnList = new List<GridColumn>
        ////                          {
        ////                              new GridColumn("Code", "Code", "", "T"),
        ////                              new GridColumn("description", "Description", "", "T")
        ////                          };

        ////    grid.GridType = 1;
        ////    grid.GridName = GridName;
        ////    grid.ShowAddButton = false;
        ////    grid.ShowFilterForm = true;
        ////    grid.AlwaysShowFilterForm = false;
        ////    grid.MultiSelect = true;
        ////    grid.ShowPagingBar = true;
        ////    grid.RowIdField = "sscMasterId";
        ////    grid.ThisPage = "RuleAdd.aspx";

        ////    grid.AllowEdit = false;
        ////    grid.GridWidth = 800;

        ////    string sql = "[proc_commissionRuleAdd] @flag =" + grid.FilterString(flag);
        ////    grid.SetComma();

        ////    rpt_grid.InnerHtml = grid.CreateGrid(sql);
        ////}

        ////private void LoadCPGrid(string flag)
        ////{
        ////    grid.FilterList = new List<GridFilter>
        ////                          {
        ////                              new GridFilter("Code", "Code", "LT")
        ////                          };

        ////    grid.ColumnList = new List<GridColumn>
        ////                          {
        ////                              new GridColumn("Code", "Code", "", "T"),
        ////                              new GridColumn("description", "Description", "", "T")
        ////                          };

        ////    grid.GridType = 1;
        ////    grid.GridName = GridName;
        ////    grid.ShowAddButton = false;
        ////    grid.ShowFilterForm = true;
        ////    grid.AlwaysShowFilterForm = false;
        ////    grid.MultiSelect = true;
        ////    grid.ShowPagingBar = true;
        ////    grid.RowIdField = "scPayMasterId";
        ////    grid.ThisPage = "RuleAdd.aspx";

        ////    grid.AllowEdit = false;
        ////    grid.GridWidth = 800;

        ////    string sql = "[proc_commissionRuleAdd] @flag =" + grid.FilterString(flag);
        ////    grid.SetComma();

        ////    rpt_grid.InnerHtml = grid.CreateGrid(sql);
        ////}

        private void LoadGrid(string flag)
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("Code", "Code", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("Code", "Code", "", "T"),
                                      new GridColumn("description", "Description", "", "T")
                                  };

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = false;
            grid.MultiSelect = true;
            grid.ShowCheckBox = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = GetRowIdField(flag);
            grid.ThisPage = "RuleAdd.aspx";

            grid.AllowEdit = false;
            grid.GridWidth = 800;

            string sql = "[proc_commissionRuleAdd] @flag =" + grid.FilterString(flag) + ",@packageId="+GetPackageId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string rsList = grid.GetRowId(GridName);
            DbResult dbResult = _commGrp.AddCommissionRule(GetStatic.GetUser(), GetPackageId().ToString(), rsList, GetFlag());
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);

            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("CommissionPackage.aspx?packageId=" + GetPackageId() + "&type=" + GetType());
            }
            else
            {
                GetStatic.PrintMessage(Page);
                //GetStatic.AlertMessageBox(Page);
            }

        }
    }
}