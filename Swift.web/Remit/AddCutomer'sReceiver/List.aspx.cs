using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AddCutomer_sReceiver
{
    public partial class List : System.Web.UI.Page
    {

        private const string ViewFunctionId = "2019300";
        private const string AddEditFunctionId = "2019310";
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(this);
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            remLibrary.CheckAuthentication(ViewFunctionId);
        }
        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("firstName", "Full Name", "T"),
                                      new GridFilter("country", "Country Name", "T"),
                                      new GridFilter("address", "Address", "T")
                                   
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                       new GridColumn("customerId",  "Customer ID", "", "T"),
                                      new GridColumn("firstName", "Full Name", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("state", "State", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("city", "City", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("Mobile", "Mobile", "", "T"),
                                      new GridColumn("workPhone", "WorkPhone", "", "T"),
                                      new GridColumn("relationship", "Relationship", "", "T")
                                  };

            var allowAddEdit = true;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = "newBankAdd";
            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "receiverId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.InputLabelOnLeftSide = true;
            //  grid.ApproveFunctionId = true;
            //grid.AllowApprove = true;
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;


            string sql = "[proc_online_receiverSetup] @Flag = 's'";
            grid.SetComma();

            rptGrid.InnerHtml = grid.CreateGrid(sql);
        }
    }
}