using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup.EventSetup
{
    public partial class List : Page
    {
        private const string GridName = "grid_countryEvent";
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly CountryDao _obj = new CountryDao();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();

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
            return "Country : " + _swiftLibrary.GetCountryName(GetCountryId().ToString());
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
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
                                   new TabField("State Setup", "../StateSetup/List.aspx" + queryStrings),
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
            _tab.TabList.Add(new TabField("Event", "", true));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("eventName", "Event Name:", "T")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("eventDate", "Event Date", "", "D"),
                                      new GridColumn("eventName", "Event Name", "", "T"),
                                      new GridColumn("eventDesc", "Event Description", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowAddButton = true;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;

            _grid.RowIdField = "rowId";

            _grid.AllowEdit = _swiftLibrary.HasRight(AddEditFunctionId);
            _grid.AllowDelete = _swiftLibrary.HasRight(DeleteFunctionId);

            _grid.AddPage = "Manage.aspx?countryId=" + GetCountryId() + "&opType=" + GetOperationType();

            string sql = "[proc_countryHolidayList] @flag = 's', @countryId = " + GetCountryId();
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.DeleteCountryHoliday(GetStatic.GetUser(), id);
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
                Response.Redirect("List.aspx?countryId=" + GetCountryId());
            }
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}