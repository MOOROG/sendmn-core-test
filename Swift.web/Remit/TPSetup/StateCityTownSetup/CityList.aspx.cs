using Swift.API.Common.SyncModel;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.Remittance.SyncDao;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.StateCityTownSetup
{
	public partial class CityList : System.Web.UI.Page
	{
		private const string GridName = "grid_list";
		private const string ViewFunctionId = "20600000";
		private const string AddEditFunctionId = "20600010";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				GetStatic.PrintMessage(Page);
				Authenticate();
				
			}
			LoadGrid();

		}
		public string GetStateCode()
		{
			return GetStatic.ReadQueryString("stateCode", "");
		}
		public string GetStateId()
		{
			return GetStatic.ReadQueryString("stateRowId", "");
			
		}
		public string GetCountryName()
		{
			return GetStatic.ReadQueryString("country", "");
		}
		public string GetApiPartner()
		{
			return GetStatic.ReadQueryString("apiPartner", "");
		}
		private void Authenticate()
		{
			swiftLibrary.CheckAuthentication(ViewFunctionId);
		}

		private void LoadGrid()
		{
			_grid.FilterList = new List<GridFilter>
								  {
									 new GridFilter("CITY_NAME", "CITY NAME", "T"),
								  };

			_grid.ColumnList = new List<GridColumn>
								  {
									  new GridColumn("SN", "SN", "", "T"),
									  new GridColumn("CITY_ID", "CITY_ID", "", "T"),
									  new GridColumn("CITY_NAME", "CITY NAME", "100", "T"),
									  new GridColumn("CITY_CODE", "CITY CODE", "", "T"),
									  new GridColumn("CITY_COUNTRY", "CITY COUNTRY", "", "T"),
									  new GridColumn("IS_ACTIVE", "IS ACTIVE", "", "T"),
									  new GridColumn("PAYMENT_TYPE", "PAYMENT TYPE", "", "T"),
								  };

			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.ShowPagingBar = true;
			_grid.ShowAddButton = false;
			_grid.AllowEdit = false;
			_grid.AllowDelete = false;
			_grid.AddPage = "AddApiPartner.aspx";
			_grid.AlwaysShowFilterForm = true;
			_grid.ShowFilterForm = true;
			_grid.AllowCustomLink = true;
			_grid.SortOrder = "ASC";
			_grid.RowIdField = "CITY_ID";
			_grid.ThisPage = "CityList.aspx";


			var townLink = "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Town\"> <a href =\"TownList.aspx?cityrowId=@CITY_ID\"><i class=\"fa fa-industry\" ></i></a></btn></span>";
			var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@CITY_ID','@CITY_NAME','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";
			_grid.CustomLinkVariables = "CITY_ID,CITY_NAME,IS_ACTIVE";
			_grid.CustomLinkText = townLink + link;
			_grid.InputPerRow = 5;

			string sql = "EXEC [PROC_API_STATE_SETUP] @flag = 'S-City',@stateId='"+ GetStateId()+"'";

			_grid.SetComma();

			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}

		protected void btnUpdate_Click(object sender, EventArgs e)
		{
			StateCityTownDao _dao = new StateCityTownDao();
			if (!string.IsNullOrEmpty(isActive.Value))
			{
				var dbResult = _dao.EnableDisableCity(rowId.Value, GetStatic.GetUser(), isActive.Value);
				GetStatic.SetMessage(dbResult);
				Response.Redirect("CityList.aspx?stateId=" + GetStateCode() + "");
			}
		}
		private string GetStateRowId()
		{
			return GetStatic.ReadQueryString("stateRowId","");
		}
		private DataRow GetDetailsOfState(string stateRowId)
		{
			StateCityTownDao _dao = new StateCityTownDao();
			return _dao.GetDetailsOfState(GetStateRowId(),GetStatic.GetUser());
		}

		protected void btnSyncCity_Click(object sender, EventArgs e)
		{
			DataRow DetailsOfSate = GetDetailsOfState(GetStateRowId());
			AddressRequest requestObj = new AddressRequest()
			{
				CountryIsoCode = DetailsOfSate["countryCode"].ToString(),
				ProviderId = GetApiPartner(),
				MethodType = "city",
				StateId = GetStateCode()

			};

			SyncStateCityTownService serviceObj = new SyncStateCityTownService();
			var response = serviceObj.GetAddressList(requestObj);
			DbResult res = new DbResult();
			if (response.ResponseCode == "0")
			{
				BankBranchDao _dao = new BankBranchDao();
				var responseData = response.Data;
				var xml = ApiUtility.ObjectToXML(responseData);
				res = _dao.SyncCity(GetStatic.GetUser(), xml, DetailsOfSate["countryName"].ToString(),DetailsOfSate["STATE_ID"].ToString());
				
				if (res.ErrorCode == "0")
				{
					GetStatic.AlertMessage(this, res.Msg);
					Page_Load(this , EventArgs.Empty );
				}
				else
				{
					GetStatic.AlertMessage(this, "Bank Sycn Failed!!!!");
				}

			}
			else
			{
				GetStatic.AlertMessage(this, response.Msg);
			}

		}
	}
}