using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.RemmitanceVoucher
{
    public partial class List : System.Web.UI.Page
    {
        private VoucherGeneration Dao = new VoucherGeneration();
        private const string ViewFunctionId = "20150200,20150210,20150220";
        private const string IntlFunctionId = "20150210";
        private const string DomFunctionId = "20150220";
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                domesticdate.Text = DateTime.Now.ToString("d");
                intDate.Text = DateTime.Now.ToString("d");
                intDate.Attributes.Add("readonly", "readonly");
                domesticdate.Attributes.Add("readonly", "readonly");
                fromDate.Text = DateTime.Now.ToString("d");
                fromDate.Attributes.Add("readonly", "readonly");
                toDate.Text = DateTime.Now.ToString("d");
                toDate.Attributes.Add("readonly", "readonly");
                voucherDate.Text = DateTime.Now.ToString("d");
                voucherDate.Attributes.Add("readonly", "readonly");
            }

            sqlMsg.InnerHtml = "";
            domesticSqlMsg.InnerHtml = "";
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
            uploadFunction.Visible = _sl.HasRight(ViewFunctionId);
            intFunction.Visible = _sl.HasRight(IntlFunctionId);
            domFunction.Visible = _sl.HasRight(DomFunctionId);
        }

        protected void btnsend_Click(object sender, EventArgs e)
        {
            var Result = Dao.IntSendVoucher(GetStatic.GetUser(), intDate.Text, rate.Text);
            sqlMsg.InnerHtml = Result.Msg;
            sqlMsg.Visible = true;
        }

        protected void btnpaid_Click(object sender, EventArgs e)
        {
            var Result = Dao.IntPaidVoucher(GetStatic.GetUser(), intDate.Text);
            sqlMsg.InnerHtml = Result.Msg;
            sqlMsg.Visible = true;
        }

        protected void btncancel_Click(object sender, EventArgs e)
        {
            var Result = Dao.IntCancelVoucher(GetStatic.GetUser(), intDate.Text, rate.Text);
            sqlMsg.InnerHtml = Result.Msg;
            sqlMsg.Visible = true;
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fileUpload.FileContent.Length > 0)
            {
                if (fileUpload.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\") + "\\doc\\tmp\\" + fileUpload.FileName;
                    string Remitpath = Server.MapPath("..\\..\\") + "\\doc\\RemittanceFile\\" + fileUpload.FileName;
                    fileUpload.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTable(path, true);
                    DataRow dr = Dao.UploadXMLData(xml, GetStatic.GetUser());
                    PopulateConfirmData(dr);
                    //File.Move(path, Remitpath);
                }
                else
                {
                    divuploadMsg.Visible = true;
                    divuploadMsg.InnerHtml = "Invalid file format uploaded";
                }
            }
        }

        private void PopulateConfirmData(DataRow dr)
        {
            if (dr["code"].ToString() == "0")
            {
                divUploadSuccess.Visible = false;
                divuploadMsg.Visible = false;
                showLog.Visible = true;
                uploadDiv.Visible = false;
                StringBuilder sb = new StringBuilder("<tr>");
                sb.AppendLine("<td>" + dr["COUNT"].ToString() + "</td>");
                sb.AppendLine("<td>" + FormatData(dr["S_AMT"].ToString()) + "</td>");
                sb.AppendLine("<td>" + FormatData(dr["P_AMT"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
                logTbl.InnerHtml = sb.ToString();
            }
            else
            {
                divUploadSuccess.Visible = false;
                divuploadMsg.Visible = true;
                divuploadMsg.InnerHtml = dr["msg"].ToString();
                showLog.Visible = false;
                uploadDiv.Visible = true;
            }
        }

        private string FormatData(string input)
        {
            if (!string.IsNullOrEmpty(input))
            {
                double data = Convert.ToDouble(input);
                return string.Format("{0:0.00}", data);
            }
            else
                return "0.00";
        }

        protected void sendvoucher_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendVoucher(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void sendtpt_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendTPToday(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void sendtct_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendTCToday(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void sendtnpt_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendTNotPToday(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void sendbpt_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendBPToday(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void sendbct_Click(object sender, EventArgs e)
        {
            var Result = Dao.DmtSendBCToday(GetStatic.GetUser(), domesticdate.Text, ddlTime.Text);
            PrintMsg(Result);
        }

        protected void confirm_Click(object sender, EventArgs e)
        {
            var Result = Dao.RemitUploadConfirm(GetStatic.GetUser());

            divUploadSuccess.Visible = true;
            uploadDiv.Visible = true;
            showLog.Visible = false;
            divUploadSuccess.InnerHtml = Result.Msg;
        }

        protected void PrintMsg(DbResult dbRes)
        {
            if (dbRes.ErrorCode == "0")
            {
                domesticSqlSuccessMsg.Visible = true;
                domesticSqlSuccessMsg.InnerHtml = dbRes.Msg;
            }
            else
            {
                domesticSqlMsg.Visible = true;
                domesticSqlMsg.InnerHtml = dbRes.Msg;
            }
        }

        protected void btnTds_Click(object sender, EventArgs e)
        {
            var fDate = fromDate.Text;
            var tDate = toDate.Text;
            var vDate = voucherDate.Text;
            var result = Dao.CalculateTdsAgent(fDate, tDate, vDate, GetStatic.GetUser());
            PrintMsg(result);
        }
    }
}