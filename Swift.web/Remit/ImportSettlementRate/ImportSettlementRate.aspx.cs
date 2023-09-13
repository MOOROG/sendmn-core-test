using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;

namespace Swift.web.Remit.ImportSettlementRate
{
    public partial class ImportSettlementRate : System.Web.UI.Page
    {
        ImportSettlementRateDao _isd = new ImportSettlementRateDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private string ViewFunctionId = "20201000";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                step1.Visible = true;
                step1a.Visible = true;
                step2.Visible = false;
                step2a.Visible = false;

                GetStatic.PrintMessage(Page);
                Authenticate();
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void import_Click(object sender, EventArgs e)
        {
            DbResult _res = new DbResult();
            if (fileUpload.FileContent.Length > 0)
            {
                if (fileUpload.FileName.ToLower().Contains(".csv"))
                {
                    string path = Server.MapPath("..\\..\\") + "\\doc\\tmp\\" + fileUpload.FileName;
                    string Remitpath = Server.MapPath("..\\..\\") + "\\SampleFile\\VoucherEntry\\" + fileUpload.FileName;
                    fileUpload.SaveAs(path);
                    var xml = GetStatic.GetCSVFileInTable(path, true);

                    File.Delete(path);
                    var rs = _isd.ImportSettlementRate(GetStatic.GetUser(), xml, GetStatic.GetSessionId());

                    _res = _sl.ParseDbResult(rs.Tables[0]);
                    if (_res.ErrorCode == "0")
                    {
                        step1.Visible = false;
                        step1a.Visible = false;
                        step2.Visible = true;
                        step2a.Visible = true;

                        PopulateData(rs.Tables[1]);
                    }
                    else
                    {
                        GetStatic.AlertMessage(this, _res.Msg);
                    }
                }
                else
                {
                    GetStatic.AlertMessage(this, "Invalid file format!");
                }
            }

        }

        private void PopulateData(DataTable dt)
        {
            if (dt == null)
            {
                return;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td><input type='checkbox' name='chkRateUpload' value='" + item["ROW_ID"].ToString() + "' checked='true'/></td>");
                sb.AppendLine("<td>" + item["countryName"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["S_CURRENCY"].ToString()+" / "+ item["P_CURRENCY"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["OldRate"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["NewRate"].ToString() + "</td>");
                sb.AppendLine("</tr>");
            }

            rateTable.InnerHtml = sb.ToString();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            _isd.ClearData(GetStatic.GetUser(), GetStatic.GetSessionId());
            step1.Visible = true;
            step1a.Visible = true;
            step2.Visible = false;
            step2a.Visible = false;
        }

        protected void btnConfirmSave_Click(object sender, EventArgs e)
        {
            var Ids = Request.Form["chkRateUpload"];
            if (!string.IsNullOrEmpty(Ids))
            {
                var _res = _isd.ConfirmSave(GetStatic.GetUser(), Ids, GetStatic.GetSessionId());

                if (_res.ErrorCode == "0")
                {
                    step1.Visible = true;
                    step1a.Visible = true;
                    step2.Visible = false;
                    step2a.Visible = false;

                    GetStatic.AlertMessage(this, _res.Msg);
                }
                else
                {
                    GetStatic.AlertMessage(this, _res.Msg);
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Please choose at least on record!");
            }
        }
    }
}