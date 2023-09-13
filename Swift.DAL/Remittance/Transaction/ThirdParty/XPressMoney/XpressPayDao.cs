using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Transaction.ThirdParty.XPressMoney
{
    public class XpressPayDao : RemittanceDao
    {
        public DbResult DeleteTransaction(string rowId, string user)
        {
            var sql = "EXEC proc_xPressTranHistory @flag = 'd'";
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@user=" + FilterString(user);

            return ParseDbResult(sql);
        }

        public List<DataRow> GetTXNDetails(string rowId)
        {
            var rows = new List<DataRow>();
            var sql = "EXEC proc_xPressTranHistory @flag = 'a', @rowId =" + FilterString(rowId);
            var row = ExecuteDataRow(sql);
            if (row == null)
                return null;

            rows.Add(row);
            var branchId = row["branchId"].ToString();

            rows.Add(GetAgentDetail(branchId));
            return rows;

        }

        public DataRow GetAgentDetail(string branchId)
        {
            var sql = "EXEC proc_autocomplete @category = 'agent-a', @searchText =" + FilterString(branchId);
            return ExecuteDataRow(sql);
        }
    }
}
