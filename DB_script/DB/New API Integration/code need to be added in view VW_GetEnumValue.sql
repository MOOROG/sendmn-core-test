
--code added in view [dbo].[VW_GetEnumValue]

SELECT 'idType'				[type],'11168'  [value], 'Residence Card'	[key], 'tranglo' [partner], '11168' [searchValue],'Residence Card'	[searchText]  union all--Residence Permit-5
SELECT 'idType'				[type],'8008'  [value], 'National ID'	[key],'tranglo' [partner], '8008' [searchValue],'National ID'	[searchText]  union all--Identification ID Code-3
SELECT 'idType'				[type],'10997'  [value], 'Passport'	[key],'tranglo' [partner], '10997' [searchValue],'Passport'	[searchText]  union all--International Passport Code-2
SELECT 'idType'				[type],'1302'  [value], 'Alien Registration Card'	[key],'tranglo' [partner], '1302' [searchValue],'Alien Registration Card'	[searchText]  union all --work permit code-1

--new select field added in sp: proc_GetHoldedTxnForApprovedByAdmin
rCountryCode -- bene country code
sCountryCode -- sending country code
rProvienceCode --Required for PT POS Cash Pickup Transactions
rRegencyCode --Required for PT POS Cash Pickup Transactions
purposeOfRemit --map this field with Tranglo API Code
SIdType and RIdType --map this value with tranglo idtype code
idtype:
switch (sIdType)
{
    case "11168":
        return 5;
    case "8008":
        return 3;
    case "10997":
        return 2;
    case "1302":
        return 1;
    default:
        return 2;
}
select * from servicetypemaster

select * from agentMaster


select * from MangoliaLogDB.dbo.ApplicationLogger

{"cAmount":"10000","RequestedBy":"mobile","calcBy":"c","pAgent":null,"pAmount":""
,"pCountry":"151","pCountryName":"Nepal","pCurrency":"NPR","paymentType":null
,"payoutPartner":null,"processId":"0f4d6e2e-1d4f-48c1-bb7e-628511f001f4","sCountry":"142"
,"sCurrency":"MNT","schemeId":null,"serviceType":"1","serviceTypeDescription":null
,"tpExRate":null,"tpPCurrnecy":null,"userId":null}

