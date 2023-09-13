<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="SendTransaction.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.SendTransaction" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <asp:HiddenField ID="hideCustomerId" runat="server" />
                    <ol class="breadcrumb">
                        <li><a href="/AgentNew/Dashboard.aspx"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Transaction </a></li>
                        <li><a href="#">Send Transaction</a></li>
                    </ol>
                </div>
            </div>
        </div>

        <div class="wizard">
            <div class="wizard-inner">
                <div class="connecting-line"></div>
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active">
                        <a href="#step1" data-toggle="tab" aria-controls="step1" role="tab" title="">
                            <span class="round-tab">
                                <i class="fa fa-user" aria-hidden="true"></i>
                            </span>
                        </a>
                    </li>

                    <li role="presentation" class="disabled">
                        <a href="#step2" data-toggle="tab" aria-controls="step2" role="tab" title="">
                            <span class="round-tab">
                                <i class="fa fa-user" aria-hidden="true"></i>
                            </span>
                        </a>
                    </li>
                    <li role="presentation" class="disabled">
                        <a href="#step3" data-toggle="tab" aria-controls="step3" role="tab" title="">
                            <span class="round-tab">
                                <i class="fa fa-file-text-o" aria-hidden="true"></i>
                            </span>
                        </a>
                    </li>
                    <li role="presentation" class="disabled">
                        <a href="#step4" data-toggle="tab" aria-controls="step4" role="tab" title="">
                            <span class="round-tab">
                                <i class="fa fa-file-text-o" aria-hidden="true"></i>
                            </span>
                        </a>
                    </li>

                    <li role="presentation" class="disabled">
                        <a href="#complete" data-toggle="tab" aria-controls="complete" role="tab" title="">
                            <span class="round-tab">
                                <i class="fa fa-check" aria-hidden="true"></i>
                            </span>
                        </a>
                    </li>
                </ul>
            </div>

            <div class="tab-content">

                <div class="tab-pane active" role="tabpanel" id="step1">
                    <div class="panel panel-default" style="margin-top: 10px;">
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <input type="text" class="form-control" placeholder="">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <input type="text" class="form-control" placeholder="">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <button type="submit" class="btn btn-primary">Advance</button>
                                    <button type="submit" class="btn btn-default">Clear All</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <h3>Sender Information</h3>
                    <div class="panel panel-default" style="margin-top: 10px;">
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">First Name</label>
                                    <input type="email" class="form-control" placeholder="First Name">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Middle Name</label>
                                    <input type="email" class="form-control" placeholder="Middle Name">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Last Name</label>
                                    <input type="email" class="form-control" placeholder="Last Name">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Zip Code</label>
                                    <input type="email" class="form-control" placeholder="Zip Code">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Street</label>
                                    <input type="email" class="form-control" placeholder="Street">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">City</label>
                                    <input type="email" class="form-control" placeholder="City">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">State</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Mobile</label>
                                    <input type="email" class="form-control" placeholder="Mobile">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Gender</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Native Country</label>
                                    <input type="email" class="form-control" placeholder="Native Country">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Monthly Income</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Email</label>
                                    <input type="email" class="form-control" placeholder="Email">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Customer Type</label>
                                    <input type="email" class="form-control" placeholder="Customer Type">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Company Name</label>
                                    <input type="email" class="form-control" placeholder="Company Name">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Business Type</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Id Type</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">ID Number</label>
                                    <input type="email" class="form-control" placeholder="ID Number">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Place of Issue</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Issued Date</label>
                                    <input type="email" class="form-control" placeholder="Issued Date">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Occupation</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <ul class="list-inline pull-right">
                        <li>
                            <button type="button" class="btn btn-primary next-step">Save and continue</button>
                        </li>
                    </ul>
                </div>

                <div class="tab-pane" role="tabpanel" id="step2">
                    <h3>Receiver Information</h3>

                    <div class="panel panel-default" style="margin-top: 10px;">

                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Choose Receiver</label>
                                    <input type="email" class="form-control" placeholder="Choose Receiver">
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">First Name</label>
                                    <input type="email" class="form-control" placeholder="First Name">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Middle Name</label>
                                    <input type="email" class="form-control" placeholder="Middle Name">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Last Name</label>
                                    <input type="email" class="form-control" placeholder="Last Name">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Address</label>
                                    <input type="email" class="form-control" placeholder="Address">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Mobile No.</label>
                                    <input type="email" class="form-control" placeholder="Mobile No.">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">ID Type</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">ID No.</label>
                                    <input type="email" class="form-control" placeholder="ID No.">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Gender</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Email</label>
                                    <input type="email" class="form-control" placeholder="Email">
                                </div>
                            </div>
                        </div>
                    </div>

                    <ul class="list-inline pull-right">
                        <li>
                            <button type="button" class="btn btn-default prev-step">Previous</button>
                        </li>
                        <li>
                            <button type="button" class="btn btn-primary next-step">Save and continue</button>
                        </li>
                    </ul>
                </div>
                <div class="tab-pane" role="tabpanel" id="step3">
                    <h3>Transaction Information</h3>

                    <div class="panel panel-default" style="margin-top: 10px;">

                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Collection Mode</label>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" value="">
                                            Cash
                                        </label>
                                        <label>
                                            <input type="checkbox" value="">
                                            Bank Deposite
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Receiving Country</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Receving Mode</label>
                                    <input type="email" class="form-control" placeholder="Receving Mode">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Agent/Bank</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Payout Currency</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Sending Amount</label>
                                    <input type="email" class="form-control" placeholder="Sending Amount">
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Collection Amount</label>
                                    <input type="email" class="form-control" placeholder="Collection Amount">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Service Charge</label>
                                    <input type="email" class="form-control" placeholder="Service Charge">
                                </div>

                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Payout Amount</label>
                                    <input type="email" class="form-control" placeholder="Payout Amount">
                                </div>

                                <div class="col-md-12">
                                    <button type="submit" class="btn btn-primary">Calculate</button>
                                    <button type="submit" class="btn btn-default">Clear</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <ul class="list-inline pull-right">
                        <li>
                            <button type="button" class="btn btn-default prev-step">Previous</button>
                        </li>
                        <!-- <li>
                                        <button type="button" class="btn btn-default next-step">Skip</button>
                                    </li> -->
                        <li>
                            <button type="button" class="btn btn-primary btn-info-full next-step">Save and continue</button>
                        </li>
                    </ul>
                </div>
                <div class="tab-pane" role="tabpanel" id="step4">
                    <h3>Customer Due Diligence Information -(CDDI)</h3>

                    <div class="panel panel-default" style="margin-top: 10px;">

                        <div class="panel-body">
                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Purpose of Remittance</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Source of Fund</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Relationship with Receiver</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-md-12 form-group">
                                    <label for="exampleInputEmail1">Message to Receiver</label>
                                    <textarea class="form-control" rows="3"></textarea>
                                </div>

                                <div class="col-md-12">
                                    <button type="submit" class="btn btn-primary">Send Transaction</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <ul class="list-inline pull-right">
                        <li>
                            <button type="button" class="btn btn-default prev-step">Previous</button>
                        </li>
                        <!--  <li>
                                        <button type="button" class="btn btn-default next-step">Skip</button>
                                    </li> -->
                        <li>
                            <button type="button" class="btn btn-primary btn-info-full next-step">Save and continue</button>
                        </li>
                    </ul>
                </div>

                <div class="tab-pane" role="tabpanel" id="complete">
                    <h3>Customer Due Diligence Information</h3>

                    <div class="panel panel-default" style="margin-top: 10px;">
                        <!--  <div class="panel-heading">
                                        Customer Due Diligence Information
                                    </div> -->
                        <div class="panel-body">

                            <div class="row">
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Purpose of Remittance</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Source of Fund</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>
                                <div class="col-sm-4 form-group">
                                    <label for="exampleInputEmail1">Relationship with Receiver</label>
                                    <select class="form-control">
                                        <option>1</option>
                                        <option>2</option>
                                        <option>3</option>
                                        <option>4</option>
                                        <option>5</option>
                                    </select>
                                </div>

                                <div class="col-md-12 form-group">
                                    <label for="exampleInputEmail1">Message to Receiver</label>
                                    <textarea class="form-control" rows="3"></textarea>
                                </div>

                                <div class="col-md-12">
                                    <button type="submit" class="btn btn-primary">Send Transaction</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <ul class="list-inline pull-right">
                        <li>
                            <button type="button" class="btn btn-default prev-step">Previous</button>
                        </li>
                        <!--  <li>
                                        <button type="button" class="btn btn-default next-step">Skip</button>
                                    </li> -->
                        <li>
                            <button type="button" class="btn btn-primary btn-info-full next-step">Save and continue</button>
                        </li>
                    </ul>

                    <div class="clearfix"></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>