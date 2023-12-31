USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[ref_master]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ref_master](
	[refid] [int] IDENTITY(1,1) NOT NULL,
	[ref_rec_type] [int] NULL,
	[ref_code] [varchar](100) NULL,
	[ref_desc] [nvarchar](1000) NULL,
	[del_flg] [char](1) NULL,
	[CREATED_BY] [varchar](50) NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFIED_BY] [varchar](50) NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[free_text] [varchar](500) NULL
) ON [PRIMARY]
GO
