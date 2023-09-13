using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Administration.ReceiverInformation
{
   public class ReceiverInformationDAO: RemittanceDao
    {
        public DataRow SelectReceiverInformationByCustomerId(string user, string customerId)
        {
            string sql = "EXEC proc_online_receiverSetup ";
            sql += " @flag ='sDetailByCusId'";
            sql += ", @customerId =" + FilterString(customerId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectReceiverInformationByReceiverId(string user, string receiverId)
        {
            string sql = "EXEC proc_online_receiverSetup ";
            sql += " @flag ='sDetailByReceiverId'";
            sql += ", @receiverId =" + FilterString(receiverId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataRow SelectReceiverInformationByReceiverIdForPrint(string user, string receiverId)
        {
            string sql = "EXEC proc_online_receiverSetup ";
            sql += " @flag ='sDetailByReceiverIdForPrint'";
            sql += ", @receiverId =" + FilterString(receiverId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable GetAllReceiverSenderDataForPrint(string receiverId, string user)
        {
            var sql = "EXEC proc_online_sender_receiver @flag ='forPrint'";
            sql += ", @user = " + FilterString(user);
            sql += ", @receiverIds = " + FilterString(receiverId);
            var dt = ExecuteDataTable(sql);
            return dt;
        }
    }
}
