using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.OFACManagement.ManualComplianceSetup
{
    public partial class List : System.Web.UI.Page
    {
        private readonly string ViewFunctionId = "20601400";
        private const string GridName = "grd_bldom";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                    new GridFilter("Name","Name","T"),
                                    new GridFilter("ofacKey","Compliance Key","T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("ofacKey", "Compliance Key", "", "T"),
                                      new GridColumn("Name", "Name", "", "T"),
                                      new GridColumn("Address", "Address", "", "T"),
                                      //new GridColumn("District", "district", "", "T"),
                                      new GridColumn("IdType", "Id Type", "", "T"),
                                      new GridColumn("IdNumber", "Id Number", "", "T"),
                                      new GridColumn("isActive", "Is Active", "", "T"),                                      
                                      new GridColumn("createdDate", "Created Date", "", "z"),
                                      new GridColumn("createdBy", "Created By", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(ViewFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "rowId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.AlwaysShowFilterForm = true;
       //     grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = false;

            string sql = "EXEC proc_blacklistDomestic @flag = 'a'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}