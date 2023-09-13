using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
    public class UploadCouponDao : SwiftDao
    {
        public DbResult Update(string user, string couponId, string couponTranNo, string CouponCode, string date)
        {
            var sql = "EXEC proc_uploadCoupon @flag='u'";
            sql += ", @user=" + FilterString(user);
            sql += ", @couponId=" + FilterString(couponId);
            sql += ", @couponTranNo=" + FilterString(couponTranNo);
            sql += ", @CouponCode=" + FilterString(CouponCode);
            sql += ", @date=" + FilterString(date);

            return ParseDbResult(sql);
        }

        public DataRow GetDataById(string user, string couponId)
        {
            var sql = "EXEC proc_uploadCoupon @flag='a'";
            sql += ", @user=" + FilterString(user);
            sql += ", @couponId=" + FilterString(couponId);
            
            return ExecuteDataset(sql).Tables[0].Rows[0];
        }
    }
}
