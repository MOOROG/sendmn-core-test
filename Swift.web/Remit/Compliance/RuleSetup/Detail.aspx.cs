using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Compliance.RuleSetup
{
    public partial class Detail : System.Web.UI.Page
    {
        private CsDetailDao cd = new CsDetailDao();
        private CsMasterDao cmd = new CsMasterDao();
        RemittanceLibrary sl = new RemittanceLibrary();
        protected const string GridName = "grd_csd";
        private const string ViewFunctionId = "20192100";
        private const string AddEditFunctionId = "20192101";
        private const string ApproveFunctionId = "20192102";
        private const string ApproveFunctionId2 = "20192103";
        SwiftGrid grid = new SwiftGrid();
        readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
              Authenticate();
                GetStatic.PrintMessage(Page);
                LoadGrid(null, null, null, null);
                PopulateDataById2();
                condition.Attributes.Add("onChange", "return ManageCriteria(this);");
                Misc.MakeNumericTextbox(ref tranCount);
                Misc.MakeNumericTextbox(ref amount);
                Misc.MakeNumericTextbox(ref period);
                PopulateDdl(null);
            }
        }

        private void Authenticate()
        {

            sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);

        }
        private void LoadGrid(string condn, string payMode, string colMode, string action)
        {
            grid.ColumnList = new List<GridColumn>
                              {
                                  new GridColumn("condition1",              "Condition",                    "",         "T"),
                                  new GridColumn("paymentMode1",            "Payment Mode",                 "",         "T"),
                                  new GridColumn("collMode1",               "Collection Mode",              "",         "T"),
                                  new GridColumn("tranCount",               "#Txn",                         "",         "T"),
                                  new GridColumn("Amount",                  "Amount",                       "",         "M"),
                                  new GridColumn("period",                  "Period(In Days)",              "",         "T"),
                                  new GridColumn("nextAction1",             "Action",                       "",         "T"),
                                  new GridColumn("isDisabled",              "Status",                       "",         "T"),
                                  new GridColumn("isDocumentRequired",      "Document Required",            "",         "T")
                              };

            var allowAddEdit = _sdd.HasRight(AddEditFunctionId);
            grid.GridName = GridName;
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.RowIdField = "csDetailId";
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.ApproveFunctionId2 = ApproveFunctionId2;
            grid.AllowApprove = _sdd.HasRight(ApproveFunctionId);
            grid.DisableSorting = true;
            grid.DisableJsFilter = false;
            grid.ShowCheckBox = true;
            grid.CallBackFunction = "GridCallBack()";
            grid.GridWidth = 1000;
            grid.SetComma();
            grid.PageSize = 10000;
            grid.SelectionCheckBoxList = grid.GetRowId();
            var csMasterId = GetCsMasterId();

            var sql = "EXEC proc_csDetail @flag = 's', @csMasterId = " + grid.FilterString(csMasterId) +
                      ",@condition = " + grid.FilterString(condn) +
                      ",@paymentMode = " + grid.FilterString(payMode) +
                      ",@collMode = " + grid.FilterString(colMode) +
                      ",@nextAction = " + grid.FilterString(action);

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void PopulateDdl(DataRow dr)
        {
            LoadPaymentMode(ref paymentMode, GetStatic.GetRowData(dr, "paymentMode"));
            LoadStaticData(ref collMode, "3500", GetStatic.GetRowData(dr, "collMode"), "All");
            LoadStaticData(ref ddlProfession, "2000", GetStatic.GetRowData(dr, "profession"), "All");
            LoadStaticData(ref condition, "4600", GetStatic.GetRowData(dr, "condition"), "All");
            //LoadStaticData(ref nextAction, "4900", GetStatic.GetRowData(dr, "nextAction"),"None");
        }
        private void LoadPaymentMode(ref DropDownList ddl, string defaultValue)
        {
            var sql = "EXEC proc_serviceTypeMaster @flag = 'l2', @user=" + cd.FilterString(GetStatic.GetUser());
            _sdd.SetDDL(ref ddl, sql, "serviceTypeId", "typeTitle", defaultValue, "All");
        }
        private void LoadStaticData(ref DropDownList ddl, string typeId, string defaultValue, string label)
        {
            _sdd.SetStaticDdl(ref ddl, typeId, defaultValue, label);
        }

        private string GetId()
        {
            return csDetailId.Value;
        }

        private string GetCsMasterId()
        {
            return GetStatic.ReadQueryString("csMasterId", "");
        }
        private void Edit()
        {
            LoadGrid(null, null, null, null);
            var id = grid.GetRowId();
            csDetailId.Value = id;
            PopulateDataById();
        }

        private void Delete()
        {
            var id = grid.GetRowId();
            var dbResult = cd.Delete(GetStatic.GetUser(), id);
            PrintMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                csDetailId.Value = "";
                LoadGrid(null, null, null, null);
            }
        }

        private void Disable()
        {
            var id = grid.GetRowId();
            var dbResult = cd.Disable(GetStatic.GetUser(), csDetailId.Value);
            ManageMessage(dbResult);
        }

        bool validateTranCountAndAmount()
        {
            var txnCount = tranCount.Text.Trim() == "" ? 0 : tranCount.Text.Trim().ToInt();
            var txnAmount = amount.Text.Trim() == "" ? 0 : amount.Text.Trim().ToDecimal();

            if (txnCount == 0 && txnAmount == 0)
            {
                return false;
            }
            return true;
        }
        private void Update()
        {
            if (!validateTranCountAndAmount())
            {
                GetStatic.AlertMessage(Page, "Transaction count and Amount both cannot be set to zero.");
                return;
            }
            var criteria = GetCriteria();
            string isRequireDocument = (requireDocumentCheckBox.Checked == true) ? "Y" : "N";

            var dbResult = cd.Update(GetStatic.GetUser(), GetId(), GetCsMasterId(), condition.Text, collMode.Text,
                                     paymentMode.Text, tranCount.Text, amount.Text, period.Text, nextAction.Text,
                                     criteria, ddlProfession.SelectedValue, isRequireDocument);

            ManageMessage(dbResult);
            //GetStatic.SetMessage(dbResult);
            //if (dbResult.ErrorCode != "0")
            //{
            //    GetStatic.AlertMessageBox(Page);
            //}
            //else
            //{
            //    GetStatic.CallBackJs2(this, "loadData1", "ManageCriteria();");
            //    return;
            //}


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
                Response.Redirect("Detail.aspx?csMasterId=" + GetCsMasterId() + "");

            }
        }
        private void PopulateDataById2()
        {
            var dr = cmd.SelectRuleDetailById(GetStatic.GetUser(), GetCsMasterId());
            if (dr == null)
                return;
            sCountry.Text = dr["sCountry"].ToString();
            sAgent.Text = dr["sAgent"].ToString();
            sState.Text = dr["sState"].ToString();
            sZip.Text = dr["sZip"].ToString();
            sGroup.Text = dr["sGroup"].ToString();
            sCustType.Text = dr["sCustType"].ToString();

            rCountry.Text = dr["rCountry"].ToString();
            rAgent.Text = dr["rAgent"].ToString();
            rState.Text = dr["rState"].ToString();
            rZip.Text = dr["rZip"].ToString();
            rGroup.Text = dr["rGroup"].ToString();
            rCustType.Text = dr["rCustType"].ToString();

            currency.Text = dr["currency"].ToString();
            ruleScope.Text = dr["ruleScope"].ToString();
        }
        private void PopulateDataById()
        {
            var dr = cd.SelectById(GetStatic.GetUser(), csDetailId.Value);
            if (dr == null)
                return;
            tranCount.Text = dr["tranCount"].ToString();
            amount.Text = dr["amount1"].ToString();
            period.Text = dr["period"].ToString();
            LoadCriteria(dr["criteria"].ToString(), dr["condition"].ToString());
            requireDocumentCheckBox.Checked = Convert.ToBoolean(dr["documentRequired1"]);
            nextAction.SelectedValue = dr["nextAction"].ToString();
            PopulateDdl(dr);
            GetStatic.CallBackJs1(this, "loadData", "ManageCriteria();");
            if (dr["isEnable"].ToString().ToUpper() == "N")
            {
                btnDelete.Text = "Enable";
            }
        }

        private void LoadCriteria(string criteriaList, string con)
        {
            var cList = criteriaList.Split(',').ToArray();
            if (con != "4603")
            {
                SetCriteriaList(ref chk_5000, "5000", cList);
                SetCriteriaList(ref chk_5001, "5001", cList);
                SetCriteriaList(ref chk_5002, "5002", cList);

            }
            if (con != "4601" || con != "4602")
            {
                SetCriteriaList(ref chk_5003, "5003", cList);
                SetCriteriaList(ref chk_5004, "5004", cList);
                SetCriteriaList(ref chk_5005, "5005", cList);
                SetCriteriaList(ref chk_5006, "5006", cList);
                SetCriteriaList(ref chk_5007, "5007", cList);
            }
        }

        private void PrintMessage(DbResult dbResult)
        {
            var data = GetStatic.ParseResultJsPrint(dbResult);
            var function = "printMessage('" + data + "')";
            GetStatic.CallBackJs1(this, "print", function);

        }

        private static void SetCriteriaList(ref CheckBox cb, string value, string[] cList)
        {
            cb.Checked = cList.Contains(value);
        }

        private string GetCriteria()
        {

            var criteriaList = new StringBuilder();
            if (condition.Text != "4603")
            {
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5000, ",5000", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5001, ",5001", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5002, ",5002", ",NULL"));
            }
            if (condition.Text != "4601" || condition.Text != "4602")
            {
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5003, ",5003", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5004, ",5004", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5005, ",5005", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5006, ",5006", ",NULL"));
                criteriaList.AppendLine(GetCheckBoxValue(ref chk_5007, ",5007", ",NULL"));
            }

            return criteriaList.ToString().Substring(1);
        }

        private string GetCheckBoxValue(ref CheckBox cb, string trueValue, string falseValue)
        {
            return cb.Checked ? trueValue : falseValue;
        }
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadGrid(condition.Text, paymentMode.Text, collMode.Text, nextAction.Text);
            var function = "SearchCallBack();";
            GetStatic.CallBackJs1(this, "cb", function);
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
            btnSave.Enabled = true;
            btnDelete.Enabled = true;
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            //Delete();
            Disable();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

    }
}