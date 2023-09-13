using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.BillVoucher.RefundWalletAmt
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20153100";
        private SwiftLibrary _sl = new SwiftLibrary();
        private readonly CustomersDao _obj = new CustomersDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnRefund_Click(object sender, EventArgs e)
        {
            if (GetStatic.ParseInt(refundAmt.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Refund amount can not be negetive");
                return;
            }
            if (GetStatic.ParseInt(hddAvailableBalance.Value) < GetStatic.ParseInt(refundAmt.Text))
            {
                GetStatic.AlertMessage(this, "Refund amount can not more than available amount");
                return;
            }
            var dbresult = _obj.RefundBalance(GetStatic.GetUser(), CustomerInfo.Value, refundAmt.Text, chargeAmt.Text);
            if (dbresult.ErrorCode == "0")
            {
                tblHistory.InnerHtml = dbresult.Msg;
                hddAvailableBalance.Value = "";
                refundAmt.Text = "";
                chargeAmt.Text = "";
                btnRefund.Visible = false;
                return;
            }
            GetStatic.AlertMessage(this, dbresult.Msg);
            return;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            double availableBalance = 0;
            if (!string.IsNullOrEmpty(CustomerInfo.Value))
            {
                DataTable dt = _obj.GetWalletInfo(GetStatic.GetUser(), CustomerInfo.Value);
                if (dt == null || dt.Rows.Count == 0)
                {
                    return;
                }
                if (dt.Rows[0]["errorCode"].ToString() != "0")
                {
                    return;
                }

                StringBuilder sb = new StringBuilder();
                foreach (DataRow item in dt.Rows)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + item["customerName"].ToString() + "</td>");
                    sb.AppendLine("<td>" + item["idNumber"].ToString() + "</td>");
                    sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["availableBalance"].ToString()) + "</td>");
                    sb.AppendLine("</tr>");

                    availableBalance = GetStatic.ParseDouble(item["availableBalance"].ToString());
                }
                tblHistory.InnerHtml = sb.ToString();
                hddAvailableBalance.Value = availableBalance.ToString();
                if (availableBalance <= 0)
                {
                    btnRefund.Visible = false;
                    searchDetail.Visible = false;
                }
                else
                {
                    btnRefund.Visible = true;
                    searchDetail.Visible = true;
                }
            }
        }
    }
}