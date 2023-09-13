namespace Swift.API.Common
{
  public class OrderCancel {
    public string customerId { get; set; }
    public string orderId { get; set; }
    public string cancelReason { get; set; }
    public string statusDate { get; set; }
    public string customerPassword { get; set; }
  }
  public class SearchEntityRequest {
    public string facet { get; set; }
    public string q { get; set; }
    public string filterDate { get; set; }
    public string filterSchemata { get; set; }
    public string highlight { get; set; }
    public string limit { get; set; }
    public string offset { get; set; }
  }
}