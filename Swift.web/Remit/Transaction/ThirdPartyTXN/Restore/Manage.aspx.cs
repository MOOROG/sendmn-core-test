using System;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction.ThirdParty;
//using Swift.DAL.BL.Remit.Transaction.ThirdParty.CashExpress;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.EzRemit;
//using Swift.DAL.BL.Remit.Transaction.ThirdParty.Ria;
using Swift.DAL.BL.System.Utility;
using Swift.web.Library;
using Swift.DAL.BL.Remit.Transaction.InstantCash;
using System.Data;
//using Swift.DAL.BL.Remit.Transaction.ThirdParty.GlobalBank;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.Restore
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly InstantCashDao icDao = new InstantCashDao();
      //  private readonly CashExpressDao ceDao = new CashExpressDao();
      //  private readonly GlobalBankDao gblDao = new GlobalBankDao();
        //private readonly EzRemitDao ezRemitDao=new EzRemitDao();        
        //private readonly RiaDao riaDao=new RiaDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txnDetails.Visible = false;
            }
        }

        public void Authentication()
        {
            //_sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PrintMessage(string msg)
        {
            GetStatic.AlertMessage(Page, msg);

        }
        
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SetControlNo();
            var dbResult = new TransactionUtilityDao().GetTxnStatus(GetStatic.GetUser(), hddControlNo.Value);
            if (dbResult.ErrorCode.Equals("0"))
            {
                PrintMessage(dbResult.Msg);
                return;
            }
            SearchTxn();
        }

        private void SetControlNo()
        {
            hddControlNo.Value = controlNo.Text;
        }

        private void SearchTxn()
        {
            var tAgentId = partner.Text;
            DataRow dr = null;
            if (tAgentId.Equals(Utility.GetgblAgentId()))
            {
                dr = GetGlobalTxn(hddControlNo.Value);
            }
            else if (tAgentId.Equals(Utility.GetICAgentId()))
            {
                dr = GetICTxn(hddControlNo.Value);
            }
            else if (tAgentId.Equals(Utility.GetCEAgentId()))
            {
                dr = GetCETxn(hddControlNo.Value);
            }
            else if (tAgentId.Equals(Utility.GetriaAgentID()))
            {
                //dr = GetRiaTxn(hddControlNo.Value);
            }
            else if (tAgentId.Equals(Utility.GetezAgentID()))
            {
                dr = GetEzTxn(hddControlNo.Value);
            }
            if (dr == null)
            {
                PrintMessage("Invalid Control Number!");
                return;
            }
            LoadTxnDetail(dr);
        }

        private DataRow GetGlobalTxn(string ctrlNo)
        {
           // return gblDao.GetTxnDetail(GetStatic.GetUser(), ctrlNo);
            return null;
        }

        private DataRow GetICTxn(string ctrlNo)
        {
            return icDao.GetTxnDetail(GetStatic.GetUser(), ctrlNo);
        }

        private DataRow GetCETxn(string ctrlNo)
        {
            //return ceDao.GetTxnDetail(GetStatic.GetUser(), ctrlNo);
            return null;
        }

        //private DataRow GetRiaTxn(string ctrlNo)
        //{
        //    return riaDao.GetTxnDetail(GetStatic.GetUser(), ctrlNo);
        //}

        private DataRow GetEzTxn(string ctrlNo)
        {
            //return ezRemitDao.GetTxnDetail(GetStatic.GetUser(), ctrlNo);
            return null;
        }

        private void LoadTxnDetail(DataRow dr)
        {

            txnDetails.Visible = true;

            //Payout Amount detail
            lblControlNo.Text = dr["controlNo"].ToString();
            pAmt.Text = GetStatic.FormatData(dr["pAmt"].ToString(), "M");
            pCurr.Text = dr["pCurr"].ToString();
            pBranch.Text = dr["pBranch"].ToString();

            //Sender Detail
            sCountry.Text = dr["sCountry"].ToString();
            sName.Text = dr["sName"].ToString();
            sAddress.Text = dr["sAddress"].ToString();
            sIdType.Text = dr["sIdType"].ToString();
            sIdNumber.Text = dr["sIdNumber"].ToString();

            //Receiver Detail
            rCountry.Text = dr["rCountry"].ToString();
            rName.Text = dr["rName"].ToString();
            rAddress.Text = dr["rAddress"].ToString();
            rCity.Text = dr["rCity"].ToString();
            rIdType.Text = dr["rIdType"].ToString();
            rIdNumber.Text = dr["rIdNumber"].ToString();
            rPhone.Text = dr["rPhone"].ToString();

            hddRowId.Value = dr["rowId"].ToString();

        }

        protected void btnRestore_Click(object sender, EventArgs e)
        {
            var tAgentId = partner.Text;
            if (tAgentId.Equals(Utility.GetgblAgentId()))
            {
                RestoreGlobalTxn();
            }
            else if (tAgentId.Equals(Utility.GetICAgentId()))
            {
                RestoreICTxn();
            }
            else if (tAgentId.Equals(Utility.GetCEAgentId()))
            {
                RestoreCETxn();
            }
            else if (tAgentId.Equals(Utility.GetriaAgentID()))
            {
                //RestoreRiaTxn();
            }
            else if (tAgentId.Equals(Utility.GetezAgentID()))
            {
                RestoreEzTxn();
            }

        }


        private void RestoreGlobalTxn()
        {
            //var dbResult = gblDao.RestoreTransaction(GetStatic.GetBranch(), GetStatic.GetBranchName(), GetStatic.GetUser(), hddRowId.Value);
            //PrintMessage(dbResult.Msg);
        }

        private void RestoreICTxn()
        {
            var dbResult = icDao.RestoreTransaction(GetStatic.GetBranch(), GetStatic.GetBranchName(), GetStatic.GetUser(), hddRowId.Value);
            PrintMessage(dbResult.Msg);
        }

        private void RestoreCETxn()
        {
            //var dbResult = ceDao.RestoreTransaction(GetStatic.GetBranch(), GetStatic.GetBranchName(), GetStatic.GetUser(), hddRowId.Value);
            //PrintMessage(dbResult.Msg);
            
        }

        //private void RestoreRiaTxn()
        //{
        //    var dbResult =riaDao.RestoreTransaction(GetStatic.GetBranch(), GetStatic.GetBranchName(), GetStatic.GetUser(), hddRowId.Value);
        //    PrintMessage(dbResult.Msg);
        //}

        private void RestoreEzTxn()
        {
            //var dbResult =ezRemitDao.RestoreTransaction(GetStatic.GetBranch(), GetStatic.GetBranchName(), GetStatic.GetUser(), hddRowId.Value);
            //PrintMessage(dbResult.Msg);
        }

    }
}