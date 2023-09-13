<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintForm.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.CustomerSetup.PrintForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <style>
        .printForm .table > tbody > tr > td,
        .printForm .table > tbody > tr > th,
        .printForm .table > tfoot > tr > td,
        .printForm .table > tfoot > tr > th,
        .printForm .table > thead > tr > td,
        .printForm .table > thead > tr > th {
            padding: 0px 6px;
        }

        .printForm .table > tbody > tr > td,
        .printForm .table > tbody > tr > th,
        .printForm .table > tfoot > tr > td,
        .printForm .table > tfoot > tr > th,
        .printForm .table > thead > tr > td,
        .printForm .table > thead > tr > th {
            vertical-align: middle;
        }

        .printForm .form-control {
            height: 24px;
            padding: 6px 12px;
            border-radius: 0;
            border: 0;
        }

        .printForm ul {
            margin: 15px;
            padding: 0;
        }

        .printForm li {
            list-style: disc;
        }

        .printForm .input-group-addon {
            border: 0;
        }

        .terms p {
            font-family: 'Lato', sans-serif;
            color: #777777;
            line-height: 10px;
            font-size: 8px;
        }

        .policy li {
            padding: 5px 0;
        }

        @page {
            size: auto;
            margin: 0mm;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <%--<ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Online Agent</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Customer Setup</a></li>
                            <li class="active"><a href="PrintForm.aspx">Print Form</a></li>
                        </ol>--%>
                    </div>
                </div>
            </div>
            <table width="97%" align="center">
                <tr>
                    <td width="20%">
                        <img src="../../../ui/images/logo-red.png" />
                    </td>
                    <td width="60%">
                        <center>
                        <b><span style="font-size: x-large; text-decoration: underline; text-align:center;">고객등록 / 소액해외송금신청서   </span>
                            <br />
                            (APPLICATION FOR REGISTRATION / REMITTANCE)</b>
                            </center>
                    </td>
                    <td width="20%" style="padding-right: 6px;">
                        <table border="1" width="100%">
                            <tr>
                                <th>실명확인</th>
                                <th>담 당</th>
                                <th>책 임 자</th>
                            </tr>
                            <tr>
                                <td>&nbsp;<br />
                                    &nbsp;</td>
                                <td>&nbsp;<br />
                                    &nbsp;</td>
                                <td>&nbsp;<br />
                                    &nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <br />

            <div class="printForm" style="padding: 10px;">
                <table class="table table-responsive main-table" width="100%">
                    <thead>
                        <tr>
                            <td>
                                <table class="table table-responsive table-bordered" width="100%">
                                    <tr>
                                        <td width="60%">Sender Information 송금인 정보</td>

                                        <td width="5%">Request<br />
                                            구분</td>
                                        <td style="padding: 0;" width="35%">
                                            <table border="0" width="100%">
                                                <tr>
                                                    <td width="25%">
                                                        <asp:CheckBox runat="server" ID="CheckBox1" Checked="true" />New<br />
                                                        신규
                                                    </td>
                                                    <td width="25%">
                                                        <asp:CheckBox runat="server" ID="CheckBox2" />Change<br />
                                                        변경
                                                    </td>
                                                    <td width="25%">
                                                        <asp:CheckBox runat="server" ID="new" />Remit<br />
                                                        송금
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="3">
                                <table class="table table-responsive table-bordered" width="100%">
                                    <tr>
                                        <td width="30%">E-mail ID for Registration<br />
                                            등록을 위한 이메일 주소
                                        </td>
                                        <td colspan="2" width="70%">
                                            <asp:Label runat="server" ID="email" Font-Bold="true"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Full Name<br />
                                            성명</td>
                                        <td colspan="2">

                                            <asp:Label runat="server" ID="fullName"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>ID / Alien Reg. No<br />
                                            주민번호/외국인등록번호</td>
                                        <td>
                                            <asp:Label ID="idNumber" runat="server"></asp:Label>
                                        </td>
                                        <td>Expiry Date <span style="font-size: 8px;">YYYYMMDD </span>
                                            <br />
                                            만료일
                            <asp:Label runat="server" ID="expiryDate" Font-Bold="true"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Mobile / Tel No<br />
                                            전화번호
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="mobileNo"></asp:Label>
                                        </td>
                                        <td>Gender<br />
                                            성별 &nbsp;
                                    <asp:RadioButton ID="male" runat="server" Text="Male" />
                                            <asp:RadioButton ID="feMale" runat="server" Text="Female" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Address in Korea<br />
                                            한국 주소</td>
                                        <td colspan="2">
                                            <asp:Label runat="server" ID="address"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Company Name<br />
                                            회사명</td>
                                        <td colspan="2">
                                            <asp:Label runat="server" ID="companyName"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <p>
                                                Please fill the details of your bank account in Japan. It may be used later as your registered account for sending money through JME.<br>
                                                한국 내 거래 은행 계좌 정보를 기입하세요. JME를 통한 해외송금의 지정출금 계좌로 등록·사용됩니다.
                                            </p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Bank Name<br />
                                            은행명</td>
                                        <td colspan="2">
                                            <asp:Label runat="server" ID="bankName"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Account No<br />
                                            계좌번호</td>
                                        <td colspan="2">
                                            <asp:Label runat="server" ID="accountNo"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3" class="policy">
                                <ul>
                                    <li>본인은 JME 송금과 관련하여 해외은행 앞으로 상기 정보 및 송금인 계좌번호가 제공됨에 동의합니다.
                                    </li>
                                    <li>본인은 소액해외송금거래를 함에 있어 JME로부터 「JME소액해외송금서비스」 이용약관의 중요내용과 주요정보설명서 내용을 직접 설명 또는

                                        전자적 장치 등을 통하여 충분히 인지하였으며, 상기 약관 및 설명서 사본을 교부받고 승인 및 준수할 것을 확약하며 위와 같이 고객등록/

                                        송금을 신청합니다.
                                    </li>
                                    <li>By signing the agreement I agree to the terms and conditions governing the money transfer service as set forth on the back of this

                                        form.
                                    </li>
                                </ul>
                                <br />
                                <br />
                                <p style="padding-left: 10px;">
                                    Date(신청일) 20 년 월 일_____________________________    &nbsp;&nbsp;&nbsp;   Name & Signature(신청인) (인)_____________________________
                                </p>
                                <br />
                                <ul>
                                    <li>이 신청서는 외국환통계 자료로 활용되며 과세자료로 국세청에 통보될 수 있습니다.
                                    </li>
                                    <li>This completed application shall be used for foreign exchange statistics and may be reported to Korean National Tax Service as a tax document.
                                    </li>
                                </ul>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <%--            <br />
            <div class="terms" style="page-break-before: always;">
                <div class="row" style="font-size: x-small;">
                    <div class="form-group" style="margin-left: 3%; margin-right: 3%;">
                        <div style="text-align: center"><br /><br />GME 소액해외송금서비스」 이용약관 (Terms and Conditions)</div>
                        <p>
                            <strong>제1조(적용범위)</strong> 이 약관은 ㈜ 글로벌머니익스프레스(이하 ‘회사’라 합니다.)와 ‘회사가 제공하는「소액해외송금서비스」(이하 ‘서비스’라 합니다.)를 이용하는 고객’(이하 ‘고객’이라 합니다.) 사이에 적

                        용됩니다.
                <br />

                            <strong>Article 1 (Scope of Application)</strong> These Terms and Conditions is a legal contract between the Customer (hereafter referred to as the "Customer") and Global Money Express (hereinafter

                        referred to as "GME") governing the use of Small Amount Overseas Remittance Service(hereinafter referred to as the "Service").
                        </p>

                        <p>
                            <strong>제2조(실명거래)</strong> 고객은 회사와의 소액해외송금거래시 실명으로 거래하여야 하며, 회사가 실명확인을 위해 고객에게 실명확인증표 등 필요한 자료를 요구할 경우 이에 따르기로 합니다.
                <br />
                            <strong>Article 2 (Real name transaction)</strong> Customer is required to use Real Name while dealing with GME to avail small amount overseas remittance transaction. When GME requests real name

                        confirmation certificate or other necessary data to confirm customer's real name, the Customer should be able to provide it.
                        </p>
                        <p>
                            <strong>제3조(송금한도)</strong> 고객이 본 서비스를 통해 송금할 수 있는 한도는 다음 각 호와 같습니다. 1. 건당 지급 및 수령 한도는 각각 미화 3천달러 2. 연간 지급 및 수령 누계 한도는 각각 미화 2만달러
                <br />
                            <strong>Article 3 (Remittance Limit)</strong> The following are the limitations that a customer can remit through this service.

                        1. Per-transaction limit is equivalent to USD 3,000 2. Annual payment and receipt limit is equivalent to USD 20,000
                        </p>
                        <p>
                            <strong>제4조(지정계좌)</strong> ① 회사는 ‘소액해외송금업무에 사용할 계좌인 것으로 소액해외송금업 등록(변경등록 포함) 당시 지정한 회사명의의 금융회사개설 계좌’(이하 ‘지정계좌’라 합니다.)를 통해서만 고

                        객에게 자금을 지급하거나 고객으로부터 자금을 수령할 수 있습니다. ② 회사는 제1항의 지정계좌에 관한 내용을 회사 홈페이지 등에 게시하고 이를 최신 내용으로 관리하여야 합니다.
                <br />
                            <strong>Article 4 (Designated Account)</strong> ① GME shall transfer funds to the Customer only through its Bank Account (hereinafter referred to as the "Designated Account") designated at the time of

                        the registration of the small overseas remittance business OR GME shall receive money from the Customer in the designated account only.

                        ② GME shall publish the matters related to the designated account on the company website and manage it with the latest contents.
                        </p>
                        <p>
                            <strong>제5조(수수료)</strong> ① 회사는 고객으로부터 본 서비스 이용신청을 받은 경우 고객이 부담하는 수수료(이하 ‘수수료’라 합니다.)에 관한 사항을 환전수수료, 송금수수료, 외국 협력업자 지급수수료 등

                        세부 구성항목별로 구분하여 그 내역을 고객에게 제공하여야 합니다. ② 회사는 수수료에 관한 사항을 회사 홈페이지 등에 게시하고 이를 최신 내용으로 관리하여야 합니다.
                <br />
                            <strong>Article 5 (Fees)</strong> ① If GME receives an application for use of the Service from the Customer, GME shall segregate the related fee (hereinafter referred to as "Fees") borne by the Customer

                        as detailed items such as the Exchange Fee, Remittance Fee. ② GME shall publish the matters related to the commission on the company website and manage it with the latest contents.
                        </p>
                        <p>
                            <strong>제6조(적용환율)</strong> ① 회사는 고객으로부터 본 서비스 이용신청을 받은 경우 고객에게 적용할 환율에 관한 사항을 제공하여야 합니다.

                        ② 회사는 고객에게 적용할 환율에 관한 사항을 회사 홈페이지 등에 게시하고 이를 최신 내용으로 관리하여야 합니다.
                <br />
                            <strong>Article 6 (Applicable Exchange Rate)</strong> ① GME shall inform the Customer with applicable exchange rate when it receives an application for the use of its Services. ② GME shall publish its

                        exchange rates on its website and manage it with the latest contents.
                        </p>
                        <p>
                            <strong>제7조(지급·수령금액)</strong> ① 회사는 본 서비스를 신청한 고객이 지정계좌에 입금할 경우 수수료를 차감한 금액을 외화로 환전하여 고객이 요청한 수취인에게 송금처리를 하여야 합니다.

                        ② 회사는 고객으로부터 본 서비스 이용신청을 받은 경우 고객이 지급‧수령하는 자금의 원화표시 및 외화표시 금액에 관한 사항을 고객에게 제공하여야 합니다.
                <br />
                            <strong>Article 7 (Payment and Receipt Amount)</strong> ① When the Customer applies for the service to deposit money in the designated account, GME shall transfer the amount from which the fee is

                        deducted to foreign currency to the recipient as requested by the Customer. ② When GME receives an application for use of the Service from the Customer, GME shall provide the

                        Customer with a statement of the original currency and the foreign currency of the amount to be paid and received by the Customer.
                        </p>
                        <p>
                            <strong>제8조(소요기간)</strong> ① 회사는 고객으로부터 본 서비스 이용신청을 받은 경우 고객에게 지급 또는 수령에 소요되는 예상 기간에 관한 사항을 제공하여야 한다.

                        ② 회사는 본 서비스를 이용할 경우 지급 또는 수령에 소요되는 예상 기간에 관한 사항을 회사 홈페이지 등에 게시하고 이를 최신 내용으로 관리하여야 합니다.
                <br />
                            <strong>Article 8 (Duration of Period)</strong> ① GME shall provide the Customer with information on the estimated time required for payment or receipt when GME receives the application for the use

                        of the Service. ② GME shall post about the estimated time required for payment or receipt on its website and keep it up to date.
                        </p>
                        <p>
                            <strong>제9조(송금의 변경·취소)</strong> ① 고객은 본 서비스를 신청하여 수취인 계좌에 정상 입금되는 등 송금처리가 완료되지 않은 건에 대하여 유선 또는 영업점 방문 등을 통하여 회사에 변경 또는 취소를

                        신청할 수 있습니다. 단, 수취인 계좌에 정상 입금되는 등 송금처리가 완료된 건에 대해서는 변경 또는 취소를 신청할 수 없습니다.

                        ② 회사는 고객으로부터 송금신청건에 대한 변경 또는 취소를 요청받은 경우 해당 요청사항을 처리하고 그 결과를 고객에게 통보하여야 합니다.
                <br />
                            <strong>Article 9 (Change or Cancellation of Remittance)</strong> ① The Customer can apply for the change or cancellation to GME by visiting the branch office or through online for cases where the

                        remittance process is not complete or the payment is not made to the receiver's account. However, the Customer can not apply for a change or cancellation for the transfer process that

                        has been completed, such as money deposited already to the beneficiary account. ② When GME receives requests to change or cancel the remittance from the Customer, GME shall

                        process the request and notify the Customer of the result.
                        </p>
                        <p>
                            <strong>제10조(송금결과의 통보)</strong> 회사는 수취인 계좌에 정상 입금되는 등 송금처리가 완료된 경우 즉시 그 결과를 고객이 사전에 등록한 연락처 등을 통하여 고객에게 통지하여야 합니다.
                <br />
                            <strong>Article 10 (Notification of remittance result)</strong> When the remittance process is completed, GME will notify the result of remittance immediately to the Customer by contact address provided

                        in advance by the Customer.
                        </p>
                        <p>
                            <strong>제11조(손해배상)</strong> 회사의 책임있는 사유로 인하여 고객에게 손해가 발생한 경우 회사의 손해배상 범위는 민법에서 정하고 있는 통상손해를 포함하고, 특별한 사정으로 인한 손해는 회사가 그 사

                        정을 알았거나 알 수 있었을 때에 한하여 배상책임이 있습니다.
                <br />
                            <strong>Article 11 (Indemnification for damages)</strong> In the event of damages to the Customer due to GME's responsible cause, GME's liability for damages shall include the ordinary damages set

                        forth in the Civil Act, and for the damages caused by special circumstances GME shall be liable for damages only if it knew or understood the circumstances.
                        </p>
                        <p>
                            <strong>제12조(환급)</strong> ① 고객의 귀책사유 없이 고객이 회사에 본 서비스를 신청하여 지정계좌에 입금한 날로부터 15일 이내에 송금처리가 완료되지 않은 경우에는 회사에 환급을 신청할 수 있습니다. ②

                        회사는 고객으로부터 제1항의 환급신청을 받은 경우 특별한 사정이 있는 경우를 제외하고는 당초 고객이 지정계좌에 입금한 금액 및 제11조(손해배상) 해당금액 등을 고객에게 지급하여야 합니다.
                <br />
                            <strong>Article 12 (Refund)</strong> ① Customer can apply for a refund to GME if the transfer is not completed within 15 days from the date the Customer submits the service to GME and transfers it

                        to the designated account without reason for the Customer's fault. ② When GME receives a refund application under paragraph 1, GME shall pay to the Customer the amount of money

                        originally deposited by the Customer in the designated account and the amount of the Article 11 (compensation for damages), except in special circumstances.
                        </p>

                        <p>
                            <strong>제13조(분쟁처리절차)</strong> ① 회사는 ‘소액해외송금업무와 관련하여 고객이 제기하는 정당한 의견이나 불만을 반영하고 고객이 소액해외송금업무와 관련하여 입은 손해를 배상하기 위한 절차’(이하

                        ‘분쟁처리절차’)에 관한 사항을 마련하여야 합니다. ② 회사는 분쟁사항에 대한 접수방법 (분쟁처리책임자와 담당자 지정내역 및 그 연락처 포함), 분쟁처리절차 (단순불만사항과 손해배상요구사항

                        을 구분하여 마련) 및 분쟁처리결과에 대한 고객통보에 관한 사항(처리기한, 고객통보방식 등) 등을 고객에게 제공하여야 합니다. ③ 고객은 소액해외송금거래의 처리에 관하여 이의가 있을 때에

                        는 회사의 분쟁처리기구 (분쟁처리책임자 및 담당자 등) 에 그 해결을 요구할 수 있으며, 회사는 이를 조사하여 제2항의 처리기한 이내에 처리결과를 고객에게 통보하여야 합니다. ④ 회사는 분

                        쟁처리책임자와 담당자 지정내역 및 그 연락처 등을 회사 홈페이지 등에 게시하고 이를 최신 내용으로 관리하여야 합니다.
                <br />

                            <strong>Article 13 (Procedures for Dispute Resolution)</strong> ① GME shall be liable for any damages arising out of or in connection with the operation of GME. The procedures for compensating the

                        damages suffered by the Customer in connection with the small amount overseas remittance business are hereinafter referred to as the "Dispute Settlement Procedures." GME shall listen

                        to and address Customer’s reasonable complaints. ② GME shall notify the Customer about the method of acceptance of the dispute (including the dispute resolution officer and the

                        person in charge and the contact details), the dispute settlement procedure (distinguishing between simple complaint and damage claim) and the result of the dispute settlement

                        (including processing period, customer notification method, etc.) ③ If the Customer objects to the remittance transaction process, GME may request its designated staffs (such as the

                        dispute handling officer and the person in charge) to resolve the matter who shall notify the Customer. ④ GME shall publish the details of the dispute resolution officer and the person

                        in charge with contact information on GME website and will update it with latest.
                        </p>

                        <p>
                            <strong>제14조(거래기록의 보존)</strong> 회사는 외국환거래법령 등에 따라 고객과의 지급 및 수령거래 기록을 5년간 보관하여야 합니다.
                <br />
                            <strong>Article 14 (Preservation of transaction records)</strong> GME shall maintain records of payments and receipt transactions with its customers for five years pursuant to the Foreign Exchange

                        Transactions Act and the like.
                        </p>
                        <p>
                            <strong>제15조(비밀보장의무)</strong> ① 회사는 ‘고객의 인적사항, 계좌정보, 회사와의 송금거래 내용 및 실적에 관한 자료 등 소액해외송금업무 수행을 통하여 알게 된 일체의 고객정보’(이하 ‘고객정보’라 합니

                        다.)에 대하여 관계법령에서 정한 경우를 제외하고는 고객 동의 없이 제3자에게 제공하거나 업무 목적 외에 누설하거나 이용하여서는 아니 됩니다. ② 회사가 관리소홀 등 회사의 귀책사유로 제

                        1항을 위반하거나 고객정보의 도난 또는 유출이 발생한 경우 회사가 피해고객에게 배상책임이 있습니다. 다만, 회사가 고의 또는 과실이 없음을 증명한 경우에는 그 책임을 면할 수 있습니다.
                <br />
                            <strong>Article 15 (Confidentiality Obligation)</strong> ① Except as provided in applicable laws and regulations, GME shall not disclose any personal information ("Customer Information") that is obtained

                        through the execution of its overseas remittance business, such as ‘personal information of the customer, account information’, or provide to third parties without the Customer’s consent.

                        ② If GME violates Paragraph 1 for reasons of negligent management or when theft or leakage of customer information occurs, GME is liable for damages to the victim customer.

                        However, if GME proves that it is not intentional or negligent, it cannot be held responsible.
                        </p>

                        <p>
                            <strong>제16조(약관의 교부·설명)</strong> ① 회사는 약관을 정하거나 변경한 경우 인터넷 홈페이지 등을 통하여 공시하여야 하며, 고객과 소액해외송금업무와 관련한 계약을 체결할 때 약관을 명시하여야 합니다.

                        ② 회사는 고객에게 전자문서의 전송(전자우편을 이용한 전송을 포함합니다.), 모사전송, 우편 또는 직접 교부의 방식으로 약관의 사본을 고객에게 교부하여야 합니다. ③ 회사는 고객이 약관의

                        내용에 대한 설명을 요청하는 경우 다음 각 호의 어느 하나의 방법으로 고객에게 약관의 중요내용을 설명하여야 합니다. 1. 약관의 중요내용을 고객에게 직접 설명 2. 약관의 중요내용에 대한

                        설명을 전자적 장치를 통하여 고객이 알기 쉽게 표시하고 고객으로부터 해당 내용을 충분히 인지하였다는 의사표시를 전자적 장치를 통하여 수령
                <br />
                            <strong>Article 16 (Issuance and Explanation of Terms)</strong> ① GME shall notify the terms and conditions through its website and specify the terms and conditions when making a contract with the

                        customer for the small amount overseas remittance business. ② GME shall give the Customer a copy of the terms and conditions in the form of electronic documents (including

                        transmission using e-mail), fax, mail or direct delivery to the Customer. ③ When the Customer asks GME to explain the contents of the terms and conditions, GME must explain those to

                        the Customer in one of the following ways: 1. Explain important contents directly to the Customer 2. Describe the important contents by electronic means recognized by the Customer.
                        </p>

                        <p>
                            <strong>제17조(준용규정)</strong> 이 약관에서 정하지 않은 사항에 대하여는 외국환거래법규 등 관련법규에 따릅니다.
                <br />
                            <strong>Article 17 (Applicable Regulations)</strong> Regarding matters not defined in these Terms and Conditions, it shall be subject to relevant laws and regulations such as the Foreign Exchange Transaction Law.
                        </p>

                        <p>
                            <strong>제18조(관할법원)</strong> 이 거래와 관련한 분쟁이 발생할 경우 양 당사자의 합의에 의해 해결함을 원칙으로 합니다. 다만 당사자 간에 합의할 수 없거나 합의가 이루어지지 않아 이 거래와 관련하여

                        소송이 제기되는 경우 관할법원은 민사소송법에서 정하는 바에 따르기로 합니다.

                           <br />
                            <strong>Article 18 (Jurisdiction of Court)</strong> If a dispute arises in connection with the transaction, it shall be resolved by agreement of both parties. However, if both parties cannot agree or no

                        agreement has been reached, the court will comply with the provisions of the Civil Procedure Act.
                        </p>
                    </div>
                </div>
            </div>--%>
        </div>
    </form>
</body>
</html>