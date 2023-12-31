USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rbacriteriaMEX]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rbacriteriaMEX](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[assessmentType] [varchar](50) NULL,
	[Criteria] [varchar](200) NULL,
	[rangeFrom] [money] NULL,
	[rangeTo] [money] NULL,
	[rating] [money] NULL,
	[weight] [money] NULL,
	[remarks] [varchar](500) NULL
) ON [PRIMARY]
GO
