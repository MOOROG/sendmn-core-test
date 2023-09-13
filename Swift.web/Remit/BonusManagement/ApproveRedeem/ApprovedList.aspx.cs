using Swift.DAL.Remittance.BonusManagement;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.BonusManagement.ApproveRedeem
{
	public partial class ApprovedList : System.Web.UI.Page
	{
		private const string ViewFunctionId = "20821300";
		protected const string GridName = "grd_pReedem";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly RedeemProcessDao _redeemDao = new RedeemProcessDao();

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				Authenticate();
			}
			LoadGrid();
		}

		private void LoadGrid()
		{
			_grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("stat", "Status", "1:EXEC proc_statusLists @flag = 'r_statusNoPending'"),
                                      new GridFilter("userName", "Customer User Name", "LT"),
                                      new GridFilter("agent", "Agent", "LT"),
                                      new GridFilter("award", "Gift", "1:EXEC [proc_dropDownLists2] @flag='ddlgiftItems'"),
                                      new GridFilter("zone", "Zone", "1:EXEC [proc_zoneDistrictMap] @flag='zl_g',@countryId='151'")
                                  };
			_grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("userName", "Customer User Name", "", "T"),
                                      new GridColumn("customerName", "Customer<br>Name", "", "T"),
                                      new GridColumn("redeemedDate", "Redeemed<br>Date", "", "T"),
                                      new GridColumn("agent", "Agent", "", "T"),
                                      new GridColumn("award", "Gift<br>Item", "", "T"),
									  new GridColumn("milageEarned", "Total Bonus<br>Point", "", "T"),
                                      new GridColumn("redeemed", "Redeemed", "", "T"),
                                      new GridColumn("availableBonus", "Bonus<br>Available", "", "T"),
                                      new GridColumn("approvedBy", "Approved<br>By", "", "T"),
                                      new GridColumn("remarks","Remarks","","T"),
                                      new GridColumn("stat","Status","","T"),
                                      new GridColumn("zone","Zone","","T"),
                                  };


			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.ShowFilterForm = true;
			_grid.ShowPagingBar = true;
			_grid.PageSize = 100;
			_grid.GridWidth = 1000;
			_grid.GridMinWidth = 800;
			_grid.RowIdField = "refNo";
			_grid.ThisPage = "ApprovedList";
			_grid.AllowCustomLink = true;
			_grid.AllowDelete = false;
			_grid.InputPerRow = 3;

			_grid.CustomLinkVariables = "refNo,customerId,redeemed,isApproved,ishanded";
			_grid.CustomLinkText = "<input id='btn2' type='button' onclick='openReceipt(@refNo,@customerId)' value='Receipt' style='display:@ishanded' class='btn btn-primary'/>";

			_grid.SetComma();
			string sql = "EXEC proc_bonusRedeemHistoryAdmin @flag='a_r'";
			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}

		private void Authenticate()
		{
			_swiftLibrary.CheckAuthentication(ViewFunctionId);
		}

		protected void btnRejectRedeem_Click(object sender, EventArgs e)
		{
			var dbResult = _redeemDao.Delete(GetStatic.GetUser(), hdnRedeemId.Value);
			GetStatic.SetMessage(dbResult);
			if (dbResult.ErrorCode == "0")
			{
				Response.Redirect("List.aspx");
			}
			else
			{
				GetStatic.PrintMessage(Page);
			}
		}

		protected void btnReceipt_Click(object sender, EventArgs e)
		{
		}
	}
}