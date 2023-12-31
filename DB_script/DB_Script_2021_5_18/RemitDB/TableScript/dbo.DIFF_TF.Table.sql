USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[DIFF_TF]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIFF_TF](
	[NARRATION] [nvarchar](24) NOT NULL,
	[CONTROLNO] [varchar](24) NOT NULL,
	[CONTROLNO2] [varchar](15) NOT NULL,
	[DEP_DATE] [varchar](10) NOT NULL,
	[TXN_DATE] [varchar](10) NOT NULL,
	[AMT] [varchar](7) NOT NULL,
	[NUM] [varchar](3) NOT NULL,
	[CONTROLNO_ENC] [varchar](30) NULL,
	[CONTROLNO_ENC2] [varchar](30) NULL,
	[PARTICULARS] [nvarchar](100) NULL,
	[CUSTOMERID] [int] NULL,
	[CONTROLNO_NEW] [varchar](30) NULL
) ON [PRIMARY]
GO
