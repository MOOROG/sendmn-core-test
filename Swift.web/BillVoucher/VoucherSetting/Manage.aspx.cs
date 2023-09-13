using Swift.DAL.VoucherReport;
using Swift.web.Library;
using System;

namespace Swift.web.BillVoucher.VoucherSetting
{
    public partial class Manage : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private VoucherReportDAO _vrdao = new VoucherReportDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                if (!string.IsNullOrWhiteSpace(GetId()))
                {
                    PopulateData();
                }
            }
        }

        private void PopulateData()
        {
            var dr = _vrdao.getVoucherSettingData(GetId());
            voucherType.Text = dr["V_TYPE"].ToString();
            approvalMode.Text = dr["Approval_mode"].ToString();
            createdBy.Text = dr["created_by"].ToString();
            createdDate.Text = dr["created_date"].ToString();
            modifiedBy.Text = dr["modified_by"].ToString();
            modifiedDate.Text = dr["modified_date"].ToString();
        }

        private string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            var res = _vrdao.updateVoucherSetting(GetId(), approvalMode.SelectedValue, GetStatic.GetUser());
            if (res.ErrorCode == "0")
            {
                GetStatic.SetMessage(res);
                Response.Redirect("List.aspx");
            }
        }
    }
}