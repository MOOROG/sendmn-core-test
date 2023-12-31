USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ref_master]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ref_master](
	[refid] [int] NOT NULL,
	[ref_rec_type] [int] NULL,
	[ref_code] [varchar](100) NULL,
	[ref_desc] [varchar](100) NULL,
	[del_flg] [char](1) NULL,
	[CREATED_BY] [varchar](50) NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFIED_BY] [varchar](50) NULL,
	[MODIFIED_DATE] [datetime] NULL,
 CONSTRAINT [pk_idx_ref_master_id] PRIMARY KEY CLUSTERED 
(
	[refid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
