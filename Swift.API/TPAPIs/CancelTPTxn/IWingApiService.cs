using Swift.API.Common;
using System.Data;
namespace Swift.API.TPAPIs.CancelTPTxn
{
    public interface IWingApiService
    {
        GetStatusResponse GetStatusWing(string controlNo, string provider);
    }
}
