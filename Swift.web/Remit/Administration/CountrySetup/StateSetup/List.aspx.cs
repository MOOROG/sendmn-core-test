using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup.StateSetup
{
    public partial class List : Page
    {
        private const string GridName = "grid_states";
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly StateDao obj = new StateDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        protected string GetCountryName()
        {
            return "Country :  " + swiftLibrary.GetCountryName(GetCountryId().ToString());
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            GenerateState();
        }

        #region method

        private void LoadTab()
        {
            var countryId = GetCountryId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "../Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "", true),
                                   new TabField("Allowed Currency", "../CountryCurrency.aspx" + queryStrings),
                                   new TabField("Mobile Format", "../MobileFormat.aspx" + queryStrings),
                                   new TabField("Valid ID Setup", "../CountryIdSetup.aspx" + queryStrings),
                               };
            switch (opType)
            {
                case "B":
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "../EventSetup/List.aspx" + queryStrings));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("stateCode", "State Code:", "T"),
                                      new GridFilter("stateName", "State Name:", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("stateCode", "State Code", "", "T"),
                                      new GridColumn("stateName", "State Name", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;

            grid.RowIdField = "stateId";

            grid.AllowEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            grid.AddPage = "Manage.aspx?countryId=" + GetCountryId() + "&opType=" + GetOperationType();

            string sql = "[proc_countryStateMaster] @flag = 's', @countryId = " + GetCountryId();
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
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx?countryId=" + GetCountryId() + "&opType=" + GetOperationType());
            }
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void GenerateState()
        {
            DbResult dbResult = obj.UpdateState(GetStatic.GetUser(), GetCountryId().ToString());
            ManageMessage(dbResult);
        }

        #endregion method
    }
}