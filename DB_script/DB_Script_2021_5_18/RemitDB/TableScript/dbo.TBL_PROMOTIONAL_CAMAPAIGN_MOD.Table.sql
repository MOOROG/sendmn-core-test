USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_PROMOTIONAL_CAMAPAIGN_MOD]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_PROMOTIONAL_CAMAPAIGN_MOD](
	[ROW_ID] [int] NOT NULL,
	[PROMOTIONAL_CODE] [varchar](20) NULL,
	[PROMOTIONAL_MSG] [varchar](250) NULL,
	[PROMOTION_TYPE] [int] NULL,
	[PROMOTION_VALUE] [money] NULL,
	[START_DT] [date] NULL,
	[END_DT] [date] NULL,
	[modType] [char](1) NULL,
	[COUNTRY_ID] [int] NULL,
	[PAYMENT_METHOD] [int] NULL,
	[IS_ACTIVE] [bit] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
