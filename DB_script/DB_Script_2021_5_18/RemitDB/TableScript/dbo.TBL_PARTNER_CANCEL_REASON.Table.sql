USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_PARTNER_CANCEL_REASON]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_PARTNER_CANCEL_REASON](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[PARTNER_ID] [bigint] NOT NULL,
	[CANCEL_REASON_CODE] [varchar](20) NOT NULL,
	[CANCEL_REASON_TITLE] [varchar](100) NULL,
	[CANCEL_REASON_TITLE_DESCRIPTION] [varchar](250) NULL,
	[IS_ACTIVE] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
