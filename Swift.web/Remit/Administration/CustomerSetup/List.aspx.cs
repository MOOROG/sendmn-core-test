using Newtonsoft.Json;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.customerSetup {
 public partial class List : Page {
  private const string GridName = "grid_list";
  private const string ViewFunctionId = "20111300";
  private const string AddFunctionId = "20111310";
  private const string EditFunctionId = "20111320";
  private const string ViewDocFunctionId = "20111330";
  private const string UploadDocFunctionId = "20111340";
  private const string ViewKYCFunctionId = "20111350";
  private const string UpdateKYCFunctionId = "20111360";
  private const string ViewBenificiaryFunctionId = "20111370";
  private const string AddBenificiaryFunctionId = "20111380";
  private const string EditBenificiaryFunctionId = "20111390";

  private const string ViewFunctionIdAgent = "40120000";
  private const string AddFunctionIdAgent = "40120010";
  private const string EditFunctionIdAgent = "40120020";
  private const string ViewDocFunctionIdAgent = "40120030";
  private const string UploadDocFunctionIdAgent = "40120040";
  private const string ViewKYCFunctionIdAgent = "40120050";
  private const string UpdateKYCFunctionIdAgent = "40120060";
  private const string ViewBenificiaryFunctionIdAgent = "40120070";
  private const string AddBenificiaryFunctionIdAgent = "40120080";
  private const string EditBenificiaryFunctionIdAgent = "40120090";

  private readonly SwiftGrid _grid = new SwiftGrid();
  private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

  protected void Page_Load(object sender, EventArgs e) {
   if(!IsPostBack) {
    string reqMethod = Request.Form["MethodName"];
    if(string.IsNullOrWhiteSpace(reqMethod)) {

    }
    switch(reqMethod) {
     case "UpdateCustomerRiskLvl":
      UpdateCustomerRiskLvl();
      break;
    }
    GetStatic.PrintMessage(Page);
    Authenticate();
   }
   LoadGrid();
  }

  private void Authenticate() {
   swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
  }

  private void LoadGrid() {
   _grid.FilterList = new List<GridFilter>
                         {
                                     new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'"),
                                     new GridFilter("searchValue", "Search Value", "T"),
                                     new GridFilter("fromDate", "Registered From","d"),
                                     new GridFilter("toDate", "Registered To", "d"),
                                  };

   _grid.ColumnList = new List<GridColumn>
                         {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("membershipId", "Customer Id", "", "T"),
                                      new GridColumn("customerType","Төрөл","","T"),
                                      new GridColumn("userName", "USERNAME", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Name", "", "T"),
                                      new GridColumn("dob", "DOB", "", "D"),
                                      //new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("countryName", "Native Country", "", "T"),
                                      new GridColumn("idtype", "ID Type", "", "T"),
                                      new GridColumn("idNumber", "ID No", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                      new GridColumn("complianceEval","Эрсдэл","","T")
                                      //new GridColumn("bankAccountNo","Account Number","","T")
                                  };

   _grid.GridType = 1;
   _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
   _grid.GridName = GridName;
   _grid.ShowPagingBar = true;
   _grid.ShowAddButton = swiftLibrary.HasRight(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));
   _grid.AllowEdit = swiftLibrary.HasRight(GetFunctionIdByUserType(EditFunctionIdAgent, EditFunctionId));
   _grid.AlwaysShowFilterForm = true;
   _grid.ShowFilterForm = true;
   _grid.SortOrder = "ASC";
   _grid.RowIdField = "customerId";
   _grid.ThisPage = "List.aspx";
   _grid.InputPerRow = 4;
   _grid.GridMinWidth = 700;
   _grid.GridWidth = 100;
   _grid.IsGridWidthInPercent = true;
   _grid.AddPage = "Manage.aspx";
   _grid.AllowCustomLink = true;
   _grid.EnableFilterCookie = false;
   _grid.RowColoredByColValue1 = new string[] { "isLocked:Y:#00FFF7", "complianceEval:high:#fd5e53", "complianceEval:medium:#f1f794" };
   var kycLink = swiftLibrary.HasRight(GetFunctionIdByUserType(ViewKYCFunctionIdAgent, ViewKYCFunctionId)) ? "<span class=\"action-icon\"> <btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Update KYC\"> <a href =\"UpdateKYC.aspx?customerId=@customerId\"><i class=\"fa fa-list\" ></i></a></btn></span>" : "";
   var docLink = swiftLibrary.HasRight(GetFunctionIdByUserType(ViewDocFunctionIdAgent, ViewDocFunctionId)) ? "&nbsp;<span class=\"action-icon\"><btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Document Upload\"><a href=\"CustomerDocument.aspx?customerId=@customerId\"><i class=\"fa fa-file\"></i></a></btn></span>" : "";

   var benificiaryLink = swiftLibrary.HasRight(GetFunctionIdByUserType(ViewBenificiaryFunctionIdAgent, ViewBenificiaryFunctionId)) ? "&nbsp;<span class=\"action-icon\"><btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Beneficiary List\"><a href=\"Benificiar\\List.aspx?customerId=@customerId\"><i class=\"fa fa-subway\"></i></a></btn></span>" : "";

   var docApprove = swiftLibrary.HasRight(GetFunctionIdByUserType(ViewDocFunctionIdAgent, ViewDocFunctionId)) ? "&nbsp;<span class=\"action-icon\"><btn class=\"btn btn-xs btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Document Approve\"><a href=\"#\" onclick=\"ApproveCustomer(@customerId, '"+ GetStatic.GetUser() + "')\"><i class=\"fa fa-check-square-o\"></i></a></btn></span>" : "";

   _grid.CustomLinkText = kycLink + docLink + benificiaryLink + docApprove;
   _grid.CustomLinkVariables = "customerId";
   string sql = "EXEC [proc_online_core_customerSetup] @flag = 's' ";
   _grid.SetComma();

   rpt_grid.InnerHtml = _grid.CreateGrid(sql);
  }

  public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
   return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
  }

  private void UpdateCustomerRiskLvl() {
   string csid = Request.Form["customerId"].ToString();
   string rLvl = Request.Form["riskLvl"].ToString();
   var sql = "update customerMaster set riskLevel = '"+rLvl+"' where membershipid = '"+ csid +"'";
   RemittanceDao swift = new RemittanceDao();
   var dt = swift.ExecuteDataset(sql);

   DbResult Result = new DbResult() {
    ErrorCode = "0",
    Msg = "Updated"
   };
   var jsonString2 = JsonConvert.SerializeObject(Result);
   Response.ContentType = "application/json";
   Response.Write(jsonString2);
   Response.End();
  }
 }
}