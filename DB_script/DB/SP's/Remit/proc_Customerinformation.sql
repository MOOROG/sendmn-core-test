USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_Customerinformation]    Script Date: 6/17/2021 3:22:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Bikash Regmi>
-- Create date: <Create Date,,>
-- Description:	<Gives Customer Details>
-- =============================================
ALTER PROCEDURE [dbo].[proc_Customerinformation]
    @flag			VARCHAR(50) ,
    @customerId		INT = NULL,
	@user			VARCHAR(50) = NULL,
	@membershipId	VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	SET XACT_ABORT ON;
    IF @flag = 'details'
    BEGIN
		DECLARE @USERTYPE CHAR(1)

		SELECT @USERTYPE = CASE WHEN ISNULL(AU.USERTYPE, 'HO') = 'HO' THEN 'A' ELSE 'B' END
		FROM applicationUsers AU(NOLOCK)
		WHERE USERNAME = @user


        SELECT  cm.fullName ,
                cm2.countryName ,
                PRO.PROVINCE_NAME AS stateName ,
                CIT.CITY_NAME AS city ,
				cm.street,
                cm.email ,
                cm.mobile ,
				cm.zipcode,
				cm.additionalAddress,
				cm.walletAccountNo,
				convert(varchar(10),cm.createdDate,121) createdDate,
				cm.createdBy,
                cm.membershipId ,
                CONVERT(VARCHAR(10), cm.dob, 111)dob,-- cm.dob ,
                sdv.detailTitle occupation ,
                sdv1.detailTitle gender ,
                sdv2.detailTitle idType ,
                cm.idNumber ,
                CONVERT(VARCHAR(10), cm.idIssueDate, 111) idIssueDate,
                CONVERT(VARCHAR(10), cm.idExpiryDate, 111) idExpiryDate,
                cm.placeOfIssue
        FROM    dbo.customerMaster cm
                LEFT JOIN dbo.countryMaster cm2 ON cm2.countryId = cm.country
                LEFT JOIN dbo.countryStateMaster csm ON csm.stateId = cm.state
				LEFT  JOIN dbo.staticDataValue sdv ON sdv.valueId = cm.occupation
				LEFT JOIN dbo.staticDataValue sdv1 ON sdv1.valueId = cm.gender
				LEFT JOIN dbo.staticDataValue sdv2 ON sdv2.valueId = cm.idType
				LEFT JOIN TBL_PROVINCE_LIST PRO(NOLOCK) ON PRO.ROW_ID=cm.district
				LEFT JOIN TBL_CITY_LIST (NOLOCK) CIT ON CIT.ROW_ID=cm.city
				WHERE cm.customerId = @customerId
				
		SELECT ri.firstName+ ' ' + COALESCE(ri.middleName + ' ', '') + COALESCE(ri.lastName1 + ' ', '')
				+ COALESCE(ri.lastName2,'') fullName ,
				ri.address ,
				ri.mobile ,
				ri.country
		FROM    dbo.receiverInformation ri 

		WHERE ri.customerId = @customerId 
		and isnull(ri.isdeleted,0) <> 'Y'
		ORDER BY ri.createdDate DESC;
		
		SELECT  ISNULL(sdv.detailTitle,'signature')  documentType ,
				cd.fileType ,
				cd.fileName
		FROM    dbo.customerDocument cd
		LEFT JOIN dbo.staticDataValue sdv ON sdv.valueId = cd.documentType
		
		WHERE cd.customerId = @customerId 
		ORDER BY cd.createdDate DESC;
				
				
		SELECT  sdv.detailTitle method ,
				sdv1.detailTitle status ,
				tck.remarks
		FROM    dbo.TBL_CUSTOMER_KYC tck
		INNER JOIN staticDataValue sdv ON tck.kycMethod = sdv.valueId
		INNER JOIN staticDataValue sdv1 ON tck.kycStatus = sdv1.valueId
		WHERE tck.customerId = @customerId 
		and isDeleted = 0
		ORDER BY tck.createdBy DESC;
		 
		SELECT	vrt.createddate,
				vrt.receiverName , 
				jmeNo = CASE WHEN @USERTYPE = 'A' THEN '<a onclick="OpenInNewWindow(''/Remit/Transaction/ReprintVoucher/SendIntlReceipt.aspx?searchBy=controlNo&controlNo='+dbo.FNADecryptString(vrt.controlNo)+''');">'+dbo.FNADecryptString(vrt.controlNo)+'</a>'  
				--ELSE '<span class="link" onclick="OpenInNewWindow(''/AgentNew/SearchTxnReport/ViewTxnDetail.aspx?controlNo='+dbo.FNADecryptString(vrt.controlNo)+'|'+tranStatus+''');">'+dbo.FNADecryptString(vrt.controlNo)+'</span>'  
				ELSE '<span class="link" onclick="OpenInNewWindow(''/AgentNew/ReprintReceipt/SendTntlReceipt.aspx?controlNo='+dbo.FNADecryptString(vrt.controlNo)+''')">'+dbo.FNADecryptString(vrt.controlNo)+'</span>'  
				END,
				vrt.cAmt pAmt ,
				vrt.serviceCharge,
				vrt.tranStatus ,
				vrt.payStatus ,
				vrt.pCountry,*
		FROM    dbo.vwRemitTran vrt
		INNER JOIN dbo.vwTranSenders vts ON vrt.id = vts.tranId
		WHERE vts.customerId = @customerId
		ORDER BY vrt.createdDate DESC;

		--SELECT TOP 10  columnName ,
		--		oldValue ,
		--		newValue ,
		--		modifiedBy ,
		--		CONVERT(VARCHAR(10), modifiedDate, 111)modifiedDate--modifiedDate
		--FROM    TBLCUSTOMERMODIFYLOGS logs
		--WHERE	logs.customerId = @customerId 
		--ORDER BY logs.modifiedDate DESC;

		select TOP 10 CML.columnName
					,COALESCE(sdv.detailDesc,CSM.stateName,CML.oldValue) oldValue 
					,COALESCE(SDV1.detailDesc,CSM1.stateName,CML.newValue) AS newValue
					,CML.modifiedBy
					,CONVERT(VARCHAR(10)
					,CML.modifiedDate, 111)modifiedDate--modifiedDate
		FROM TBLCUSTOMERMODIFYLOGS CML (NOLOCK)
		LEFT JOIN staticDataValue SDV (NOLOCK) ON cast(SDV.valueId as nvarchar) = CML.oldValue
		LEFT JOIN staticDataValue SDV1 (NOLOCK) ON CAST(SDV1.valueId AS nvarchar) = CML.newValue
		LEFT JOIN countryStateMaster CSM (NOLOCK) ON CAST(CSM.stateId AS nvarchar) = CML.oldValue
		LEFT JOIN countryStateMaster CSM1 (NOLOCK) ON CAST(CSM1.stateId AS nvarchar) = CML.newValue
		WHERE	CML.customerId = @customerId 
		ORDER BY CML.modifiedDate DESC;
				
    END;
	IF @flag = 'detals-fromMembershipId'
	BEGIN
		SELECT @customerId = CUSTOMERID  FROM CUSTOMERMASTER WHERE MEMBERSHIPID = @membershipId	
		SELECT *  
			FROM (SELECT fileName, 
							fileType, 
							documentType = detailTitle,
							ROW_NUMBER()OVER(PARTITION BY SV.detailTitle ORDER BY CD.createdDate DESC)rn
					FROM customerDocument CD(NOLOCK)
					INNER JOIN STATICDATAVALUE SV(NOLOCK) ON SV.valueId = CD.documentType
					WHERE ISNULL(isDeleted, 'N') = 'N'
					AND customerId = @customerId
					AND valueId IN (11054, 11055, 11056, 11057)
			)X WHERE rn=1

               SELECT  
                       cm.customerId,
                       cm.createdDate,
					   customerType = TYP.detailTitle,
                       cm.fullName ,
					   CM.membershipId,
                       cmb.countryName AS [country] ,
					   cm.zipcode,
                       email,
                       sdg.detailTitle AS [gender] ,
                       cmn.countryName AS [nativeCountry] ,
                       ISNULL(CSM.stateName,'') + ', ' +  ISNULL(cm.city,'')+ ', '  +  ISNULL(cm.street,'') + ', ' + ISNULL(cm.additionalAddress,'')  [address],
                       cm.city ,
                       COALESCE(cm.telNo,cm.homePhone) telNo,
                       cm.mobile ,
                       sdo.detailTitle AS [occupation] ,
                       sdi.detailTitle AS [idType] ,
                       cm.idType AS [idTypeCode] ,
                       cm.idNumber ,
                       CONVERT(VARCHAR(10), dob, 121) AS [dob] ,
                       CONVERT(VARCHAR(10), idIssueDate, 121) AS [idIssueDate] ,
                       CONVERT(VARCHAR(10), idExpiryDate, 121) AS [idExpiryDate] ,
					   sdv.detailDesc visaStatus,
					   sdv1.detailDesc employeeBusinessType,
					   cm.nameOfEmployeer,
					   cm.SSNNO,
					   sdv2.detailDesc sourceOfFund,
					   cm.monthlyIncome,
					   case cm.remittanceAllowed WHEN 1 THEN 'Yes' ELSE 'No' END remittanceAllowed,
					   CASE cm.onlineUser WHEN 'Y' THEN 'Yes' ELSE 'No' END onlineUser,
					   cm.remarks
               FROM    customerMaster cm ( NOLOCK )
			LEFT JOIN staticDataValue TYP(NOLOCK) ON TYP.valueId = cm.customerType
               LEFT JOIN staticDataValue sdg ( NOLOCK ) ON sdg.valueId = cm.gender
               LEFT JOIN dbo.countryMaster cmb ( NOLOCK ) ON cmb.countryId = cm.country
               LEFT JOIN dbo.countryMaster cmn ( NOLOCK ) ON cmn.countryId = cm.nativeCountry
               LEFT JOIN staticDataValue sdo ( NOLOCK ) ON sdo.valueId = cm.occupation
               LEFT JOIN staticDataValue sdi ( NOLOCK ) ON sdi.valueId = cm.idType
			LEFT JOIN countryStateMaster CSM (NOLOCK) ON CSM.stateId = CAST(cm.state AS VARCHAR)
			LEFT JOIN dbo.staticDataValue sdv (NOLOCK) ON sdv.valueId = cm.visaStatus
			LEFT JOIN dbo.staticDataValue sdv1 (NOLOCK) ON sdv1.valueId = cm.employeeBusinessType
			LEFT JOIN dbo.staticDataValue sdv2 (NOLOCK) ON sdv2.valueId = cm.sourceOfFund
               WHERE   customerId = @customerId;
           END;
END;
