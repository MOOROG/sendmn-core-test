USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranEdd]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranEdd](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](50) NULL,
	[eddRemarks] [varchar](300) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
