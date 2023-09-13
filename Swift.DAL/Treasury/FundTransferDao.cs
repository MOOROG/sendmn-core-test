using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Treasury
{
    public class FundTransferDao : SwiftDao, IFundTransferDao
    {

        public DbResult AddNewBank(string bankName, string krwAcc, string usdAcc, string user, string rowID, string hasChk)
        {
            string sql = "exec proc_DealBankSetting  @Flag=" + (rowID == "0" || rowID == "" ? "'i'" : "'u'");
            sql += ",@rowID=" + FilterString(rowID);
            sql += ",@BankName=" + FilterString(bankName);
            sql += ",@SellAccNo=" + FilterString(krwAcc);
            sql += ",@BuyAccNo=" + FilterString(usdAcc);
            sql += ",@Settle_PayCurr=" + FilterString(hasChk);
            sql += ",@User=" + FilterString(user);
            return ParseDbResult(sql);
        }

        public DbResult SaveDealBooking(string Date, string BankId, string UsdAmt, string Rate, string LCYAmt, string Dealer, string MaturityDate, string ContractNo, string User)
        {
            var sql = "Exec spa_saveDealBookingVoucher ";
            sql += " @date =" + FilterString(Date);
            sql += ",@BankId =" + FilterString(BankId);
            sql += ",@UsdAmt =" + FilterString(UsdAmt);
            sql += ",@Rate =" + FilterString(Rate);
            sql += ",@LCYAmt =" + FilterString(LCYAmt);
            sql += ",@Dealer =" + FilterString(Dealer);
            sql += ",@MaturityDate =" + FilterString(MaturityDate);
            sql += ",@ContractNo =" + FilterString(ContractNo);
            sql += ",@User =" + FilterString(User);

            return ParseDbResult(sql);
        }
        public DataRow SelectBankById(string Id, string User)
        {
            string sql = "exec proc_DealBankSetting  @Flag='sById' ";
            sql += ",@rowID=" + FilterString(Id);
            sql += ",@User=" + FilterString(User);
            return ExecuteDataRow(sql);
        }

        public DataTable GetDealSummaryToTransfer(string bankId)
        {
            var sql = "EXEC proc_DealStockSummary @flag='s'";
            sql += " ,@bankId=" + FilterString(bankId);
            return ExecuteDataTable(sql);
        }

        public DbResult SaveFundTransfer(string PartnerId, string tAmt, string ids, string User,string Date)
        {
            var sql = "EXEC proc_fundTransferFifo ";
            sql += " @ReceivingPartner=" + FilterString(PartnerId);
            sql += " ,@User=" + FilterString(User);
            sql += " ,@DATE=" + FilterString(Date);
            sql += " ,@TxnAmt=" + FilterString(tAmt);
            sql += " ,@Ids=" + FilterString(ids);
            return ParseDbResult(sql);
        }

        public DbResult UpdateFundTransferDetail(string rowId, string nameOfPartner, string receiveInUSD, string furtherTransferTo, string User)
        {
            var sql = "EXEC proc_DealBankSetting ";
            sql += " @flag='u-payoutAcc'";
            sql += " ,@rowId=" + FilterString(rowId);
            sql += " ,@User=" + FilterString(User);
            sql += " ,@nameOfPartner=" + FilterString(nameOfPartner);
            sql += " ,@receiveUSDNostro=" + FilterString(receiveInUSD);
            sql += " ,@receiveUSDCorrespondent=" + FilterString(furtherTransferTo);
            return ParseDbResult(sql);
        }

        public DataRow GetSettingDetails(string rowId)
        {
            var sql = "EXEC proc_DealBankSetting ";
            sql += " @flag='s-payoutAcc'";
            sql += " ,@rowId=" + FilterString(rowId);
            
            return ExecuteDataRow(sql);
        }


        public DbResult AddCorrespondent(string TransferFund, string PartnerName, string ReceiveAc, string CorrespondentAc, string User, string Id)
        {
            string sql = "exec proc_PayoutAgentAccount  @Flag=" + (Id == "0" || Id == "" ? "'i'" : "'u'");
            sql += " ,@TransferType=" + FilterString(TransferFund);
            sql += " ,@nameOfPartner=" + FilterString(PartnerName);
            sql += " ,@receiveUSDNostro=" + FilterString(ReceiveAc);
            sql += " ,@receiveUSDCorrespondent=" + FilterString(CorrespondentAc);
            sql += " ,@User=" + FilterString(User);
            sql += " ,@rowID=" + FilterString(Id);
            return ParseDbResult(sql);
        }


        public DataRow SelectCorrespondentBankById(string Id, string User)
        {
            var sql = "EXEC proc_PayoutAgentAccount  @flag='a'";
            sql += " ,@rowId=" + FilterString(Id);

            return ExecuteDataRow(sql);
        }
    }
}
