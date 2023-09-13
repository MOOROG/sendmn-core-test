using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.Bonus_Management
{
	public partial class RedeemRequestList : System.Web.UI.Page
	{
		protected const string GridName = "grid_Redeem";
		private const string ViewFunctionId = "40122500";
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly BonusManagementDao _redeemDao = new BonusManagementDao();
		private readonly SwiftGrid _grid = new SwiftGrid();
		protected void Page_Load(object sender, EventArgs e)
		{
			Authenticate();
			LoadGrid();
		}

		private void Authenticate()
		{
			_swiftLibrary.CheckAuthentication(ViewFunctionId);
		}

		private void LoadGrid()
		{
			var dbResult = GetStatic.GetMessage();
			if (dbResult != null)
			{
				if (dbResult.Msg != null || dbResult.Msg != "")
				{
					GetStatic.PrintSuccessMessage(this, dbResult.Msg);
					DbResult dbres = new DbResult();
					dbres.Msg = "";
					GetStatic.SetMessage(dbres);
				}
			}
			_grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("stat", "Status", "1:EXEC proc_statusLists @flag = 'redeemStatus'"),
                                      new GridFilter("userName", "Customer User Name(Email)", "LT"),
                                      new GridFilter("agent", "Agent", "LT")
                                  };
			_grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("userName", "Customer User Name<br>ID", "", "T"),
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
                                  };


			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.ShowFilterForm = true;
			_grid.ShowPagingBar = true;
			_grid.PageSize = 50;
			_grid.GridWidth = 800;
			_grid.GridMinWidth = 800;
			_grid.RowIdField = "refNo";
			_grid.ThisPage = "RedeemRequest";
			_grid.AllowCustomLink = true;
			_grid.AllowDelete = false;
			_grid.InputPerRow = 3;

			_grid.CustomLinkVariables = "refNo,customerId,redeemed,isApproved,ishanded,award";
			_grid.CustomLinkText = "<input id='btn1' type='button' value='Gift Handover' onclick='giftHandedOver(@refNo,@customerId)' style='display:@isApproved' class='btn btn-primary'/><input id='btn2' type='button' value='Receipt' onclick='openReceipt(@refNo,@customerId)' style='display:@ishanded' class='btn btn-primary'/>";

			_grid.SetComma();
			string sql = "EXEC [proc_bonusRedeemHistoryAdmin] @flag='status'";
			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}

		protected void btnHandedOver_Click(object sender, EventArgs e)
		{
			string redeemId = hdnRedeemId.Value;
			string customerId = hdnCustomerId.Value;

			var dbRes = _redeemDao.GiftHandedOver(redeemId, customerId, GetStatic.GetUser());

			if (dbRes.ErrorCode.Equals("0"))
			{
				GetStatic.PrintSuccessMessage(this, dbRes.Msg);
				LoadGrid();
			}
		}
	}
}