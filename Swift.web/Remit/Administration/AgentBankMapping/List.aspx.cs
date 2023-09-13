using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.AgentBankMapping
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "gridAgentBankMapping";
        private const string ViewFunctionId = "10122600";
        private const string AddEditFunctionId = "10122610";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.PrintMessage(this);
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                      new GridFilter("bankpartnerId", "Bank Partner ID", "LT")
                                    // , new GridFilter("bankpartnerName", "Bank Partner Name ",
                                    // "1:proc_dropDownLists2 @flag='getAPIBank'")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("bankpartnerName", "Bank Partner Name", "", "T"),
                                       new GridColumn("bankpartnerId", "Bank Partner ID", "", "T"),
                                       new GridColumn("bankName", "Bank Name", "", "T"),
                                       new GridColumn("bankId", "Bank ID ", "", "T"),
                                  // new GridColumn("bankCountry", "Bank Country", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "DT")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.InputPerRow = 4;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Bank Mapping";
            _grid.RowIdField = "rowId";
            _grid.AlwaysShowFilterForm = true;

            // _grid.AllowCustomLink = _sl.HasRight(AddEditFunctionId);

            //_grid.CustomLinkText =
            //    "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Assign Function\"> <a href =\"rolefunction.aspx?roleId=@roleId&roleName=@roleName\"><i class=\"fa fa-cogs\" ></i></a></btn></span>";
            //_grid.CustomLinkVariables = "roleId,roleName";
            _grid.AddPage = "Manage.aspx";
            _grid.ThisPage = "List.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            const string sql = "exec [Proc_AgentBankMapping] @flag = 's'";

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}