using Swift.DAL.Treasury;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.BillVoucher.FundTransfer
{
    public partial class Transfer : System.Web.UI.Page
    {
        private const string ViewFuntionId = "20153000";
        private readonly SwiftLibrary _sdd = new SwiftLibrary();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private IFundTransferDao _sd = new FundTransferDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            date.Text = DateTime.Now.ToString("yyyy-MM-dd");
            date.Attributes.Add("readonly", "readonly");
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDDL();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFuntionId);
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref ddlTransferFrom, "EXEC proc_dropDownList @FLAG='BankList'", "RowId", "BankName", "", "Select Bank");
            _sdd.SetDDL(ref ddlTransferFundTo, "EXEC proc_dropDownList @FLAG='RPartner'", "rowId", "nameOfPartner", "", "Select Partner");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            var dt = _sd.GetDealSummaryToTransfer(ddlTransferFrom.Text);
            if (dt == null)
                return;

            var ids = GetIds(dt);
            var sb = new StringBuilder("<div class='table-responsive'><table class='table table-striped'>");
            sb.Append("<thead>");
            sb.Append("<tr>");
            sb.Append("<th>Bank Name</th>");
            sb.Append("<th>Remaining To Transfer</th>");
            sb.Append("<th>Transfer Amount</th>");
            sb.Append("</tr>");
            sb.Append("</thead>");
            sb.Append("<tbody>");
            foreach (DataRow dr in dt.Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td>" + dr["BankName"] + "</td>");
                sb.Append("<td><span id=\"amt_" + dr["BankId"].ToString().Replace(" ", "") + "\">" + GetStatic.ShowDecimal(dr["RemainingtoTransfer"].ToString()) + "</span></td>");
                sb.Append("<td><input type=\"text\" name='txt_amt' id=\"txt_" + dr["BankId"].ToString().Replace(" ", "") + "\" onchange=\"Calculate('" + ids + "')\"/>" + "</td>");
                sb.Append("</tr>");
            }
            sb.Append("</tbody>");
            sb.Append("</table></div>");
            remainToTransfer.InnerHtml = sb.ToString();
        }

        private string GetIds(DataTable dt)
        {
            string ids = "";
            int i = 0;
            foreach (DataRow item in dt.Rows)
            {
                if (i == 0)
                {
                    ids += item["BankId"].ToString().Replace(" ", "");
                }
                else
                {
                    ids += "," + item["BankId"].ToString().Replace(" ", "");
                }
                i++;
            }
            hdnBankId.Value = ids;
            return ids;
        }

        protected void btnTransfer_Click(object sender, EventArgs e)
        {
            string tAmt = Request.Form["txt_amt"];
            string ids = hdnBankId.Value;
            var dbResult = _sd.SaveFundTransfer(ddlTransferFundTo.Text, tAmt, ids, GetStatic.GetUser(), date.Text);
            if (dbResult.ErrorCode == "1")
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
            else
            {
                divMsg.Visible = true;
                divMsg.InnerHtml = dbResult.Msg;
                remainToTransfer.InnerHtml = "";
                ddlTransferFundTo.Text = "";
            }
        }
    }
}