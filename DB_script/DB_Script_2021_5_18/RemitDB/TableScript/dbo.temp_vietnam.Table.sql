USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[temp_vietnam]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_vietnam](
	[TRANNO] [varchar](6) NOT NULL,
	[CONTROLNO] [varchar](8) NOT NULL,
	[CUSTOMERRATE] [varchar](8) NOT NULL,
	[PCURRCOSTRATE] [varchar](5) NOT NULL,
	[FX] [varchar](17) NOT NULL
) ON [PRIMARY]
GO
