USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[luckyDrawNumbers]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[luckyDrawNumbers](
	[controlNo] [varchar](50) NULL,
	[drawType] [char](1) NULL,
	[forDate] [datetime] NULL
) ON [PRIMARY]
GO
