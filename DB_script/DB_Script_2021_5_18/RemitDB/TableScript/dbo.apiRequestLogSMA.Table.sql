USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRequestLogSMA]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRequestLogSMA](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_CODE] [varchar](50) NULL,
	[USER_ID] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[AGENT_SESSION_ID] [varchar](50) NULL,
	[AGENT_TXNID] [varchar](50) NULL,
	[LOCATION_ID] [varchar](50) NULL,
	[SENDER_NAME] [varchar](50) NULL,
	[SENDER_GENDER] [varchar](50) NULL,
	[SENDER_ADDRESS] [varchar](50) NULL,
	[SENDER_MOBILE] [varchar](50) NULL,
	[SENDER_CITY] [varchar](100) NULL,
	[SENDER_COUNTRY] [varchar](50) NULL,
	[SENDER_ID_TYPE] [varchar](50) NULL,
	[SENDER_ID_NUMBER] [varchar](50) NULL,
	[SENDER_ID_ISSUE_DATE] [varchar](50) NULL,
	[SENDER_ID_EXPIRE_DATE] [varchar](50) NULL,
	[SENDER_DATE_OF_BIRTH] [varchar](50) NULL,
	[RECEIVER_NAME] [varchar](50) NULL,
	[RECEIVER_ADDRESS] [varchar](50) NULL,
	[RECEIVER_CONTACT_NUMBER] [varchar](50) NULL,
	[RECEIVER_CITY] [varchar](50) NULL,
	[RECEIVER_COUNTRY] [varchar](50) NULL,
	[PAYOUT_AMOUNT] [varchar](50) NULL,
	[PAYMENTMODE] [varchar](50) NULL,
	[BANKID] [varchar](50) NULL,
	[BANK_ACCOUNT_NUMBER] [varchar](50) NULL,
	[OUR_SERVICE_CHARGE] [money] NULL,
	[EXT_BANK_BRANCH_ID] [varchar](50) NULL,
	[SETTLE_USD_AMT] [varchar](50) NULL,
	[SETTLE_RATE] [varchar](50) NULL,
	[CUSTOMER_ID] [varchar](50) NULL,
	[RECEIVER_RELATION] [varchar](50) NULL,
	[SOURCE_OF_INCOME] [varchar](50) NULL,
	[REASON_FOR_REMITTANCE] [varchar](50) NULL,
	[SENDER_OCCUPATION] [varchar](50) NULL,
	[REQUEST_DATE] [datetime] NULL,
	[errorCode] [varchar](50) NULL,
	[errorMsg] [varchar](500) NULL,
	[controlNo] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiRequestLogSMA] ADD  CONSTRAINT [MSrepl_tran_version_default_D390FDEC_E39F_45B1_94B8_5A71215DFC8E_1149611534]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
