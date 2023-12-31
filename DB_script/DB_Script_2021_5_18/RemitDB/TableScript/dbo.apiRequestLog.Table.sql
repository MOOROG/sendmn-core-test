USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRequestLog]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRequestLog](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_CODE] [varchar](50) NULL,
	[USER_ID] [varchar](50) NULL,
	[PASSWORD] [varchar](50) NULL,
	[AGENT_SESSION_ID] [varchar](50) NULL,
	[AGENT_TXN_ID] [varchar](50) NULL,
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
	[TRANSFER_AMOUNT] [money] NULL,
	[COLLECT_AMT] [money] NULL,
	[PAYOUTAMT] [money] NULL,
	[PAYMENT_MODE] [varchar](50) NULL,
	[BANK_ID] [varchar](50) NULL,
	[BANK_NAME] [varchar](150) NULL,
	[BANK_BRANCH_NAME] [varchar](150) NULL,
	[BANK_ACCOUNT_NUMBER] [varchar](50) NULL,
	[CALC_BY] [varchar](50) NULL,
	[AUTHORIZED_REQUIRED] [char](1) NULL,
	[OUR_SERVICE_CHARGE] [money] NULL,
	[EXT_BANK_BRANCH_ID] [varchar](50) NULL,
	[RECEIVER_IDENTITY_TYPE] [varchar](50) NULL,
	[RECEIVER_IDENTITY_NUMBER] [varchar](50) NULL,
	[RECEIVER_RELATION] [varchar](50) NULL,
	[PAYOUT_AGENT_ID] [varchar](50) NULL,
	[REQUESTED_DATE] [datetime] NULL,
	[TRNDATE] [datetime] NULL,
	[SETTLE_USD_AMT] [varchar](50) NULL,
	[SETTLE_RATE] [varchar](50) NULL,
	[CUSTOMER_ID] [varchar](50) NULL,
	[SOURCE_OF_INCOME] [varchar](50) NULL,
	[REASON_FOR_REMITTANCE] [varchar](50) NULL,
	[SENDER_OCCUPATION] [varchar](50) NULL,
	[controlNo] [varchar](50) NULL,
	[errorCode] [varchar](50) NULL,
	[errorMsg] [varchar](max) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[OCCUPATION] [varchar](50) NULL,
	[SOURCE_OF_FUND] [varchar](50) NULL,
	[RELATIONSHIP] [varchar](50) NULL,
	[PURPOSE_OF_REMITTANCE] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiRequestLog] ADD  CONSTRAINT [MSrepl_tran_version_default_8BF1D223_55C0_46BC_9C74_A77E0261169D_237608285]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
