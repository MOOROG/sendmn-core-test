USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[comm_for_back_date]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[comm_for_back_date](
	[controlno] [varchar](100) NULL,
	[id] [bigint] NOT NULL,
	[camt] [money] NULL,
	[is_gen] [int] NULL
) ON [PRIMARY]
GO
