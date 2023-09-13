using System;
using Swift.DAL.SwiftDAL;
using System.Data;
using Swift.DAL.Common;
using System.Collections.Generic;
using Swift.DAL.Library;

namespace Swift.DAL.VoucherReport
{
    public class VoucherReportDAO : SwiftDao
    {
        public DataTable GetVoucherReport(string vNum, string typeDDL, string searchType = "v")
        {
            var sql = "Exec procUserStatement @flag = 't' ";
            sql += ",@user =" + FilterString(vNum);
            sql += " ,@vouchertype = " + FilterString(typeDDL);
            sql += " ,@searchType = " + FilterString(searchType);
            sql += ",@company_id =1";

            return ExecuteDataTable(sql);
        }

        public DataTable GetEditVoucherData(string RefNum, string TranType, string SessionID, string flag)
        {
            var sql = "Exec proc_EditVoucher @flag =" + FilterString(flag);
            sql += ",@refNum =" + FilterString(RefNum);
            sql += " ,@tranType = " + FilterString(TranType);
            sql += " ,@sessionID = " + FilterString(SessionID);

            return ExecuteDataTable(sql);
        }

        public DbResult InsertTempVoucherEntryUSD(string sessionID, string entry_user_id, string acct_num, string part_tran_type, string usd_amt,
           string rate, string lc_amt)
        {
            var sql = "Exec proc_voucherEntryUSD @flag = 'i' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@entry_user_id =" + FilterString(entry_user_id);
            sql += ",@acct_num =" + FilterString(acct_num);
            sql += ",@usd_amt =" + FilterString(usd_amt);
            sql += ",@ex_rate =" + FilterString(rate);
            sql += ",@lc_amt =" + FilterString(lc_amt);
            sql += ",@part_tran_type =" + FilterString(part_tran_type);

            return ParseDbResult(sql);
        }

        public DataTable GetTempVoucherEntryDataFRV(string sessionID)
        {
            var sql = "Exec proc_voucherEntryFRV @flag = 's' ";
            sql += ",@sessionID =" + FilterString(sessionID);

            return ExecuteDataTable(sql);
        }

        public DbResult InsertEditTempVoucherEntry(string sessionId, string user, string accNum, string tranType, string amount, string refNum, string vType)
        {
            var sql = "Exec proc_EditVoucher @flag = 'i' ";
            sql += ",@tranType = " + FilterString(tranType);//for dr or cr 
            sql += ",@sessionID = " + FilterString(sessionId);
            sql += ",@user = " + FilterString(user);
            sql += ",@accNum = " + FilterString(accNum);
            sql += ",@amount = " + FilterString(amount);
            sql += ",@refNum = " + FilterString(refNum);
            sql += ",@vType = " + FilterString(vType);
            return ParseDbResult(sql);
        }

        public DbResult DeleteRecordVoucherEntryFRV(string tranID)
        {
            var sql = "Exec proc_voucherEntryFRV @flag = 'd' ";
            sql += ",@tran_id = " + FilterString(tranID);
            return ParseDbResult(sql);
        }

        public DbResult SaveTempTransactionUSD(string sessionID, string date, string narration, string strCheckNo, string v_type, string user, string voucherPath)
        {
            var sql = "Exec spa_saveTempTrnUSD @flag='i'";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@date =" + FilterString(date);
            sql += ",@narration =" + FilterString(narration);
            sql += ",@v_type =" + FilterString(v_type);
            sql += ",@user =" + FilterString(user);
            sql += ",@voucherPath =" + FilterString(voucherPath);

            return ParseDbResult(sql);
        }

        public DataTable SaveTempTransactionUSDMultiple(string sessionID, string date, string narration, string strCheckNo, string v_type, string user, string voucherPath)
        {
            var sql = "Exec spa_saveTempTrnUSD_Multiple @flag='i'";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@date =" + FilterString(date);
            sql += ",@narration =" + FilterString(narration);
            sql += ",@v_type =" + FilterString(v_type);
            sql += ",@user =" + FilterString(user);
            sql += ",@voucherPath =" + FilterString(voucherPath);

            return ExecuteDataTable(sql);
        }

        public DbResult finalSaveEditVoucher(string sessionId, string user, string tranDate, string refNum, string vType, string narration, string chequeNo)
        {
            var sql = "Exec proc_EditVoucher @flag = 'final' ";
            sql += ",@sessionID = " + FilterString(sessionId);
            sql += ",@user = " + FilterString(user);
            sql += ",@date = " + FilterString(tranDate);//.......@,@,@,@,@,@,@date
            sql += ",@refNum = " + FilterString(refNum);
            sql += ",@vType = " + FilterString(vType);
            sql += ",@remarks = " + FilterString(narration);
            sql += ",@chequeNo = " + FilterString(chequeNo);
            return ParseDbResult(sql);
        }

        public DbResult DeleteEditVoucherEntry(string id, string sessionId)
        {
            var sql = "Exec proc_EditVoucher @flag = 'd' ";
            sql += ",@tranId = " + FilterString(id);
            sql += ",@sessionID = " + FilterString(sessionId);
            return ParseDbResult(sql);
        }

        public DbResult InsertTempVoucherEntryDetailsNew(string sessionID, string entry_user_id, string acct_num, string part_tran_type, string tran_amt, string deptid, string branchid, string empname, string field1, string field2, string pcnt)
        {
            var sql = "Exec proc_voucherEntryDetails @flag = 'i-new' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@entry_user_id =" + FilterString(entry_user_id);
            sql += ",@acct_num =" + FilterString(acct_num);
            sql += ",@tran_amt =" + FilterString(tran_amt);
            sql += ",@part_tran_type =" + FilterString(part_tran_type);
            sql += ",@dept_id =" + FilterString(deptid);
            sql += ",@branch_id =" + FilterString(branchid);
            sql += ",@emp_name =" + FilterString(empname);
            sql += ",@field1 =" + FilterString(field1);
            sql += ",@field2 =" + FilterString(field2);
            sql += ",@pcnt =" + FilterString(pcnt);

            return ParseDbResult(sql);
        }


        public DbResult InsertTempVoucherEntryDetails(string sessionID, string entry_user_id, string acct_num, string part_tran_type, string tran_amt, string deptid, string branchid, string empname, string field1, string field2)
        {
            var sql = "Exec proc_voucherEntryDetails @flag = 'i' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@entry_user_id =" + FilterString(entry_user_id);
            sql += ",@acct_num =" + FilterString(acct_num);
            sql += ",@tran_amt =" + FilterString(tran_amt);
            sql += ",@part_tran_type =" + FilterString(part_tran_type);
            sql += ",@dept_id =" + FilterString(deptid);
            sql += ",@branch_id =" + FilterString(branchid);
            sql += ",@emp_name =" + FilterString(empname);
            sql += ",@field1 =" + FilterString(field1);
            sql += ",@field2 =" + FilterString(field2);

            return ParseDbResult(sql);
        }

        //public DbResult InsertTempVoucherEntry(string sessionID, string entry_user_id, string acct_num, string part_tran_type, string tran_amt)
        //{
        //    var sql = "Exec proc_voucherEntry @flag = 'i' ";
        //    sql += ",@sessionID =" + FilterString(sessionID);
        //    sql += ",@entry_user_id =" + FilterString(entry_user_id);
        //    sql += ",@acct_num =" + FilterString(acct_num);
        //    sql += ",@tran_amt =" + FilterString(tran_amt);
        //    sql += ",@part_tran_type =" + FilterString(part_tran_type);

        //    return ParseDbResult(sql);
        //}

        public DbResult InsertTempVoucherEntry(string sessionID, string entry_user_id, string acct_num, string part_tran_type, string tran_amt, string deptid
            , string branchid, string empname, string field1, string field2, string fcy, string fcyamount, string rate, string refNum, string vType)
        {
            var sql = "Exec proc_EditVoucher @flag = 'FCYI' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(entry_user_id);
            sql += ",@accNum =" + FilterString(acct_num);
            sql += ",@amount =" + FilterString(tran_amt);
            sql += ",@tranType =" + FilterString(part_tran_type);
            sql += ",@dept_id =" + FilterString(deptid);
            sql += ",@branch_id =" + FilterString(branchid);
            sql += ",@emp_name =" + FilterString(empname);
            sql += ",@field1 =" + FilterString(field1);
            sql += ",@field2 =" + FilterString(field2);
            sql += ",@trn_currency =" + FilterString(fcy);
            sql += ",@usd_amt =" + FilterString(fcyamount);
            sql += ",@ex_rate =" + FilterString(rate);
            sql += ",@refNum =" + FilterString(refNum);
            sql += ",@vType =" + FilterString(vType);

            return ParseDbResult(sql);
        }

        public DataTable GetTempVoucherEntryData(string sessionID)
        {
            var sql = "Exec proc_voucherEntryUSD @flag = 's' ";
            sql += ",@sessionID =" + FilterString(sessionID);

            return ExecuteDataTable(sql);
        }

        public DataTable GetTempVoucherEntryDataDetails(string sessionID)
        {
            var sql = "Exec proc_voucherEntryDetails @flag = 's' ";
            sql += ",@sessionID =" + FilterString(sessionID);

            return ExecuteDataTable(sql);
        }

        public IList<VoucherTempData> GetTempVoucherEntryDataDetailsList(string sessionID)
        {
            var sql = "Exec proc_voucherEntryDetails @flag = 's' ";
            sql += ",@sessionID =" + FilterString(sessionID);

            DataTable dt = ExecuteDataTable(sql);
            return Mapper.DataTableToClass<VoucherTempData>(dt);
        }

        public DbResult DeleteRecordVoucherEntry(string tranID)
        {
            var sql = "Exec proc_voucherEntry @flag = 'd' ";
            sql += ",@tran_id = " + FilterString(tranID);
            return ParseDbResult(sql);
        }

        public DbResult DeleteRecordVoucherEntryDetails(string tranID)
        {
            var sql = "Exec proc_voucherEntryDetails @flag = 'd' ";
            sql += ",@tran_id = " + FilterString(tranID);
            return ParseDbResult(sql);
        }

        public DbResult SaveTempTransaction(string sessionID, string date, string narration, string v_type, string tran_ref_code, string user, string voucherimg)
        {
            var sql = "Exec spa_saveTempTrn @flag = 'i' ";
            sql += ",@company_id = '1'";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@date =" + FilterString(date);
            sql += ",@narration =" + FilterString(narration);
            sql += ",@v_type =" + FilterString(v_type);
            sql += ",@tran_ref_code =" + FilterString(tran_ref_code);
            sql += ",@user =" + FilterString(user);
            sql += ",@voucherimg =" + FilterString(voucherimg);

            return ParseDbResult(sql);
        }
        public DataRow getVoucherSettingData(string id)
        {
            var sql = "Exec proc_voucherSetting @flag = 'y' ";
            sql += ",@id =" + Convert.ToInt32(id);

            return ExecuteDataRow(sql);
        }
        public DbResult updateVoucherSetting(string id, string appMode, string user)
        {
            var sql = "Exec proc_voucherSetting @flag = 'u' ";
            sql += ",@id =" + Convert.ToInt32(id);
            sql += ",@Approval_mode =" + FilterString(appMode);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DbResult SaveTempTransactionManual(string sessionId, string date, string narration, string vType, string chequeNum, string vNum)
        {
            var sql = "Exec spa_saveTempTrnManual @flag = 'i' ";
            sql += ",@company_id = '1'";
            sql += ",@sessionID =" + FilterString(sessionId);
            sql += ",@date =" + FilterString(date);
            sql += ",@narration =" + FilterString(narration);
            sql += ",@v_type =" + FilterString(vType);
            sql += ",@tran_ref_code =" + FilterString(chequeNum);
            //sql += ",@user =" + FilterString(user);
            sql += ",@voucherNumber =" + FilterString(vNum);

            return ParseDbResult(sql);
        }

        public DbResult InsertTempVoucherEntryFromFile(string sessionID, string user, string xml)
        {
            var sql = "Exec ProcTempVoucherUpload @flag = 'i' ";
            sql += ",@sessionId =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(user);
            sql += ",@xml ='" + xml + "'";
            return ParseDbResult(sql);
        }

        public DbResult InsertTempVoucherEntryFCYFromFile(string sessionID, string user, string xml)
        {
            var sql = "Exec ProcTempVoucherUploadFCY @flag = 'i' ";
            sql += ",@sessionId =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(user);
            sql += ",@xml ='" + xml + "'";
            return ParseDbResult(sql);
        }
        public DbResult InsertTempVoucherEntryFCYFromFileNew(string sessionID, string user, string xml, string fileName)
        {
            var sql = "Exec Proc_TwoEntryTempVoucherUpload @flag = 'i' ";
            sql += ",@sessionId =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(user);
            sql += ",@xml = N'" + xml + "'";
            sql += ",@fileName =" + FilterString(fileName);
            return ParseDbResult(sql);
        }
        public DataTable GetTempVoucherEntryDataNew(string sessionID)
        {
            var sql = "Exec Proc_TwoEntryTempVoucherUpload @flag = 's' ";
            sql += ",@sessionID =" + FilterString(sessionID);

            return ExecuteDataTable(sql);
        }
        public DataTable FinalSave(string user, string sessionID)
        {
            var sql = "Exec Proc_TwoEntryTempVoucherUpload @flag = 'SAVE' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public void ClearData(string user, string sessionID)
        {
            var sql = "Exec Proc_TwoEntryTempVoucherUpload @flag = 'CLEAR' ";
            sql += ",@sessionID =" + FilterString(sessionID);
            sql += ",@user =" + FilterString(user);

            ExecuteDataTable(sql);
        }
    }
}
