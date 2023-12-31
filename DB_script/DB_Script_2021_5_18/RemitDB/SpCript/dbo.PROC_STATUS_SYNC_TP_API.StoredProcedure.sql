USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_STATUS_SYNC_TP_API]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_STATUS_SYNC_TP_API]
(
	 @FLAG				VARCHAR(30)
	,@PROVIDER			VARCHAR(50)
	,@TRANID			BIGINT = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    DECLARE @dbblpAgent INT = 392504,@sbrpAgent INT=392509,@xpresspAgent INT = 392521;
	DECLARE @AgentId BIGINT,@controlNo VARCHAR(20),@ref_num VARCHAR(20),@sRouteId varchar(5),@message varchar(500)

	SET @AgentId = CASE WHEN @PROVIDER ='wing' THEN '221226' 
						 WHEN @PROVIDER ='commercial' THEN '221271' 
						 WHEN @PROVIDER ='globalbank' THEN '1056' 
						 WHEN @PROVIDER ='contact' THEN '392527' 
						 WHEN @PROVIDER ='vcbr' THEN '393229' 
						 WHEN @PROVIDER ='donga' THEN '2090' 
						 WHEN @PROVIDER ='mtrade' THEN '2129' 
						 WHEN @PROVIDER ='transfast' THEN '394130' 
						 WHEN @PROVIDER='dbbl' THEN @dbblpAgent  --its the apiParter 
						 WHEN @PROVIDER='sbr' THEN @sbrpAgent 
						 WHEN @PROVIDER='xpress' THEN @xpresspAgent
					END
	IF @FLAG = 'mark-paid'
	BEGIN
		UPDATE remitTran SET 
			payStatus		= 'Paid', 
			tranStatus		= 'Paid', 
			paidBy			= 'system', 
			paidDate		= GETDATE(),
			paidDateLocal	= GETUTCDATE()
		WHERE id = @TRANID
		--AND payStatus = 'Post' AND tranStatus='Payment' AND pAgent  = @AgentId
		AND payStatus IN ('Post','Unpaid') AND tranStatus='Payment' AND pAgent  = @AgentId
	END
	ELSE IF @FLAG = 'mark-cancel'
	BEGIN
		SET @message = 'Cancelled as per customer request'

		IF @PROVIDER ='contact'
		BEGIN
			SELECT @controlNo = DBO.FNADecryptString(CONTROLNO),@sRouteId = sRouteId FROM remitTran(NOLOCK) WHERE id = @TRANID AND pAgent  = @AgentId

			--INSERT INTO @tempTbl(errorcode, msg, id)
			EXEC [proc_cancelTran] @flag = 'cancel',@controlNo = @controlNo,@user = 'system',@cancelReason = @message,@refund = 'N'

			EXEC [proc_cancelTran] @flag = 'cancelReceipt',@tranId = @TRANID,@user = 'system'
		END
		IF @PROVIDER ='transfast'
		BEGIN
			SELECT @controlNo = DBO.FNADecryptString(CONTROLNO),@sRouteId = sRouteId FROM remitTrantemp (NOLOCK) WHERE id = @TRANID AND pAgent  = @AgentId

			--INSERT INTO @tempTbl(errorcode, msg, id)
			EXEC [proc_cancelTran] @flag = 'cancel',@controlNo = @controlNo,@user = 'system',@cancelReason = @message,@refund = 'N'

			EXEC [proc_cancelTran] @flag = 'cancelReceipt',@tranId = @TRANID,@user = 'system'
		END
	END
ELSE IF @FLAG = 'sync-list'
	BEGIN
		IF @PROVIDER = 'mtrade'
		BEGIN
			SELECT TOP 100
				trn.id,[uploadLogId] = ISNULL(ContNo,uploadLogId),controlNo = dbo.FNADecryptString(trn.controlNo)
			FROM remitTran trn WITH(NOLOCK)
			WHERE 
			trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
			AND tranStatus = 'payment' AND trn.pAgent = @AgentId
			AND Approveddate < dateadd(day,-1,getdate())
			ORDER BY NEWID()
		END
		ELSE IF @PROVIDER = 'donga'
		BEGIN
			SELECT TOP 1000 controlNo = dbo.FNADecryptString(controlNo),id
			FROM remitTran (NOLOCK) 
			WHERE  
			payStatus = 'Post' AND tranStatus = 'Payment' 
			AND pCountry = 'VIETNAM' AND pAgent = @AgentId
			AND Approveddate < dateadd(hour,-2,getdate())
			ORDER BY 1 DESC
		END
		ELSE IF @PROVIDER = 'wing'
		BEGIN
			SELECT TOP 100 controlNo = dbo.FNADecryptString(controlNo2),id,paymentMethod
			FROM remitTran (NOLOCK) 
			WHERE  
			payStatus = 'Post' AND tranStatus = 'Payment' 
			AND pCountry = 'Cambodia' AND pAgent = @AgentId
			AND Approveddate < dateadd(hour,-2,getdate())
			ORDER BY NEWID()
		END
		ELSE IF @PROVIDER = 'commercial'
		BEGIN
			SELECT TOP 100 controlNo = dbo.FNADecryptString(controlNo2) ,id,paymentMethod
			FROM remitTran (NOLOCK) 
			WHERE  
			payStatus = 'Post' AND tranStatus = 'Payment' 
			AND pCountry = 'Sri Lanka' AND pAgent = @AgentId
			AND Approveddate < dateadd(hour,-2,getdate())
			order by id desc
		END
		ELSE IF @PROVIDER = 'bni'
		BEGIN
			SELECT TOP 30
				trn.id, controlNo = dbo.FNADecryptString(trn.controlNo)
				, trxDate = FORMAT(approvedDate,'yyyy-MM-ddTHH:mm:ss')
			FROM remitTran trn WITH(NOLOCK)
			WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
			AND tranStatus = 'Payment' AND trn.pAgent = 392227
			order by newid() 
		END
		ELSE IF @PROVIDER = 'contact'
		BEGIN
			SELECT TOP 30
				trn.id, controlNo = dbo.FNADecryptString(trn.controlNo)
				,DocId = ContNo
				,trxDate = CAST(CAST(trn.approvedDate AS DATE) AS VARCHAR) +'T'+ CAST(CAST(trn.approvedDate AS TIME) AS VARCHAR(8))
			FROM remitTran trn WITH(NOLOCK)
			WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
			AND tranStatus IN( 'Payment','CancelRequested') AND trn.pAgent = 392527
			AND Approveddate < dateadd(hour,-2,getdate())
			order by trn.id 
		END
		ELSE IF @PROVIDER = 'vcbr'
		BEGIN
			SELECT TOP 30 id,trn.id AS TxId, controlNo = dbo.FNADecryptString(trn.controlNo)
			FROM remitTran trn WITH(NOLOCK)
			WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
			AND tranStatus = 'Payment' AND trn.pAgent = @AgentId
			AND Approveddate < dateadd(hour,-2,getdate())
			order by newid() 
		END
		ELSE IF @PROVIDER = 'sbr'
		BEGIN
			SELECT TOP 30
				id,trn.id AS TxId, controlNo = dbo.FNADecryptString(trn.controlNo), DocId=dbo.FNADecryptString(trn.controlNo2)
				,trxDate = CAST(CAST(trn.approvedDate AS DATE) AS VARCHAR) +'T'+ CAST(CAST(trn.approvedDate AS TIME) AS VARCHAR(8))
			FROM remitTran trn WITH(NOLOCK)
			WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Post'
			AND tranStatus = 'Payment' AND trn.pAgent = 393862
			AND Approveddate < dateadd(hour,-2,getdate())
			order by trn.id 
		END
		ELSE IF @PROVIDER='xpress'
		BEGIN
			SELECT TOP 5
			id, 
			xpin = dbo.FNADecryptString(trn.controlNo)
			FROM remitTran trn WITH(NOLOCK)
			WHERE trn.approvedBy IS NOT NULL AND trn.payStatus ='Unpaid'  --need to ask
			AND tranStatus = 'Payment' AND trn.pAgent = 392521
			--AND Approveddate < dateadd(hour,-2,getdate())
			order by trn.id 	
		END
	END
	ELSE IF @FLAG='cancel-requested-list'
	BEGIN
		SELECT TOP 1
			 TransactionId	=	RT.id
			,GmeControlNo	=	dbo.FNADecryptString(RT.controlNo2)
			,PartnerPin		=	rt.ContNo----dbo.FNADecryptString(RT.controlNo2)
			,DocId			=	rt.ContNo
			,Provider		=	CASE WHEN RT.pAgent = @xpresspAgent THEN 'xpress' ELSE 'other' END
		FROM dbo.remitTran AS RT(NOLOCK) 
		WHERE RT.tranStatus = 'CancelRequest' 
		AND RT.payStatus IN ('Post','Unpaid') --need to ask
		AND rt.pAgent=@xpresspAgent
		ORDER BY id DESC
	END
	ELSE IF @FLAG='update-status' ----'update-cancel-requested'
	BEGIN
		UPDATE dbo.remitTran SET 
			 tranStatus = 'CancelRequested'
		WHERE id = @TRANID AND pAgent = @xpresspAgent

		SELECT '0' ErrorCode,'Cancel Requested Successfully' Msg, NULL Id
	END

END



GO
