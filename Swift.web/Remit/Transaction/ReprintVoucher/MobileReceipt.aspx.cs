using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher {
  public partial class MobileReceipt : System.Web.UI.Page {
    private readonly ReceiptDao obj = new ReceiptDao();
    private readonly SwiftLibrary sl = new SwiftLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      ShowData();
    }

    private string GetControlNo() {
      return GetStatic.ReadQueryString("controlNo", "");
    }

    protected void ShowData() {
      DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
      if (ds.Tables.Count >= 1) {
        if (ds.Tables[0].Rows.Count > 0) {
          DataRow sRow = ds.Tables[0].Rows[0];
          HControlNo.Text = sRow["controlNo"].ToString();
          curDate.Text = DateTime.Parse(sRow["createdDate"].ToString()).ToString("yyyy-MM-dd");
          senderName.Text = sRow["senderName"].ToString();
          memberId.Text = sRow["sMemId"].ToString();
          sCountry.Text = sRow["sCountryName"].ToString();
          sContactNo.Text = sRow["sContactNo"].ToString();
          sAddress.Text = sRow["sAddress"].ToString();
          pCountry.Text = sRow["rCountryName"].ToString();
          receiverName.Text = sRow["receiverName"].ToString();
          rContactNo.Text = sRow["rContactNo"].ToString();
          rAddress.Text = sRow["rAddress"].ToString();
          relWithSender.Text = sRow["relWithSender"].ToString();
          txnNum.Text = sRow["controlNo"].ToString();
          txnAmount.Text = sRow["cAmt"].ToString();
          txnNote.Text = sRow["purpose"].ToString();
          paymentMode.Text = sRow["paymentMode"].ToString();
          bankName.Text = sRow["BankName"].ToString();
          bankAccNum.Text = sRow["accountNo"].ToString();

          //operator1.Text = "Г. Гоёоцэцэг";
        }
      }
    }
  }
}