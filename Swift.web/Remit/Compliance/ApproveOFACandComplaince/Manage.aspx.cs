using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Compliance.ApproveOFACandComplaince
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            obj.CheckSession();
            ShowTxnDetail();
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }

        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") != "Y" ? false : true);
        }

        protected bool ShowOfac()
        {
            return GetStatic.ReadQueryString("ShowOfac", "Y") != "N";
        }

        protected bool ShowComplaince()
        {
            return GetStatic.ReadQueryString("ShowComplaince", "Y") != "N";
        }

        protected bool ShowApproveButton()
        {
            return GetStatic.ReadQueryString("ShowApproveButton", "Y") != "N";
        }

        private void ShowTxnDetail()
        {
            string txnId = GetStatic.ReadQueryString("tranId", "");
            string cntNo = GetStatic.ReadQueryString("controlNo", "");

            if (txnId != "" || cntNo != "")
            {
                ucTran.ShowCommentBlock = ShowCommentFlag();
                ucTran.ShowBankDetail = ShowBankDetail();
                ucTran.ShowOfac = ShowOfac();
                ucTran.ShowCompliance = ShowComplaince();
                ucTran.ShowApproveButton = ShowApproveButton();
                ucTran.SearchData(txnId, cntNo, "", "", "COMPLIANCE", "ADM: APPROVE OFAC/COMPLIANCE");
                divTranDetails.Visible = ucTran.TranFound;
            }
            ShowQuestionaireLink();
            LoadGrid();
        }
        public void ShowQuestionaireLink()
        {
            var obj = new TranViewDao();
            DataTable res = obj.QuestionaireExists(GetStatic.GetUser(), ucTran.HoldTranId);
            if (res.Rows.Count > 0)
            {
                questionaireDiv.Visible = true;
            }
            else
            {
                questionaireDiv.Visible = false;
            }
        }
        private void LoadGrid()
        {
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
            _grid.ThisPage = "ModifyTran.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            //_grid.AllowApprove = swiftLibrary.HasRight(ApproveFunctionId);
            string sql = "EXEC [proc_transactionView] @flag = 's-QuestionaireAnswer',@tranId='" + ucTran.HoldTranId + "'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
    }
}