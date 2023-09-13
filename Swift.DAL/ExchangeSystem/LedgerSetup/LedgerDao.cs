using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.ExchangeSystem.LedgerSetup
{
    public class LedgerDao :SwiftDao
    {
        public DataTable GetLedgerHeader(string type)
        {
            string sql = "EXEC proc_Ledger @flag=" + FilterString("header") + "";
            sql += " ,@type=" + FilterString(type);
            return ExecuteDataTable(sql);
        }

        public DataTable GetLedgerSubHeader(string pId)
        {
            string sql = "EXEC proc_Ledger @flag=" + FilterString("subheader") + "";
            sql += " ,@PId=" + FilterString(pId);
            return ExecuteDataTable(sql);
        }
        public DataTable GetLedgerSubGL(string pId)
        {
            string sql = "EXEC proc_Ledger @flag=" + FilterString("subGL") + "";
            sql += " ,@PId=" + FilterString(pId);
            return ExecuteDataTable(sql);
        }

        public DataRow GetGLData(string PId)
        {
            string sql = "EXEC proc_Ledger @flag=" + FilterString("GetGL") + "";
            sql += " ,@PId=" + FilterString(PId);
            return ExecuteDataRow(sql);
        }

        public DbResult InsertLedger(string id, string user, string map, string desc, string code , string accountPrifix)
        {          
            string sql = "EXEC procFindGLTreeShape";
            sql += " @bal_grp=" + FilterString(map);
            sql += " ,@gl_name=" + FilterString(desc);
            sql += " ,@p_id=" + FilterString(code);
            sql += " ,@accountPrifix=" + FilterString(accountPrifix);
            return ParseDbResult(sql);
        }

        public DbResult UpdateLedger(string id, string desc , string accPrefix)
        {
            string sql = "EXEC proc_Ledger  @flag=" + FilterString("u");
            sql += " ,@type=" + FilterString(desc);
            sql += " ,@PId=" + FilterString(id);
            sql += " ,@accountPrefix=" + FilterString(accPrefix);
            return ParseDbResult(sql);
        }

        public DbResult DeleteLedger(string id,string user)
        {
            string sql = "EXEC ProcDeleteLedgerGroup  @flag=" + FilterString("d");
            sql += " ,@rowid=" + FilterString(id);
            sql += " ,@user=" + FilterString(user);
            return ParseDbResult(sql);
        }

        public DbResult DeleteAccount(string id, string user)
        {
            string sql = "EXEC ProcDeleteAccount @flag="+FilterString("d");
            sql += " ,@rowid=" + FilterString(id);
            sql += " ,@user=" + FilterString(user);
            return ParseDbResult(sql);
        }

        public DataTable SearchLedger(string acNum, string searchBy)
        {
            string sql = "EXEC ProcSearchAc @flag=" + FilterString(searchBy);
             sql += " ,@acct_Num=" + FilterString(acNum);            
            return ExecuteDataTable(sql);
        }

        public DataTable GetLedgerDetails(string id)
        {
            string sql = "EXEC proc_Ledger @flag=" + FilterString("getLedgerDet");
            sql += " ,@PId=" + FilterString(id);
            return ExecuteDataTable(sql);
        }

        public DbResult DoLedgerMovement(string fromId, string toId, string SelectedItems)
        {
            string sql = "EXEC procLedgerMovement @flag=" + FilterString("m");
            sql += " ,@moveFrom=" + FilterString(fromId);
            sql += " ,@moveTo=" + FilterString(toId);
            sql += " ,@AcNumbers=" + FilterString(SelectedItems);
            return ParseDbResult(sql);
        }
    }
}
