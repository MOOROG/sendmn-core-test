using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.CustomerSetup.AgentCustomerSetup.UploadDocuments
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40122000";
        private const string AddEditFunctionId = "40122010";

        private const string GridName = "gridCusUploadAgent";

        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CustomersDao obj = new CustomersDao();
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        #region Method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("searchBy", "Search By",
                                                     "1:EXEC [proc_dropDownLists2] @flag = 'custFilter'","membershipId"),
                                      new GridFilter("searchValue", "Search Value", "LT"),
                                      //new GridFilter("status", "Status",
                                        //  "1:EXEC [proc_dropDownLists2] @flag = 'cust-status'"),
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("membershipId", "Mem. Id", "", "T"),
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D"),
                                      new GridColumn("isApproved1", "Is Approve", "", "T"),
                                      new GridColumn("remarks", "HO-Complain", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridWidth = 800;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Customer";
            grid.RowIdField = "customerId";
            grid.MultiSelect = false;
            grid.InputPerRow = 4;
            grid.CustomLinkVariables = "customerId,membershipId";
            grid.AllowCustomLink = true;
            var customLink = "";
            //if (sl.HasRight(ViewFunctionId))
            //{
            customLink = "<a href='" + GetStatic.GetUrlRoot() + "/Remit/Administration/CustomerSetup/AgentCustomerSetup/UploadDocuments/UploadDocs.aspx?customerId=@customerId'><img src = \"../../../../../images/edit.gif\" border=0 alt = \"Upload\" title=\"Upload Customer Documents\" /></a>";
            //}

            grid.CustomLinkText = customLink;
            string sql = "[proc_customerMasterAgent] @flag='s-docupload'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion Method
    }
}