using Swift.DAL.Remittance;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Swift.web.Component.Grid {
  public class SwiftGrid : GridDao {
    private ArrayList CheckBoxIds;
    private bool IdsAreParsed = false;

    public enum GridDS {
      AccountDB = 0,
      RemittanceDB = 1,
      LogDb = 2
    };
    #region Loan State Color table
    Dictionary<string, string> loanStateColor = new Dictionary<string, string> {
      {"Төлсөн","#00C864"},
      {"Төлөгдөөгүй","#83898A"},
      {"Хаагдсан","#1770D8"},
      {"Цуцлагдсан","#E02424"},
      {"Батлагдсан","#00C864"},
      {"Хүлээгдэж байгаа","#FD891E"},
      {"Шинэ","#A815DC"}
    };
    #endregion
    #region Properties

    public bool EncodeJSInData = false;
    ////private string _extraConn="";
    ////public string ExtraConn
    ////{
    ////    set { _extraConn = value; }
    ////    get { return _extraConn; }
    ////}

    public string AddButtonCallBack { get; set; }
    public bool EnableProcessBar = false;

    private bool _hasFilter;

    private int _gridWidth = 700;

    public int GridWidth {
      set { _gridWidth = value; }
      get { return _gridWidth; }
    }

    private bool _isGridWidthInPercent;

    public bool IsGridWidthInPercent {
      set { _isGridWidthInPercent = value; }
      get { return _isGridWidthInPercent; }
    }

    private int _gridHeight = -1;

    public int GridHeight {
      set { _gridHeight = value; }
      get { return _gridHeight; }
    }

    private int _gridMinWidth = 700;

    public int GridMinWidth {
      set { _gridMinWidth = value; }
      get { return _gridMinWidth; }
    }

    private string _gridName = "";

    public string GridName {
      set { _gridName = value; }
      get { return _gridName; }
    }

    private Boolean _showFilterForm;

    public Boolean ShowFilterForm {
      set { _showFilterForm = value; }
      get { return _showFilterForm; }
    }

    private Boolean _alwaysShowFilterForm = true;

    public Boolean AlwaysShowFilterForm {
      set { _alwaysShowFilterForm = value; }
      get { return _alwaysShowFilterForm; }
    }

    private Boolean _showPagingBar;

    public Boolean ShowPagingBar {
      set { _showPagingBar = value; }
      get { return _showPagingBar; }
    }

    private Boolean _showAddButton;

    public Boolean ShowAddButton {
      set { _showAddButton = value; }
      get { return _showAddButton; }
    }

    private Boolean _showPopUpWindowOnAddButtonClick;

    public Boolean ShowPopUpWindowOnAddButtonClick {
      set { _showPopUpWindowOnAddButtonClick = value; }
      get { return _showPopUpWindowOnAddButtonClick; }
    }

    private string _addButtonTitleText;

    public string AddButtonTitleText {
      set { _addButtonTitleText = value; }
      get { return _addButtonTitleText; }
    }

    private string _addPage;

    public string AddPage {
      set { _addPage = value; }
      get { return _addPage; }
    }

    private string _thisPage;

    public string ThisPage {
      set { _thisPage = value; }
      get { return _thisPage; }
    }

    private string _rootDir = "";

    public string RootDir {
      set { _rootDir = value; }
      get { return _rootDir; }
    }

    private string _callBackFunction = "";

    public string CallBackFunction {
      set { _callBackFunction = value; }
      get { return _callBackFunction; }
    }

    private Boolean _downlodable = true;

    public Boolean Downloadable {
      get { return _downlodable; }
      set { _downlodable = value; }
    }

    private Boolean _enablePdfDownload = true;

    public Boolean EnablePdfDownload {
      get { return _enablePdfDownload; }
      set { _enablePdfDownload = value; }
    }

    private Boolean _landscapeMode = true;

    public Boolean LandscapeMode {
      get { return _landscapeMode; }
      set { _landscapeMode = value; }
    }

    private int _pageSize;

    public int PageSize {
      get { return _pageSize; }
      set { _pageSize = value; }
    }

    private string[] _rowColoredByColValue1;

    public string[] RowColoredByColValue1 {
      get { return _rowColoredByColValue1; }
      set { _rowColoredByColValue1 = value; }
    }

    private string _rowColoredByColValue;

    public string RowColoredByColValue {
      get { return _rowColoredByColValue; }
      set { _rowColoredByColValue = value; }
    }

    private string[] _cellColoredByCellValue;

    public string[] CellColoredByCellValue {
      get { return _cellColoredByCellValue; }
      set { _cellColoredByCellValue = value; }
    }
    private int _pageNumber;

    public int PageNumber {
      get { return _pageNumber; }
      set { _pageNumber = value; }
    }

    private string _sortOrder;

    public string SortOrder {
      get { return _sortOrder == "" ? "ASC" : _sortOrder; }
      set { _sortOrder = value; }
    }

    private string _sortBy = "";

    public string SortBy {
      get { return _sortBy == "" ? RowIdField : _sortBy; }
      set { _sortBy = value; }
    }

    public bool LoadGridOnFilterOnly { get; set; }

    private bool _enableCookie = true;

    public bool EnableCookie {
      set { _enableCookie = value; }
      get { return _enableCookie; }
    }

    private bool _enableFilterCookie = true;

    public bool EnableFilterCookie {
      set { _enableFilterCookie = value; }
      get { return _enableFilterCookie; }
    }

    private string _uploadPage = "";

    public string UploadPage {
      set { _uploadPage = value; }
      get { return _uploadPage; }
    }

    private string _comma = "";

    public void SetComma() {
      _comma = ",";
    }

    private string _rowIdField;

    public string RowIdField {
      set { _rowIdField = value; }
      get { return _rowIdField ?? ""; }
    }

    private Boolean _showFilterLabel;

    public Boolean ShowFilterLabel {
      set { _showFilterLabel = true; }
      get { return _showFilterLabel; }
    }

    private string _showFilterLabelText;

    public string ShowFilterLabelText {
      set { _showFilterLabelText = value; }
      get { return _showFilterLabelText; }
    }

    private bool _enableToolTip;

    public bool EnableToolTip {
      set { _enableToolTip = value; }
      get { return _enableToolTip; }
    }

    private string _toolTipField;

    public string ToolTipField {
      set { _toolTipField = value; }
      get { return _toolTipField ?? ""; }
    }

    private string _fileType;

    public string FileType {
      set { _fileType = value; }
      get { return _fileType ?? ""; }
    }

    private Boolean _multiSelect;

    public Boolean MultiSelect {
      set { _multiSelect = value; }
      get { return _multiSelect; }
    }

    private Boolean _disableAuditWindow = false;

    public Boolean DisableAuditWindow {
      set { _disableAuditWindow = value; }
      get { return _disableAuditWindow; }
    }

    private Boolean _allowApprove;

    public Boolean AllowApprove {
      set { _allowApprove = value; }
      get { return _allowApprove; }
    }

    //private string _approveText = "<img alt = \"View Changes\" border = \"0\" title = \"View Changes\" src=\"" + GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" /> ";
    private string _approveText = "<span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"View Changes\">  <i class=\"fa fa-eye\"></i></btn></span>";

    public string ApproveText {
      set { _approveText = value; }
      get { return _approveText; }
    }

    private string _viewFunctionId = "";

    public string ViewFunctionId {
      set { _viewFunctionId = value; }
      get { return _viewFunctionId; }
    }

    private string _approveFunctionId = "";

    public string ApproveFunctionId {
      set { _approveFunctionId = value; }
      get { return _approveFunctionId; }
    }

    private string _approveFunctionId2 = "";

    public string ApproveFunctionId2 {
      set { _approveFunctionId2 = value; }
      get { return _approveFunctionId2; }
    }

    private string _popUpParam = "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes";

    public string PopUpParam {
      set { _popUpParam = value; }
      get { return _popUpParam; }
    }

    //PopUp

    private Boolean _allowEdit;

    public Boolean AllowEdit {
      set { _allowEdit = value; }
      get { return _allowEdit; }
    }

    //private string _editText = "<img class = \"showHand\" border = \"0\" title = \"Edit\" src=\"" + GetStatic.GetUrlRoot() + "/images/edit.gif\" />";
    private string _editText = "<span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\">  <i class=\"fa fa-pencil\"></i></btn></span>";

    public string EditText {
      set { _editText = value; }
      get { return _editText; }
    }

    private Boolean _allowDelete;

    public Boolean AllowDelete {
      set { _allowDelete = value; }
      get { return _allowDelete; }
    }

    //private string _deleteText = "<img class = \"showHand\" border = \"0\" title = \"Delete\" src=\"" + GetStatic.GetUrlRoot() + "/images/delete.gif\" />";
    private string _deleteText = "<span class=\"action-icon\"><btn class=\"btn btn-xs btn-danger\" data-toggle=\"tooltip\" data-placement=\"top\" title = \"Delete\">  <i class=\"fa fa-trash\"></i></btn></span>";

    public string DeleteText {
      set { _deleteText = value; }
      get { return _deleteText; }
    }

    private string _deleteAlertText = "Are you sure to delete selected record?";

    public string DeleteAlertText {
      set { _deleteAlertText = value; }
      get { return _deleteAlertText; }
    }

    private Boolean _allowCustomLink;

    public Boolean AllowCustomLink {
      set { _allowCustomLink = value; }
      get { return _allowCustomLink; }
    }

    private string _customLinkText = "";

    public string CustomLinkText {
      set { _customLinkText = value; }
      get { return _customLinkText; }
    }

    private Boolean _allowCustomLink1;

    public Boolean AllowCustomLink1 {
      set { _allowCustomLink1 = value; }
      get { return _allowCustomLink1; }
    }

    private string _customLinkText1 = "";

    public string CustomLinkText1 {
      set { _customLinkText1 = value; }
      get { return _customLinkText1; }
    }

    private string _customLinkVariables = "";

    public string CustomLinkVariables {
      set { _customLinkVariables = value; }
      get { return _customLinkVariables; }
    }

    private Boolean _showCheckBox;

    public Boolean ShowCheckBox {
      set { _showCheckBox = value; }
      get { return _showCheckBox; }
    }

    private int _inputPerRow = 1;

    public int InputPerRow {
      set { _inputPerRow = value; }
      get { return _inputPerRow; }
    }

    private bool _inputLabelOnLeftSide;

    public bool InputLabelOnLeftSide {
      set { _inputLabelOnLeftSide = value; }
      get { return _inputLabelOnLeftSide; }
    }

    //Added By Bijay
    private bool _allowFileView;

    public bool AllowFileView {
      set { _allowFileView = value; }
      get { return _allowFileView; }
    }

    private bool _allowGridFieldEdit;

    public bool AllowGridFieldEdit {
      set { _allowGridFieldEdit = value; }
      get { return _allowGridFieldEdit; }
    }

    private int _gridType = 2;

    public int GridType {
      set { _gridType = value; }
      get { return _gridType; }
    }

    private List<GridColumn> _columnList;

    public List<GridColumn> ColumnList {
      set { _columnList = value; }
      get { return _columnList; }
    }

    private List<GridFilter> _filterList;

    public List<GridFilter> FilterList {
      set { _filterList = value; }
      get { return _filterList; }
    }

    private bool _verifyMode;

    public Boolean VerifyMode {
      set { _verifyMode = value; }
      get { return _verifyMode; }
    }

    private int _fixePageSizeTo;

    public int FixePageSizeTo {
      set { _fixePageSizeTo = value; }
      get { return _fixePageSizeTo; }
    }

    private bool _disableSorting;

    public Boolean DisableSorting {
      set { _disableSorting = value; }
      get { return _disableSorting; }
    }

    private bool _disableJsFilter;

    public Boolean DisableJsFilter {
      set { _disableJsFilter = value; }
      get { return _disableJsFilter; }
    }

    private string _totalFields = "";

    public string TotalFields {
      get { return _totalFields; }
      set { _totalFields = value; }
    }

    private int _totalFieldCol;

    public int TotalFieldCol {
      get { return _totalFieldCol; }
      set { _totalFieldCol = value; }
    }

    private string _editCallBackFunction;

    public string EditCallBackFunction {
      set { _editCallBackFunction = value; }
      get { return _editCallBackFunction; }
    }

    private string _selectionCheckBoxList = "";

    public string SelectionCheckBoxList {
      set { _selectionCheckBoxList = value; }
      get { return _selectionCheckBoxList; }
    }

    public bool AllowRowDisable { get; set; }
    public String DisabledRowValueSourceField { get; set; }

    #endregion Properties

    #region Public Methods

    public GridDS GridDataSource { get; set; }

    public SwiftGrid() {
      LoadGridOnFilterOnly = false;
      PageSize = 10;
      PageNumber = 1;
      SortOrder = "";
    }

    public string CreateGrid(string sql, string whichDb = "") {
      if (GetStatic.GetUser() == "")
        HttpContext.Current.Response.Redirect(GetStatic.GetLogoutPage());
      LoadVariables();
      var executeSql = "";

      var fileterSql = GetFilterSql();
      switch (GridType) {
        case 1: {
            //Based On SP
            executeSql = sql + fileterSql;
          }
          break;

        case 2: {
            //Based On Sql Statement
            var sqlHeader = "SELECT COUNT_BIG(*) totalRow FROM (" + sql + ") x WHERE 1 = 1 " + fileterSql;
            var sqlBody = "SELECT x.* FROM (SELECT x.*, ROW_NUMBER() OVER(ORDER BY " + SortBy + " " + SortOrder +
                          ") rowNumberId FROM (" + sql + ") x WHERE 1 = 1 " + fileterSql + ") x";
            sqlBody = sqlBody + " WHERE rowNumberId BETWEEN " + ((PageNumber - 1) * PageSize + 1) + " AND " +
                      (PageNumber * PageSize);

            executeSql = sqlHeader + ";" + sqlBody;
          }
          break;
      }

      ArrayList gridSource;

      if (GridDS.RemittanceDB == GridDataSource) {
        var RemitGridDao = new RemittanceGridDao();
        gridSource = RemitGridDao.GetGridDataSource(executeSql, _hasFilter, LoadGridOnFilterOnly);
      } else if (GridDS.LogDb == GridDataSource) {
        var logDbGridDao = new LogDbGridDao();
        gridSource = logDbGridDao.GetGridDataSource(executeSql, _hasFilter, LoadGridOnFilterOnly);
      } else {
        gridSource = GetGridDataSource(executeSql, _hasFilter, LoadGridOnFilterOnly);
      }

      //gridSource = GetGridDataSource(executeSql, _hasFilter, LoadGridOnFilterOnly);

      HttpContext.Current.Session["exportSource"] = executeSql;
      HttpContext.Current.Session["grid_column"] = ColumnList;

      var totalRecord = Convert.ToInt32(gridSource[0].ToString());
      var totalPage = totalRecord / PageSize;
      if ((totalPage * PageSize) < totalRecord)
        totalPage++;

      //var sortFunctionTmp = "SortGrid('" + GridName + "', '{sort_by}', '{sort_order}')";
      var sortFunctionTmp = "SortGrid('" + GridName + "', '{sort_by}', '{sort_order}'" + ShowProcessBar() + ")";
      string sortFunction;
      double total = 0.0;

      var html = new StringBuilder("");
      if (GridHeight > -1) {
        html.AppendLine("<div style = \"height: " + GridHeight + "px;overflow: auto;\">");
      }
      var minWidth = "style=\"min-width: " + GridMinWidth + "px;\"";
      html.AppendLine("<div class='table-responsive'>");
      html.AppendLine("<table class=\"table table-bordered table-striped table-condensed table-scroll\" id =\"" + GridName + "_body\">");

      html.AppendLine("<tr>");
      var cssClass = "";
      if (AllowCustomLink1) {
        html.AppendLine("<th></th>");
      }
      if (ShowCheckBox) {
        var headerFuntion = "SelectAll(this, '" + GridName + "'," + (MultiSelect ? "true" : "false") + ");" + CallBackFunction;
        html.AppendLine("<th onclick =\"" + headerFuntion + "\">" + (MultiSelect ? "√" : "×") + "</th>");
      }
      var colIndex = -1;
      foreach (var column in ColumnList) {
        var width = "";
        cssClass = "hdtitle";

        if ((column.Width) != "")
          width = "style= \"min-width : " + (column.Width) + "px;\"";

        if (column.Type.ToLower() == "nosort") {
          html.AppendLine("<th align=\"left\" nowrap = \"nowrap\" " + width + ">" + column.Description + "</th>");
        } else {
          var sortIcon = "";
          var sortText = "<span style = \"float:left\"><b>" + column.Description + "</b></span>";
          var filterText = "";
          if (!DisableSorting) {
            if (column.Key.ToLower() == SortBy.ToLower()) {
              sortFunction = sortFunctionTmp.Replace("{sort_order}", ReverseSortOrder(SortOrder));
              sortIcon = "<img border= \"0\" src =\"" +
                         (SortOrder.ToLower() == "asc"
                              ? "" + GetStatic.GetUrlRoot() + "/images/sortup.gif"
                              : "" + GetStatic.GetUrlRoot() + "/images/sortdn.gif") + "\" /> ";
              cssClass = "sortAsc";
            } else {
              sortFunction = sortFunctionTmp.Replace("{sort_order}", "asc");
              cssClass = "";
            }

            sortFunction = sortFunction.Replace("{sort_by}", column.Key);
            sortText = "<span title =\"Sort\" style = \"cursor:pointer;float:left\" onclick =\"" + sortFunction + "\">" +
                       column.Description + "&nbsp;" + sortIcon + "</span>";
          }

          if (!DisableJsFilter) {
            var filterFunction = "ShowFilter(this, '" + GridName + "', " + (++colIndex + (ShowCheckBox ? 1 : 0)) + ");";
            if (DisableSorting) {
              sortText = "<span style = \"float:left;cursor:pointer;width:100%\" onclick =\"" + filterFunction + "\"><b>" + column.Description + "</b></span>";
              filterText = "";
            } else {
              filterText = DisableSorting
                               ? ""
                               : "<br />" +
                                 "<span title =\"Filter\" style = \"clear:both;cursor:pointer;width:50px;float:right\" onclick =\"" +
                                 filterFunction + "\">&nbsp;</span>";
            }
          }

          html.AppendLine("<th  Class=\"" + cssClass + "\" align=\"left\" " + width + ">" + sortText + filterText + "</th>");
        }
      }
      if (AllowEdit || AllowDelete || AllowCustomLink || AllowApprove || AllowFileView) {
        html.AppendLine("<th Class=\"" + cssClass + "\" nowrap = \"nowrap\">&nbsp;</th>");
      }
      html.AppendLine("</tr>");

      var cnt = 0;
      var checkBoxFunction = "";

      if (ShowCheckBox) {
        checkBoxFunction = "ManageSelection(this, '" + GridName + "'," + (MultiSelect ? "true" : "false") + ");" +
                           CallBackFunction;
      }
      if (LoadGridOnFilterOnly && !_hasFilter) {
      } else {
        foreach (var row in (List<Hashtable>)gridSource[1]) {
          var editDeleteId = row[RowIdField.ToLower()].ToString();
          if (EnableToolTip) {
            var toolTipMsg = row[ToolTipField].ToString();
            html.AppendLine(++cnt % 2 == 1

                                ? "<tr title=\"" + toolTipMsg +
                                  "\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                : "<tr  title=\"" + toolTipMsg +
                                  "\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
          } else {
            if (null != _rowColoredByColValue1 && _rowColoredByColValue1.Length > 0) {
              string[] colNval;
              string col = "";
              string val = "";
              string colorValue = "";

              for (int i = 0; i < _rowColoredByColValue1.Length; i++) {
                colNval = _rowColoredByColValue1[i].Split(':');

                col = row[colNval[0].ToLower().Trim()].ToString();
                val = colNval[1].Trim();
                colorValue = colNval[2];
                if (col.ToLower() == val.ToLower())
                  break;
              }

              if (col.ToLower() == val.ToLower()) {
                html.AppendLine("<tr  style=\"background-color:" + colorValue + "\" >");
              } else {
                html.AppendLine(++cnt % 2 == 1

                            ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                            : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
              }
            } else if (!string.IsNullOrWhiteSpace(_rowColoredByColValue)) {
              string[] colNval = _rowColoredByColValue.Split(':');
              string col = row[colNval[0].ToLower().Trim()].ToString();
              string val = colNval[1].Trim();
              if (col.ToLower() == val.ToLower()) {
                html.AppendLine("<tr onMouseOver=\"this.className='GridbgOndemandRowOver'\" onMouseOut=\"this.className='bgOndemand'\" >");
              } else {
                html.AppendLine(++cnt % 2 == 1

                            ? "<tr onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                            : "<tr onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
              }
            } else {
              html.AppendLine(++cnt % 2 == 1

                          ? "<tr onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                          : "<tr onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
            }
          }
          if (AllowCustomLink1) {
            var customLinkVariableList = CustomLinkVariables.Split(',');
            var parsedCustomLinkText = CustomLinkText1;
            foreach (var variable in customLinkVariableList) {
              parsedCustomLinkText = parsedCustomLinkText.Replace("@" + variable,
                                                                  row[variable.ToLower().Trim()].ToString());
            }
            html.AppendLine("<td>" + parsedCustomLinkText + "</td>");
          }
          var disabled = "";
          if (AllowRowDisable) {
            if (!string.IsNullOrWhiteSpace(DisabledRowValueSourceField)) {
              if (row[DisabledRowValueSourceField.ToLower()].ToString() == "1") {
                disabled = "disabled";
              }
            }
          }
          if (ShowCheckBox) {
            if (AllowRowDisable) {
              if (row[DisabledRowValueSourceField.ToLower()].ToString() == "1") {
                disabled = "disabled";
              }
            }
            if (disabled == "") {
              html.AppendLine("<td align=\"center\"><input type = \"checkbox\" value = \"" + editDeleteId +
                              "\" name =\"" + GridName + "_rowId\" onclick = \"" + checkBoxFunction + "\" " +
                              AppendChkBoxProperties(editDeleteId) + " " + disabled + "></td>");
            } else {
              html.AppendLine("<td>&nbsp;</td>");
            }
          }
          if (!string.IsNullOrEmpty(TotalFields)) {
            total += Convert.ToDouble(row[TotalFields.ToLower()]);
          }
          foreach (var column in ColumnList) {
            var data = row[column.Key.ToLower()].ToString();
            if (EncodeJSInData) {
              data = HttpUtility.JavaScriptStringEncode(data);
            }
            switch (column.Type.ToUpper()) {
              case "R":
                html.AppendLine("<td align=\"right\">" + FormatData(data, "") + "</td>");
                break;

              case "EXI":
                // FOR EXCHANGE SYSTEM IMAGE ONLY ADDED BY PRALHAD
                html.AppendLine("<td align=\"left\"><img src='" + GetStatic.GetUrlRoot() + "/Images/ExSystemImage/" + data + ".gif' border='0'>&nbsp; &nbsp; " + FormatData(data, "") + "</td>");
                break;

              case "M":
                html.AppendLine(
                    "<td style =\"font-weight: bold; font-style: italic; text-align: right;\">" +
                    FormatData(data, "M") + "</td>");
                break;

              case "LNSTATE":
                String colorString = "";
                colorString = loanStateColor[data];
                html.AppendLine("<td align=\"center\"><span class='action-icon text-center'><btn class='btn btn-xs btn-default' title='State History' style='background-color:"+colorString+ ";width: 130px; color: white;' onclick=OpenInNewWindow('../Loan/LoanStateHistory.aspx?loanId=" + row["loanid"].ToString() + "') >" + FormatData(data, "") + "</btn></span></td>");
                break;

              case "D":
                html.AppendLine("<td align=\"center\">" + FormatData(data, "D") + "</td>");
                break;

              case "DT":
                html.AppendLine("<td align=\"center\">" + FormatData(data, "DT") + "</td>");
                break;

              case "NOSORT":
                html.AppendLine("<td align=\"left\" nowrap = \"nowrap\">" + FormatData(data, "") +
                                "</td>");
                break;

              default:
                html.AppendLine("<td align=\"left\">" + FormatData(data, "") + "</td>");
                break;
            }
          }

          if (AllowEdit || AllowDelete || AllowCustomLink || AllowApprove || AllowFileView) {
            html.AppendLine("<td align=\"left\" valign=\"middle\" nowrap = \"nowrap\">");

            if (AllowEdit) {
              if (disabled == "") {
                var customLinkVariableList = CustomLinkVariables.Split(',');
                var customVar = AddPage;
                if (customLinkVariableList[0] != "") {
                  customVar = customLinkVariableList.Aggregate(customVar, (current, variable) => current.Replace("@" + variable, row[variable.ToLower().Trim()].ToString()));
                }

                var editLink = (customLinkVariableList[0] != "" ? customVar : AddPage) +
                               (AddPage.IndexOf('?') > -1 ? "&" : "?") + RowIdField + "=" + editDeleteId +
                               (VerifyMode ? "&mode=verify" : "");
                if (ShowPopUpWindowOnAddButtonClick) {
                  html.AppendLine("<a href=\"javascript:void(0);\" onclick =\"PopUp('" + GridName + "','" +
                                  editLink + "','" + PopUpParam + "');\" title=\"Edit\">" + EditText +
                                  "</a>");
                } else {
                  if (string.IsNullOrEmpty(EditCallBackFunction)) {
                    html.AppendLine("<a title = \"Edit\" href=\"" + editLink + "\">" + EditText + "</a>");
                  } else {
                    html.AppendLine("<a href=\"javascript:void(0);\" onclick =\"" + EditCallBackFunction +
                                    "('" + editDeleteId + "');\" title=\"Edit\">" + EditText + "</a>");
                  }
                }
              }
            }

            if (AllowDelete) {
              if (disabled == "") {
                var deleteLink = "onclick = \"DeleteRow('" + editDeleteId + "','" + GridName + "', '" +
                                 DeleteAlertText + "'" + ShowProcessBar() + ");";

                //DeleteText = "<img alt = \"Delete\" border = \"0\" title = \"Delete\" src=\"" +
                //                    GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" />";

                html.AppendLine("&nbsp;<a title = \"Delete\" href=\"javascript:void(0)\" " + deleteLink +
                                "\">" + DeleteText + "</a>");
              } else {
                html.AppendLine("&nbsp;");
              }
            }

            if (AllowCustomLink) {
              var customLinkVariableList = CustomLinkVariables.Split(',');
              var parsedCustomLinkText = CustomLinkText;
              foreach (var variable in customLinkVariableList) {
                parsedCustomLinkText = parsedCustomLinkText.Replace("@" + variable,
                                                                    row[variable.ToLower().Trim()].
                                                                        ToString());
              }
              html.AppendLine("&nbsp;" + parsedCustomLinkText);
            }

            if (AllowApprove) {
              if (row["haschanged"].ToString().ToUpper().Equals("Y")) {
                if (row["modifiedby"].ToString() == GetStatic.GetUser()) {
                  var approveLink = "id=" + editDeleteId + "&functionId=" +
                                    (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
                                    "&functionId2=" + ApproveFunctionId + "&modBy=" +
                                    row["modifiedby"];
                  var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                  var jsText = DisableAuditWindow
                                   ? ""
                                   : "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" +
                                     PopUpParam + "');\"";
                  html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " +
                                  jsText +
                                  "\"><img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" +
                                  GetStatic.GetUrlRoot() + "/images/wait-icon.png\" /></a>");
                } else {
                  var approveLink = "id=" + editDeleteId + "&functionId=" +
                                    (ApproveFunctionId2 == "" ? ApproveFunctionId : ApproveFunctionId2) +
                                    "&functionId2=" + ApproveFunctionId;
                  var approvePage = GetStatic.GetUrlRoot() + "/ViewChanges.aspx?" + approveLink;
                  var jsText = DisableAuditWindow
                                   ? ""
                                   : "onclick = \"PopUp('" + GridName + "','" + approvePage + "','" + PopUpParam + "');";

                  ApproveText = "<img alt = \"Waiting for Approval\" border = \"0\" title = \"Waiting for Approval\" src=\"" +
                                  GetStatic.GetUrlRoot() + "/images/view-changes.jpg\" />";
                  html.AppendLine("&nbsp;<a title = \"View Changes\" href=\"javascript:void(0)\" " +
                                  jsText + "\">" + ApproveText + "</a>");
                }
              }
            }

            if (AllowFileView) {
              //var fn = row["filename"].ToString();
              //var fileViewLink = "<a target='_blank' href='/doc/" + editDeleteId + "." + fType + "'> View </a>";
              //html.AppendLine("&nbsp;" + fileViewLink);
              var fileLink = "id=" + editDeleteId + "&functionId=" + ViewFunctionId;
              var filePage = GetStatic.GetUrlRoot() + "/ShowFile.aspx?" + fileLink;
              var jsText = "onclick = \"PopUp('" + GridName + "','" + filePage + "','" + PopUpParam +
                           "');\"";
              html.AppendLine("&nbsp;<a title = \"View File\" href=\"javascript:void(0)\" " + jsText +
                              "\">View</a>");
            }

            html.AppendLine("</td>");
          }
          html.AppendLine("</tr>");
        }
      }
      if (!string.IsNullOrEmpty(_totalFields)) {
        html.AppendLine("<tr>");
        html.AppendLine("<td colspan=\"" + (TotalFieldCol).ToString() + "\" style=\"text-align: right; border:1px solid #dedede;\"><b>Total Amount</b></td>");
        html.AppendLine("<td style=\"text-align: right; border:1px solid #dedede;\"><b>" + GetStatic.ShowDecimal(total.ToString()) + "</b></td>");
        html.Append("</tr>");
      }
      html.AppendLine("</table>");
      html.AppendLine("</div>");

      if (ShowPagingBar) {
        html.AppendLine("<table style = \"clear:both\" width = \"" + GridWidth + (IsGridWidthInPercent ? "%" : "px") + "\" cellspacing=\"2\" cellpadding=\"2\" border=\"0\">");
        html.AppendLine("<tr> <td align=\"center\"> <strong> Page " + PageNumber + " of " + totalPage +
                        "</strong></td></tr>");
        html.AppendLine("<tr> <td></td></tr>");
        html.AppendLine("</table></div>");
      }
      html.AppendLine("<input type = \"submit\" id = \"" + GridName + "_submitButton\" name = \"" + GridName + "_submitButton\" style=\"display:none\">");

      if (GridHeight > -1) {
        html.AppendLine("</div>");
      }

      var filterFormHtml = ShowFilterForm ? MakeFilterForm() : "";

      var pagingBarHtml = ShowPagingBar ? GetPagingBlock(totalRecord, totalPage) : "";
      var completeScript = "";
      if (EnableProcessBar) {
        var id = GridName + "_submitButton";
        completeScript = @"<script>
                                    //<![CDATA[
                                        CallBackForProcessBar('" + GridName + @"');
                                    //]]>
                                 </script>";
      }
      return "<div class=\"col-md-12\">" + filterFormHtml + "</div><div class=\"col-md-12\">" + pagingBarHtml + "</div><div class=\"col-md-12\">" + html + "</div><div class=\"col-md-12\">" + CreateDefaultControl() + "</div>" + completeScript;
    }

    public string GetCurrentRowId(string gridName) {
      return GetStatic.ReadFormData(gridName + "_currentRowId", "");
    }

    public string GetRowId(string gridName) {
      return GetStatic.ReadFormData(gridName + "_rowId", "");
    }

    public string GetRowId() {
      return GetRowId(GridName);
    }

    public static string FormatData(string data, string dataType) {
      return GetStatic.FormatData(data, dataType);
    }

    public string GetGridInputValue(string key, string defaultValue) {
      return ReadData(key, defaultValue, true);
    }

    public string GetGridInputName(string inputName) {
      return GridName + "_" + inputName;
    }

    #endregion Public Methods

    #region Private Methods

    private string ShowProcessBar() {
      return (EnableProcessBar ? ",true" : ",false");
    }

    private string GetPagingBlock(int totalRecord, int totalPage) {
      string[] pageSizeList = { "10", "20", "30", "40", "50", "100" };

      var html = new StringBuilder("");
      html.AppendLine("<div class=\"row-paging\">");
      html.AppendLine("<div class=\"form-group\">");
      html.AppendLine("<div class=\"form-inline clearfix\">");
      html.AppendLine("<div class=\"form-group pull-left\">");
      html.AppendLine("<div style = \"float:left" + (totalRecord == PageSize ? ";disabled:disabled;\"" : "\"") + ">");
      html.AppendLine("<span>Result :&nbsp;&nbsp;</span><label>" + totalRecord + "</label><span>&nbsp;records</span>&nbsp;");
      html.AppendLine("<select class=\"form-control\" name=\"" + GridName + "_pageSize\" onChange=\"Nav(1, '" + GridName + "'" + ShowProcessBar() + ");\">");
      foreach (var page in pageSizeList) {
        if (FixePageSizeTo == 0 || FixePageSizeTo == Convert.ToInt16(page)) {
          html.AppendLine("<option value=\"" + page + "\" " + AutoSelect(page, PageSize.ToString()) + ">" +
                          page + "</option>");
        }
      }

      html.AppendLine("</select><span>&nbsp;&nbsp;&nbsp; per page<span>");

      html.AppendLine("<select  class=\"form-control\" name=\"" + GridName + "_ddl_pageNumber\"  onChange=\"Nav(this.value, '" + GridName + "'" + ShowProcessBar() + ");\">");
      for (var i = 1; i <= totalPage; i++) {
        html.AppendLine("<option value=\"" + i + "\" " + AutoSelect(i.ToString(), PageNumber.ToString()) + ">" + i + "</option>");
      }

      html.AppendLine("</select>&nbsp;&nbsp;");
      html.AppendLine("</div>");
      html.AppendLine("</div>");
      html.AppendLine("<div class=\"form-group pull-right\">");
      if (PageNumber > 1)
        html.AppendLine("<span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = \"cursor:pointer\" onclick =\"Nav(" + (PageNumber - 1) + ", '" + _gridName + "'" + ShowProcessBar() + ");\" title='Go to Previous page(Page : " + (PageNumber - 1) + ")' ><i class=\"fa fa-arrow-left\"></i></span>&nbsp;&nbsp;&nbsp;");
      else
        //html.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
        html.AppendLine("<span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = \"cursor:pointer\"><i class=\"fa fa-arrow-left\" ></i></span>");

      if (PageNumber * PageSize < totalRecord)
        html.AppendLine("<span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = \"cursor:pointer\" onclick =\"Nav(" + (PageNumber + 1) + ", '" + _gridName + "'" + ShowProcessBar() + ");\" title='Go to Next page(Page : " + (PageNumber + 1) + ")'><i class=\"fa fa-arrow-right\" ></i></span>&nbsp;&nbsp;&nbsp;");
      else
        //html.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");
        html.AppendLine("<span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = \"cursor:pointer\"> <i class=\"fa fa-arrow-right\" ></i></span>");

      if (ShowAddButton) {
        if (ShowPopUpWindowOnAddButtonClick) {
          html.AppendLine("<a class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = 'cursor:pointer color:blue' href=\"javascript:void(0);\" onclick =\"PopUp('" + GridName + "','" + AddPage + "','" + PopUpParam + "'" + ShowProcessBar() + ");\" title=\"" + AddButtonTitleText + "\" ><i class=\"fa fa-plus-circle\"></i></a>");
        } else if (!string.IsNullOrEmpty(AddButtonCallBack)) {
          html.AppendLine("<a class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" href=\"javascript:void(0);\" onclick =\"" + AddButtonCallBack + "\"  style = 'cursor:pointer color:blue' title=\"" + AddButtonTitleText + "\"><i class=\"fa fa-plus-circle\"></i></a>");
        } else {
          html.AppendLine("<a class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = 'cursor:pointer color:blue' href=\"" + AddPage + "\" title=\"" + AddButtonTitleText + "\"><i class=\"fa fa-plus-circle\"></i></a>");
        }
      }
      if (_uploadPage != "")
        html.AppendLine("&nbsp;&nbsp;<a class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" style = 'cursor:pointer color:blue' href=\"" + _uploadPage + "\" title=\"Upload\"><i class=\"fa fa-upload\"></i></a>");

      if (Downloadable) {
        if (GridDS.RemittanceDB == GridDataSource || GridDS.LogDb == GridDataSource) {
          html.AppendLine("&nbsp; <span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = 'Export to Excel' style = 'cursor:pointer color:green' onclick = \"DownloadGridRemit('" + GetStatic.GetUrlRoot() + "','xls',0,'');\")'><i class=\"fa fa-file-excel-o\"></i></span>&nbsp;&nbsp;&nbsp;");
        } else
          html.AppendLine("&nbsp; <span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = 'Export to Excel' style = 'cursor:pointer color:green' onclick = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "','xls',0,'');\")'><i class=\"fa fa-file-excel-o\"></i></span>&nbsp;&nbsp;&nbsp;");
      }

      if (EnablePdfDownload) {
        var lm = LandscapeMode ? "1" : "0";
        html.AppendLine("<span class=\"tool btn btn-default\" data-toggle=\"tooltip\" data-placement=\"top\" title = 'Export to PDF' style = 'cursor:pointer color:#FA4345' onclick = \"DownloadPDFGrid('" + GetStatic.GetUrlRoot() + "','pdf'," + lm + ",'');\")'><i class=\"fa fa-file-pdf-o\" style = 'cursor:pointer color:#FA4345' ></i></span>&nbsp;&nbsp;&nbsp;");
      }

      html.AppendLine("</div>");
      html.AppendLine("</div></div></div>");

      return html.ToString();
    }

    private string MakeFilterForm() {
      var html = new StringBuilder("<div class=\"row-filter\">");
      if (!AlwaysShowFilterForm) {
        html.AppendLine("<div class=\"form-group\"><a class=\"btn btn-sm btn-default\" data-toggle=\"collapse\" href=\"#filter\">Filter Results <span class=\"caret\"></span></a></div>");
        html.AppendLine("<div class=\"collapse\" id=\"filter\"><table class=\"filter-tblform table\" id ='" + _gridName + "_tblFilter'>");
        //html.AppendLine("<tr>");
        //html.AppendLine(
        //    "<td class=\"GridTextNormal\" align=\"left\"><b><span {{style}}>Filtered results</span></b>&nbsp;&nbsp;&nbsp;<img style = \"cursor:pointer\" onclick =\"NewTableToggle('td_Search', 'img_Search', '" +
        //    _gridName + "','" + GetStatic.GetUrlRoot() + "');\" src=\"" + GetStatic.GetUrlRoot() +
        //    "/images/icon_show.gif\" border=\"0\" alt=\"Show\" id=\"" + _gridName + "_img_Search\">&nbsp;");
        //html.AppendLine("<img style = \"cursor:pointer\" src=\"" + GetStatic.GetUrlRoot() + "/images/clear-icon.png\" border=\"0\" title=\"Clear Filters\" onclick = \"FilterAll('" + _gridName + "'" + ShowProcessBar() + ")\" />");
        //html.AppendLine("</td></tr>");
      } else {
        html.AppendLine(ShowFilterLabel == true
            ? "<div class=\"form-group\"><h3>" + ShowFilterLabelText + "</h3></div>"
            : "<div class=\"form-group\"><a class=\"btn btn-sm btn-default\" data-toggle=\"collapse\" href=\"#filter\">Filter Results <span class=\"caret\"></span></a></div>");

        html.AppendLine("<div id=\"filter\"><table class=\"filter-tblform table\" id ='" + _gridName + "_tblFilter'>");
      }

      //else
      //{
      //    html.AppendLine("<tr>");
      //    html.AppendLine(
      //        "<td class=\"GridTextNormal\" align=\"left\"><b><span {{style}}>Filtered results</span></b>");
      //    html.AppendLine("<img style = \"cursor:pointer\" src=\"" + GetStatic.GetUrlRoot() + "/images/clear-icon.png\" border=\"0\" title=\"Clear Filters\" onclick = \"FilterAll('" + _gridName + "'" + ShowProcessBar() + ")\" />");
      //    html.AppendLine("</td></tr>");
      //}
      //html.AppendLine("<tr>");

      //html.AppendLine("<td id=\"" + _gridName + "_td_Search\" align=\"left\"");
      //if (!AlwaysShowFilterForm)
      //{
      //    html.Append(" style=\"display:none\"");
      //}
      html.Append("");
      //html.AppendLine("<div> <table class=\"table  table-condensed\">");

      var user = GetStatic.GetUser();
      var cnt = 0;
      foreach (var filter in FilterList) {
        cnt++;
        var childControl = "";
        var readOnly = "";
        var jsFunction = "";
        if (cnt == 1)
          html.AppendLine("<tr>");
        //html.AppendLine("<td>" + filter.Description);
        html.AppendLine("<td>");
        html.AppendLine("<div class=\"form-group\"><label class=\"control-label\">" + filter.Description + "</label>");

        //if (InputLabelOnLeftSide)
        //{
        //    html.AppendLine("</div>");
        //    html.AppendLine("</td>");
        //}

        //html.AppendLine("<td>");
        var ctlName = GridName + "_" + filter.Key;
        var defaultValue = "";
        var filterControlType = filter.Type.Substring(0, 1).ToLower();
        // html.AppendLine("<div class=\"form-group\"><label>" + filter.Description + "</label>");

        if (!filterControlType.Equals("a") || string.IsNullOrWhiteSpace(filter.Category)) {
          if (EnableFilterCookie) {
            defaultValue = GetStatic.ReadCookie(ctlName + "_c_" + user, "");
            defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);
            GetStatic.WriteCookie(ctlName + "_c_" + user, defaultValue);
          } else {
            defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);
          }
        }

        if (filterControlType == "d" || filterControlType == "z") {
          //jsFunction = "onchange=\"return DateValidation(" + "'" + GridName + "_fromDate','t','" + GridName + "_toDate'" + ")\" maxlength=\"10\"";
          //filter.DefaultValue = null;
          //readOnly = " readOnly = \"readOnly\"";
          html.Append(@"<script language = ""javascript"" type =""text/javascript"">
                            $(document).ready(function () {
                                ShowCalDefault('#" + ctlName + @"');
                            });
                            </script>");
        }

        //html.AppendLine(InputLabelOnLeftSide ? "<td>":"");

        if (string.IsNullOrEmpty(defaultValue)) {
          defaultValue = filter.DefaultValue;
        }

        switch (filterControlType) {
          case "1": {
              var sp = filter.Type.Substring(2);
              if (GridDS.RemittanceDB == GridDataSource || GridDS.LogDb == GridDataSource) {
                var remittanceLibrary = new RemittanceLibrary();
                html.AppendLine(remittanceLibrary.CreateDynamicDropDownBox(ctlName, sp, "value", "text", defaultValue) + "</td>");
              } else {
                var swiftLibrary = new SwiftLibrary();
                html.AppendLine(swiftLibrary.CreateDynamicDropDownBox(ctlName, sp, "value", "text", defaultValue) + "</td>");
              }
            }
            break;

          case "2":
            html.Append("<select name=\"" + ctlName + "\" id =\"" + ctlName + "\" class = \"form-control\">");
            html.Append("<option value=\"\"" + AutoSelect("", defaultValue) + ">All</option>");
            html.Append("<option value=\"N\"" + AutoSelect("N", defaultValue) + ">No</option>");
            html.Append("<option value=\"Y\"" + AutoSelect("Y", defaultValue) + ">Yes</option>");
            html.Append("</select></td>");
            break;

          case "z":
            //if (defaultValue == "")
            //    defaultValue = DateTime.Now.ToString("MM/dd/yyyy");
            html.AppendLine("<div class=\"form-inline\">");
            html.AppendLine("<input class=\"form-control\" style=\"width: 100%;\" type=\"text\" name=\"" + ctlName + "\"  id=\"" + ctlName + "\"" + jsFunction +
            readOnly + " value=\"" + defaultValue + "\">" + childControl + "</div></div></td>");
            break;

          case "i":
            html.AppendLine(Misc.MakeIntegerTextbox(ctlName, ctlName, defaultValue, "class=\"form-control\" style=\"width: 100%;\"", "") + "</div></td>");
            break;

          case "m":
            html.AppendLine(Misc.MakeFloatTextbox(ctlName, ctlName, defaultValue, "class=\"form-control\" style=\"width: 100%;\"", "") + "</div></td>");
            break;

          case "a":
            if (!string.IsNullOrWhiteSpace(filter.Category)) {
              html.AppendLine(MakeAutoCompleteControl(filter) + "</div></td>");
            } else {
              html.AppendLine("<input class=\"form-control\" type=\"text\" name=\"" + ctlName + "\"  style=\"width: 100%;\"  id=\"" +
                              ctlName + "\"" + jsFunction +
                              readOnly + " value=\"" + defaultValue + "\">" + childControl + "</div></td>");
            }
            break;

          default:
            html.AppendLine("<div class=\"form-inline\">");
            html.AppendLine("<input class=\"form-control\" type=\"text\" name=\"" + ctlName + "\" style=\"width: 100%;\"   id=\"" + ctlName + "\"" + jsFunction +
                            readOnly + " value=\"" + defaultValue + "\">" + childControl + "</div></div></td>");
            break;
        }

        if (cnt % InputPerRow == 0) {
          html.AppendLine("</tr>");
          cnt = 0;
        }
      }
      if (cnt != 0) {
        html.AppendLine("</tr>");
      }
      html.AppendLine("<tr>");
      if (InputLabelOnLeftSide)
        html.AppendLine("<td>&nbsp;</td>");

      html.AppendLine("</table>");
      html.AppendLine("<div class=\"form-group\">");

      html.AppendLine(
          "<input type=\"button\" value=\"Filter\" class=\"btn btn-primary m-t-25\" onclick=\"Nav(1, '" +
          _gridName + "'" + ShowProcessBar() + ",1);\">");
      html.AppendLine("<input type = 'button' class=\"btn btn-clear m-t-25\" value = 'Clear Filters' title = \"Clear Filters\" onclick = \"FilterAll('" + _gridName + "'" + ShowProcessBar() + ")\" />");

      html.AppendLine("</div>");
      html.AppendLine("</div>");
      var filterText = _hasFilter ? "style = 'background-color:yellow'" : "";
      return html.ToString().Replace("{{style}}", filterText);
    }

    private void LoadVariables() {
      if (EnableCookie) {
        if (PageSize != -1) {
          PageNumber = Convert.ToInt16(GetStatic.ReadFormData(GridName + "_pageNumber", "1"));
          PageSize = Convert.ToInt16(ReadData2("pageSize", PageSize.ToString()));
        }

        SortOrder = ReadFormData("sortOrder", SortOrder);
        SortBy = ReadFormData("sortBy", SortBy);
      }

      if (GridWidth == -1) {
        GridWidth = Convert.ToInt16(GetStatic.ReadWebConfig("gridWidth", "-1"));
        if (GridWidth == -1)
          GridWidth = 700;
      }

      if (GridHeight == -1) {
        GridHeight = Convert.ToInt16(GetStatic.ReadWebConfig("gridHeight", "-1"));
      }
    }

    private string ReadFormData(string key, string defaultValue) {
      var user = GetStatic.GetUser();
      var ctlName = GridName + "_" + key;
      defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);
      return defaultValue;
    }

    private string ReadData(string key, string defaultValue) {
      return ReadData(key, defaultValue, true);
    }

    private string ReadData(string key, string defaultValue, bool writeCookie) {
      var user = GetStatic.GetUser();
      var ctlName = GridName + "_" + key;
      defaultValue = GetStatic.ReadCookie(ctlName + "_c_" + user, defaultValue);
      defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);

      if (!writeCookie || string.IsNullOrEmpty(defaultValue.Trim())) {
        GetStatic.DeleteCookie(ctlName + "_c_" + user);
      } else {
        GetStatic.WriteCookie(ctlName + "_c_" + user, defaultValue);
      }

      return defaultValue;
    }

    private string ReadData2(string key, string defaultValue) {
      return ReadData2(key, defaultValue, true);
    }

    private string ReadData2(string key, string defaultValue, bool writeCookie) {
      var user = GetStatic.GetUser();
      var ctlName1 = key;
      var ctlName = GridName + "_" + key;
      defaultValue = GetStatic.ReadCookie(ctlName1 + "_c_" + user, defaultValue);
      defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);

      if (!writeCookie || string.IsNullOrEmpty(defaultValue.Trim())) {
        GetStatic.DeleteCookie(ctlName1 + "_c_" + user);
      } else {
        GetStatic.WriteCookie(ctlName1 + "_c_" + user, defaultValue);
      }

      return defaultValue;
    }

    private string GetFilterSql() {
      var user = GetStatic.GetUser();
      var sql = "";

      switch (GridType) {
        case 1:
          sql = "  " + _comma + "@pageNumber=" + FilterString(PageNumber.ToString());
          sql += ", @pageSize=" + FilterString(PageSize.ToString());
          sql += ", @sortBy=" + FilterString(SortBy);
          sql += ", @sortOrder=" + FilterString(SortOrder);
          sql += ", @user = " + FilterString(GetStatic.GetUser());
          _comma = ", ";
          if (FilterList != null) {
            foreach (var filter in FilterList) {
              var defaultValue = "";

              if (filter.Type.ToLower().Equals("a") && !string.IsNullOrWhiteSpace(filter.Category)) {
                defaultValue = GetAutoCompleteValue(filter);
              } else {
                var ctlName = GridName + "_" + filter.Key;
                defaultValue = GetStatic.ReadCookie(ctlName + "_c_" + user, "");
                defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);
              }

              if (defaultValue.Trim() == "")
                continue;
              sql = sql + _comma + "@" + filter.Key + " = " + FilterString(defaultValue);
              _comma = ", ";
              _hasFilter = true;
            }
          }
          break;

        case 2:
          if (FilterList != null) {
            foreach (var filter in FilterList) {
              var defaultValue = "";
              if (filter.Type.ToLower().Equals("a") && !string.IsNullOrWhiteSpace(filter.Category)) {
                defaultValue = GetAutoCompleteValue(filter);
              } else {
                var ctlName = GridName + "_" + filter.Key;
                defaultValue = GetStatic.ReadCookie(ctlName + "_c_" + user, "");
                defaultValue = GetStatic.ReadFormData(ctlName, defaultValue);
              }
              if (defaultValue.Trim() == "")
                continue;
              if (filter.Type.ToLower() == "lt") {
                sql = sql + " AND " + filter.Key + " LIKE '" + FilterString(defaultValue).Replace("'", "") +
                      "%'";
              } else {
                sql = sql + " AND " + filter.Key + " = " + FilterString(defaultValue);
              }
              _hasFilter = true;
            }
          }
          break;
      }

      return sql;
    }

    private static string ReverseSortOrder(string sortOrder) {
      return sortOrder.ToLower().Trim() == "asc" ? "desc" : "asc";
    }

    private string CreateDefaultControl() {
      //grd_ssc_sch_sortBy
      var html = new StringBuilder("");
      html.AppendLine("<input id = \"" + GridName + "_sortOrder\" name = \"" + GridName + "_sortOrder\" type = \"hidden\" value = \"" + SortOrder + "\">");
      html.AppendLine("<input id = \"" + GridName + "_sortBy\" name = \"" + GridName + "_sortBy\" type = \"hidden\" value = \"" + SortBy + "\">");
      html.AppendLine("<input id = \"" + GridName + "_pageNumber\" name = \"" + GridName + "_pageNumber\" type = \"hidden\" value = \"" + PageNumber + "\">");
      html.AppendLine("<input id = \"" + GridName + "_currentRowId\" name = \"" + GridName + "_currentRowId\" type = \"hidden\" value = \"\">");
      html.AppendLine("<input id = \"" + GridName + "_mode\" name = \"" + GridName + "_mode\" type = \"hidden\" value = \"\">");

      return html.ToString();
    }

    private string AppendChkBoxProperties(string id) {
      if (!IdsAreParsed) {
        CheckBoxIds = new ArrayList();
        var valueList = SelectionCheckBoxList.Split(',');
        foreach (var s in valueList) {
          CheckBoxIds.Add(s.Trim().ToUpper());
        }
        IdsAreParsed = true;
      }

      if (CheckBoxIds.Contains(id.Trim().ToUpper())) {
        return "checked = \"checked\"";
      } else {
        return "";
      }
    }

    private string MakeAutoCompleteControl(GridFilter f) {
      var url = GetStatic.GetUrlRoot() + "/Component/AutoComplete/DataSource.asmx/GetList" + GetSurfix(f);

      var usr = GetStatic.GetUser();
      var sb = new StringBuilder();
      var strClientID = GridName + "_" + f.Key;
      var ctlValue = strClientID + "_aValue";
      var ctlText = strClientID + "_aText";
      var ctlSearch = strClientID + "_aSearch";

      var defValue = "";
      if (EnableFilterCookie) {
        defValue = GetStatic.ReadCookie(ctlValue + "_c_" + usr, defValue);
        defValue = GetStatic.ReadFormData(ctlValue, defValue);
        GetStatic.WriteCookie(ctlValue + "_c_" + usr, defValue);
      } else {
        defValue = GetStatic.ReadFormData(ctlValue, defValue);
      }

      var defText = "";
      if (EnableFilterCookie) {
        defText = GetStatic.ReadCookie(ctlText + "_c_" + usr, defText);
        defText = GetStatic.ReadFormData(ctlText, defText);
        GetStatic.WriteCookie(ctlText + "_c_" + usr, defText);
      } else {
        defText = GetStatic.ReadFormData(ctlText + "_c_" + usr, defText);
      }
      //grdRole_gl_code_aText_c_admin////grdRole_gl_code_aSearch
      sb.Append("<input type = 'hidden' id = '" + ctlValue + "' name = '" + ctlValue + "' value = '" + defValue + "' />");
      sb.Append("<input type = 'text' id = '" + ctlText + "' name = '" + ctlText + "' value = '" + defText + "' class='form-control' />");
      sb.Append("<input style = 'background-color:#BBF;display:none' type = 'text' id = '" + ctlSearch + "' name = '" + ctlSearch + "' value = '" + defText + "'' class='form-control' />");
      sb.Append("<script language = 'javascript' type ='text/javascript'>");
      sb.Append("$(document).ready(function () {");
      sb.Append("function Auto_" + strClientID + "() {");
      sb.Append(InitFunction(f, url, GridName, "150px"));
      sb.Append("} Auto_" + strClientID + "();");
      sb.Append("});");
      sb.Append("</script>");

      return sb.ToString();
    }

    private string InitFunction(GridFilter f, string url, string gridName, string width) {
      var strClientID = gridName + "_" + f.Key;
      var sb = new StringBuilder();
      sb.Append("LoadAutoCompleteTextBox(");
      sb.Append(@"""" + url + @"""");
      sb.Append(@",""#" + strClientID + @"""");
      sb.Append(@",""" + width + @"""");
      sb.Append(@",""" + GetData(f) + @""");");
      return sb.ToString();
    }

    protected String GetData(GridFilter f) {
      var sb = new StringBuilder();

      sb.Append("'category' : '" + f.Category.Replace("'", "").Replace(",", "") + "'");

      if (!string.IsNullOrWhiteSpace(f.Param1)) {
        var data = ParseParam("param1", f.Param1);
        sb.Append("," + data);
      }
      if (!string.IsNullOrWhiteSpace(f.Param2)) {
        var data = ParseParam("param2", f.Param2);
        sb.Append("," + data);
      }
      if (!string.IsNullOrWhiteSpace(f.Param3)) {
        var data = ParseParam("param3", f.Param3);
        sb.Append("," + data);
      }

      return sb.ToString();
    }

    private string ParseParam(string key, string data) {
      if (data.StartsWith("@")) {
        return @"'" + key + @"':'"" + " + data.Substring(1) + @" +  ""'";
      } else {
        return "'" + key + "':'" + data.Replace("'", "").Replace(",", "") + "'";
      }
    }

    private string GetSurfix(GridFilter f) {
      string surfix = "";

      if (!string.IsNullOrWhiteSpace(f.Param1)) {
        surfix = "1";
      }
      if (!string.IsNullOrWhiteSpace(f.Param2)) {
        surfix = "2";
      }
      if (!string.IsNullOrWhiteSpace(f.Param3)) {
        surfix = "3";
      }
      return surfix;
    }

    private string GetAutoCompleteValue(GridFilter f) {
      var usr = GetStatic.GetUser();
      var sb = new StringBuilder();
      var strClientID = GridName + "_" + f.Key;

      var retVal = "";
      if (f.Value) {
        var ctlValue = strClientID + "_aValue";
        retVal = GetStatic.ReadCookie(ctlValue + "_c_" + usr, retVal);
        retVal = GetStatic.ReadFormData(ctlValue, retVal);
      } else {
        var ctlText = strClientID + "_aText";
        retVal = GetStatic.ReadCookie(ctlText + "_c_" + usr, retVal);
        retVal = GetStatic.ReadFormData(ctlText, retVal);
      }
      return retVal;
    }

    #endregion Private Methods
  }
}