USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_WALLET_DEPOSIT_REQUEST]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_WALLET_DEPOSIT_REQUEST](
	[ROW_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[USER] [varchar](80) NOT NULL,
	[CUSTOMER_ID] [bigint] NOT NULL,
	[AMOUNT] [money] NOT NULL,
	[BILL_NO] [varchar](50) NULL,
	[DATE] [datetime] NOT NULL,
	[DESCRIPTION] [nvarchar](150) NOT NULL,
	[VAT_FLAG] [bit] NOT NULL,
	[CREATED_BY] [varchar](80) NOT NULL,
	[CREATED_DATE] [datetime] NOT NULL,
	[IS_EXPIRED] [bit] NOT NULL,
	[IS_SUCCESS] [bit] NOT NULL,
	[STATUS_UPDATED_DATE] [datetime] NULL,
	[RESPONSE_CODE] [nvarchar](100) NULL,
	[RESPONSE_MESSAGE] [nvarchar](250) NULL,
	[TP_CODE] [varchar](50) NULL,
	[TP_CODE_EXTRA] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
