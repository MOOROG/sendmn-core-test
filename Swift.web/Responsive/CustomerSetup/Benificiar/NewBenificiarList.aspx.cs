﻿using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.CustomerSetup.Benificiar
{
    public partial class NewBenificiarList : System.Web.UI.Page
    {
        private const string GridName = "newBenificiar_grid";
        private const string ViewFunctionId = "20193010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            swiftLibrary.CheckSession();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                swiftLibrary.CheckAuthentication(ViewFunctionId);
            }
            LoadGrid();
        }
        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("receiverId", "Receiver Name", "a", "", "remit-ReceiverName", true),
                new GridFilter("fromDate", "From Date","d"),
                new GridFilter("toDate", "To Date", "d"),
            };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "S.N.", "", "T"),
                                      new GridColumn("membershipId", "Customer Id", "", "T"),
                                      new GridColumn("fullName", "Sender Name", "", "T"),
                                      new GridColumn("address","Sender Address","","T"),
                                      new GridColumn("mobile", "Sender Mobile", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("receiverAddress", "Receiver Address", "", "T"),
                                      new GridColumn("receiverMobile", "Receiver Mobile", "", "T"),
                                      new GridColumn("receiverCreatedBy", "Created By", "", "T"),
                                      new GridColumn("receiverCreatedDate","Created Date","","D"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "receiverId";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.ShowCheckBox = true;
            _grid.MultiSelect = true;
            _grid.IsGridWidthInPercent = true;
            _grid.CustomLinkVariables = "receiverId,customerId";
            string sql = "EXEC [proc_online_sender_receiver] @flag = 's'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            var receiverIds = Request.Form["newBenificiar_grid_rowId"];
            GetStatic.WriteSession("receiverIds", receiverIds);
            Response.Redirect("NewReceiverPrint.aspx");
        }
    }
}