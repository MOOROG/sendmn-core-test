USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_HISTORY]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_HISTORY](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRAN_ID] [bigint] NULL,
	[OLD_REFERRAL] [varchar](30) NULL,
	[NEW_REFERRAL] [varchar](30) NULL,
	[MODIFIED_BY] [varchar](50) NULL,
	[MODIFIED_DATE] [datetime] NULL
) ON [PRIMARY]
GO
