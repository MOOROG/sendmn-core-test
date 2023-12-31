USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tran_master_deleted]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_master_deleted](
	[tran_id] [int] NOT NULL,
	[acc_num] [varchar](25) NULL,
	[agent_id] [int] NULL,
	[branch_id] [int] NULL,
	[del_flg] [char](1) NULL,
	[entry_user_id] [varchar](20) NULL,
	[gl_sub_head_code] [varchar](10) NULL,
	[module_id] [varchar](5) NULL,
	[part_tran_srl_num] [varchar](4) NULL,
	[part_tran_type] [varchar](2) NULL,
	[ref_num] [varchar](20) NULL,
	[rpt_code] [varchar](25) NULL,
	[tran_amt] [numeric](20, 4) NULL,
	[tran_date] [datetime] NULL,
	[tran_particular] [varchar](500) NULL,
	[tran_rmks] [varchar](60) NULL,
	[vfd_date] [datetime] NULL,
	[vfd_user_id] [varchar](15) NULL,
	[billdate] [datetime] NULL,
	[billno] [varchar](50) NULL,
	[party] [int] NULL,
	[otherinfo] [varchar](52) NULL,
	[tran_type] [varchar](20) NULL,
	[created_date] [datetime] NULL,
	[v_type] [char](1) NULL,
 CONSTRAINT [pk_idx_tran_master_deleted_tran_id] PRIMARY KEY CLUSTERED 
(
	[tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
