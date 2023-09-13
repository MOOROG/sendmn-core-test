using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher {
  public partial class ContactVoucher : System.Web.UI.Page {
    private readonly ReceiptDao obj = new ReceiptDao();
    private readonly SwiftLibrary sl = new SwiftLibrary();

    protected void Page_Load(object sender, EventArgs e) {
      if (!GetStatic.ReadQueryString("flg", "").Equals("0")) {
        sl.CheckSession();
        GetStatic.AlertMessage(this.Page);
      }
      ShowData();
      ShowMultipleReceipt();
      if (!IsPostBack) {
        officeCenterDiv.Visible = false;
      }

      if (hide.Value == "office") {
        officeDiv.Visible = false;
        customerDiv.Visible = true;
        officeCenterDiv.Visible = false;
        Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "Print()", true);

      } else if (hide.Value == "customer") {
        customerDiv.Visible = false;
        officeDiv.Visible = true;
        officeDiv.Attributes["style"] = "margin-top:120px;";
        officeCenterDiv.Visible = true;
        Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "Print()", true);
      } else if (hide.Value == "both") {
        officeDiv.Visible = true;
        customerDiv.Visible = true;
        officeCenterDiv.Visible = false;
        Page.ClientScript.RegisterStartupScript(this.GetType(), "CallMyFunction", "Print()", true);
      }

    }
    private void ShowMultipleReceipt() {
      if (GetInvoicePrintMode() != "") {
        if (GetInvoicePrintMode() == "s") {
          divInvoiceSecond.Attributes.Add("style", "margin: 15px 0; display: none;");
          divInvoiceSecond1.Attributes.Add("style", "display: none;");
        }
      }
    }

    private string GetControlNo() {
      return GetStatic.ReadQueryString("controlNo", "");
    }

    private string GetInvoicePrintMode() {
      return GetStatic.ReadQueryString("invoicePrint", "");
    }

    protected void ShowData() {
      //lblControlNo.Text = GetStatic.GetTranNoName();
      DataSet ds = obj.GetSendIntlReceipt(GetControlNo(), GetStatic.GetUser(), "S");
      if (ds.Tables.Count >= 1) {
        if (ds.Tables[0].Rows.Count > 0) {
          //Load Sender Information
          DataRow sRow = ds.Tables[0].Rows[0];
          tranStatus.Text = sRow["tranStatus"].ToString();
          senderName.Text = sRow["senderName"].ToString();
          sMemId.Text = sRow["sMemId"].ToString();
          sAddress.Text = sRow["sAddress"].ToString();
          sNativeCountry.Text = sRow["sNativeCountry"].ToString();
          purpose.Text = sRow["payoutMsg"].ToString();
          sDob.Text = sRow["sDob"].ToString();
          sContactNo.Text = sRow["sContactNo"].ToString();
          visaStatus.Text = sRow["visaStatus"].ToString();
          custEmail.Value = sRow["Email"].ToString();

          serial1.Text = sRow["tranId"].ToString();
          serial2.Text = sRow["tranId"].ToString();
          //Load Receiver Information
          receiverName.Text = sRow["receiverName"].ToString();
          pAgentCountry.Text = sRow["pAgentCountry"].ToString();
          paymentMode.Text = sRow["paymentMode"].ToString();
          rContactNo.Text = sRow["rContactNo"].ToString();
          pAgent.Text = sRow["pAgent"].ToString();
          rAddress.Text = sRow["rAddress"].ToString();
          pBankName.Text = sRow["pBankName"].ToString();
          relationShip.Text = sRow["relwithSender"].ToString();

          pBranchName.Text = sRow["BranchName"].ToString();
          accountNo.Text = sRow["accountNo"].ToString();
          controlNo.Text = sRow["controlNo"].ToString();
          createdBy.Text = sRow["createdBy"].ToString();
          approvedDate.Text = DateTime.Parse(sRow["createdDate"].ToString()).ToString("yyyy-MM-dd hh:mm:ss tt");
          cAmt.Text = GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
          serviceCharge.Text = GetStatic.ShowWithoutDecimal(sRow["serviceCharge"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
          tAmt.Text = GetStatic.ShowWithoutDecimal(sRow["tAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
          exRate.Text = sRow["exRate"].ToString() + "&nbsp" + sRow["payoutCurr"].ToString();
          pAmt.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + "&nbsp" + sRow["payoutCurr"].ToString();
          depositType.Text = sRow["collMode"].ToString();

          //operator1.Text = sRow["createdBy"].ToString();
          //operator1.Text = "";

          //for second from
          //Load Sender Information
          senderName1.Text = sRow["senderName"].ToString();
          sMemId1.Text = sRow["sMemId"].ToString();
          sAddress1.Text = sRow["sAddress"].ToString();
          sNativeCountry1.Text = sRow["sNativeCountry"].ToString();
          purpose1.Text = sRow["purpose"].ToString();
          sDob1.Text = sRow["sDob"].ToString();
          sContactNo1.Text = sRow["sContactNo"].ToString();
          visaStatus1.Text = sRow["visaStatus"].ToString();

          //Load Receiver Information
          receiverName1.Text = sRow["receiverName"].ToString();
          pAgentCountry1.Text = sRow["pAgentCountry"].ToString();
          paymentMode1.Text = sRow["paymentMode"].ToString();
          rContactNo1.Text = sRow["rContactNo"].ToString();
          pAgent1.Text = sRow["pAgent"].ToString();
          rAddress1.Text = sRow["rAddress"].ToString();
          pBankName1.Text = sRow["pBankName"].ToString();
          relationShip1.Text = sRow["relwithSender"].ToString();

          pBranchName1.Text = sRow["BranchName"].ToString();
          accountNo1.Text = sRow["accountNo"].ToString();
          //rAmtWords1.Text = GetStatic.NumberToWord(sRow["pAmt"].ToString());
          controlNo1.Text = sRow["controlNo"].ToString();
          createdBy1.Text = sRow["createdBy"].ToString();
          approvedDate1.Text = DateTime.Parse(sRow["createdDate"].ToString()).ToString("yyyy-MM-dd hh:mm:ss tt");

          cAmt1.Text = GetStatic.ShowWithoutDecimal(sRow["cAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
          serviceCharge1.Text = GetStatic.ShowWithoutDecimal(sRow["serviceCharge"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();

          tAmt1.Text = GetStatic.ShowWithoutDecimal(sRow["tAmt"].ToString()) + "&nbsp" + sRow["collCurr"].ToString();
          exRate1.Text = sRow["exRate"].ToString() + "&nbsp" + sRow["payoutCurr"].ToString();
          pAmt1.Text = GetStatic.ShowDecimal(sRow["pAmt"].ToString()) + "&nbsp" + sRow["payoutCurr"].ToString();
          depositType1.Text = sRow["collMode"].ToString();
          //operator2.Text = sRow["createdBy"].ToString();
          //operator2.Text = "";

          if (sRow["paymentMethod"].ToString().ToUpper().Equals("CASH PAYMENT")) {
            bank3.Attributes.Add("style", "display: none;");
            bank4.Attributes.Add("style", "display: none;");
            bank5.Attributes.Add("style", "display: none;");
            bank6.Attributes.Add("style", "display: none;");
            bank7.Attributes.Add("style", "display: none;");
            bank8.Attributes.Add("style", "display: none;");
            bank9.Attributes.Add("style", "display: none;");
            bank10.Attributes.Add("style", "display: none;");
            bankLable.InnerHtml = "Cash Location";
            bankLable1.InnerHtml = "Cash Location";
          }

          if (GetStatic.ReadQueryString("flg", "").Equals("0")) {
            officeDiv.Visible = false;
            btnSave.Visible = false;
          }
        }
      }
    }
  }
}