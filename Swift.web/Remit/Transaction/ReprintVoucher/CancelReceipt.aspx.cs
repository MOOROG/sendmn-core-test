using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ReprintVoucher
{
    public partial class CancelReceipt : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private CancelTransactionDao _obj = new CancelTransactionDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadReceipt();
        }

        private void Authenticate()
        {
            _sl.CheckSession();
        }
        private long GetTranId()
        {
            return GetStatic.ReadNumericDataFromQueryString("tranId");
        }

        private void LoadReceipt()
        {
            var dr = _obj.LoadReceipt(GetStatic.GetUser(), GetTranId().ToString());
            if (dr == null)
                return;

            controlNo.Text = dr["controlNo"].ToString();
            postedBy.Text = dr["postedBy"].ToString();
            sender.Text = dr["sender"].ToString();
            receiver.Text = dr["receiver"].ToString();
            rContactNo.Text = dr["rContactNo"].ToString();
            collCurr.Text = dr["collCurr"].ToString();
            cAmt.Text = GetStatic.FormatData(dr["cAmt"].ToString(), "M");
            serviceCharge.Text = GetStatic.FormatData(dr["serviceCharge"].ToString(), "M");
            pAmt.Text = GetStatic.FormatData(dr["pAmt"].ToString(), "M");
            cancelCharge.Text = GetStatic.FormatData(dr["cancelCharge"].ToString(), "M");
            returnAmt.Text = GetStatic.FormatData(dr["returnAmt"].ToString(), "M");
            sendDate.Text = dr["createdDate"].ToString();
            cancelDate.Text = dr["cancelDate"].ToString();
        }
    }
}