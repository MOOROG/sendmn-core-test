using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.AccountReport
{
    public class VoucherGeneration : SwiftDao
    {
        public DbResult IntSendVoucher(String user, String txtDate, string Rate)
        {
            var sql = "Exec ProcExtractDailyTransation_nepal  @flag='v'";
            sql += " ,@date= " + FilterString(txtDate);
            sql += " ,@ExRate_user= " + FilterString(Rate);
            sql += " ,@user= " + FilterString(user);
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }

        public DbResult IntPaidVoucher(String user, String date)
        {
            var sql = "Exec ProcExtractDailyPaidTransation_nepal @flag='i'";
            sql += ",@date=" + FilterString(date);
            sql += " ,@user=" + FilterString(user);
            sql += ",@company_id=1";
            return ParseDbResult(sql);
        }
        public DbResult IntCancelVoucher(String user, String date, String rate)
        {
            var sql = "Exec ProcExtractDailyCancelTransation_nepal @flag='v'";
            sql += ",@date=" + FilterString(date);
            sql += " ,@user=" + FilterString(user);
            sql += " ,@ExRate_user=" + FilterString(rate);
            sql += ",@company_id=1";
            return ParseDbResult(sql);
        }

        public DbResult RemitUploadConfirm(String user)
        {
            var sql = "Exec ProcRemittanceDataUpload @flag='confirm'";
            sql += " ,@user=" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataRow UploadXMLData(string xml, string user)
        {
            var sql = "Exec ProcRemittanceDataUpload @flag='temp'";
            sql += " ,@user=" + FilterString(user);
            sql += " ,@xml='" + xml + "'";

            return ExecuteDataRow(sql);
        }

        public DbResult UploadXMLDatas(string xml, string user)
        {
            var sql = "Exec ProcRemittanceDataUpload @flag='virtualAccNumberMapping'";
            sql += " ,@user=" + FilterString(user);
            sql += " ,@xml='" + xml + "'";

            return ParseDbResult(sql);
        }

        public DbResult DmtSendVoucher(String user, String date, string time)
        {
            var sql = "Exec procSendRemittanceTran_local @flag='a'";
            sql += " ,@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";

            return ParseDbResult(sql);

        }
        public DbResult DmtSendTPToday(String user, String date, string time)
        {
            var sql = "Exec procSendTodayPaidTodayTrn_local @flag='a'";
            sql += ",@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }
        public DbResult DmtSendTCToday(String user, String date, string time)
        {
            var sql = "Exec procSendTodayCancelTodayTrn_local @flag='a'";
            sql += ",@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }
        public DbResult DmtSendTNotPToday(String user, String date, string time)
        {
            var sql = "Exec procSendTodayNotPaidTodayTrn_local @flag='a'";
            sql += ",@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }
        public DbResult DmtSendBPToday(String user, String date, string time)
        {
            var sql = "Exec procSendYesterdayPaidTodayTran_local  @flag='a'";
            sql += ",@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }
        public DbResult DmtSendBCToday(String user, String date, string time)
        {
            var sql = "Exec procSendYesterdayCancelTodayTrn_local @flag='a'";
            sql += ",@user=" + FilterString(user);
            sql += ",@date=" + FilterString(date);
            sql += ",@time=" + FilterString(time.ToString());
            sql += " ,@company_id=1 ";
            return ParseDbResult(sql);
        }


        public DbResult CalculateTdsAgent(string fromDate, string toDate, string voucherDate,string User)
        {
            string sql = "Exec ProcTDSCalculateMonthly ";
            sql += " @datefrom=" + FilterString(fromDate);
            sql += ",@dateTo=" + FilterString(toDate);
            sql += ",@date=" + FilterString(voucherDate);
            sql += ",@User=" + FilterString(User);
            sql += ",@company_id=1 ";
            return ParseDbResult(sql);
        }

    }
}
