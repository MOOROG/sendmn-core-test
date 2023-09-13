using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Xml;

namespace Swift.web.AgentNew.Modify {
  public partial class ModifyTran : System.Web.UI.Page {
    private const string ViewFunctionId = "40101700";
    private const string ProcessFunctionId = "40101710";
    private readonly StaticDataDdl sd = new StaticDataDdl();
    private readonly SwiftGrid _grid = new SwiftGrid();

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
      } else {
        LoadGridView(controlNo.Text, "", "", "", startDate.Text, toDate.Text);
      }
    }
    public void ShowQuestionaireLink() {
      var obj = new TranViewDao();
      DataTable res = obj.QuestionaireExists(GetStatic.GetUser(), ucTran.HoldTranId);
      if (res.Rows.Count > 0) {
        questionaireDiv.Visible = true;
      } else {
        questionaireDiv.Visible = false;
      }
    }

    private void Authenticate() {
      sd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
    }

    protected void btnSearchDetail_Click(object sender, EventArgs e) {
      LoadGridView(controlNo.Text, "", "", "", startDate.Text, toDate.Text, statusDdl.SelectedValue);
    }

    //protected void btnClick_Click(object sender, EventArgs e)
    //{
    //  LoadByControlNo(hdnControlNo.Value, hdnStatus.Value);
    //  LoadGrid();
    //}

    private void LoadGridView(string cNo, string txnId, string searchByText, string serachBy, string fromDate, string toDate, string statusVal = "All") {
      var obj = new TranViewDao();
      if (!string.IsNullOrEmpty(cNo)) {
        fromDate = "";
        toDate = "";
      }
      var ds = obj.DisplayMatchTran(GetStatic.GetUser(), searchByText, serachBy, fromDate, cNo, txnId, toDate, statusVal);

      if (ds == null) {
        divLoadGrid.Visible = false;
        PrintMessage("Transaction not found1!");
        return;
      }

      if (ds.Tables[0].Rows.Count > 0) {
        var dt = ds.Tables[0];
        int cols = dt.Columns.Count;
        DataRow a = dt.Rows[0];
        var str = new StringBuilder("<div class='panel panel-default'><div class='panel-heading' style=\"font-weight: bolder; \">Search Result</div><div class='panel-body'><div class='table-responsive'><table class='table table-bordered' border=\"0\" cellspacing=0 cellpadding=\"3\"></div></div>");
        str.Append("<tr>");
        for (int i = 0; i < cols; i++) {
          str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
        }
        str.Append("</tr>");
        foreach (DataRow dr in dt.Rows) {
          str.Append("<tr>");
          for (int i = 0; i < cols; i++) {
            str.Append("<td align=\"left\">" + dr[i].ToString() + "</td>");
          }
          str.Append("</tr>");
        }
        str.Append("</table></div></fieldset>");
        divLoadGrid.Visible = true;
        divLoadGrid.InnerHtml = str.ToString();
      }
    }

    private void LoadByControlNo(string cNo, string tranStatus) {
      if (sd.HasRight(ProcessFunctionId) && tranStatus == "Payment")
        ucTran.SearchData("", cNo, "u", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");
      else
        ucTran.SearchData("", cNo, "", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");

      if (!ucTran.TranFound) {
        PrintMessage("Transaction not found2!");
        return;
      }

      divTranDetails.Visible = ucTran.TranFound;
      divSearch.Visible = !ucTran.TranFound;
      ShowQuestionaireLink();
    }

    private void LoadByControlNo(string cNo) {
      if (sd.HasRight(ProcessFunctionId))
        ucTran.SearchData("", cNo, "u", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");
      else
        ucTran.SearchData("", cNo, "", "", "SEARCH", "AGT: VIEW TXN (SEARCH TRANSACTION)");

      if (!ucTran.TranFound) {
        PrintMessage("Transaction not found3!");
        return;
      }

      if (ucTran.TranStatus != "Payment") {
        string status = ucTran.TranStatus;
        divTranDetails.Visible = false;
        PrintMessage("Transaction not authorised for modification; Status:" + status + "!");
        return;
      }

      /*
      var createdBy = ucTran.CreatedBy;
      if (GetStatic.GetUser() != createdBy)
      {
          GetStatic.AlertMessage(Page, "You are not authorized to view this transaction");
          return;
      }
       * */
      divTranDetails.Visible = ucTran.TranFound;
      divSearch.Visible = !ucTran.TranFound;
    }

    private void PrintMessage(string msg) {
      GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
    }

    protected void btnReloadDetail_Click(object sender, EventArgs e) {
      LoadByControlNo(ucTran.CtrlNo);
    }
    private void LoadGrid() {
      _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("QUES_ID", "SN", "", "T"),
                                      new GridColumn("QSN", "Name", "Question", "T"),
                                      new GridColumn("ANSWER_TEXT", "Answer", "", "T")
                                  };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.AllowEdit = false;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "QUES_ID";
      _grid.DisableSorting = true;
      _grid.ThisPage = "ModifyTran.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      //_grid.AllowApprove = swiftLibrary.HasRight(ApproveFunctionId);
      string sql = "EXEC [proc_transactionView] @flag = 's-QuestionaireAnswer',@holdTranId='" + ucTran.HoldTranId + "'";
      _grid.SetComma();

      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }
  }
}