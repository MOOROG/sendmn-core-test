using Swift.DAL.BL.AgentPanel.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.Utilities.CustomerSetup
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_cs";
        private const string ViewFunctionId = "40132500";
        private const string AddEditFunctionId = "40132510";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CustomerSetupDao cd = new CustomerSetupDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            //Authenticate();
            if (!IsPostBack)
            {
            }
            GetStatic.PrintMessage(Page);
            LoadGrid();
            DeleteRow();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string ddlSql = "EXEC [proc_customerSetup] @flag = 'idType', @country = " + grid.FilterString(GetStatic.GetCountryId());
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("fullName", "Name", "LT"),
                                      new GridFilter("memberId", "Membership Id", "T"),
                                      new GridFilter("customerIdType", "ID Type", "1:" + ddlSql),
                                      new GridFilter("passportNo", "ID Number", "T"),
                                      new GridFilter("mobile", "Mobile", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("companyName", "Company Name", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("idType", "ID Type", "", "T"),
                                      new GridColumn("passportNo", "Id Number", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("nativeCountry", "Native Country", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "DT"),
                                       new GridColumn("lastIdUploadDate","last Id Uploaded Date","","DT")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridWidth = 100;
            grid.IsGridWidthInPercent = true;
            grid.GridMinWidth = 800;
            grid.ShowAddButton = allowAddEdit;
            grid.Downloadable = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Customer";
            grid.RowIdField = "customerId";
            grid.MultiSelect = false;
            grid.InputPerRow = 5;
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = false;
            grid.LoadGridOnFilterOnly = true;
            grid.AddPage = "manage.aspx";
            string sql = "[proc_customerSetup] @flag='s',@country = " + grid.FilterString(GetStatic.GetCountryId()) + "";
            grid.AllowCustomLink = true;
            grid.CustomLinkText = "<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/AgentPanel/Utilities/CustomerSetup/TranHistory.aspx?customerName=@name&idNumber=@passportNo')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" border=0 title = \"View History\" /></a>";
            grid.CustomLinkText += "&nbsp;&nbsp;<a href=\"#\"><img src = \"../../../images/uploadIdImage.gif\" height=\"15px\" border=0 alt = \"Upload Id Image\" title=\"Upload Id Image\" onclick=\"ViewImage('@customerId')\" /></a>";
            grid.CustomLinkVariables = "passportNo,name,customerId";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;

            var dbResult = cd.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
            LoadGrid();
        }

        protected void ManageMessage(DbResult dbResult)
        {
            GetStatic.PrintMessage(Page, dbResult);
        }
    }
}